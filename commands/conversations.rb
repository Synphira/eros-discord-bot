# frozen_string_literal: true

module Commands
  module Conversations
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOURS = { 'berry' => 0xe14b7a, 'syn' => 0x9b2d6f, 'covar' => 0x5c1a4a }.freeze

    module_function

    def show(event, person = 'berry', notice: nil)
      player = ErosHelpers.require_player(event) or return
      person = Engine::Conversations.normalize_person(person)
      spec = Engine::Conversations.person(person)

      if Eros.encounter_for(player)
        ErosUI.reply_v2(event, ephemeral: true, with_actions: :combat) do |c|
          c.text_display(content: 'Nobody is starting a conversation mid-fight. Deal with the monster first.')
        end
        return
      end

      # The reveal: after a first return from floor 35, Syn delivers it in
      # person the next time this delver talks to her.
      if person == 'syn' && Engine::Conversations.reveal_ready?(player)
        Engine::Conversations.note_revealed!(player)
        notice = [Engine::Conversations::REVEAL_SCENE, notice].compact.join("\n\n")
      end

      topics = Engine::Conversations.topics_for(player, person)
      unlocked = topics.select { |topic| topic[:unlocked] }
      locked = topics.reject { |topic| topic[:unlocked] }

      ErosUI.reply_v2(event, colour: COLOURS[person]) do |c|
        c.text_display(content: "## #{spec[:emoji]} #{spec[:heading]} — #{player.display_name}\n#{spec[:intro]}")
        c.text_display(content: notice) if notice
        if person != 'covar' && (regard = Engine::Regard.line(player, person == 'syn' ? :parlour : :shop))
          c.text_display(content: regard)
        end
        if person != 'covar' && Engine::Conversations.temple_revealed?(player)
          c.text_display(content: '-# You know what this place is now. Their answers have changed — ask again.')
        end
        if person != 'covar' && topics.any? { |t| t[:boss] && t[:unlocked] && Engine::Conversations.boss_satisfied?(player, t) }
          c.text_display(content: '-# They especially want to hear about the bosses you **satisfied**, not just beat.')
        end

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

        if person == 'covar'
          heard = Engine::Conversations.covar_topics_heard(player).size
          if Engine::Conversations.covar_sex_unlocked?(player)
            c.text_display(
              content: '_Covar has stopped pretending this is only conversation. "You know me well enough ' \
                       'now, delver. If you\'re wound too tight to think, my bed\'s behind the curtain — ' \
                       'I\'ll drain that lust right out of you. No defiance, no charge. Call it shop ' \
                       'hospitality."_'
            )
          else
            c.text_display(
              content: "-# Get to know Covar: **#{heard}/#{Engine::Conversations::COVAR_SEX_TOPICS_REQUIRED}** " \
                       'conversations heard. He likes to be courted before he is climbed.'
            )
          end
          c.row do |row|
            row.button(label: '🛏️ Go to bed with Covar', style: :danger, custom_id: "eros:cshop:bed:#{event.user.id}")
            row.button(label: '◀ Cursed Shop', style: :secondary, custom_id: "eros:cshop:open:#{event.user.id}")
            row.button(label: 'Shop', style: :secondary, custom_id: "eros:shop:cat:weapon:#{event.user.id}")
          end
        else
          c.row do |row|
            row.button(label: '🍓 Talk to Berry', style: person == 'berry' ? :primary : :secondary,
                       custom_id: "eros:talk:berry:#{event.user.id}", disabled: person == 'berry')
            row.button(label: '🖤 Talk to Syn', style: person == 'syn' ? :primary : :secondary,
                       custom_id: "eros:talk:syn:#{event.user.id}", disabled: person == 'syn')
          end
          c.row do |row|
            row.button(label: '🍓 Quest Board', style: :secondary, custom_id: "eros:quests:view:#{event.user.id}")
            row.button(label: 'Parlour', style: :secondary, custom_id: "eros:parlour:view:#{event.user.id}")
            row.button(label: '📖 Journal', style: :secondary, custom_id: "eros:codex:view:#{event.user.id}")
          end
        end
      end
    end

    def ask(event, person, key)
      player = ErosHelpers.require_player(event) or return
      person = Engine::Conversations.normalize_person(person)
      was_unlocked = person != 'covar' || Engine::Conversations.covar_sex_unlocked?(player)
      result = Engine::Conversations.answer(player, person, key)
      spec = Engine::Conversations.person(person)
      Engine::Conversations.note_covar_topic!(player, key) if person == 'covar' && result[:ok]

      notice =
        if result[:ok]
          text = "**#{spec[:name]} on #{result[:topic][:label]}**\n#{result[:text]}"
          if person == 'covar' && !was_unlocked && Engine::Conversations.covar_sex_unlocked?(player)
            text += "\n\n_Covar's grin turns slow and certain. \"There it is. You know me now, delver — " \
                    'well enough. If that lust ever gets too loud, my bed is behind the curtain. Press ' \
                    '**🛏️ Go to bed with Covar** and I\'ll take care of it. All of it."_'
          end
          text
        else
          result[:message]
        end
      show(event, person, notice: notice)
    end

    button(custom_id: /^eros:talk:(berry|syn|covar):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      person = event.custom_id[/\Aeros:talk:(berry|syn|covar):\d+\z/, 1]
      Commands::Conversations.show(event, person)
    end

    string_select(custom_id: /^eros:talk:topic:(berry|syn|covar):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      person = event.custom_id[/\Aeros:talk:topic:(berry|syn|covar):\d+\z/, 1]
      Commands::Conversations.ask(event, person, Array(event.values).first.to_s)
    end
  end
end
