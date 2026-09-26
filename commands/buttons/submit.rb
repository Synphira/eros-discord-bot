# frozen_string_literal: true

module Commands
  module Buttons
    module Submit
      extend Discordrb::EventContainer

      button(custom_id: /^eros:submit:\d+$/) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        Commands::Combat.run_action(event, :submit)
      end
    end
  end
end
