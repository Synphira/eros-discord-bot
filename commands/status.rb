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
        count = player.condition_list.size
        burden_count = Engine::Burdens.active(player).size
        c.row do |row|
          row.button(label: "⛓️ Burdens (#{burden_count})", style: :primary, custom_id: "eros:status:burdens:#{event.user.id}")
          row.button(label: "Conditions (#{count})", style: :secondary, custom_id: "eros:status:conditions:#{event.user.id}")
        end
      end
    end

    def burdens(event, notice: nil)
      player = ErosHelpers.require_player(event) or return
      active = Engine::Burdens.active(player)
      changeable = Engine::Burdens.changeable?(player)

      ErosUI.reply_v2(event, colour: 0x6b5b95) do |c|
        c.text_display(content: "## ⛓️ Cycle Burdens — #{player.display_name}")
        c.text_display(
          content: 'Take on up to **3 torments** for the whole cycle. Every burden makes **every LP gain +25%** ' \
                   "(you are at **×#{format('%.2f', Engine::Burdens.lp_multiplier(player))}**). Burdens can only " \
                   'be taken or shed at a cycle\'s start — floor 1, before you delve; once you climb, they are ' \
                   'locked in until you clear the tower.'
        )
        c.text_display(content: notice) if notice
        lines = Engine::Burdens::BURDENS.map do |key, spec|
          on = active.include?(key)
          "#{on ? '⛓️' : '▫️'} **#{spec[:name]}**#{on ? ' _(carried)_' : ''} — #{spec[:description]}"
        end
        c.text_display(content: lines.join("\n"))
        c.text_display(
          content: changeable ? '-# You are at a cycle\'s start: the buttons below work.' \
                              : '-# Locked in — burdens can only change at a cycle\'s start (floor 1).'
        )
        c.row do |row|
          Engine::Burdens::BURDENS.each do |key, spec|
            on = active.include?(key)
            row.button(label: "#{on ? '✓ ' : ''}#{spec[:name]}", style: on ? :danger : :secondary,
                       custom_id: "eros:burden:toggle:#{key}:#{event.user.id}",
                       disabled: !changeable)
          end
        end
        c.row do |row|
          row.button(label: 'Back to Status', style: :primary, custom_id: "eros:status:view:#{event.user.id}")
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
      result = Engine::Burdens.toggle!(player, key)
      player.refresh
      Commands::Status.burdens(event, notice: result[:ok] ? "✅ #{result[:message]}" : "❌ #{result[:message]}")
    end

    button(custom_id: /^eros:status:burdens:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Status.burdens(event)
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
