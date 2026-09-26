# frozen_string_literal: true

module Commands
  module Buttons
    module CreateCharacter
      extend Discordrb::EventContainer

      button(custom_id: /^eros:create:([1-5]):\d+$/) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        archetype_id = event.custom_id[/\Aeros:create:([1-5]):\d+\z/, 1].to_i
        Commands::Create.show_submission_menu(event, archetype_id)
      end

      button(custom_id: /^eros:submission:(eager|curious|neutral|reluctant|resistant):\d+$/) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        choice = event.custom_id[/\Aeros:submission:(eager|curious|neutral|reluctant|resistant):\d+\z/, 1]
        Commands::Create.finish(event, submission_choice: choice)
      end
    end
  end
end
