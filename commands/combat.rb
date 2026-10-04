# frozen_string_literal: true

module Commands
  module Combat
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    module_function

    def run_action(event, action)

      player = ErosHelpers.require_player(event) or return

      enc = Eros.encounter_for(player)
      unless enc
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'You are not in combat. Use `/explore` or `e,explore` first.')
        end
        return
      end

      result = Engine::CombatEngine.act!(player, action, enc)

      unless result[:ok]
        actions = result[:phase] ? { phase: result[:phase] } : nil
        ErosUI.reply_v2(event, ephemeral: true, with_actions: actions) do |c|
          ErosUI.append_action_log(c, result[:log])
        end
        return
      end

      result[:log].concat(player.check_progress!)
      Engine::ContentOptions.scrub!(player, result[:log])

      if result[:tower_cleared]
        Eros.clear_encounter!(player)
        ErosUI.reply_v2(event, colour: 0xd4af37, with_actions: :explore) do |c|
          c.text_display(content: '## The Tower Is Conquered')
          ErosUI.append_action_log(c, result[:log])
        end
        return
      end

      if result[:fled] || result[:satisfied]
        Eros.clear_encounter!(player)
        ErosUI.reply_v2(event, colour: 0x4a7c59, with_actions: :explore) do |c|
          ErosUI.append_action_log(c, result[:log])
        end
        return
      end

      if result[:victory]
        Eros.clear_encounter!(player)
        ErosUI.reply_v2(event, colour: 0x4a7c59, with_actions: :explore) do |c|
          ErosUI.append_action_log(c, result[:log])
        end
        return
      end

      if result[:defeated] || result[:broken]
        Eros.clear_encounter!(player)
        ErosUI.reply_v2(event, colour: 0x444444, with_actions: :defeat) do |c|
          ErosUI.append_action_log(c, result[:log])
        end
        return
      end

      Eros.set_encounter!(player, result[:encounter])
      enc = result[:encounter]
      colour = enc[:color] || 0x8b1a1a
      actions = result[:phase] ? { phase: result[:phase] } : :combat
      ErosUI.reply_v2(event, colour: colour, with_actions: actions) do |c|
        ErosUI.append_action_log(c, result[:log])
        c.separator(divider: true, spacing: :small)
        c.text_display(
          content: "**#{enc[:name]}** _(#{enc[:type_name]})_ HP `#{enc[:hp]}/#{enc[:max_hp]}` · " \
                   "STR `#{enc[:strength]}` · Your Defiance `#{player.defiance}/#{player.max_defiance}` · " \
                   "Lust `#{player.lust}`"
        )
      end
    end

    button(custom_id: /^eros:phase:(resist|give_in):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      choice = event.custom_id[/\Aeros:phase:(resist|give_in):\d+\z/, 1]
      Commands::Combat.run_action(event, choice.to_sym)
    end

    application_command(:fight) { |event| Commands::Combat.run_action(event, :fight) }
    application_command(:flee) { |event| Commands::Combat.run_action(event, :flee) }
    application_command(:submit) { |event| Commands::Combat.run_action(event, :submit) }

    command(:fight, description: 'Attack the current monster') do |event|
      Commands::Combat.run_action(event, :fight)
      nil
    end

    command(:flee, description: 'Try to escape combat') do |event|
      Commands::Combat.run_action(event, :flee)
      nil
    end

    command(:submit, description: 'Submit to the monster') do |event|
      Commands::Combat.run_action(event, :submit)
      nil
    end
  end
end
