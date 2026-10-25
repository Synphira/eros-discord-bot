# frozen_string_literal: true

module Commands
  module Conversations
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOURS = {
      'berry' => 0xe14b7a, 'syn' => 0x9b2d6f, 'covar' => 0x5c1a4a,
      'vex' => 0x6b4c7a, 'pip' => 0x3d7a4a, 'nectar' => 0xc4a35a, 'cartographer' => 0x4a5568,
      'broodmother' => 0x8b4513, 'queen' => 0x9b2d6f, 'king' => 0xb33a3a,
      'dryad' => 0x2e7d4f, 'lich' => 0x5b7c99, 'alpha' => 0x8b6914, 'eros' => 0xb01030
    }.freeze

    PERSON_RE = Engine::Conversations::PEOPLE.keys.map { |k| Regexp.escape(k) }.join('|').freeze
    CAT_RE = Engine::Conversations::CATEGORIES.map { |c| Regexp.escape(c[:key]) }.join('|').freeze

    module_function

    def colour_for(person)
      COLOURS[Engine::Conversations.normalize_person(person)] || 0x8b1a4a
    end

    # Entry: category chooser (or single-category jump).
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

      if person == 'syn' && Engine::Conversations.reveal_ready?(player)
        Engine::Conversations.note_revealed!(player)
        notice = [Engine::Conversations::REVEAL_SCENE, notice].compact.join("\n\n")
      end

      categories = Engine::Conversations.categories_for(player, person)
      if categories.size == 1
        return show_category(event, person, categories.first[:key], notice: notice)
      end

      ErosUI.reply_v2(event, colour: colour_for(person)) do |c|
        header(c, player, person, spec, notice)
        c.text_display(content: '_Pick a subject. Then ask._')
        c.row do |row|
          categories.each do |cat|
            row.button(label: cat[:label], style: :primary,
                       custom_id: "eros:talk:cat:#{person}:#{cat[:key]}:#{event.user.id}")
          end
        end
        nav_row(c, event, player, person)
      end
    end

    def show_category(event, person, category, notice: nil)
      player = ErosHelpers.require_player(event) or return
      person = Engine::Conversations.normalize_person(person)
      category = category.to_s
      unless Engine::Conversations::CATEGORIES.any? { |c| c[:key] == category }
        return show(event, person, notice: notice)
      end

      spec = Engine::Conversations.person(person)
      topics = Engine::Conversations.topics_in_category(player, person, category)
      unlocked = topics.select { |t| t[:unlocked] }
      locked = topics.reject { |t| t[:unlocked] }
      cat_label = Engine::Conversations.category_label(category)

      ErosUI.reply_v2(event, colour: colour_for(person)) do |c|
        header(c, player, person, spec, notice)
        c.text_display(content: "### #{cat_label}")

        if unlocked.any?
          c.row do |row|
            row.string_select(
              custom_id: "eros:talk:topic:#{person}:#{category}:#{event.user.id}",
              placeholder: "Ask #{spec[:name]} about…",
              min_values: 1,
              max_values: 1
            ) do |menu|
              unlocked.first(25).each do |topic|
                desc = (topic[:question] || topic[:label]).to_s
                menu.option(label: topic[:label][0, 100], value: topic[:key],
                            description: desc[0, 100])
              end
            end
          end
        else
          c.text_display(content: '_Nothing unlocked in this subject yet._')
        end

        if locked.any?
          lines = locked.first(12).map do |topic|
            "🔒 **#{topic[:label]}** — #{Engine::Conversations.unlock_hint(player, topic)}"
          end
          c.text_display(content: lines.join("\n"))
        end

        covar_bed_note(c, player, person)

        c.row do |row|
          row.button(label: '◀ Subjects', style: :secondary,
                     custom_id: "eros:talk:#{person}:#{event.user.id}")
        end
        nav_row(c, event, player, person)
      end
    end

    def ask(event, person, category, key)
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

      cat = (result.dig(:topic, :category) || category || 'general').to_s
      show_category(event, person, cat, notice: notice)
    end

    def header(c, player, person, spec, notice)
      c.text_display(content: "## #{spec[:emoji]} #{spec[:heading]} — #{player.display_name}\n#{spec[:intro]}")
      c.text_display(content: notice) if notice
      regard_ctx =
        if person == 'syn' then :parlour
        elsif person == 'berry' then :shop
        elsif person == 'covar' then :cursed
        end
      if regard_ctx && (regard = Engine::Regard.line(player, regard_ctx))
        c.text_display(content: regard)
      end
      if Engine::Conversations.fairy?(person) && Engine::Conversations.temple_revealed?(player)
        c.text_display(content: '-# You know what this place is now. Their answers have changed — ask again.')
      end
      if Engine::Conversations.fairy?(person) &&
         Engine::Conversations.topics_for(player, person).any? { |t| t[:boss] && t[:unlocked] && Engine::Conversations.boss_satisfied?(player, t) }
        c.text_display(content: '-# They especially want to hear about the bosses you **satisfied**, not just beat.')
      end
    end

    def covar_bed_note(c, player, person)
      return unless person == 'covar'

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
    end

    def nav_row(c, event, player, person)
      uid = event.user.id
      if person == 'covar'
        c.row do |row|
          row.button(label: '🛏️ Go to bed with Covar', style: :danger, custom_id: "eros:cshop:bed:#{uid}")
          row.button(label: '◀ Cursed Shop', style: :secondary, custom_id: "eros:cshop:open:#{uid}")
          row.button(label: 'Shop', style: :secondary, custom_id: "eros:shop:cat:weapon:#{uid}")
        end
      elsif Engine::Conversations.resident?(person)
        c.row do |row|
          row.button(label: '◀ Visit', style: :secondary, custom_id: "eros:resident:show:#{person}:#{uid}")
          row.button(label: 'Residents', style: :secondary, custom_id: "eros:residents:view:#{uid}")
        end
      elsif Engine::Conversations.clergy?(person)
        c.row do |row|
          row.button(label: '◀ Explore', style: :primary, custom_id: "eros:explore_path:#{uid}")
        end
      else
        c.row do |row|
          row.button(label: '🍓 Talk to Berry', style: person == 'berry' ? :primary : :secondary,
                     custom_id: "eros:talk:berry:#{uid}", disabled: person == 'berry')
          row.button(label: '🖤 Talk to Syn', style: person == 'syn' ? :primary : :secondary,
                     custom_id: "eros:talk:syn:#{uid}", disabled: person == 'syn')
        end
        c.row do |row|
          row.button(label: '🍓 Quest Board', style: :secondary, custom_id: "eros:quests:view:#{uid}")
          row.button(label: 'Parlour', style: :secondary, custom_id: "eros:parlour:view:#{uid}")
          row.button(label: '📖 Journal', style: :secondary, custom_id: "eros:codex:view:#{uid}")
        end
      end
    end

    button(custom_id: /^eros:talk:(#{PERSON_RE}):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      person = event.custom_id[/\Aeros:talk:(#{PERSON_RE}):\d+\z/, 1]
      Commands::Conversations.show(event, person)
    end

    button(custom_id: /^eros:talk:cat:(#{PERSON_RE}):(#{CAT_RE}):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      person, category = event.custom_id.match(/\Aeros:talk:cat:(#{PERSON_RE}):(#{CAT_RE}):\d+\z/).captures
      Commands::Conversations.show_category(event, person, category)
    end

    string_select(custom_id: /^eros:talk:topic:(#{PERSON_RE}):(#{CAT_RE}):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      person, category = event.custom_id.match(/\Aeros:talk:topic:(#{PERSON_RE}):(#{CAT_RE}):\d+\z/).captures
      Commands::Conversations.ask(event, person, category, Array(event.values).first.to_s)
    end
  end
end
