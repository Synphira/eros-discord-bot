# frozen_string_literal: true

module Commands
  module LevelUp
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    module_function

    def show_menu(event)

      player = ErosHelpers.require_player(event) or return

      if Eros.encounter_for(player)
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'You cannot level up mid-combat.')
        end
        return
      end

      ErosUI.reply_v2(event, colour: 0x6b5b95, with_actions: :levelup) do |c|
        c.text_display(content: '## Level Up')
        c.text_display(
          content: "Welcome to the Level Up menu! You have **#{player.lp}** Lust Points.\n" \
                   "Lv **#{player.level}** · STR #{player.strength} · AGI #{player.agility} · RES #{player.resistance}"
        )
        c.separator(divider: true, spacing: :small)
        c.text_display(
          content: "What would you like to upgrade?\n" \
                   "1. **Strength** (10 LP)\n" \
                   "2. **Agility** (10 LP)\n" \
                   "3. **Resistance** (10 LP)\n" \
                   "4. **Level** (50 LP) — also +1 to all stats\n\n" \
                   '_Use the buttons, or `!levelup strength|agility|resistance|level`._'
        )
      end
    end

    def apply(event, choice)

      player = ErosHelpers.require_player(event) or return

      if Eros.encounter_for(player)
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'You cannot level up mid-combat.')
        end
        return
      end

      result =
        case choice.to_s.downcase
        when '1', 'strength', 'str' then player.upgrade_stat!(:strength)
        when '2', 'agility', 'agi' then player.upgrade_stat!(:agility)
        when '3', 'resistance', 'res' then player.upgrade_stat!(:resistance)
        when '4', 'level', 'lvl' then player.upgrade_level!
        else
          { ok: false, message: 'Unknown choice. Pick strength, agility, resistance, or level.' }
        end

      colour = result[:ok] ? 0x4a7c59 : 0x8b1a1a
      ErosUI.reply_v2(event, colour: colour, with_actions: :levelup) do |c|
        c.text_display(content: result[:message])
        if result[:ok]
          player.refresh
          c.separator(divider: false, spacing: :small)
          c.text_display(
            content: "Lv **#{player.level}** · STR #{player.strength} · AGI #{player.agility} · " \
                     "RES #{player.resistance} · LP `#{player.lp}`"
          )
        end
      end
    end

    application_command(:levelup) { |event| Commands::LevelUp.show_menu(event) }

    command(:levelup, description: 'Spend Lust Points to upgrade stats or level') do |event, choice|
      if choice && !choice.empty?
        Commands::LevelUp.apply(event, choice)
      else
        Commands::LevelUp.show_menu(event)
      end
      nil
    end
  end
end
