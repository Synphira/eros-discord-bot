# frozen_string_literal: true

module Commands
  module Explore
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    module_function

    def run(event)
      player = ErosHelpers.require_player(event) or return

      if Eros.encounter_for(player)
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
        if result.kind == :boss
          enc = result.monster
          enc = Engine::CombatEngine.encounter_snapshot(enc) unless enc.is_a?(Hash)
          Eros.set_encounter!(player, enc.merge(is_boss: true))
          ErosUI.reply_v2(event, colour: result.colour, with_actions: :combat) do |c|
            c.text_display(content: result.message)
            c.separator(divider: true, spacing: :small)
            c.text_display(
              content: '**Boss fight!** Choose **Fight**, **Flee**, or **Submit**.' \
                       "\n-# Submitting is a gamble: land #{Engine::CombatEngine::BOSS_SATISFY_NEEDED} successful " \
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
          ErosUI.reply_v2(event, colour: 0x444444) do |c|
            c.text_display(content: result.message)
          end
        else
          ErosUI.reply_v2(event, colour: result.colour, with_actions: :explore) do |c|
            c.text_display(content: result.message)
          end
        end
      when :treasure
        if result.broken
          ErosUI.reply_v2(event, colour: 0x444444) do |c|
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
          result[:broken] ? false : :explore
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

    application_command(:explore) { |event| Commands::Explore.run(event) }

    command(:explore, description: 'Step deeper into the endless dungeon') do |event|
      Commands::Explore.run(event)
      nil
    end
  end
end
