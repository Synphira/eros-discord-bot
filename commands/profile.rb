# frozen_string_literal: true

module Commands
  module Profile
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0xd4af37
    TITLES_PER_PAGE = 8
    ACHIEVEMENTS_PER_PAGE = 6

    module_function

    def show_profile(event, lookup: nil)
      if lookup && !lookup.strip.empty?
        target = Player.find_by_character_name(lookup)
        unless target
          ErosUI.reply_v2(event, ephemeral: true) do |c|
            c.text_display(content: "No delver named **#{Player.normalize_character_name(lookup)}** was found.")
          end
          return
        end
        own = target.discord_id == event.user.id
      else
        target = ErosHelpers.require_player(event) or return
        own = true
      end

      news = own ? target.check_progress! : []

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        title = target.active_title_name
        header = "## #{target.display_name}"
        c.text_display(content: header)
        hybrid = target.active_transformation_name
        identity = title ? "_#{title}_ · #{target.gender}" : target.gender.to_s
        identity += " · **Hybrid:** #{hybrid}" if hybrid
        c.text_display(content: identity)
        c.separator(divider: true, spacing: :small)
        c.text_display(
          content: "**Current** Cycle #{target.current_cycle} · Floor #{target.current_floor} · Lv #{target.level}\n" \
                   "**Cycles completed** #{target.tracker('cycles_completed')} · " \
                   "**Deepest** #{Engine::ProfileSystem.format_value('depth', Engine::ProfileSystem::STATS['depth'][:value].call(target))}\n" \
                   "**Monsters defeated** #{target.tracker('monsters_killed')} · " \
                   "**Bosses defeated** #{target.tracker('bosses_defeated')}\n" \
                   "**LP earned** #{target.tracker('lp_earned')} · **Submissions** #{target.tracker('submissions')} · " \
                   "**Chests opened** #{target.tracker('treasure_found')}"
        )
        c.text_display(
          content: "**Titles** #{target.earned_titles.size}/#{Engine::TitleSystem.visible_titles(target).size} · " \
                   "**Achievements** #{target.earned_achievements.size}/#{Engine::TitleSystem.visible_achievements(target).size} · " \
                   "**Hybrid forms** #{target.unlocked_transformations.size}/#{Engine::TransformationSystem.visible(target).size}"
        )
        if news.any?
          c.separator(divider: true, spacing: :small)
          c.text_display(content: news.join("\n"))
        end
        if own && target.character_name.to_s.empty?
          c.text_display(content: '-# Unnamed delvers are hidden from the leaderboard — press **Rename** to choose a name.')
        end
        attach_nav(c, event.user.id, :profile, rename: own) if own
      end
    end

    def show_titles(event, notice: nil, page: 0)
      player = ErosHelpers.require_player(event) or return
      news = player.check_progress!
      active = player.active_title_key
      titles = Engine::TitleSystem.visible_titles(player)
      pages = [(titles.size.to_f / TITLES_PER_PAGE).ceil, 1].max
      page = page.to_i.clamp(0, pages - 1)
      slice = titles.to_a.slice(page * TITLES_PER_PAGE, TITLES_PER_PAGE) || []
      earned_all = player.earned_titles.select { |k| Engine::TitleSystem::TITLES.key?(k) }

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        active_name = Engine::TitleSystem.title(active)&.dig(:name) || '_none_'
        c.text_display(
          content: "## Titles — #{player.display_name}\n" \
                   "_#{earned_all.size}/#{titles.size} earned · showing **#{active_name}**" \
                   "#{player.selected_title ? '' : ' (auto)'}_"
        )
        c.text_display(content: notice) if notice
        lines = slice.map do |key, t|
          if player.earned_titles.include?(key)
            marker = key == active ? '**▶**' : '◆'
            "#{marker} **#{t[:name]}** — _#{t[:description]}_"
          else
            "◇ #{t[:name]} — _#{Engine::TitleSystem.progress_text(player, t[:requirement])}_"
          end
        end
        c.text_display(content: lines.join("\n"))
        c.text_display(content: news.join("\n")) if news.any?
        c.separator(divider: true, spacing: :small)

        earned_here = slice.map(&:first).select { |k| player.earned_titles.include?(k) }
        if earned_here.any? || player.selected_title
          c.row do |row|
            row.string_select(
              custom_id: "eros:titles:pick:#{page}:#{event.user.id}",
              placeholder: earned_here.any? ? 'Equip a title from this page…' : 'No titles earned on this page',
              min_values: 1,
              max_values: 1
            ) do |menu|
              menu.option(label: 'Auto (best earned title)', value: 'auto', default: player.selected_title.nil?)
              earned_here.each do |key|
                t = Engine::TitleSystem.title(key)
                menu.option(label: t[:name][0, 100], value: key, description: t[:description][0, 100],
                            default: key == player.selected_title)
              end
            end
          end
        else
          c.text_display(content: '-# No titles earned on this page yet.')
        end

        attach_pager(c, "eros:titles:page", page, pages, event.user.id) if pages > 1
        attach_nav(c, event.user.id, :titles)
      end
    end

    def show_achievements(event, category: nil, page: 0)
      player = ErosHelpers.require_player(event) or return
      news = player.check_progress!
      cats = Engine::TitleSystem::ACHIEVEMENT_CATEGORIES
      category = cats.key?(category.to_s) ? category.to_s : cats.keys.first
      list = Engine::TitleSystem.achievements_in(category, player)
      pages = [(list.size.to_f / ACHIEVEMENTS_PER_PAGE).ceil, 1].max
      page = page.to_i.clamp(0, pages - 1)
      done = player.earned_achievements
      total = Engine::TitleSystem.visible_achievements(player).size

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(
          content: "## Achievements — #{player.display_name}\n" \
                   "_#{done.size}/#{total} unlocked · **#{cats[category]}**_"
        )
        if category == 'kinks'
          c.text_display(content: '-# Kink achievements only show for themes enabled in `/options`.')
        end
        lines = (list.slice(page * ACHIEVEMENTS_PER_PAGE, ACHIEVEMENTS_PER_PAGE) || []).map do |a|
          reward = a.dig(:reward, :lp) ? " · #{a[:reward][:lp]} LP" : ''
          if done.include?(a[:id])
            "◆ **#{a[:name]}** — _#{a[:description]}_#{reward}"
          else
            "◇ #{a[:name]} — _#{a[:description]}_ " \
              "(#{Engine::TitleSystem.progress_text(player, a[:requirement])})#{reward}"
          end
        end
        c.text_display(content: lines.empty? ? '_Nothing here yet._' : lines.join("\n"))
        c.text_display(content: news.join("\n")) if news.any?
        c.separator(divider: true, spacing: :small)

        cats.keys.each_slice(4) do |group|
          c.row do |row|
            group.each do |key|
              in_cat = Engine::TitleSystem.achievements_in(key, player)
              got = in_cat.count { |a| done.include?(a[:id]) }
              row.button(
                label: "#{cats[key]} #{got}/#{in_cat.size}",
                style: key == category ? :primary : :secondary,
                custom_id: "eros:ach:cat:#{key}:#{event.user.id}"
              )
            end
          end
        end
        attach_pager(c, "eros:ach:page:#{category}", page, pages, event.user.id) if pages > 1
        attach_nav(c, event.user.id, :achievements)
      end
    end

    def attach_pager(container, prefix, page, pages, owner_id)
      container.row do |row|
        row.button(label: '◀ Prev', style: :secondary, custom_id: "#{prefix}:#{page - 1}:#{owner_id}", disabled: page.zero?)
        row.button(label: "Page #{page + 1}/#{pages}", style: :secondary, custom_id: "#{prefix}:info:#{owner_id}", disabled: true)
        row.button(label: 'Next ▶', style: :secondary, custom_id: "#{prefix}:#{page + 1}:#{owner_id}",
                   disabled: page >= pages - 1)
      end
    end

    def show_leaderboard(event, stat = nil)
      stat = Engine::ProfileSystem.normalize_stat(stat)
      spec = Engine::ProfileSystem::STATS[stat]
      rows = Engine::ProfileSystem.leaderboard(stat, limit: 10)
      viewer = Player[event.user.id]

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: "## Leaderboard — #{spec[:label]}")
        if rows.empty?
          c.text_display(content: '_No named delvers yet. Set a character name to appear here._')
        else
          lines = rows.each_with_index.map do |row, i|
            p = row[:player]
            title = p.active_title_name
            title_part = title ? " _(#{title})_" : ''
            "**#{i + 1}.** #{p.character_name}#{title_part} — #{Engine::ProfileSystem.format_value(stat, row[:value])}"
          end
          c.text_display(content: lines.join("\n"))
        end
        if viewer
          rank = Engine::ProfileSystem.rank_of(viewer, stat)
          note = rank ? "Your rank: **##{rank}**" : 'Set a character name (`/profile` → **Rename**) to appear on the leaderboard.'
          c.text_display(content: "-# #{note}")
        end
        c.row do |row|
          Engine::ProfileSystem::STATS.each do |key, s|
            row.button(
              label: s[:label],
              style: key == stat ? :primary : :secondary,
              custom_id: "eros:lb:#{key}:#{event.user.id}"
            )
          end
        end
        attach_nav(c, event.user.id, :leaderboard) if viewer
      end
    end

    def set_name(event, raw)
      player = ErosHelpers.require_player(event) or return
      if raw.nil? || raw.strip.empty?
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'Usage: `!name Your Character Name` — or `/profile` → **Rename**.')
        end
        return
      end

      result = player.set_character_name!(raw)
      unless result[:ok]
        ErosUI.reply_v2(event, ephemeral: true) { |c| c.text_display(content: result[:message]) }
        return
      end
      show_profile(event)
    end

    def set_title(event, raw)
      player = ErosHelpers.require_player(event) or return
      query = raw.to_s.strip.downcase
      if query.empty?
        show_titles(event)
        return
      end

      key =
        if %w[auto none clear].include?(query)
          nil
        else
          Engine::TitleSystem::TITLES.find { |k, t| k == query || t[:name].downcase == query }&.first
        end
      if key.nil? && !%w[auto none clear].include?(query)
        ErosUI.reply_v2(event, ephemeral: true) { |c| c.text_display(content: "No title named **#{raw.strip}**.") }
        return
      end

      result = player.select_title!(key)
      show_titles(event, notice: result[:message])
    end

    def attach_nav(container, owner_id, current, rename: false)
      container.row do |row|
        {
          profile: ['Profile', "eros:profile:view:#{owner_id}"],
          titles: ['Titles', "eros:titles:view:#{owner_id}"],
          achievements: ['Achievements', "eros:achievements:view:#{owner_id}"],
          hybrids: ['Hybrids', "eros:hybrid:view:#{owner_id}"],
          leaderboard: ['Leaderboard', "eros:lb:open:#{owner_id}"]
        }.each do |key, (label, id)|
          row.button(label: label, style: key == current ? :primary : :secondary, custom_id: id)
        end
      end
      return unless rename

      container.row do |row|
        row.button(label: 'Rename', style: :success, custom_id: "eros:profile:rename:#{owner_id}")
      end
    end

    button(custom_id: /^eros:profile:view:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Profile.show_profile(event)
    end

    button(custom_id: /^eros:profile:rename:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      unless player
        ErosUI.reply_v2(event, ephemeral: true) { |c| c.text_display(content: 'No profile. `/create` first.') }
        next
      end
      ErosUI.show_name_modal(event, "eros:namemodal:rename:#{event.user.id}", current: player.character_name)
    end

    modal_submit(custom_id: /^eros:namemodal:rename:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Profile.set_name(event, event.value('character_name'))
    end

    button(custom_id: /^eros:titles:view:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Profile.show_titles(event)
    end

    button(custom_id: /^eros:titles:set:[a-z0-9_]+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      key = event.custom_id[/\Aeros:titles:set:([a-z0-9_]+):\d+\z/, 1]
      player = Player[event.user.id]
      next unless player

      result = player.select_title!(key)
      Commands::Profile.show_titles(event, notice: result[:message])
    end

    button(custom_id: /^eros:titles:clear:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      result = player.select_title!(nil)
      Commands::Profile.show_titles(event, notice: result[:message])
    end

    string_select(custom_id: /^eros:titles:pick:\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      page = event.custom_id[/\Aeros:titles:pick:(\d+):\d+\z/, 1].to_i
      choice = Array(event.values).first.to_s
      result = player.select_title!(choice == 'auto' ? nil : choice)
      Commands::Profile.show_titles(event, notice: result[:message], page: page)
    end

    button(custom_id: /^eros:titles:page:-?\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      page = event.custom_id[/\Aeros:titles:page:(-?\d+):\d+\z/, 1].to_i
      Commands::Profile.show_titles(event, page: page)
    end

    button(custom_id: /^eros:achievements:view:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Profile.show_achievements(event)
    end

    button(custom_id: /^eros:ach:cat:[a-z]+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      cat = event.custom_id[/\Aeros:ach:cat:([a-z]+):\d+\z/, 1]
      Commands::Profile.show_achievements(event, category: cat)
    end

    button(custom_id: /^eros:ach:page:[a-z]+:-?\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      _, cat, page = event.custom_id.match(/\Aeros:ach:page:([a-z]+):(-?\d+):\d+\z/).to_a
      Commands::Profile.show_achievements(event, category: cat, page: page.to_i)
    end

    button(custom_id: /^eros:lb:[a-z]+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      stat = event.custom_id[/\Aeros:lb:([a-z]+):\d+\z/, 1]
      Commands::Profile.show_leaderboard(event, stat)
    end

    application_command(:profile) { |event| Commands::Profile.show_profile(event, lookup: event.options['name'].to_s) }
    application_command(:titles) { |event| Commands::Profile.show_titles(event) }
    application_command(:title) { |event| Commands::Profile.set_title(event, event.options['name'].to_s) }
    application_command(:achievements) do |event|
      Commands::Profile.show_achievements(event, category: event.options['category'])
    end
    application_command(:leaderboard) { |event| Commands::Profile.show_leaderboard(event, event.options['stat']) }
    application_command(:name) do |event|
      Commands::Profile.set_name(event, event.options['name'].to_s)
    end

    command(:profile, description: 'View your profile, or another delver by character name') do |event, *parts|
      Commands::Profile.show_profile(event, lookup: parts.join(' '))
      nil
    end

    command(:titles, description: 'View and equip titles') do |event|
      Commands::Profile.show_titles(event)
      nil
    end

    command(:title, description: 'Equip a title by name (or "auto")') do |event, *parts|
      Commands::Profile.set_title(event, parts.join(' '))
      nil
    end

    command(:achievements, description: 'View achievements (optionally by category)') do |event, category|
      Commands::Profile.show_achievements(event, category: category&.downcase)
      nil
    end

    command(:leaderboard, description: 'Top delvers (cycles, depth, kills, lp)') do |event, stat|
      Commands::Profile.show_leaderboard(event, stat)
      nil
    end

    command(:name, description: 'Set your character name') do |event, *parts|
      Commands::Profile.set_name(event, parts.join(' '))
      nil
    end
  end
end
