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
