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
        respond_v2(event, ephemeral: false, colour: colour, with_actions: with_actions, owner_id: owner_id, &block)
      end
      return
    end

    if interaction_event?(event)
      respond_v2(event, ephemeral: false, colour: colour, with_actions: with_actions, owner_id: owner_id, &block)
    else
      send_v2(event.channel, colour: colour, with_actions: with_actions, owner_id: owner_id, &block)
    end
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
    when Hash
      if with_actions[:shop]
        attach_shop_buttons(container, with_actions[:shop], owner_id)
      end
      if with_actions[:event_choices]
        attach_event_choice_buttons(container, with_actions[:event_choices], owner_id)
      elsif with_actions[:event_continue]
        attach_event_continue_button(container, owner_id)
      end
      if with_actions[:removecurse]
        attach_removecurse_buttons(container, with_actions[:removecurse], owner_id)
      end
      attach_explore_buttons(container, owner_id) if with_actions[:explore]
    end
  end

  def attach_shop_buttons(container, shop, owner_id)
    category = Engine::Shop.normalize_category(shop[:category] || shop['category'])
    page = (shop[:page] || shop['page']).to_i
    pages = [(shop[:pages] || shop['pages']).to_i, 1].max
    items = Array(shop[:items] || shop['items'])

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

    items.each_slice(5) do |slice|
      container.row do |row|
        slice.each do |item|
          id = item[:id] || item['id']
          name = item[:name] || item['name']
          cost = item[:cost] || item['cost']
          label = "#{name} · #{cost} LP"
          label = "#{name[0, 40]}… · #{cost}" if label.length > 80
          row.button(
            label: label,
            style: :success,
            custom_id: "eros:shop:buy:#{id}:#{category}:#{page}:#{owner_id}"
          )
        end
      end
    end

    return if pages <= 1

    container.row do |row|
      row.button(
        label: '◀ Prev',
        style: :secondary,
        custom_id: "eros:shop:page:#{category}:#{[page - 1, 0].max}:#{owner_id}"
      ) if page.positive?

      row.button(
        label: "Pg #{page + 1}/#{pages}",
        style: :secondary,
        custom_id: "eros:shop:page:#{category}:#{page}:#{owner_id}"
      )

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
            custom_id: "eros:event_choice:#{choice[:key] || choice['key']}:#{owner_id}"
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
      lines << '_Use the menus, or `!removecurse [number]` / `!suppresscurse [number]`._'
      lines << "-# LP: `#{player.lp}`"
    end
    lines.join("\n")
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

  def append_action_log(container, log)
    segments = []
    Array(log).each do |entry|
      scene = entry.is_a?(Hash) ? (entry[:scene] || entry['scene']) : nil
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

    parts = sizes.map { |part, spec| "#{spec[:label]} **#{Engine::ContentOptions.size_of(player, part)}**" }
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
      container.text_display(content: '-# No character name yet — use `/profile` → **Rename**, or `!name Your Name`.')
    end
    hybrid = player.active_transformation_name
    container.text_display(
      content: "**#{player.gender}**#{hybrid ? " · **Hybrid:** #{hybrid}" : ''}\n" \
               "Lv **#{player.level}** · **Cycle #{player.current_cycle}** · " \
               "Floor **#{player.current_floor}**/#{Engine::Tower::FINAL_BOSS_FLOOR}\n" \
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
    conditions = player.condition_list
    unless conditions.empty?
      lines = conditions.map do |c|
        floors = c['floors'].to_i
        "• **#{c['name']}** — #{c['summary']} _(#{floors} floor#{'s' unless floors == 1})_"
      end
      container.text_display(content: "**Conditions**\n#{lines.join("\n")}")
    end
    container.separator(divider: true, spacing: :small)
    combat_line = player.reconcile_encounter! ? 'Engaged' : 'Quiet for now'
    event = player.event_data
    if event
      extra =
        if event[:mode].to_s == 'timed'
          " · Event: **#{event[:name]}** _(turn #{event[:turn]}/#{event[:duration]})_ — press **Continue**"
        else
          " · Event: **#{event[:name]}** — choose a button"
        end
      container.text_display(content: "**Combat:** #{combat_line}#{extra}")
    else
      container.text_display(content: "**Combat:** #{combat_line}")
    end
    container.separator(divider: false, spacing: :small)
    container.text_display(
      content: '-# Defeat resets the run and returns you to Cycle 1 — LP, curses, living gear, titles, ' \
               'and deepest floor persist; trophies and conditions are lost. Use `/curses` for brands, `/profile` for titles & achievements.'
    )
  end
end
