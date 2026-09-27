# frozen_string_literal: true

# Presentation helpers for Endless Ruins of Sin — all Discord replies use Components V2
# (IS_COMPONENTS_V2 / has_components: true). Content and embeds are disabled;
# text goes in Text Display components, often wrapped in a Container.
#
# Buttons edit the message they came from (update_message).
# Slash / prefix commands always send a new message.
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

  # Unified reply: Components V2 for both interactions and prefix/message events.
  # with_actions: false | :explore | :combat | true (:explore)
  # Ephemeral replies always create a new (private) response.
  # Action buttons are locked to event.user (owner id embedded in custom_id).
  def reply_v2(event, ephemeral: false, colour: ACCENT, with_actions: false, &block)
    owner_id = event.user.id

    if ephemeral
      return respond_v2(event, ephemeral: true, colour: colour, with_actions: with_actions, owner_id: owner_id, &block) if interaction_event?(event)

      send_v2(event.channel, colour: colour, with_actions: with_actions, owner_id: owner_id, &block)
      return
    end

    # Buttons / selects: edit the message the component belongs to.
    if component_event?(event)
      begin
        update_v2(event, colour: colour, with_actions: with_actions, owner_id: owner_id, &block)
      rescue StandardError => e
        warn "Component update failed: #{e.class}: #{e.message}"
        respond_v2(event, ephemeral: false, colour: colour, with_actions: with_actions, owner_id: owner_id, &block)
      end
      return
    end

    # Slash / prefix: always a fresh message.
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
            style: choice[:key].to_s == 'ignore' ? :secondary : :primary,
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
    container.row do |row|
      row.button(label: 'STR (10 LP)', style: :primary, custom_id: "eros:levelup:strength:#{owner_id}")
      row.button(label: 'AGI (10 LP)', style: :primary, custom_id: "eros:levelup:agility:#{owner_id}")
      row.button(label: 'RES (10 LP)', style: :primary, custom_id: "eros:levelup:resistance:#{owner_id}")
      row.button(label: 'Level (50 LP)', style: :success, custom_id: "eros:levelup:level:#{owner_id}")
    end
  end

  # Up to 5 remove buttons per row; `entries` is [{index:, curse:}, ...]
  def attach_removecurse_buttons(container, entries, owner_id)
    entries.each_slice(5) do |slice|
      container.row do |row|
        slice.each do |entry|
          label = "#{entry[:index] + 1}. #{entry[:curse].name}"
          label = "#{label[0, 77]}..." if label.length > 80
          row.button(
            label: label,
            style: :danger,
            custom_id: "eros:removecurse:#{entry[:index]}:#{owner_id}"
          )
        end
      end
    end
  end

  def build_curses_text(player, with_cost: false)
    grouped = player.curses_grouped_by_type
    return 'You don\'t have any curses!' if grouped.empty?

    lines = [with_cost ? 'Your curses:' : 'Your current curses:']
    grouped.each do |type, entries|
      type_name = Engine::CurseCatalog.type_label(type)
      lines << ''
      lines << "**#{type_name} Curses:**"
      entries.each do |entry|
        curse = entry[:curse]
        cost = with_cost ? ' (Cost: 50 LP)' : ''
        lines << "#{entry[:index] + 1}. **#{curse.name}**: #{curse.description}#{cost}"
      end
    end
    lines << ''
    lines << '_Type `!removecurse [number]` or use a button to remove one._' if with_cost
    lines << "-# LP: `#{player.lp}`" if with_cost
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

  def attach_submission_buttons(container, owner_id)
    # Discord allows 5 buttons per row; we have exactly 5 choices.
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

  # Combat logs mix plain strings with `{ scene: "..." }` entries.
  # Scenes render in their own italic block between dividers.
  def append_action_log(container, log)
    buffer = []

    flush = lambda do
      return if buffer.empty?

      container.text_display(content: buffer.join("\n"))
      buffer.clear
    end

    Array(log).each do |entry|
      scene =
        if entry.is_a?(Hash)
          entry[:scene] || entry['scene']
        end

      if scene
        flush.call
        container.separator(divider: true, spacing: :small)
        container.text_display(content: "_#{scene}_")
        container.separator(divider: true, spacing: :small)
      else
        buffer << entry.to_s
      end
    end

    flush.call
  end

  def build_status_container(container, player)
    threat = Engine::ThreatCalculator.calculate(player)

    container.text_display(content: '## Endless Ruins of Sin — Delver Status')
    container.text_display(content: '_Descend. Endure. Desire._')
    container.separator(divider: true, spacing: :small)
    container.text_display(
      content: "**#{player.gender}** — #{player.body_parts_display}\n" \
               "Lv **#{player.level}** · Floor **#{player.current_floor}** " \
               "_(#{player.pos_x}, #{player.pos_y})_\n" \
               "**Deepest floor** `#{player.highest_floor_reached}`\n" \
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
      content: '-# Defeat resets the run — LP, curses, living gear, and deepest floor persist. Use `/curses` for brands.'
    )
  end
end
