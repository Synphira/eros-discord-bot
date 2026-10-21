# frozen_string_literal: true

module Commands
  module Conversations
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOURS = { 'berry' => 0xe14b7a, 'syn' => 0x9b2d6f }.freeze

    module_function

    def show(event, person = 'berry', notice: nil)
      player = ErosHelpers.require_player(event) or return
      person = Engine::Conversations.normalize_person(person)
      spec = Engine::Conversations.person(person)

      if Eros.encounter_for(player)
        ErosUI.reply_v2(event, ephemeral: true, with_actions: :combat) do |c|
          c.text_display(content: 'Neither fairy is starting a conversation mid-fight. Deal with the monster first.')
        end
        return
      end

      topics = Engine::Conversations.topics_for(player, person)
      unlocked = topics.select { |topic| topic[:unlocked] }
      locked = topics.reject { |topic| topic[:unlocked] }

      ErosUI.reply_v2(event, colour: COLOURS[person]) do |c|
        c.text_display(content: "## #{spec[:emoji]} #{spec[:heading]} — #{player.display_name}\n#{spec[:intro]}")
        c.text_display(content: notice) if notice

        c.row do |row|
          row.string_select(
            custom_id: "eros:talk:topic:#{person}:#{event.user.id}",
            placeholder: "Ask #{spec[:name]} about…",
            min_values: 1,
            max_values: 1
          ) do |menu|
            unlocked.first(25).each do |topic|
              menu.option(label: topic[:label][0, 100], value: topic[:key],
                          description: topic[:question][0, 100])
            end
          end
        end

        if locked.any?
          lines = locked.map do |topic|
            "🔒 **#{topic[:label]}** — #{Engine::Conversations.unlock_hint(player, topic)}"
          end
          c.text_display(content: lines.join("\n"))
        end

        c.row do |row|
          row.button(label: '🍓 Talk to Berry', style: person == 'berry' ? :primary : :secondary,
                     custom_id: "eros:talk:berry:#{event.user.id}", disabled: person == 'berry')
          row.button(label: '🖤 Talk to Syn', style: person == 'syn' ? :primary : :secondary,
                     custom_id: "eros:talk:syn:#{event.user.id}", disabled: person == 'syn')
        end
        c.row do |row|
          row.button(label: '🍓 Quest Board', style: :secondary, custom_id: "eros:quests:view:#{event.user.id}")
          row.button(label: 'Parlour', style: :secondary, custom_id: "eros:parlour:view:#{event.user.id}")
        end
      end
    end

    def ask(event, person, key)
      player = ErosHelpers.require_player(event) or return
      person = Engine::Conversations.normalize_person(person)
      result = Engine::Conversations.answer(player, person, key)
      spec = Engine::Conversations.person(person)

      notice =
        if result[:ok]
          "**#{spec[:name]} on #{result[:topic][:label]}**\n#{result[:text]}"
        else
          result[:message]
        end
      show(event, person, notice: notice)
    end

    button(custom_id: /^eros:talk:(berry|syn):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      person = event.custom_id[/\Aeros:talk:(berry|syn):\d+\z/, 1]
      Commands::Conversations.show(event, person)
    end

    string_select(custom_id: /^eros:talk:topic:(berry|syn):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      person = event.custom_id[/\Aeros:talk:topic:(berry|syn):\d+\z/, 1]
      Commands::Conversations.ask(event, person, Array(event.values).first.to_s)
    end
  end
end
