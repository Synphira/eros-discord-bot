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
                   "Lv **#{player.level}** · STR #{player.strength} · AGI #{player.agility} · RES #{player.resistance} · " \
                   "Max defiance **#{player.max_defiance}**"
        )
        c.separator(divider: true, spacing: :small)
        next_max = Player.calculate_max_hp(player.level + 1) - Player.calculate_max_hp(player.level)
        c.text_display(
          content: "What would you like to upgrade?\n" \
                   "1. **Strength** (#{player.stat_upgrade_cost(:strength)} LP) — damage per hit\n" \
                   "2. **Agility** (#{player.stat_upgrade_cost(:agility)} LP) — flee, dodge attacks, avoid traps, slip free of events\n" \
                   "3. **Resistance** (#{player.stat_upgrade_cost(:resistance)} LP) — cuts lust from every hit by a percentage\n" \
                   "4. **Level** (#{player.level_upgrade_cost} LP) — +1 to all stats, **+#{next_max} max defiance**, and a full defiance restore\n\n" \
                   "-# Each stat costs 5 + its current value, and a level costs 80% of all three combined.\n" \
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

    application_command(:levelup) do |event|
      choice = event.options['choice']
      if choice && !choice.to_s.empty?
        Commands::LevelUp.apply(event, choice)
      else
        Commands::LevelUp.show_menu(event)
      end
    end

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
