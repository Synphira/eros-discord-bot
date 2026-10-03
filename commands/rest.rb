# frozen_string_literal: true

module Commands
  module Rest
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COOLDOWN = 300

    module_function

    def ready_at(player)
      player.tracker('last_rest_at') + COOLDOWN
    end

    def run(event)
      player = ErosHelpers.require_player(event) or return

      if Eros.encounter_for(player)
        ErosUI.reply_v2(event, ephemeral: true, with_actions: :combat) do |c|
          c.text_display(content: 'You cannot rest mid-combat. Fight, flee, or submit.')
        end
        return
      end

      if player.active_event?
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'Something still has hold of you — finish the event before resting.')
        end
        return
      end

      now = Time.now.to_i
      if now < ready_at(player) && !Engine::Dev.debug?(player)
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: "You're too restless to sleep yet. You can rest again <t:#{ready_at(player)}:R>.")
        end
        return
      end

      old_lust = player.lust
      old_def = player.defiance
      player.update(lust: 0, defiance: player.max_defiance)
      player.set_tracker!('last_rest_at', now)
      threat = Engine::ThreatCalculator.calculate(player)

      ErosUI.reply_v2(event, colour: ErosUI.threat_color(threat.category), with_actions: true) do |c|
        c.text_display(
          content: "You curl up in a quiet corner and sleep until the ache fades.\n" \
                   "**−#{old_lust - player.lust} Lust** (now `#{player.lust}`) · " \
                   "**+#{player.defiance - old_def} Defiance** (now `#{player.defiance}/#{player.max_defiance}`)\n" \
                   "Threat **#{ErosUI.threat_label(threat.category)}** #{ErosUI.threat_bar(threat.percent)}\n" \
                   "-# You can rest again <t:#{ready_at(player)}:R>."
        )
      end
    end

    button(custom_id: /^eros:rest:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Rest.run(event)
    end

    application_command(:rest) { |event| Commands::Rest.run(event) }

    command(:rest, description: 'Rest: clear all lust and fully restore defiance (5-minute cooldown)') do |event|
      Commands::Rest.run(event)
      nil
    end
  end
end
