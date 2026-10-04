# frozen_string_literal: true

module Commands
  module Buttons
    module RandomEvent
      extend Discordrb::EventContainer

      button(custom_id: /^eros:event_choice:[a-z_]+:\d+$/) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        player = Player[event.user.id]
        unless player
          ErosUI.reply_v2(event, ephemeral: true) do |c|
            c.text_display(content: 'No profile. `/create` or `e,create` first.')
          end
          next
        end

        key = event.custom_id[/\Aeros:event_choice:([a-z_]+):\d+\z/, 1]
        result = Engine::RandomEvents.choose!(player, key)
        Commands::Explore.render_event(event, player, result)
      end

      button(custom_id: /^eros:event_continue:\d+$/) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        player = Player[event.user.id]
        unless player
          ErosUI.reply_v2(event, ephemeral: true) do |c|
            c.text_display(content: 'No profile. `/create` or `e,create` first.')
          end
          next
        end

        result = Engine::RandomEvents.continue!(player)
        Commands::Explore.render_event(event, player, result)
      end
    end
  end
end
