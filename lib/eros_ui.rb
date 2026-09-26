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
      if with_actions[:removecurse]
        attach_removecurse_buttons(container, with_actions[:removecurse], owner_id)
      end
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

  def build_status_container(container, player)
    threat = Engine::ThreatCalculator.calculate(player)
    active = player.active_curses
    curse_lines =
      if active.empty?
        '_None — the dark has not marked you yet._'
      else
        active.map { |c| "• **#{c.name}** _(#{c.category})_ — #{c.description}" }.join("\n")
      end

    container.text_display(content: '## Endless Ruins of Sin — Delver Status')
    container.text_display(content: '_Descend. Endure. Desire._')
    container.separator(divider: true, spacing: :small)
    container.text_display(
      content: "**#{player.gender}** — #{player.body_parts_display}\n" \
               "Lv **#{player.level}** · Floor **#{player.current_floor}** " \
               "_(#{player.pos_x}, #{player.pos_y})_"
    )
    container.text_display(
      content: "**HP** `#{player.hp}/#{player.max_hp}`  ·  " \
               "**Defiance** `#{player.defiance}`  ·  " \
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
    container.text_display(content: "**Active Curses**\n#{curse_lines}")
    container.text_display(
      content: "**Combat:** #{player.reconcile_encounter! ? 'Engaged' : 'Quiet for now'}"
    )
    container.separator(divider: false, spacing: :small)
    container.text_display(content: '-# Defeat resets floor & defiance — LP & curses persist.')
  end
end
