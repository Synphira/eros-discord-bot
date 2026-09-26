# frozen_string_literal: true

module Commands
  module Buttons
    module Curses
      extend Discordrb::EventContainer

      button(custom_id: /^eros:curses:\d+$/) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        Commands::Curses.run(event)
      end

      button(custom_id: /^eros:removecurse:(\d+):\d+$/) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        index = event.custom_id[/\Aeros:removecurse:(\d+):\d+\z/, 1].to_i
        Commands::RemoveCurse.apply(event, index)
      end
    end
  end
end
