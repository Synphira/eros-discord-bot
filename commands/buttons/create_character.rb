# frozen_string_literal: true

module Commands
  module Buttons
    module CreateCharacter
      extend Discordrb::EventContainer

      SUBMISSION_KEYS = 'eager|curious|neutral|reluctant|resistant'

      button(custom_id: /^eros:create:([1-5]):\d+$/) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        archetype_id = event.custom_id[/\Aeros:create:([1-5]):\d+\z/, 1].to_i
        Commands::Create.show_submission_menu(event, archetype_id)
      end

      button(custom_id: /^eros:submission:(#{SUBMISSION_KEYS}):\d+$/o) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        choice = event.custom_id[/\Aeros:submission:(#{SUBMISSION_KEYS}):\d+\z/o, 1]
        ErosUI.show_name_modal(event, "eros:namemodal:create:#{choice}:#{event.user.id}")
      end

      modal_submit(custom_id: /^eros:namemodal:create:(#{SUBMISSION_KEYS}):\d+$/o) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        choice = event.custom_id[/\Aeros:namemodal:create:(#{SUBMISSION_KEYS}):\d+\z/o, 1]
        Commands::Create.finish(event, submission_choice: choice, character_name: event.value('character_name'))
      end
    end
  end
end
