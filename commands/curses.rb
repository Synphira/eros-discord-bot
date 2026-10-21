# frozen_string_literal: true

module Commands
  module Curses
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    module_function

    def show(event, page: 0)
      player = ErosHelpers.require_player(event) or return

      if player.active_curse_count.zero? && player.suppressed_curses.empty?
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: "You don't have any curses!")
        end
        return
      end

      text, pages = ErosUI.build_curses_page(player, page: page, with_cost: false)
      page = page.to_i.clamp(0, pages - 1)
      ErosUI.reply_v2(event, colour: 0x6b5b95) do |c|
        c.text_display(content: text)
        Commands::Profile.attach_pager(c, 'eros:curses:page', page, pages, event.user.id) if pages > 1
      end
    end

    def run(event)
      show(event)
    end

    button(custom_id: /^eros:curses:page:-?\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      page = event.custom_id[/\Aeros:curses:page:(-?\d+):\d+\z/, 1].to_i
      Commands::Curses.show(event, page: page)
    end

    application_command(:curses) { |event| Commands::Curses.run(event) }

    command(:curses, description: 'List your active curses by type') do |event|
      Commands::Curses.run(event)
      nil
    end
  end
end
