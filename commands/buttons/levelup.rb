# frozen_string_literal: true

module Commands
  module Buttons
    module LevelUp
      extend Discordrb::EventContainer

      button(custom_id: /^eros:levelup_menu:\d+$/) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        Commands::LevelUp.show_menu(event)
      end

      button(custom_id: /^eros:levelup:(strength|agility|resistance|level):\d+$/) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        choice = event.custom_id[/\Aeros:levelup:(strength|agility|resistance|level):\d+\z/, 1]
        Commands::LevelUp.apply(event, choice)
      end
    end
  end
end
