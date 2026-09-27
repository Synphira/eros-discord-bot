# frozen_string_literal: true

module Commands
  module Buttons
    module Rest
      extend Discordrb::EventContainer

      button(custom_id: /^eros:rest:\d+$/) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        player = Player[event.user.id]
        unless player
          ErosUI.reply_v2(event, ephemeral: true) do |c|
            c.text_display(content: 'No profile. `/create` or `!create` first.')
          end
          next
        end

        if Eros.encounter_for(player)
          ErosUI.reply_v2(event, ephemeral: true) do |c|
            c.text_display(content: 'You cannot rest mid-combat. Fight, flee, or submit.')
          end
          next
        end

        lust_relief = 20
        defiance_gain = 15

        old_lust = player.lust
        old_def = player.defiance
        player.update(lust: [player.lust - lust_relief, player.base_lust].max) if player.lust > player.base_lust
        player.heal_defiance!(defiance_gain)
        threat = Engine::ThreatCalculator.calculate(player)

        lust_lost = old_lust - player.lust
        def_gained = player.defiance - old_def

        ErosUI.reply_v2(
          event,
          colour: ErosUI.threat_color(threat.category),
          with_actions: true
        ) do |c|
          c.text_display(
            content: "You rest against cold stone and catch your breath.\n" \
                     "**−#{lust_lost} Lust** (now `#{player.lust}`) · " \
                     "**+#{def_gained} Defiance** (now `#{player.defiance}/#{player.max_defiance}`)\n" \
                     "Threat **#{ErosUI.threat_label(threat.category)}** " \
                     "#{ErosUI.threat_bar(threat.percent)}"
          )
        end
      end
    end
  end
end
