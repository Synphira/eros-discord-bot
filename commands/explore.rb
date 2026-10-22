# frozen_string_literal: true

module Commands
  module Explore
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    module_function

    def run(event)
      player = ErosHelpers.require_player(event) or return

      if player.tracker('eros_intro_pending').positive? && Eros.encounter_for(player)
        show_eros_intro(event, player)
        return
      end

      if (enc = Eros.encounter_for(player))
        spec = (enc[:phase] || enc['phase']).to_s == 'pending' && Engine::BossFights.phase(enc[:name] || enc['name'])
        if spec
          ErosUI.reply_v2(event, ephemeral: true,
                                 with_actions: { phase: { resist: spec[:resist_label], give_in: spec[:give_label] } }) do |c|
            c.text_display(content: "The #{enc[:name] || enc['name']} is waiting for your answer.")
          end
          return
        end
        ErosUI.reply_v2(event, ephemeral: true, with_actions: :combat) do |c|
          c.text_display(
            content: 'You are already in combat. Choose **Fight**, **Flee**, or **Submit**.'
          )
        end
        return
      end

      result = Engine::Exploration.roll(player)
      progress = player.check_progress!
      if progress.any?
        if result.kind == :event && result.event_result
          result.event_result[:log] = Array(result.event_result[:log]) + progress
        else
          result.message = "#{result.message}\n\n#{progress.join("\n")}"
        end
      end

      case result.kind
      when :monster, :boss
        if result.kind == :boss && result.boss_intro
          show_eros_intro(event, player, message: result.message, colour: result.colour)
        elsif result.kind == :boss
          enc = result.monster
          enc = Engine::CombatEngine.encounter_snapshot(enc) unless enc.is_a?(Hash)
          Eros.set_encounter!(player, enc.merge(is_boss: true))
          ErosUI.reply_v2(event, colour: result.colour, with_actions: :combat) do |c|
            c.text_display(content: result.message)
            c.separator(divider: true, spacing: :small)
            c.text_display(
              content: '**Boss fight!** Choose **Fight**, **Flee**, or **Submit**.' \
                       "\n-# Submitting is a gamble: land #{Engine::CombatEngine.boss_satisfy_needed(player)} successful " \
                       "submits to satisfy the boss for ×#{Engine::CombatEngine::BOSS_SATISFY_LP_MULT} LP — " \
                       "but it keeps attacking and you can't dodge while submitting."
            )
          end
        else
          started = Engine::CombatEngine.start_encounter(player, monster: result.monster)
          Eros.set_encounter!(player, started[:encounter])

          ErosUI.reply_v2(event, colour: result.colour, with_actions: :combat) do |c|
            c.text_display(content: result.message)
            c.separator(divider: true, spacing: :small)
            c.text_display(content: started[:message])
          end
        end
      when :event
        render_event(event, player, result.event_result || {
          mode: :done,
          colour: result.colour,
          log: [result.message],
          choices: [],
          broken: result.broken
        })
      when :trap
        if result.broken
          ErosUI.reply_v2(event, colour: 0x444444, with_actions: :defeat) do |c|
            c.text_display(content: result.message)
          end
        else
          ErosUI.reply_v2(event, colour: result.colour, with_actions: :explore) do |c|
            c.text_display(content: result.message)
          end
        end
      when :treasure
        if result.broken
          ErosUI.reply_v2(event, colour: 0x444444, with_actions: :defeat) do |c|
            c.text_display(content: result.message)
          end
        else
          ErosUI.reply_v2(event, colour: result.colour, with_actions: :explore) do |c|
            ErosUI.append_action_log(c, result.message.split("\n"))
          end
        end
      else
        ErosUI.reply_v2(event, colour: result.colour, with_actions: :explore) do |c|
          c.text_display(content: result.message)
        end
      end
    end

    def render_event(event, player, result)
      result = result.transform_keys(&:to_sym) if result.is_a?(Hash)
      mode = result[:mode].to_sym
      colour = result[:colour] || Engine::RandomEvents::COLOUR
      log = Engine::ContentOptions.scrub!(player, Array(result[:log]).dup)

      if mode == :combat
        started = Engine::CombatEngine.start_encounter(player, monster: result[:monster])
        Eros.set_encounter!(player, started[:encounter])
        ErosUI.reply_v2(event, colour: colour, with_actions: :combat) do |c|
          c.text_display(content: "## #{result[:name]}") if result[:name]
          ErosUI.append_action_log(c, log)
          c.separator(divider: true, spacing: :small)
          c.text_display(content: started[:message])
        end
        return
      end

      actions =
        case mode
        when :choice
          { event_choices: result[:choices] }
        when :continue
          { event_continue: true }
        else
          result[:broken] ? :defeat : :explore
        end

      ErosUI.reply_v2(event, colour: colour, with_actions: actions) do |c|
        c.text_display(content: "## #{result[:name] || 'Random Event'}") if result[:name]
        ErosUI.append_action_log(c, log)
        if mode == :choice && result[:choices]&.any?
          c.separator(divider: true, spacing: :small)
          lines = result[:choices].map { |ch| "• **#{ch[:label]}** — #{ch[:text]}" }
          c.text_display(content: lines.join("\n"))
        end
      end
    end

    # The goddess, before the fight: her dialogue alone, with one way
    # forward. Reaching her stores the encounter, but combat does not
    # begin until Continue is pressed.
    def show_eros_intro(event, player, message: nil, colour: 0x5c0a2e)
      boss = Engine::BossFights.boss_for_floor(player.current_floor)
      message ||= Engine::BossFights.eros_dialogue(player, player.current_floor, boss)
      ErosUI.reply_v2(event, colour: colour) do |c|
        c.text_display(content: message)
        c.separator(divider: true, spacing: :small)
        c.text_display(content: '_She is in no hurry. Neither, until you have heard her, are you._')
        c.row do |row|
          row.button(label: '▶ Continue', style: :danger,
                     custom_id: "eros:boss:continue:#{event.user.id}")
        end
      end
    end

    def show_eros_combat(event, player)
      enc = Eros.encounter_for(player)
      unless enc
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'She is no longer waiting. Use `/explore` to climb again.')
        end
        return
      end

      player.set_tracker!('eros_intro_pending', 0)
      ErosUI.reply_v2(event, colour: 0x5c0a2e, with_actions: :combat) do |c|
        c.text_display(content: Engine::BossFights.boss_combat_banner(enc))
        c.separator(divider: true, spacing: :small)
        c.text_display(
          content: '**Boss fight!** Choose **Fight**, **Flee**, or **Submit**.' \
                   "\n-# Submitting is a gamble: land #{Engine::CombatEngine.boss_satisfy_needed(player)} successful " \
                   "submits to satisfy the boss for ×#{Engine::CombatEngine::BOSS_SATISFY_LP_MULT} LP — " \
                   "but it keeps attacking and you can't dodge while submitting."
        )
      end
    end

    def show_submission(event)
      ErosUI.reply_v2(event, colour: 0x444444, with_actions: :submission) do |c|
        c.text_display(content: '## Submission')
        c.text_display(content: 'You lost all defiance and gave into your desires. The tower forever ravages you.')
      end
    end

    button(custom_id: /^eros:boss:continue:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      Commands::Explore.show_eros_combat(event, player)
    end

    button(custom_id: /^eros:defeat_continue:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Explore.show_submission(event)
    end

    button(custom_id: /^eros:try_again:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Explore.run(event)
    end

    application_command(:explore) { |event| Commands::Explore.run(event) }

    command(:explore, description: 'Step deeper into the endless dungeon') do |event|
      Commands::Explore.run(event)
      nil
    end
  end
end
