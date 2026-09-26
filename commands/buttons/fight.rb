# frozen_string_literal: true

module Commands
  module Buttons
    module Fight
      extend Discordrb::EventContainer

      button(custom_id: /^eros:fight:\d+$/) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        Commands::Combat.run_action(event, :fight)
      end
    end
  end
end
