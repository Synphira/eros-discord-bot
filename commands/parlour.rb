# frozen_string_literal: true

module Commands
  module Parlour
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0x9b2d6f

    INTRO = "## Syn & Berry's\n" \
            "_One half of the shop glows with clean steel and bottled light, where **Berry** — a strawberry-bright " \
            "fairy with a smile like sunrise and a grip like ownership — is already writing your name in her ledger. " \
            "The other half is velvet, ink and candle smoke, where her wife **Syn** lounges over the parlour bench: " \
            "a heavy-lidded fairy with a waist-length cascade of platinum-blonde hair and sleepless shadows " \
            "under her eyes, wearing next to nothing but a few scraps of black lace — because her own skin is " \
            "the catalogue. Every tattoo and piercing she sells is displayed on her own inked, pierced body, " \
            "from the sigil low on her belly to the gold rings through her nipples. \"Something permanent, " \
            "darling?\" Syn purrs, not looking up. \"My work never fades. Not " \
            "after defeat, not after a new cycle, not ever.\" Berry's wings flick. \"Eyes on the board while my " \
            "wife works, pet. She's mine — the quests are yours.\"_"

    module_function

    def show(event, notice: nil)
      player = ErosHelpers.require_player(event) or return

      if Eros.encounter_for(player)
        ErosUI.reply_v2(event, ephemeral: true, with_actions: :combat) do |c|
          c.text_display(content: 'Syn will not ink a delver mid-fight. Deal with the monster first — Berry is taking bets.')
        end
        return
      end

      owned = Engine::Marks.owned(player)
      offers = Engine::Marks.available(player)
      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: INTRO)
        c.text_display(content: notice) if notice
        lines = owned.map { |k| "◆ #{Engine::Marks.label(k)} — _#{Engine::Marks::MARKS[k][:perk]}_" }
        c.text_display(
          content: "**Your marks** #{owned.size}/#{Engine::Marks::MAX_MARKS} · **LP** #{player.lp}\n" \
                   "#{lines.empty? ? '_Your skin is still bare. Syn is already sketching on it in her head._' : lines.join("\n")}"
        )
        c.separator(divider: true, spacing: :small)

        if offers.any? && owned.size < Engine::Marks::MAX_MARKS
          c.row do |row|
            row.string_select(custom_id: "eros:parlour:buy:#{event.user.id}", placeholder: "Choose a design from Syn…",
                              min_values: 1, max_values: 1) do |menu|
              offers.first(25).each do |key, m|
                kind = m[:kind] == :tattoo ? 'Tattoo' : 'Piercing'
                menu.option(label: "#{m[:name]} — #{m[:cost]} LP"[0, 100], value: key,
                            description: "#{kind}, #{m[:place]} · #{m[:perk]}"[0, 100])
              end
            end
          end
        elsif owned.size >= Engine::Marks::MAX_MARKS
          c.text_display(content: '-# You have no room for more marks. Remove one to make space.')
        else
          c.text_display(content: '-# Syn has nothing new for you right now. More designs unlock with themes in `/options`.')
        end

        if owned.any?
          c.row do |row|
            row.string_select(custom_id: "eros:parlour:remove:#{event.user.id}", placeholder: 'Remove a mark (free)…',
                              min_values: 1, max_values: 1) do |menu|
              owned.each do |key|
                menu.option(label: Engine::Marks::MARKS[key][:name], value: key)
              end
            end
          end
        end

        attach_quest_board(c, player, event.user.id)
      end
    end

    def attach_quest_board(container, player, owner_id)
      container.separator(divider: true, spacing: :small)
      container.text_display(
        content: "### 🍓 Berry's Quest Board\n" \
                 "_\"Errands, sugar! I run the shop, Syn runs the bench, and you run your pretty legs off for both " \
                 "of us.\"_\n" \
                 "#{Engine::Quests.board_lines(player).join("\n")}\n" \
                 "-# Quests completed for Berry: **#{Engine::Quests.completed(player)}**"
      )

      active = Engine::Quests.active(player)
      ready = active.select { |row| Engine::Quests.complete?(player, row) }
      if ready.any?
        container.row do |row|
          ready.first(5).each do |row_q|
            spec = Engine::Quests.quest(row_q['key'])
            row.button(label: "Claim: #{spec[:name]} (#{spec[:reward]} LP)", style: :success,
                       custom_id: "eros:parlour:claim:#{row_q['key']}:#{owner_id}")
          end
        end
      end

      offers = Engine::Quests.offers(player)
      if offers.any? && active.size < Engine::Quests::MAX_ACTIVE
        container.row do |row|
          row.string_select(custom_id: "eros:parlour:quest:#{owner_id}", placeholder: "Take a quest from Berry…",
                            min_values: 1, max_values: 1) do |menu|
            offers.each do |key|
              spec = Engine::Quests.quest(key)
              label = Engine::TitleSystem::TRACKER_LABELS.fetch(spec[:tracker].to_sym, spec[:tracker])
              menu.option(label: "#{spec[:name]} — #{spec[:reward]} LP"[0, 100], value: key,
                          description: "#{spec[:target]}× #{label}"[0, 100])
            end
          end
        end
      elsif active.size >= Engine::Quests::MAX_ACTIVE
        container.text_display(content: '-# Your quest list is full. Claim or drop one to take more of Berry\'s errands.')
      end

      if active.any?
        container.row do |row|
          row.string_select(custom_id: "eros:parlour:abandon:#{owner_id}", placeholder: 'Drop a quest…',
                            min_values: 1, max_values: 1) do |menu|
            active.each do |row_q|
              spec = Engine::Quests.quest(row_q['key'])
              done, target = Engine::Quests.progress(player, row_q)
              menu.option(label: "#{spec[:name]} (#{done}/#{target})"[0, 100], value: row_q['key'])
            end
          end
        end
      end
    end

    def handle(event, action, key)
      player = ErosHelpers.require_player(event) or return
      if Eros.encounter_for(player)
        show(event)
        return
      end

      result = action == 'buy' ? Engine::Marks.buy!(player, key) : Engine::Marks.remove!(player, key)
      news = result[:ok] ? player.check_progress! : []
      show(event, notice: ([result[:message]] + news).join("\n"))
    end

    def handle_quest(event, action, key)
      player = ErosHelpers.require_player(event) or return
      return show(event) if Eros.encounter_for(player)

      result =
        case action
        when 'quest' then Engine::Quests.accept!(player, key)
        when 'claim' then Engine::Quests.claim!(player, key)
        when 'abandon' then Engine::Quests.abandon!(player, key)
        end
      lines = [result[:message]] + Array(result[:news])
      show(event, notice: lines.join("\n"))
    end

    string_select(custom_id: /^eros:parlour:(buy|remove):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      action = event.custom_id[/\Aeros:parlour:(buy|remove):\d+\z/, 1]
      Commands::Parlour.handle(event, action, Array(event.values).first.to_s)
    end

    string_select(custom_id: /^eros:parlour:(quest|abandon):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      action = event.custom_id[/\Aeros:parlour:(quest|abandon):\d+\z/, 1]
      Commands::Parlour.handle_quest(event, action, Array(event.values).first.to_s)
    end

    button(custom_id: /^eros:parlour:claim:[a-z_]+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      key = event.custom_id[/\Aeros:parlour:claim:([a-z_]+):\d+\z/, 1]
      Commands::Parlour.handle_quest(event, 'claim', key)
    end

    button(custom_id: /^eros:parlour:view:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Parlour.show(event)
    end

    application_command(:parlour) { |event| Commands::Parlour.show(event) }

    command(:parlour, description: "Visit Syn & Berry's: Syn's tattoos and piercings, and Berry's quests") do |event|
      Commands::Parlour.show(event)
      nil
    end
  end
end
