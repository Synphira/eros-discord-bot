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
        if (form = Engine::TransformationSystem.get(active_key))
          c.text_display(
            content: "**#{form[:name]}** — _#{form[:description]}_\n" \
                     "**Appearance** #{form[:appearance].join(' · ')}\n" \
                     "**Effects** #{Engine::TransformationSystem.effect_lines(form).join(' · ')}"
          )
        end
        c.separator(divider: true, spacing: :small)

        lines = slice.map do |key, t|
          if owned.include?(key)
            marker = key == active_key ? '**▶**' : '◆'
            "#{marker} **#{t[:name]}** _(#{t[:group]})_ — #{Engine::TransformationSystem.effect_lines(t).join(' · ')}"
          else
            "◇ #{t[:name]} _(#{t[:group]})_ — _#{Engine::TitleSystem.progress_text(player, t[:requirement])}_"
          end
        end
        c.text_display(content: lines.empty? ? '_No forms available with your current content options._' : lines.join("\n"))
        c.text_display(content: news.join("\n")) if news.any?

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

        Commands::Profile.attach_pager(c, 'eros:hybrid:page', page, pages, event.user.id) if pages > 1
        Commands::Profile.attach_nav(c, event.user.id, :hybrids)
      end
    end

    def set_by_name(event, raw)
      player = ErosHelpers.require_player(event) or return
      query = raw.to_s.strip
      return show(event) if query.empty?

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
