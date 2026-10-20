# frozen_string_literal: true

module Commands
  module Transformation
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0xb57edc
    PER_PAGE = 5
    CLEAR_WORDS = %w[clear none human off].freeze

    module_function

    def show(event, notice: nil, page: 0)
      player = ErosHelpers.require_player(event) or return
      unless player.transformations_supported?
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'Hybrid forms need a database update — ask the operator to run `bundle exec rake db:migrate`.')
        end
        return
      end

      news = player.check_progress!
      forms = Engine::TransformationSystem.visible(player).to_a
      owned = player.unlocked_transformations
      active_key = player.active_transformation_key
      pages = [(forms.size.to_f / PER_PAGE).ceil, 1].max
      page = page.to_i.clamp(0, pages - 1)
      slice = forms.slice(page * PER_PAGE, PER_PAGE) || []

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(
          content: "## Hybrid Forms — #{player.display_name}\n" \
                   "_#{owned.size}/#{forms.size} unlocked · current form: **#{player.active_transformation_name || 'Human'}**_"
        )
        c.text_display(content: notice) if notice
        if (form = Engine::TransformationSystem.active(player))
          c.text_display(
            content: "**#{form[:name]}** — _#{form[:description].to_s[0, 160]}_\n" \
                     "**Appearance** #{form[:appearance].join(' · ')[0, 200]}\n" \
                     "**Effects** #{Engine::TransformationSystem.effect_lines(form).join(' · ')[0, 200]}"
          )
        end
        if active_key
          stage = Engine::TransformationSystem.deepen_stage(player, active_key)
          chosen = Engine::TransformationSystem.mutations_for(player, active_key)
          c.text_display(
            content: "🧬 **Deepening** — Stage **#{stage}**/3" \
                     "#{chosen.any? ? " · mutations: #{chosen.map { |m| Engine::TransformationSystem::MUTATIONS[m][:name] }.join(', ')}" : ''}\n" \
                     '-# Win fights or satisfy monsters in this form to deepen it.'
          )
          if Engine::TransformationSystem.pending_mutations(player, active_key).positive?
            c.row do |row|
              row.string_select(custom_id: "eros:mutation:pick:#{event.user.id}", placeholder: 'Your form stirs — choose a mutation…',
                                min_values: 1, max_values: 1) do |menu|
                Engine::TransformationSystem.mutation_choices(player, active_key).each do |m|
                  spec = Engine::TransformationSystem::MUTATIONS[m]
                  menu.option(label: spec[:name], value: m, description: spec[:description][0, 100])
                end
              end
            end
          end
        end
        c.separator(divider: true, spacing: :small)

        lines = slice.map do |key, t|
          if owned.include?(key)
            marker = key == active_key ? '**▶**' : '◆'
            "#{marker} **#{t[:name]}** _(#{t[:group]})_ — #{Engine::TransformationSystem.effect_lines(t).join(' · ')}"
          else
            "◇ #{t[:name]} _(#{t[:group]})_ — _#{Engine::TitleSystem.progress_text(player, t[:requirement])}_"
          end[0, 220]
        end
        c.text_display(content: lines.empty? ? '_No forms available with your current content options._' : lines.join("\n"))
        if news.any?
          shown = news.first(3)
          shown << "-# …and #{news.size - 3} more unlocks — see `/titles` and `/achievements`." if news.size > 3
          c.text_display(content: shown.join("\n"))
        end

        owned_here = slice.map(&:first).select { |k| owned.include?(k) }
        if owned_here.any? || active_key
          c.row do |row|
            row.string_select(
              custom_id: "eros:hybrid:pick:#{page}:#{event.user.id}",
              placeholder: owned_here.any? ? 'Take a form from this page…' : 'No forms unlocked on this page',
              min_values: 1,
              max_values: 1
            ) do |menu|
              menu.option(label: 'Human (no hybrid form)', value: 'human', default: active_key.nil?)
              owned_here.each do |key|
                t = Engine::TransformationSystem.get(key)
                menu.option(label: t[:name], value: key, description: t[:description][0, 100], default: key == active_key)
              end
            end
          end
        else
          c.text_display(content: '-# No forms unlocked on this page yet. Forms are earned through events and submissions.')
        end

        combo = Engine::TransformationSystem.chimera_combo(player)
        if combo
          form = Engine::TransformationSystem.chimera_form(player)
          c.separator(divider: true, spacing: :small)
          c.text_display(
            content: "🧬 **Your Chimera — #{form[:name]}**\n" \
                     "_#{form[:description].to_s[0, 160]}_\n" \
                     "**Appearance** #{form[:appearance].join(' · ')[0, 200]}\n" \
                     "**Effects** #{Engine::TransformationSystem.effect_lines(form).join(' · ')[0, 200]}"
          )
          if active_key != Engine::TransformationSystem::CHIMERA_KEY
            c.row do |row|
              row.button(label: 'Take your Chimera', style: :primary,
                         custom_id: "eros:chimera:take:#{event.user.id}")
            end
          end
        end

        if owned.size >= 2
          pick_a = player.tracker_hash['chimera_pick_primary'].to_s
          pick_b = player.tracker_hash['chimera_pick_secondary'].to_s
          name_of = ->(k) { Engine::TransformationSystem.get(k)&.dig(:name) || '—' }
          c.separator(divider: true, spacing: :small)
          c.text_display(
            content: "**Fuse a Chimera** (#{Engine::TransformationSystem::FUSION_COST} LP) — primary **#{name_of.call(pick_a)}** " \
                     "+ secondary **#{name_of.call(pick_b)}**\n" \
                     '-# The primary keeps its full effects and combat special; the secondary echoes at half strength.'
          )
          c.row do |row|
            row.string_select(custom_id: "eros:chimera:primary:#{event.user.id}", placeholder: 'Choose the primary form…',
                              min_values: 1, max_values: 1) do |menu|
              owned.first(25).each do |key|
                t = Engine::TransformationSystem.get(key)
                menu.option(label: t[:name], value: key, default: key == pick_a)
              end
            end
          end
          c.row do |row|
            row.string_select(custom_id: "eros:chimera:secondary:#{event.user.id}", placeholder: 'Choose the secondary form…',
                              min_values: 1, max_values: 1) do |menu|
              owned.first(25).each do |key|
                t = Engine::TransformationSystem.get(key)
                menu.option(label: t[:name], value: key, default: key == pick_b)
              end
            end
          end
          c.row do |row|
            row.button(label: "Fuse them (#{Engine::TransformationSystem::FUSION_COST} LP)", style: :success,
                       custom_id: "eros:chimera:fuse:#{event.user.id}")
          end
        end

        Commands::Profile.attach_pager(c, 'eros:hybrid:page', page, pages, event.user.id) if pages > 1
        Commands::Profile.attach_nav(c, event.user.id, :hybrids)
      end
    end

    def set_by_name(event, raw)
      player = ErosHelpers.require_player(event) or return
      query = raw.to_s.strip
      return show(event) if query.empty?

      if query.downcase.start_with?('fuse')
        names = query[4..].to_s.split(/\s*(?:\+|,|\band\b)\s*/).map(&:strip).reject(&:empty?)
        keys = names.map { |n| Engine::TransformationSystem.find(n) }
        if keys.size == 2 && keys.all?
          result = Engine::TransformationSystem.fuse!(player, keys[0], keys[1])
          return show(event, notice: result[:message])
        end

        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'Fuse two unlocked forms: `e,transformation fuse Kitten + Slimekin`.')
        end
        return
      end

      if CLEAR_WORDS.include?(query.downcase)
        result = player.select_transformation!(nil)
      else
        key = Engine::TransformationSystem.find(query)
        unless key
          ErosUI.reply_v2(event, ephemeral: true) { |c| c.text_display(content: "No hybrid form named **#{query}**.") }
          return
        end
        result = player.select_transformation!(key)
      end
      show(event, notice: result[:message])
    end

    string_select(custom_id: /^eros:mutation:pick:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      result = Engine::TransformationSystem.choose_mutation!(player, Array(event.values).first.to_s)
      Commands::Transformation.show(event, notice: result[:message])
    end

    string_select(custom_id: /^eros:chimera:(primary|secondary):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      which = event.custom_id[/\Aeros:chimera:(primary|secondary):\d+\z/, 1]
      player.set_tracker!("chimera_pick_#{which}", Array(event.values).first.to_s)
      Commands::Transformation.show(event, notice: "#{which.capitalize} form chosen. Pick the other half, then **Fuse them**.")
    end

    button(custom_id: /^eros:chimera:fuse:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      result = Engine::TransformationSystem.fuse!(player, player.tracker_hash['chimera_pick_primary'].to_s,
                                                  player.tracker_hash['chimera_pick_secondary'].to_s)
      Commands::Transformation.show(event, notice: result[:message])
    end

    button(custom_id: /^eros:chimera:take:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      result = player.select_transformation!(Engine::TransformationSystem::CHIMERA_KEY)
      Commands::Transformation.show(event, notice: result[:message])
    end

    button(custom_id: /^eros:hybrid:view:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Transformation.show(event)
    end

    button(custom_id: /^eros:hybrid:page:-?\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      page = event.custom_id[/\Aeros:hybrid:page:(-?\d+):\d+\z/, 1].to_i
      Commands::Transformation.show(event, page: page)
    end

    string_select(custom_id: /^eros:hybrid:pick:\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      page = event.custom_id[/\Aeros:hybrid:pick:(\d+):\d+\z/, 1].to_i
      choice = Array(event.values).first.to_s
      result = player.select_transformation!(choice == 'human' ? nil : choice)
      Commands::Transformation.show(event, notice: result[:message], page: page)
    end

    application_command(:transformation) do |event|
      Commands::Transformation.set_by_name(event, event.options['name'].to_s)
    end

    command(:transformation, aliases: %i[hybrid transform],
                             description: 'View hybrid forms, or take one: e,transformation <name|clear>') do |event, *parts|
      Commands::Transformation.set_by_name(event, parts.join(' '))
      nil
    end
  end
end
