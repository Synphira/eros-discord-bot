# frozen_string_literal: true

module Commands
  module Parlour
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0x9b2d6f

    module_function

    def show(event, notice: nil)
      player = ErosHelpers.require_player(event) or return

      if Eros.encounter_for(player)
        ErosUI.reply_v2(event, ephemeral: true, with_actions: :combat) do |c|
          c.text_display(content: 'Vex will not ink a delver mid-fight. Deal with the monster first.')
        end
        return
      end

      owned = Engine::Marks.owned(player)
      offers = Engine::Marks.available(player)
      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(
          content: "## Madame Vex's Parlour\n" \
                   "_A succubus with ink-stained fingertips lounges on a velvet bench, surrounded by gold rings and " \
                   "bottles of glowing ink. \"Something permanent, darling? My work never fades. Not after defeat, not " \
                   "after a new cycle, not ever.\"_"
        )
        c.text_display(content: notice) if notice
        lines = owned.map { |k| "◆ #{Engine::Marks.label(k)} — _#{Engine::Marks::MARKS[k][:perk]}_" }
        c.text_display(
          content: "**Your marks** #{owned.size}/#{Engine::Marks::MAX_MARKS} · **LP** #{player.lp}\n" \
                   "#{lines.empty? ? '_Your skin is still bare._' : lines.join("\n")}"
        )
        c.separator(divider: true, spacing: :small)

        if offers.any? && owned.size < Engine::Marks::MAX_MARKS
          c.row do |row|
            row.string_select(custom_id: "eros:parlour:buy:#{event.user.id}", placeholder: 'Choose a design…',
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
          c.text_display(content: '-# Vex has nothing new for you right now. More designs unlock with themes in `/options`.')
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

    string_select(custom_id: /^eros:parlour:(buy|remove):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      action = event.custom_id[/\Aeros:parlour:(buy|remove):\d+\z/, 1]
      Commands::Parlour.handle(event, action, Array(event.values).first.to_s)
    end

    button(custom_id: /^eros:parlour:view:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Parlour.show(event)
    end

    application_command(:parlour) { |event| Commands::Parlour.show(event) }

    command(:parlour, description: "Visit Madame Vex's parlour for permanent tattoos and piercings") do |event|
      Commands::Parlour.show(event)
      nil
    end
  end
end
