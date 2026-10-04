# frozen_string_literal: true

module Commands
  module Buttons
    module ExplorePath
      extend Discordrb::EventContainer

      button(custom_id: /^eros:explore_path:\d+$/) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        player = Player[event.user.id]
        unless player
          ErosUI.reply_v2(event, ephemeral: true) do |c|
            c.text_display(content: 'No profile. `/create` or `e,create` first.')
          end
          next
        end

        if Eros.encounter_for(player)
          ErosUI.reply_v2(event, ephemeral: true) do |c|
            c.text_display(
              content: 'You are in combat! Choose **Fight**, **Flee**, or **Submit** ' \
                       '(or `e,fight` / `e,flee` / `e,submit`).'
            )
          end
          next
        end

        Commands::Explore.run(event)
      end
    end
  end
end
