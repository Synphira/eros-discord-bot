# frozen_string_literal: true

module Commands
  module Codex
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0x6b4a8b
    EVENTS_PER_PAGE = 12

    module_function

    # The journal opens on a hub now: Fragments or the Event Index,
    # so future sections (residents, monsters...) get a door of their
    # own instead of a longer and longer single page.
    def show(event, notice: nil)
      player = ErosHelpers.require_player(event) or return
      milestone_lines = Engine::Codex.claim_event_milestones!(player)
      notice = ([notice].compact + milestone_lines).join("\n")
      notice = nil if notice.empty?
      fragments = Engine::Codex.entries(player)
      recovered = fragments.count { |e| e[:unlocked] }
      catalog = Engine::Codex.event_catalog(player)
      seen = catalog.count { |e| e[:seen].positive? }

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: "## 📖 Delver's Journal — #{player.display_name}")
        c.text_display(content: notice) if notice
        c.text_display(
          content: 'Fragments of the tower\'s truth, earned by living in it; and an index of every ' \
                   'strange thing it has done to you. Nothing here is bought.'
        )
        c.section do |section|
          section.text_display(
            content: "**Fragments** — the tower's truth, recovered piece by piece.\n" \
                     "-# Recovered: **#{recovered}/#{fragments.size}**"
          )
          section.button(label: 'Read Fragments', style: :primary, custom_id: "eros:codex:fragments:#{event.user.id}")
        end
        c.section do |section|
          section.text_display(
            content: "**Event Index** — every random event, fetish encounter, and timed ordeal in the " \
                     "tower, and how often each has found you.\n" \
                     "-# Experienced: **#{seen}/#{catalog.size}**"
          )
          section.button(label: 'Browse Events', style: :primary, custom_id: "eros:codex:events:0:#{event.user.id}")
        end
        c.text_display(content: '-# Event counts accrue from when the index opened — earlier sightings are fond memories only.')
      end
    end

    def fragments(event, notice: nil)
      player = ErosHelpers.require_player(event) or return
      entries = Engine::Codex.entries(player)
      unlocked = entries.select { |e| e[:unlocked] }
      locked = entries.reject { |e| e[:unlocked] }

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: "## 📖 Delver's Journal — Fragments\n" \
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
          row.button(label: '◀ Journal', style: :primary, custom_id: "eros:codex:view:#{event.user.id}")
        end
      end
    end

    def events(event, page: 0)
      player = ErosHelpers.require_player(event) or return
      milestone_lines = Engine::Codex.claim_event_milestones!(player)
      catalog = Engine::Codex.event_catalog(player)
      seen = catalog.count { |e| e[:seen].positive? }
      pages = [(catalog.size.to_f / EVENTS_PER_PAGE).ceil, 1].max
      page = page.to_i % pages
      slice = catalog.slice(page * EVENTS_PER_PAGE, EVENTS_PER_PAGE) || []

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: "## 📖 Event Index — #{seen}/#{catalog.size} experienced")
        c.text_display(content: milestone_lines.join("\n")) if milestone_lines.any?
        lines = slice.map do |e|
          if e[:seen].positive?
            "✓ **#{e[:name]}** — experienced ×#{e[:seen]}"
          else
            "🔒 **???** — #{e[:hint]}"
          end
        end
        c.text_display(content: lines.join("\n"))
        c.row do |row|
          row.button(label: '◀ Prev', style: :secondary, custom_id: "eros:codex:events:#{page - 1}:#{event.user.id}")
          row.button(label: "Page #{page + 1}/#{pages}", style: :secondary,
                     custom_id: "eros:codex:events:info:#{event.user.id}", disabled: true)
          row.button(label: 'Next ▶', style: :secondary, custom_id: "eros:codex:events:#{page + 1}:#{event.user.id}")
        end
        c.row do |row|
          row.button(label: '◀ Journal', style: :primary, custom_id: "eros:codex:view:#{event.user.id}")
        end
        c.text_display(content: '-# The tower holds more than this page. The blank ones are still out there, waiting.')
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
      fragments(event, notice: notice)
    end

    application_command(:codex) { |event| Commands::Codex.show(event) }

    command(:codex, aliases: %i[journal lore], description: "Your delver's journal: lore fragments earned in the tower") do |event|
      Commands::Codex.show(event)
    end

    button(custom_id: /^eros:codex:view:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Codex.show(event)
    end

    button(custom_id: /^eros:codex:fragments:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Codex.fragments(event)
    end

    button(custom_id: /^eros:codex:events:-?\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      page = event.custom_id[/\Aeros:codex:events:(-?\d+):\d+\z/, 1]
      Commands::Codex.events(event, page: page.to_i)
    end

    string_select(custom_id: /^eros:codex:pick:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Codex.read(event, Array(event.values).first.to_s)
    end
  end
end
