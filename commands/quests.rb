# frozen_string_literal: true

module Commands
  module Quests
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0xe14b7a

    INTRO = "## 🍓 Berry's Quest Board\n" \
            "_Pinned up beside the shop counter, in Berry's round, cheerful handwriting, with little hearts " \
            "dotting every i. Berry herself hovers over it — a strawberry-bright fairy with a smile like " \
            "sunrise and a grip like ownership — quill already poised over your name._\n" \
            "_\"Errands, sugar! I run the shop, my wife Syn runs the parlour bench, and you run your pretty " \
            "legs off for both of us. Finish one, come back, and I'll pay you in Lust Points and praise. " \
            "Eyes on the board while my wife works, though. She's mine — the quests are yours.\"_"

    module_function

    def show(event, notice: nil)
      player = ErosHelpers.require_player(event) or return

      if Eros.encounter_for(player)
        ErosUI.reply_v2(event, ephemeral: true, with_actions: :combat) do |c|
          c.text_display(content: 'Berry will not hand out errands mid-fight. Deal with the monster first — she is taking bets.')
        end
        return
      end

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: INTRO)
        c.text_display(content: notice) if notice
        c.text_display(
          content: "#{Engine::Quests.board_lines(player).join("\n")}\n" \
                   "-# Quests completed for Berry: **#{Engine::Quests.completed(player)}** · **LP** #{player.lp}"
        )

        active = Engine::Quests.active(player)
        ready = active.select { |row| Engine::Quests.complete?(player, row) }
        if ready.any?
          c.row do |row|
            ready.first(5).each do |row_q|
              spec = Engine::Quests.quest(row_q['key'])
              row.button(label: "Claim: #{spec[:name]} (#{spec[:reward]} LP)", style: :success,
                         custom_id: "eros:quests:claim:#{row_q['key']}:#{event.user.id}")
            end
          end
        end

        offers = Engine::Quests.offers(player)
        if offers.any? && active.size < Engine::Quests::MAX_ACTIVE
          c.row do |row|
            row.string_select(custom_id: "eros:quests:take:#{event.user.id}", placeholder: 'Take a quest from Berry…',
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
          c.text_display(content: '-# Your quest list is full. Claim or drop one to take more of Berry\'s errands.')
        end

        if active.any?
          c.row do |row|
            row.string_select(custom_id: "eros:quests:abandon:#{event.user.id}", placeholder: 'Drop a quest…',
                              min_values: 1, max_values: 1) do |menu|
              active.each do |row_q|
                spec = Engine::Quests.quest(row_q['key'])
                done, target = Engine::Quests.progress(player, row_q)
                menu.option(label: "#{spec[:name]} (#{done}/#{target})"[0, 100], value: row_q['key'])
              end
            end
          end
        end

        c.row do |row|
          row.button(label: '🍓 Talk to Berry', style: :primary, custom_id: "eros:talk:berry:#{event.user.id}")
          row.button(label: '🖤 Talk to Syn', style: :secondary, custom_id: "eros:talk:syn:#{event.user.id}")
        end
      end
    end

    def handle(event, action, key)
      player = ErosHelpers.require_player(event) or return
      return show(event) if Eros.encounter_for(player)

      result =
        case action
        when 'take' then Engine::Quests.accept!(player, key)
        when 'claim' then Engine::Quests.claim!(player, key)
        when 'abandon' then Engine::Quests.abandon!(player, key)
        end
      lines = [result[:message]] + Array(result[:news])
      show(event, notice: lines.join("\n"))
    end

    string_select(custom_id: /^eros:quests:(take|abandon):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      action = event.custom_id[/\Aeros:quests:(take|abandon):\d+\z/, 1]
      Commands::Quests.handle(event, action, Array(event.values).first.to_s)
    end

    button(custom_id: /^eros:quests:claim:[a-z_]+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      key = event.custom_id[/\Aeros:quests:claim:([a-z_]+):\d+\z/, 1]
      Commands::Quests.handle(event, 'claim', key)
    end

    button(custom_id: /^eros:quests:view:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Quests.show(event)
    end

    application_command(:quests) { |event| Commands::Quests.show(event) }

    command(:quests, description: "Berry's quest board: errands for Lust Points at Syn & Berry's") do |event|
      Commands::Quests.show(event)
      nil
    end
  end
end
