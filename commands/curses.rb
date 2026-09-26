# frozen_string_literal: true

module Commands
  module Curses
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    module_function

    def run(event)

      player = ErosHelpers.require_player(event) or return

      if player.active_curse_count.zero?
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: "You don't have any curses!")
        end
        return
      end

      ErosUI.reply_v2(event, colour: 0x6b5b95) do |c|
        c.text_display(content: ErosUI.build_curses_text(player, with_cost: false))
      end
    end

    application_command(:curses) { |event| Commands::Curses.run(event) }

    command(:curses, description: 'List your active curses by type') do |event|
      Commands::Curses.run(event)
      nil
    end
  end
end
