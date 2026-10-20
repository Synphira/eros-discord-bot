# frozen_string_literal: true

module Commands
  module Status
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    module_function

    def run(event)
      player = ErosHelpers.require_player(event) or return
      threat = Engine::ThreatCalculator.calculate(player)

      ErosUI.reply_v2(event, colour: ErosUI.threat_color(threat.category)) do |c|
        ErosUI.build_status_container(c, player)
        burdens = Engine::Burdens.active(player)
        c.text_display(
          content: "⛓️ **Cycle Burdens** — LP gains ×#{format('%.2f', Engine::Burdens.lp_multiplier(player))}" \
                   "#{burdens.any? ? " · carrying: #{burdens.map { |b| Engine::Burdens::BURDENS[b][:name] }.join(', ')}" : ''}\n" \
                   "-# #{Engine::Burdens.changeable?(player) ? 'You are at a cycle\'s start: take on or shed burdens (max 3, +25% LP each).' : 'Burdens are chosen at a cycle\'s start and set until you clear the tower.'}"
        )
        c.row do |row|
          Engine::Burdens::BURDENS.each do |key, spec|
            on = burdens.include?(key)
            row.button(label: "#{on ? '✓ ' : ''}#{spec[:name]}", style: on ? :danger : :secondary,
                       custom_id: "eros:burden:toggle:#{key}:#{event.user.id}",
                       disabled: !Engine::Burdens.changeable?(player))
          end
        end
        count = player.condition_list.size
        c.row do |row|
          row.button(label: "Conditions (#{count})", style: :secondary, custom_id: "eros:status:conditions:#{event.user.id}")
        end
      end
    end

    def conditions(event)
      player = ErosHelpers.require_player(event) or return
      threat = Engine::ThreatCalculator.calculate(player)

      ErosUI.reply_v2(event, colour: ErosUI.threat_color(threat.category)) do |c|
        ErosUI.build_conditions_container(c, player)
        c.row do |row|
          row.button(label: 'Back to Status', style: :primary, custom_id: "eros:status:view:#{event.user.id}")
        end
      end
    end

    button(custom_id: /^eros:burden:toggle:[a-z_]+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      key = event.custom_id[/\Aeros:burden:toggle:([a-z_]+):\d+\z/, 1]
      Engine::Burdens.toggle!(player, key)
      Commands::Status.run(event)
    end

    button(custom_id: /^eros:status:conditions:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Status.conditions(event)
    end

    button(custom_id: /^eros:status:view:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Status.run(event)
    end

    application_command(:status) { |event| Commands::Status.run(event) }

    command(:status, description: 'Show HP, LP, curses, and Threat Level') do |event|
      Commands::Status.run(event)
      nil
    end
  end
end
