# frozen_string_literal: true

module Commands
  module Buttons
    module CreateCharacter
      extend Discordrb::EventContainer

      button(custom_id: /^eros:create:([1-5]):\d+$/) do |event|
        next unless ErosHelpers.assert_button_owner!(event)

        archetype_id = event.custom_id[/\Aeros:create:([1-5]):\d+\z/, 1].to_i
        Commands::Create.finish(event, archetype_id)
      end
    end
  end
end
