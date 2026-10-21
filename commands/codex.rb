# frozen_string_literal: true

module Commands
  module Codex
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0x6b4a8b

    module_function

    def show(event, notice: nil)
      player = ErosHelpers.require_player(event) or return
      entries = Engine::Codex.entries(player)
      unlocked = entries.select { |e| e[:unlocked] }
      locked = entries.reject { |e| e[:unlocked] }

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: "## 📖 Delver's Journal — #{player.display_name}\n" \
                                'Fragments of the tower\'s truth, earned by living in it. Nothing here is bought; ' \
                                'every page is something you have done, seen, or survived.')
        c.text_display(content: notice) if notice
        c.text_display(content: "-# Fragments recovered: **#{unlocked.size}/#{entries.size}**")

        if unlocked.any?
          c.row do |row|
            row.string_select(
              custom_id: "eros:codex:pick:#{event.user.id}",
              placeholder: 'Read a fragment…',
              min_values: 1,
              max_values: 1
            ) do |menu|
              unlocked.first(25).each do |e|
                menu.option(label: "#{e[:emoji]} #{e[:title]}"[0, 100], value: e[:key],
                            description: 'Recovered fragment')
              end
            end
          end
        end

        if locked.any?
          lines = locked.map { |e| "🔒 **#{e[:title]}** — #{e[:hint]}" }
          c.text_display(content: lines.join("\n"))
        end

        c.row do |row|
          row.button(label: '🍓 Talk to Berry', style: :secondary, custom_id: "eros:talk:berry:#{event.user.id}")
          row.button(label: '🖤 Talk to Syn', style: :secondary, custom_id: "eros:talk:syn:#{event.user.id}")
          row.button(label: '🍓 Quest Board', style: :secondary, custom_id: "eros:quests:view:#{event.user.id}")
        end
      end
    end

    def read(event, key)
      player = ErosHelpers.require_player(event) or return
      entry = Engine::Codex.find(player, key)
      notice =
        if entry && entry[:unlocked]
          "### #{entry[:emoji]} #{entry[:title]}\n#{entry[:text]}"
        else
          'That page is still blank. Earn it first.'
        end
      show(event, notice: notice)
    end

    application_command(:codex) { |event| Commands::Codex.show(event) }

    command(:codex, aliases: %i[journal lore], description: "Your delver's journal: lore fragments earned in the tower") do |event|
      Commands::Codex.show(event)
    end

    button(custom_id: /^eros:codex:view:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Codex.show(event)
    end

    string_select(custom_id: /^eros:codex:pick:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Codex.read(event, Array(event.values).first.to_s)
    end
  end
end
