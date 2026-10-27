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
        status_nav(c, player, event, current: :status)
      end
    end

    # One select instead of a button row — keeps the sheet short on mobile.
    def status_nav(container, player, event, current:)
      uid = event.user.id
      burdens = Engine::Burdens.active(player).size
      bonuses = Engine::SupportBonuses.active_count(player)
      conditions = player.condition_list.size
      candy = Engine::Halloween.candy_count(player)
      leftovers = Engine::Thanksgiving.leftovers_count(player)
      stocking = Engine::Christmas.candy_count(player)
      bubbles = Engine::NewYear.bubbles_count(player)
      hearts = Engine::Valentines.hearts_count(player)
      cake = Engine::MardiGras.cake_count(player)
      eggs = Engine::Easter.eggs_count(player)
      sweets = Engine::AprilFools.sweets_count(player)
      wine = Engine::MayDay.wine_count(player)
      honey = Engine::Midsummer.honey_count(player)
      glitter = Engine::Pride.glitter_count(player)

      container.row do |row|
        row.string_select(custom_id: "eros:status:goto:#{uid}", placeholder: 'Open a panel…',
                          min_values: 1, max_values: 1) do |menu|
          menu.option(label: 'Status', value: 'status',
                      description: 'Your delver sheet',
                      emoji: { name: '📜' }, default: current == :status)
          menu.option(label: 'Events', value: 'events',
                      description: 'Weekly, seasons & stash',
                      emoji: { name: '📅' }, default: current == :events)
          menu.option(label: "Burdens (#{burdens})", value: 'burdens',
                      description: 'Cycle torments & oaths',
                      emoji: { name: '⛓️' }, default: current == :burdens)
          menu.option(label: "Bonuses (#{bonuses})", value: 'bonuses',
                      description: 'Support-server perks',
                      emoji: { name: '✨' }, default: current == :bonuses)
          menu.option(label: "Conditions (#{conditions})", value: 'conditions',
                      description: 'Active floor effects',
                      emoji: { name: '🩸' }, default: current == :conditions)
          if candy.positive?
            menu.option(label: "Eat Candy (#{candy})", value: 'candy',
                        description: 'Spend a Halloween sweet',
                        emoji: { name: '🍬' })
          end
          if leftovers.positive?
            menu.option(label: "Eat Leftovers (#{leftovers})", value: 'leftovers',
                        description: 'Spend a feast plate',
                        emoji: { name: '🍗' })
          end
          if stocking.positive?
            menu.option(label: "Eat Stocking (#{stocking})", value: 'stocking',
                        description: 'Spend a Yule sweet',
                        emoji: { name: '🍬' })
          end
          if bubbles.positive?
            menu.option(label: "Drink Bubbles (#{bubbles})", value: 'bubbles',
                        description: 'Spend a midnight toast',
                        emoji: { name: '🥂' })
          end
          if hearts.positive?
            menu.option(label: "Eat Hearts (#{hearts})", value: 'hearts',
                        description: 'Spend a chocolate heart',
                        emoji: { name: '🍫' })
          end
          if cake.positive?
            menu.option(label: "Eat King Cake (#{cake})", value: 'cake',
                        description: 'Spend a carnival bite',
                        emoji: { name: '🍰' })
          end
          if eggs.positive?
            menu.option(label: "Eat Eggs (#{eggs})", value: 'eggs',
                        description: 'Spend a chocolate egg',
                        emoji: { name: '🥚' })
          end
          if sweets.positive?
            menu.option(label: "Eat Fool's Sweets (#{sweets})", value: 'sweets',
                        description: 'Spend an April joke candy',
                        emoji: { name: '🃏' })
          end
          if wine.positive?
            menu.option(label: "Drink May Wine (#{wine})", value: 'wine',
                        description: 'Spend a maypole sip',
                        emoji: { name: '🍷' })
          end
          if honey.positive?
            menu.option(label: "Eat Sun Honey (#{honey})", value: 'honey',
                        description: 'Spend a solstice sweet',
                        emoji: { name: '🍯' })
          end
          if glitter.positive?
            menu.option(label: "Eat Pride Glitter (#{glitter})", value: 'glitter',
                        description: 'Spend a parade sweet',
                        emoji: { name: '✨' })
          end
        end
      end
    end

    def events(event)
      player = ErosHelpers.require_player(event) or return

      ErosUI.reply_v2(event, colour: 0x9b59b6) do |c|
        ErosUI.build_events_container(c, player)
        status_nav(c, player, event, current: :events)
      end
    end

    def eat_candy(event)
      player = ErosHelpers.require_player(event) or return
      result = Engine::Halloween.eat_candy!(player)
      reply_after_eat(event, player, result)
    end

    def eat_leftovers(event)
      player = ErosHelpers.require_player(event) or return
      result = Engine::Thanksgiving.eat_leftovers!(player)
      reply_after_eat(event, player, result)
    end

    def eat_stocking(event)
      player = ErosHelpers.require_player(event) or return
      result = Engine::Christmas.eat_candy!(player)
      reply_after_eat(event, player, result)
    end

    def drink_bubbles(event)
      player = ErosHelpers.require_player(event) or return
      result = Engine::NewYear.eat_bubbles!(player)
      reply_after_eat(event, player, result)
    end

    def eat_hearts(event)
      player = ErosHelpers.require_player(event) or return
      result = Engine::Valentines.eat_hearts!(player)
      reply_after_eat(event, player, result)
    end

    def eat_cake(event)
      player = ErosHelpers.require_player(event) or return
      result = Engine::MardiGras.eat_cake!(player)
      reply_after_eat(event, player, result)
    end

    def eat_eggs(event)
      player = ErosHelpers.require_player(event) or return
      result = Engine::Easter.eat_eggs!(player)
      reply_after_eat(event, player, result)
    end

    def eat_sweets(event)
      player = ErosHelpers.require_player(event) or return
      result = Engine::AprilFools.eat_sweets!(player)
      reply_after_eat(event, player, result)
    end

    def drink_wine(event)
      player = ErosHelpers.require_player(event) or return
      result = Engine::MayDay.eat_wine!(player)
      reply_after_eat(event, player, result)
    end

    def eat_honey(event)
      player = ErosHelpers.require_player(event) or return
      result = Engine::Midsummer.eat_honey!(player)
      reply_after_eat(event, player, result)
    end

    def eat_glitter(event)
      player = ErosHelpers.require_player(event) or return
      result = Engine::Pride.eat_glitter!(player)
      reply_after_eat(event, player, result)
    end

    def reply_after_eat(event, player, result)
      player.refresh if player.respond_to?(:refresh)
      notice = result[:ok] ? "✅ #{result[:message]}" : "❌ #{result[:message]}"
      threat = Engine::ThreatCalculator.calculate(player)
      ErosUI.reply_v2(event, colour: ErosUI.threat_color(threat.category)) do |c|
        ErosUI.build_status_container(c, player)
        c.text_display(content: notice)
        status_nav(c, player, event, current: :status)
      end
    end
    private_class_method :reply_after_eat

    def bonuses(event)
      player = ErosHelpers.require_player(event) or return
      bot = event.respond_to?(:bot) ? event.bot : nil
      title_lines = Engine::SupportBonuses.observe!(event.user, bot: bot, force: true, player: player)
      player.refresh if player.respond_to?(:refresh)

      ErosUI.reply_v2(event, colour: 0xf0c27f) do |c|
        c.text_display(content: "## Bonuses — #{player.display_name}")
        c.text_display(content: Engine::SupportBonuses.bonus_lines(player).join("\n"))
        if title_lines&.any?
          c.separator(divider: true, spacing: :small)
          c.text_display(content: title_lines.join("\n"))
        end
        c.separator(divider: true, spacing: :small)
        c.text_display(content: Engine::SupportBonuses.promo_text)
        c.row do |row|
          row.button(label: 'Join Support Server', style: :link,
                     url: Engine::SupportBonuses::INVITE_URL)
        end
        status_nav(c, player, event, current: :bonuses)
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
        status_nav(c, player, event, current: :burdens)
      end
    end

    def conditions(event, page: 0)
      player = ErosHelpers.require_player(event) or return
      threat = Engine::ThreatCalculator.calculate(player)

      ErosUI.reply_v2(event, colour: ErosUI.threat_color(threat.category)) do |c|
        _slice, pages, page = ErosUI.build_conditions_container(c, player, page: page)
        Commands::Profile.attach_pager(c, 'eros:status:condpage', page, pages, event.user.id) if pages > 1
        status_nav(c, player, event, current: :conditions)
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

    string_select(custom_id: /^eros:status:goto:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      case Array(event.values).first.to_s
      when 'events' then Commands::Status.events(event)
      when 'burdens' then Commands::Status.burdens(event)
      when 'bonuses' then Commands::Status.bonuses(event)
      when 'conditions' then Commands::Status.conditions(event, page: 0)
      when 'candy' then Commands::Status.eat_candy(event)
      when 'leftovers' then Commands::Status.eat_leftovers(event)
      when 'stocking' then Commands::Status.eat_stocking(event)
      when 'bubbles' then Commands::Status.drink_bubbles(event)
      when 'hearts' then Commands::Status.eat_hearts(event)
      when 'cake' then Commands::Status.eat_cake(event)
      when 'eggs' then Commands::Status.eat_eggs(event)
      when 'sweets' then Commands::Status.eat_sweets(event)
      when 'wine' then Commands::Status.drink_wine(event)
      when 'honey' then Commands::Status.eat_honey(event)
      when 'glitter' then Commands::Status.eat_glitter(event)
      else Commands::Status.run(event)
      end
    end

    button(custom_id: /^eros:status:condpage:-?\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      page = event.custom_id[/\Aeros:status:condpage:(-?\d+):\d+\z/, 1].to_i
      Commands::Status.conditions(event, page: page)
    end

    # Legacy button ids — old panels in chat still work until they refresh.
    button(custom_id: /^eros:status:burdens:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Status.burdens(event)
    end

    button(custom_id: /^eros:status:bonuses:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Status.bonuses(event)
    end

    button(custom_id: /^eros:status:candy:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Status.eat_candy(event)
    end

    button(custom_id: /^eros:status:leftovers:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Status.eat_leftovers(event)
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
