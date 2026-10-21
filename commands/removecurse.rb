# frozen_string_literal: true

module Commands
  module RemoveCurse
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    module_function

    # The purge menu is Syn's curse ledger now (see Commands::Curses);
    # these commands remain as direct numeric shortcuts into it.
    def show_menu(event, page: 0)
      Commands::Curses.show(event, page: page)
    end

    def apply(event, index, action: :remove)
      player = ErosHelpers.require_player(event) or return

      if Eros.encounter_for(player)
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'You cannot purge curses mid-combat.')
        end
        return
      end

      action = action.to_s == 'suppress' ? :suppress : :remove
      result = action == :suppress ? player.suppress_curse_at!(index.to_i) : player.remove_curse_at!(index.to_i)
      Commands::Curses.show(event, page: 0, notice: Commands::Curses.syn_result_notice(result, action))
    end

    def apply_all(event)
      player = ErosHelpers.require_player(event) or return

      if Eros.encounter_for(player)
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'You cannot purge curses mid-combat.')
        end
        return
      end

      result = player.remove_all_curses!
      Commands::Curses.show(event, page: 0, notice: Commands::Curses.syn_bulk_notice(result))
    end

    button(custom_id: /^eros:curseact:remove_all:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::RemoveCurse.apply_all(event)
    end

    button(custom_id: /^eros:removecurse:page:-?\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      page = event.custom_id[/\Aeros:removecurse:page:(-?\d+):\d+\z/, 1].to_i
      Commands::RemoveCurse.show_menu(event, page: page)
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
