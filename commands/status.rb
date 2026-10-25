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
        bonus_count = Engine::SupportBonuses.active_count(player)
        c.row do |row|
          row.button(label: "⛓️ Burdens (#{burden_count})", style: :primary, custom_id: "eros:status:burdens:#{event.user.id}")
          row.button(label: "Bonuses (#{bonus_count})", style: :secondary, custom_id: "eros:status:bonuses:#{event.user.id}")
          row.button(label: "Conditions (#{count})", style: :secondary, custom_id: "eros:status:conditions:#{event.user.id}")
        end
      end
    end

    def bonuses(event)
      player = ErosHelpers.require_player(event) or return
      bot = event.respond_to?(:bot) ? event.bot : nil
      Engine::SupportBonuses.observe!(event.user, bot: bot, force: true)
      player.refresh if player.respond_to?(:refresh)

      ErosUI.reply_v2(event, colour: 0xf0c27f) do |c|
        c.text_display(content: "## Bonuses — #{player.display_name}")
        c.text_display(content: Engine::SupportBonuses.bonus_lines(player).join("\n"))
        c.separator(divider: true, spacing: :small)
        c.text_display(content: Engine::SupportBonuses.promo_text)
        c.row do |row|
          row.button(label: 'Join Support Server', style: :link,
                     url: Engine::SupportBonuses::INVITE_URL)
        end
        c.row do |row|
          row.button(label: 'Back to Status', style: :primary, custom_id: "eros:status:view:#{event.user.id}")
          row.button(label: '⛓️ Burdens', style: :secondary, custom_id: "eros:status:burdens:#{event.user.id}")
          row.button(label: 'Conditions', style: :secondary, custom_id: "eros:status:conditions:#{event.user.id}")
        end
      end
    end

    def burdens(event, notice: nil)
      player = ErosHelpers.require_player(event) or return
      active = Engine::Burdens.active(player)
      changeable = Engine::Burdens.changeable?(player)
      oaths_ok = Engine::Burdens.oaths_changeable?(player)
      reroll_ok = Engine::Burdens.rerollable?(player)
      price = Engine::Burdens.reroll_price(player)

      ErosUI.reply_v2(event, colour: 0x6b5b95) do |c|
        c.text_display(content: "## ⛓️ Cycle Burdens — #{player.display_name}")
        c.text_display(
          content: 'Take on up to **3 torments** for the whole cycle. Every burden makes **every LP gain +25%** ' \
                   "(you are at **×#{format('%.2f', Engine::Burdens.lp_multiplier(player))}**). Taking or shedding " \
                   'burdens is only allowed at a cycle\'s start — **floor 1**. Rerolls and oaths work on any floor.'
        )
        c.text_display(
          content: '_The truly devoted may also swear up to **2 Oaths** — extra torments beyond the three, ' \
                   'worth **+10% LP each**. Oaths torment exactly like burdens, but devotion is its own ' \
                   'category: they never count toward Burdens Carried honours. Toggle them anytime (outside combat)._'
        )
        c.text_display(content: notice) if notice
        sworn = Engine::Burdens.oaths(player)
        lines = Engine::Burdens::BURDENS.map do |key, spec|
          on = active.include?(key)
          oath = sworn.include?(key)
          "#{on ? '⛓️' : oath ? '📜' : '▫️'} **#{spec[:name]}**#{on ? ' _(carried)_' : oath ? ' _(oath)_' : ''} — #{spec[:description]}"
        end
        c.text_display(content: lines.join("\n"))
        c.text_display(
          content: changeable ? '-# Floor 1: take or shed burdens freely.' \
                              : '-# Burdens locked — take/shed only on floor 1. Oaths and rerolls still work.'
        )
        c.row do |row|
          Engine::Burdens::BURDENS.each do |key, spec|
            on = active.include?(key)
            row.button(label: "#{on ? '✓ ' : ''}#{spec[:name]}", style: on ? :danger : :secondary,
                       custom_id: "eros:burden:toggle:#{key}:#{event.user.id}",
                       disabled: !changeable)
          end
        end
        if active.any?
          c.separator(divider: true, spacing: :small)
          c.text_display(
            content: '_Or let Eros shuffle a carried burden into a different one — never one you already ' \
                     "carry, and never one sworn as an oath. Shuffling costs **#{price} LP** and climbs " \
                     "#{Engine::Burdens::REROLL_STEP} LP with every mid-climb shuffle; the price resets on " \
                     '**floor 1**._'
          )
          c.row do |row|
            active.each do |key|
              row.button(label: "🎲 Reroll: #{Engine::Burdens::BURDENS[key][:name]}", style: :secondary,
                         custom_id: "eros:burden:reroll:#{key}:#{event.user.id}",
                         disabled: !reroll_ok || player.lp < price ||
                                   Engine::Burdens.reroll_pool(player).empty?)
            end
          end
        end
        c.row do |row|
          Engine::Burdens::BURDENS.each do |key, spec|
            oath = sworn.include?(key)
            row.button(label: "#{oath ? '✓ ' : ''}📜 #{spec[:name]}", style: oath ? :danger : :secondary,
                       custom_id: "eros:burden:oath:#{key}:#{event.user.id}",
                       disabled: !oaths_ok || active.include?(key) ||
                                 (!oath && sworn.size >= Engine::Burdens::MAX_OATHS))
          end
        end
        c.row do |row|
          row.button(label: 'Back to Status', style: :primary, custom_id: "eros:status:view:#{event.user.id}")
          row.button(label: 'Bonuses', style: :secondary, custom_id: "eros:status:bonuses:#{event.user.id}")
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
          row.button(label: 'Bonuses', style: :secondary, custom_id: "eros:status:bonuses:#{event.user.id}")
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

    button(custom_id: /^eros:burden:oath:[a-z_]+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      key = event.custom_id[/\Aeros:burden:oath:([a-z_]+):\d+\z/, 1]
      result = Engine::Burdens.toggle_oath!(player, key)
      player.refresh
      Commands::Status.burdens(event, notice: result[:ok] ? "📜 #{result[:message]}" : "❌ #{result[:message]}")
    end

    button(custom_id: /^eros:burden:reroll:[a-z_]+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      key = event.custom_id[/\Aeros:burden:reroll:([a-z_]+):\d+\z/, 1]
      result = Engine::Burdens.reroll!(player, key)
      player.refresh
      Commands::Status.burdens(event, notice: result[:ok] ? "🎲 #{result[:message]}" : "❌ #{result[:message]}")
    end

    button(custom_id: /^eros:status:burdens:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Status.burdens(event)
    end

    button(custom_id: /^eros:status:bonuses:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Status.bonuses(event)
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
