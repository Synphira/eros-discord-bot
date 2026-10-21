# frozen_string_literal: true

module ErosUI
  module_function

  ACCENT = 0x8b1a1a

  def threat_bar(percent)
    clamped = [[percent, 0].max, 100].min
    filled = (clamped / 10).floor
    empty = 10 - filled
    "`[#{'█' * filled}#{'░' * empty}]` #{clamped.round(1)}%"
  end

  def threat_label(category)
    case category
    when :low    then 'LOW'
    when :medium then 'MEDIUM'
    when :high   then 'HIGH'
    else category.to_s.upcase
    end
  end

  def threat_color(category)
    case category
    when :low    then 0x4a7c59
    when :medium then 0xb8860b
    when :high   then 0x8b1a1a
    else 0x444444
    end
  end

  def interaction_event?(event)
    event.is_a?(Discordrb::Events::InteractionCreateEvent)
  end

  def component_event?(event)
    event.is_a?(Discordrb::Events::ComponentEvent)
  end

  def reply_v2(event, ephemeral: false, colour: ACCENT, with_actions: false, &block)
    owner_id = event.user.id

    if ephemeral
      return respond_v2(event, ephemeral: true, colour: colour, with_actions: with_actions, owner_id: owner_id, &block) if interaction_event?(event)

      send_v2(event.channel, colour: colour, with_actions: with_actions, owner_id: owner_id, &block)
      return
    end

    if component_event?(event)
      begin
        update_v2(event, colour: colour, with_actions: with_actions, owner_id: owner_id, &block)
      rescue StandardError => e
        warn "[panel] Editing the message failed (#{e.message.to_s.lines.map(&:strip).reject(&:empty?).join(' — ')}); " \
             'sending a new message instead.'
        respond_or_send(event, colour: colour, with_actions: with_actions, owner_id: owner_id, &block)
      end
      return
    end

    if interaction_event?(event)
      respond_or_send(event, colour: colour, with_actions: with_actions, owner_id: owner_id, &block)
    else
      send_v2(event.channel, colour: colour, with_actions: with_actions, owner_id: owner_id, &block)
    end
  end

  UNKNOWN_INTERACTION = 10_062

  def interaction_expired?(error)
    error.respond_to?(:code) && error.code == UNKNOWN_INTERACTION
  end

  # Discord only accepts an interaction reply within 3 seconds; after that the
  # token is dead, so the panel is posted as a normal channel message instead.
  def respond_or_send(event, colour:, with_actions:, owner_id:, &block)
    respond_v2(event, ephemeral: false, colour: colour, with_actions: with_actions, owner_id: owner_id, &block)
  rescue StandardError => e
    raise unless interaction_expired?(e) && event.channel

    warn '[panel] Interaction expired before the bot replied (slow response); posting to the channel instead.'
    send_v2(event.channel, colour: colour, with_actions: with_actions, owner_id: owner_id, &block)
  end

  def update_v2(event, colour: ACCENT, with_actions: false, owner_id:)
    event.update_message(has_components: true) do |_builder, view|
      view.container(colour: colour) do |container|
        yield container
        attach_action_buttons(container, with_actions, owner_id)
      end
    end
  end

  def respond_v2(event, ephemeral: false, colour: ACCENT, with_actions: false, wait: false, owner_id:)
    event.respond(has_components: true, ephemeral: ephemeral, wait: wait) do |_builder, view|
      view.container(colour: colour) do |container|
        yield container
        attach_action_buttons(container, with_actions, owner_id)
      end
    end
  end

  def send_v2(channel, colour: ACCENT, with_actions: false, owner_id:)
    view = Discordrb::Webhooks::View.new
    view.container(colour: colour) do |container|
      yield container
      attach_action_buttons(container, with_actions, owner_id)
    end
    channel.send_message!(has_components: true, components: view)
  end

  def attach_action_buttons(container, with_actions, owner_id)
    case with_actions
    when true, :explore then attach_explore_buttons(container, owner_id)
    when :combat then attach_combat_buttons(container, owner_id)
    when :levelup then attach_levelup_buttons(container, owner_id)
    when :defeat then attach_defeat_button(container, owner_id)
    when :submission then attach_try_again_button(container, owner_id)
    when Hash
      if with_actions[:shop]
        attach_shop_buttons(container, with_actions[:shop], owner_id)
      end
      if with_actions[:event_choices]
        attach_event_choice_buttons(container, with_actions[:event_choices], owner_id)
      elsif with_actions[:event_continue]
        attach_event_continue_button(container, owner_id)
      end
      attach_phase_buttons(container, with_actions[:phase], owner_id) if with_actions[:phase]
      if with_actions[:removecurse]
        attach_removecurse_buttons(container, with_actions[:removecurse], owner_id)
      end
      attach_explore_buttons(container, owner_id) if with_actions[:explore]
    end
  end

  # One shop item as a Discord section: the item's text with its own Buy
  # button sitting beside it as the section accessory.
  def attach_shop_item_section(container, item, player:, category:, page:, owner_id:)
    owned = player.owns_equipment?(item.id) && item.type != 'special'
    tag = owned ? ' _(owned)_' : ''
    mods = Engine::Treasure.format_stat_changes(item.stat_modifiers)
    content = "**#{item.name}** (#{item.cost} LP)#{tag} — _#{item.description}_"
    content += "\n#{mods}" unless mods.to_s.empty? || mods == '_none_'

    container.section do |section|
      section.text_display(content: content)
      section.button(
        label: owned ? 'Owned' : 'Buy',
        style: owned ? :secondary : :success,
        custom_id: "eros:shop:buy:#{item.id}:#{category}:#{page}:#{owner_id}",
        disabled: owned || player.lp < item.cost.to_i
      )
    end
  end

  # One Cursed Shop item as a section, mirroring the normal shop: the
  # piece's text with its own state button beside it. Living gear is free
  # to call back once unlocked; the button says why when it cannot be.
  def attach_cursed_item_section(container, item, player:, category:, page:, owner_id:)
    tpl = Engine::Treasure.template_for(item.name)
    owned = player.owns_equipment?(item.id)
    unlocked = player.cursed_shop_unlocked?(item.name)
    block_reason = unlocked && !owned ? Engine::Treasure.template_block_reason(player, tpl) : nil
    mods = Engine::Treasure.format_stat_changes(item.stat_modifiers)

    label, style, disabled =
      if owned
        ['Bound', :secondary, true]
      elsif !unlocked
        ['Locked', :secondary, true]
      elsif block_reason
        ['Sealed', :secondary, true]
      else
        ['Take', :danger, false]
      end

    content =
      if unlocked || owned
        "**#{item.name}** (Free)#{owned ? ' _(already bound)_' : ''} — _#{item.description}_\n" \
          "#{mods} · removal #{item.removal_cost.to_i} LP" \
          "#{block_reason ? "\n_Sealed: #{block_reason}._" : ''}"
      else
        "**???** (#{item.slot}) — _find it in a chest, wear it, and tear it free to unlock it_"
      end

    container.section do |section|
      section.text_display(content: content)
      section.button(
        label: label,
        style: style,
        custom_id: "eros:cshop:take:#{item.id}:#{category}:#{page}:#{owner_id}",
        disabled: disabled
      )
    end
  end

  def attach_shop_buttons(container, shop, owner_id)
    category = Engine::Shop.normalize_category(shop[:category] || shop['category'])
    page = (shop[:page] || shop['page']).to_i
    pages = [(shop[:pages] || shop['pages']).to_i, 1].max

    container.row do |row|
      Engine::Shop::CATEGORIES.each do |cat|
        row.button(
          label: Engine::Shop::CATEGORY_LABELS[cat],
          style: cat == category ? :primary : :secondary,
          custom_id: "eros:shop:cat:#{cat}:#{owner_id}"
        )
      end
      row.button(label: 'Cursed', style: :danger, custom_id: "eros:cshop:open:#{owner_id}")
    end

    container.row do |row|
      row.button(label: "🍓 Berry's Quests", style: :primary, custom_id: "eros:quests:view:#{owner_id}")
      row.button(label: "Syn's Parlour", style: :secondary, custom_id: "eros:parlour:view:#{owner_id}")
    end

    return if pages <= 1

    container.row do |row|
      row.button(
        label: '◀ Prev',
        style: :secondary,
        custom_id: "eros:shop:page:#{category}:#{[page - 1, 0].max}:#{owner_id}"
      ) if page.positive?

      row.button(
        label: 'Next ▶',
        style: :secondary,
        custom_id: "eros:shop:page:#{category}:#{[page + 1, pages - 1].min}:#{owner_id}"
      ) if page < pages - 1
    end
  end

  def attach_event_choice_buttons(container, choices, owner_id)
    Array(choices).each_slice(5) do |slice|
      container.row do |row|
        slice.each do |choice|
          row.button(
            label: choice[:label] || choice['label'] || choice[:key],
            style: choice[:style] || (choice[:key].to_s == 'ignore' ? :secondary : :primary),
            custom_id: "eros:event_choice:#{choice[:key] || choice['key']}:#{owner_id}",
            disabled: choice[:disabled] || choice['disabled'] || false
          )
        end
      end
    end
  end

  def attach_event_continue_button(container, owner_id)
    container.row do |row|
      row.button(
        label: 'Continue',
        style: :primary,
        custom_id: "eros:event_continue:#{owner_id}"
      )
    end
  end

  def attach_explore_buttons(container, owner_id)
    container.row do |row|
      row.button(label: 'Explore', style: :primary, custom_id: "eros:explore_path:#{owner_id}")
      row.button(label: 'Rest', style: :secondary, custom_id: "eros:rest:#{owner_id}")
      row.button(label: 'Level Up', style: :success, custom_id: "eros:levelup_menu:#{owner_id}")
      row.button(label: 'Curses', style: :secondary, custom_id: "eros:curses:#{owner_id}")
    end
  end

  def attach_defeat_button(container, owner_id)
    container.row do |row|
      row.button(label: 'Continue', style: :secondary, custom_id: "eros:defeat_continue:#{owner_id}")
    end
  end

  def attach_try_again_button(container, owner_id)
    container.row do |row|
      row.button(label: 'Try again', style: :primary, custom_id: "eros:try_again:#{owner_id}")
    end
  end

  def attach_phase_buttons(container, labels, owner_id)
    container.row do |row|
      row.button(label: labels[:resist], style: :danger, custom_id: "eros:phase:resist:#{owner_id}")
      row.button(label: labels[:give_in], style: :primary, custom_id: "eros:phase:give_in:#{owner_id}")
    end
  end

  def attach_combat_buttons(container, owner_id)
    container.row do |row|
      row.button(label: 'Fight', style: :danger, custom_id: "eros:fight:#{owner_id}")
      row.button(label: 'Flee', style: :secondary, custom_id: "eros:flee:#{owner_id}")
      row.button(label: 'Submit', style: :primary, custom_id: "eros:submit:#{owner_id}")
    end
  end

  def attach_levelup_buttons(container, owner_id)
    player = Player[owner_id]
    cost = ->(stat) { player ? " (#{player.stat_upgrade_cost(stat)} LP)" : '' }
    level_cost = player ? " (#{player.level_upgrade_cost} LP)" : ''
    container.row do |row|
      row.button(label: "STR#{cost.call(:strength)}", style: :primary, custom_id: "eros:levelup:strength:#{owner_id}")
      row.button(label: "AGI#{cost.call(:agility)}", style: :primary, custom_id: "eros:levelup:agility:#{owner_id}")
      row.button(label: "RES#{cost.call(:resistance)}", style: :primary, custom_id: "eros:levelup:resistance:#{owner_id}")
      row.button(label: "Level#{level_cost}", style: :success, custom_id: "eros:levelup:level:#{owner_id}")
    end
    container.row do |row|
      row.button(label: 'Explore', style: :secondary, custom_id: "eros:explore_path:#{owner_id}")
    end
  end

  def attach_removecurse_buttons(container, entries, owner_id)
    {
      'remove' => "Remove a curse permanently (#{Player::CURSE_REMOVE_COST} LP)",
      'suppress' => "Suppress a curse until defeat (#{Player::CURSE_SUPPRESS_COST} LP)"
    }.each do |action, placeholder|
      container.row do |row|
        row.string_select(custom_id: "eros:curseact:#{action}:#{owner_id}", placeholder: placeholder,
                          min_values: 1, max_values: 1) do |menu|
          entries.first(25).each do |entry|
            menu.option(label: "#{entry[:index] + 1}. #{entry[:curse].name}"[0, 100], value: entry[:index].to_s,
                        description: entry[:curse].description.to_s[0, 100])
          end
        end
      end
    end
    player = Player[owner_id]
    if player&.active_curse_count&.positive?
      total = player.active_curse_count
      cost = player.remove_all_curses_cost
      container.row do |row|
        row.button(label: "Remove ALL #{total} curses (#{cost} LP)", style: :danger,
                   custom_id: "eros:curseact:remove_all:#{owner_id}",
                   disabled: player.lp < cost)
      end
    end
  end

  def build_curses_text(player, with_cost: false)
    grouped = player.curses_grouped_by_type
    suppressed = player.suppressed_curses
    return 'You don\'t have any curses!' if grouped.empty? && suppressed.empty?

    lines = [with_cost ? 'Your curses:' : 'Your current curses:']
    grouped.each do |type, entries|
      type_name = Engine::CurseCatalog.type_label(type)
      lines << ''
      lines << "**#{type_name} Curses:**"
      entries.each do |entry|
        curse = entry[:curse]
        lines << "#{entry[:index] + 1}. **#{curse.name}**: #{curse.description}"
      end
    end
    if suppressed.any?
      lines << ''
      lines << '**Suppressed** _(no effect until you are defeated)_:'
      suppressed.sort_by(&:name).each { |curse| lines << "• ~~#{curse.name}~~" }
    end
    lines << ''
    if with_cost
      lines << "_**Remove** (#{Player::CURSE_REMOVE_COST} LP) deletes a curse for good. " \
               "**Suppress** (#{Player::CURSE_SUPPRESS_COST} LP) silences it until your next defeat._"
      lines << '_Use the menus, or `e,removecurse [number]` / `e,suppresscurse [number]`._'
      lines << "-# LP: `#{player.lp}`"
    end
    lines.join("\n")
  end

  CURSES_PER_PAGE = 8

  # Paginated curse list for Discord's component limits: returns
  # [text, total_pages]. Numbering stays global across pages so it always
  # matches the numbers used by `e,removecurse N` and the purge menus.
  def build_curses_page(player, page: 0, with_cost: false)
    flat = player.curses_grouped_by_type.flat_map do |type, entries|
      entries.map { |entry| entry.merge(type: type) }
    end
    suppressed = player.suppressed_curses
    return ["You don't have any curses!", 1] if flat.empty? && suppressed.empty?

    pages = [(flat.size.to_f / CURSES_PER_PAGE).ceil, 1].max
    page = page.to_i.clamp(0, pages - 1)
    slice = flat.slice(page * CURSES_PER_PAGE, CURSES_PER_PAGE) || []

    lines = [with_cost ? 'Your curses:' : 'Your current curses:']
    last_type = nil
    slice.each do |entry|
      if entry[:type] != last_type
        lines << ''
        lines << "**#{Engine::CurseCatalog.type_label(entry[:type])} Curses:**"
        last_type = entry[:type]
      end
      curse = entry[:curse]
      lines << "#{entry[:index] + 1}. **#{curse.name}**: #{curse.description.to_s[0, 220]}"
    end
    lines << "_Page #{page + 1} of #{pages} — curse numbers are the same on every page._" if pages > 1
    if page == pages - 1 && suppressed.any?
      lines << ''
      lines << '**Suppressed** _(no effect until you are defeated)_:'
      suppressed.sort_by(&:name).each { |curse| lines << "• ~~#{curse.name}~~" }
    end
    if with_cost
      lines << ''
      lines << "_**Remove** (#{Player::CURSE_REMOVE_COST} LP) deletes a curse for good. " \
               "**Suppress** (#{Player::CURSE_SUPPRESS_COST} LP) silences it until your next defeat._"
      if flat.size > 1
        lines << "_Or purge everything at once: **Remove ALL #{flat.size} curses (#{player.remove_all_curses_cost} LP)**._"
      end
      lines << '_Use the menus, or `e,removecurse [number]` / `e,suppresscurse [number]`._'
      lines << "-# LP: `#{player.lp}`"
    end
    [lines.join("\n"), pages]
  end

  def attach_create_buttons(container, owner_id)
    container.row do |row|
      CharacterArchetypes::ALL.each do |id, archetype|
        row.button(
          label: "#{id}. #{archetype[:label]}",
          style: :secondary,
          custom_id: "eros:create:#{id}:#{owner_id}"
        )
      end
    end
  end

  def show_name_modal(event, custom_id, current: nil)
    event.show_modal(title: 'Name Your Delver', custom_id: custom_id) do |modal|
      modal.label(
        label: 'Character name',
        description: 'Shown on your profile and the leaderboard instead of your Discord name.'
      ) do |label|
        label.text_input(
          style: :short,
          custom_id: 'character_name',
          min_length: Player::CHARACTER_NAME_LENGTH.min,
          max_length: Player::CHARACTER_NAME_LENGTH.max,
          required: true,
          value: current,
          placeholder: 'e.g. Lyra Ashvale'
        )
      end
    end
  end

  def attach_submission_buttons(container, owner_id)
    container.row do |row|
      CharacterArchetypes::SUBMISSION_CHOICES.each do |key, entry|
        row.button(
          label: entry[:label],
          style: :secondary,
          custom_id: "eros:submission:#{key}:#{owner_id}"
        )
      end
    end
  end

  LOG_COMPONENT_BUDGET = 22
  LOG_CHAR_BUDGET = 3300

  def dedupe_article(text)
    @proper_name_article ||= /\b[Tt]he (?=(?:#{Engine::BossFights::PROPER_NAMES.join('|')})\b)/
    text.gsub(/\b([Tt]he) the\b/i, '\1').gsub(@proper_name_article, '')
  end

  def append_action_log(container, log)
    segments = []
    Array(log).each do |entry|
      scene = entry.is_a?(Hash) ? (entry[:scene] || entry['scene']) : nil
      scene = dedupe_article(scene) if scene
      entry = dedupe_article(entry.to_s) unless scene
      if scene
        segments << [:scene, "_#{scene}_"]
      elsif segments.last&.first == :text
        segments.last[1] = "#{segments.last[1]}\n#{entry}"
      else
        segments << [:text, entry.to_s]
      end
    end

    cost = -> { segments.sum { |type, _| type == :scene ? 3 : 1 } }
    while cost.call > LOG_COMPONENT_BUDGET && segments.size > 1
      i = (0...(segments.size - 1)).min_by { |j| segments[j][1].size + segments[j + 1][1].size }
      segments[i] = [:text, "#{segments[i][1]}\n#{segments[i + 1][1]}"]
      segments.delete_at(i + 1)
    end

    total = segments.sum { |_, text| text.size }
    if total > LOG_CHAR_BUDGET
      segments.map! do |type, text|
        limit = [(text.size * LOG_CHAR_BUDGET / total.to_f).floor, 40].max
        [type, text.size > limit ? "#{text[0, limit - 1]}…" : text]
      end
    end

    segments.each_with_index do |(type, text), i|
      if type == :scene
        container.separator(divider: true, spacing: :small)
        container.text_display(content: text)
        container.separator(divider: true, spacing: :small) if segments[i + 1]&.first == :text
      else
        container.text_display(content: text)
      end
    end
  end

  def body_sizes_line(player)
    sizes = Engine::ContentOptions.applicable_sizes(player)
    return '' if sizes.empty?

    parts = sizes.map do |part, spec|
      "#{spec[:label]} **#{Engine::ContentOptions.size_label(part, Engine::ContentOptions.size_of(player, part))}**"
    end
    "**Body** #{parts.join(' · ')}\n"
  end

  def build_status_container(container, player)
    threat = Engine::ThreatCalculator.calculate(player)

    container.text_display(content: '## Endless Ruins of Sin — Delver Status')
    container.text_display(content: '_Descend. Endure. Desire._')
    container.separator(divider: true, spacing: :small)
    title = player.active_title_name
    name_line = "### #{player.display_name}"
    name_line += " — _#{title}_" if title
    container.text_display(content: name_line)
    if player.character_name.to_s.empty?
      container.text_display(content: '-# No character name yet — use `/profile` → **Rename**, or `e,name Your Name`.')
    end
    hybrid = player.active_transformation_name
    container.text_display(
      content: "**#{player.gender}**#{hybrid ? " · **Hybrid:** #{hybrid}" : ''}\n" \
               "Lv **#{player.level}** · **Cycle #{player.current_cycle}** · " \
               "Floor **#{player.current_floor}**/#{Engine::Tower::FINAL_BOSS_FLOOR}\n" \
               "**Floor progress** Rooms searched **#{Engine::Exploration.stairs_status(player)[:searched]}** · " \
               "stairs from room **#{Engine::Exploration.stairs_status(player)[:minimum]}** · " \
               "guaranteed by room **#{Engine::Exploration.stairs_status(player)[:limit]}**\n" \
               "#{body_sizes_line(player)}" \
               "**Submission** `#{player.effective_submission}` _(#{player.submission_display}, " \
               "base #{player.submission})_"
    )
    container.text_display(
      content: "**Defiance** `#{player.defiance}/#{player.max_defiance}`  ·  " \
               "**Lust** `#{player.lust}`  ·  " \
               "**LP** `#{player.lp}`"
    )
    container.text_display(
      content: "**STR** #{player.effective_strength} _(base #{player.strength})_  ·  " \
               "**AGI** #{player.effective_agility} _(base #{player.agility})_  ·  " \
               "**RES** #{player.effective_resistance} _(base #{player.resistance})_"
    )
    container.text_display(
      content: "**Threat Level — #{threat_label(threat.category)}** #{threat_bar(threat.percent)}\n" \
               "_LP contrib #{threat.lp_component}% · Curses +#{threat.curse_component}_"
    )
    if (chastity = Engine::ChastitySystem.description(player))
      container.text_display(content: "🔒 #{chastity}")
    end
    if (corruption = Engine::Corruption.status_line(player))
      container.text_display(content: corruption)
    end
    admirer_types = Engine::Admirers.types(player)
    admirer_line = "**Admirers** — **#{admirer_types.size}** current · **#{Engine::Admirers.total(player)}** all time"
    if admirer_types.any?
      soonest = admirer_types.sort_by { |type| Engine::Admirers.rooms_left(player, type) }.first(3)
      following = soonest.map do |type|
        name = Engine::Admirers.name_for(player, type) || type
        "#{name} _(#{Engine::Admirers.rooms_left(player, type)} rooms left)_"
      end
      following << "+#{admirer_types.size - 3} more" if admirer_types.size > 3
      admirer_line += "\n-# Leaving you soonest: #{following.join(' · ')}"
    end
    container.text_display(content: admirer_line)
    container.text_display(content: Engine::Weekly.status_line)
    player.reconcile_encounter!
    container.separator(divider: false, spacing: :small)
    container.text_display(
      content: '-# Defeat resets the run and returns you to Cycle 1 — LP, curses, living gear, titles, ' \
               'and deepest floor persist; trophies and conditions are lost. Use `/curses` for brands, `/profile` for titles & achievements.'
    )
  end

  def build_conditions_container(container, player)
    container.text_display(content: "## Conditions — #{player.display_name}")
    container.separator(divider: true, spacing: :small)
    if (chastity = Engine::ChastitySystem.description(player))
      container.text_display(content: "🔒 #{chastity}")
    end
    conditions = player.condition_list
    if conditions.empty?
      container.text_display(content: '_No active conditions._')
    else
      lines = conditions.map do |c|
        floors = c['floors'].to_i
        duration = c['key'] == Engine::Corruption::KEY ? 'until defeat' : "#{floors} floor#{'s' unless floors == 1}"
        "• **#{c['name']}** — #{c['summary']} _(#{duration})_"
      end
      container.text_display(content: lines.join("\n"))
    end
    container.separator(divider: false, spacing: :small)
    container.text_display(content: '-# Conditions tick down each floor and are cleared on defeat.')
  end
end
