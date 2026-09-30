# frozen_string_literal: true

module Commands
  module RemoveCurse
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    module_function

    def show_menu(event)

      player = ErosHelpers.require_player(event) or return

      if Eros.encounter_for(player)
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'You cannot purge curses mid-combat.')
        end
        return
      end

      entries = player.active_curses_ordered.each_with_index.map { |curse, i| { index: i, curse: curse } }
      if entries.empty?
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: player.suppressed_curses.any? ? "You have no active curses — the rest are suppressed until your next defeat." : "You don't have any curses to remove!")
        end
        return
      end

      ErosUI.reply_v2(
        event,
        colour: 0x8b1a1a,
        with_actions: { removecurse: entries }
      ) do |c|
        c.text_display(content: ErosUI.build_curses_text(player, with_cost: true))
      end
    end

    def apply(event, index, action: :remove)

      player = ErosHelpers.require_player(event) or return

      if Eros.encounter_for(player)
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'You cannot purge curses mid-combat.')
        end
        return
      end

      result = action == :suppress ? player.suppress_curse_at!(index.to_i) : player.remove_curse_at!(index.to_i)
      colour = result[:ok] ? 0x4a7c59 : 0x8b1a1a

      remaining = player.active_curses_ordered.each_with_index.map { |curse, i| { index: i, curse: curse } }
      actions = remaining.empty? ? false : { removecurse: remaining }

      ErosUI.reply_v2(event, colour: colour, with_actions: actions) do |c|
        c.text_display(content: result[:message])
        unless remaining.empty?
          c.separator(divider: true, spacing: :small)
          c.text_display(content: ErosUI.build_curses_text(player.refresh, with_cost: true))
        end
      end
    end

    application_command(:removecurse) do |event|
      number = event.options['number']
      number ? Commands::RemoveCurse.apply(event, number.to_i - 1) : Commands::RemoveCurse.show_menu(event)
    end

    command(:removecurse, description: 'Spend 50 LP to remove a curse') do |event, choice|
      if choice && !choice.empty?
        Commands::RemoveCurse.apply(event, choice.to_i - 1)
      else
        Commands::RemoveCurse.show_menu(event)
      end
      nil
    end

    application_command(:suppresscurse) do |event|
      number = event.options['number']
      if number
        Commands::RemoveCurse.apply(event, number.to_i - 1, action: :suppress)
      else
        Commands::RemoveCurse.show_menu(event)
      end
    end

    command(:suppresscurse, aliases: [:suppress],
                            description: 'Spend 25 LP to suppress a curse until your next defeat') do |event, choice|
      if choice && !choice.empty?
        Commands::RemoveCurse.apply(event, choice.to_i - 1, action: :suppress)
      else
        Commands::RemoveCurse.show_menu(event)
      end
      nil
    end

    string_select(custom_id: /^eros:curseact:(remove|suppress):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      action = event.custom_id[/\Aeros:curseact:(remove|suppress):\d+\z/, 1].to_sym
      Commands::RemoveCurse.apply(event, Array(event.values).first.to_i, action: action)
    end
  end
end
