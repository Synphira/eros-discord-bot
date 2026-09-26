# frozen_string_literal: true

module Commands
  module Buttons
    module Shop
      extend Discordrb::EventContainer

      button(custom_id: /^eros:shop:cat:(weapon|armor|accessory|special):\d+$/) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        player = Player[event.user.id]
        unless player
          ErosUI.reply_v2(event, ephemeral: true) do |c|
            c.text_display(content: 'No profile. `/create` first.')
          end
          next
        end

        category = event.custom_id[/\Aeros:shop:cat:(weapon|armor|accessory|special):\d+\z/, 1]
        Commands::Shop.show(event, player, category: category, page: 0)
      end

      button(custom_id: /^eros:shop:page:(weapon|armor|accessory|special):\d+:\d+$/) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        player = Player[event.user.id]
        unless player
          ErosUI.reply_v2(event, ephemeral: true) do |c|
            c.text_display(content: 'No profile. `/create` first.')
          end
          next
        end

        match = event.custom_id.match(/\Aeros:shop:page:(weapon|armor|accessory|special):(\d+):(\d+)\z/)
        Commands::Shop.show(event, player, category: match[1], page: match[2].to_i)
      end

      button(custom_id: /^eros:shop:buy:\d+:(weapon|armor|accessory|special):\d+:\d+$/) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        player = Player[event.user.id]
        unless player
          ErosUI.reply_v2(event, ephemeral: true) do |c|
            c.text_display(content: 'No profile. `/create` first.')
          end
          next
        end

        match = event.custom_id.match(
          /\Aeros:shop:buy:(\d+):(weapon|armor|accessory|special):(\d+):(\d+)\z/
        )
        Commands::Shop.buy_by_id(
          event,
          player,
          match[1].to_i,
          category: match[2],
          page: match[3].to_i
        )
      end
    end
  end
end
