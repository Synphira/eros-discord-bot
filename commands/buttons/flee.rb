# frozen_string_literal: true

module Commands
  module Buttons
    module Flee
      extend Discordrb::EventContainer

      button(custom_id: /^eros:flee:\d+$/) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        Commands::Combat.run_action(event, :flee)
      end
    end
  end
end
