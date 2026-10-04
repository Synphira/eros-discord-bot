# frozen_string_literal: true

module Commands
  module Restart
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    module_function

    def confirm(event)
      player = ErosHelpers.require_player(event) or return

      ErosUI.reply_v2(event, colour: 0x8b1a1a) do |c|
        c.text_display(content: '## Start Over?')
        c.text_display(
          content: "This **erases** your current delver:\n" \
                   "• Level, stats, and all **#{player.lp}** Lust Points\n" \
                   "• Every curse (**#{player.active_curse_count}**) and all gear, cursed or not\n" \
                   "• Your character name, body sizes, and current cycle\n\n" \
                   "**Kept:** your **#{player.earned_titles.size}** titles, **#{player.earned_achievements.size}** " \
                   'achievements, all achievement/title progress, your deepest-floor record, Cursed Shop unlocks, ' \
                   "and your content options.\n\n" \
                   'You will then choose a new **body type** and **Submission** stance.'
        )
        c.separator(divider: true, spacing: :small)
        c.row do |row|
          row.button(label: 'Restart', style: :danger, custom_id: "eros:restart:confirm:#{event.user.id}")
          row.button(label: 'Cancel', style: :secondary, custom_id: "eros:restart:cancel:#{event.user.id}")
        end
      end
    end

    def wipe!(discord_id)
      DB.transaction do
        Player[discord_id]&.save_legacy!
        DB[:player_curses].where(player_id: discord_id).delete
        DB[:player_equipment].where(player_id: discord_id).delete
        DB[:players].where(discord_id: discord_id).delete
      end
      Eros::ENCOUNTERS.delete(discord_id)
      Commands::Create::PENDING.delete(discord_id)
    end

    button(custom_id: /^eros:restart:confirm:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      unless Player[event.user.id]
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'You have no delver to erase. Use `/create` or `e,create`.')
        end
        next
      end

      Commands::Restart.wipe!(event.user.id)
      Commands::Create.show_menu(event)
    end

    button(custom_id: /^eros:restart:cancel:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      ErosUI.reply_v2(event, colour: 0x4a7c59, with_actions: :explore) do |c|
        c.text_display(content: 'Restart cancelled — your delver endures.')
      end
    end

    application_command(:restart) { |event| Commands::Restart.confirm(event) }

    command(:restart, description: 'Erase your delver and create a new one') do |event|
      Commands::Restart.confirm(event)
      nil
    end
  end
end
