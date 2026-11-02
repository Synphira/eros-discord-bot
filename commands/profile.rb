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
      return if ErosHelpers.guard_channel!(event)

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
      if own
        # Once-ever stories finished before the shelf existed still
        # owe their keepsakes; the shelf settles up on first sight.
        Engine::Residents.backfill_story_keepsakes!(target)
        Engine::Quests.backfill_wedding_keepsake!(target)
        Engine::BossFights.backfill_mementos!(target)
        target.refresh
      end

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        title = target.active_title_name
        header = "## #{target.display_name}"
        c.text_display(content: header)
        hybrid = target.active_transformation_name
        identity = title ? "_#{title}_ · #{target.gender}" : target.gender.to_s
        identity += " · **Hybrid:** #{hybrid}" if hybrid
        c.text_display(content: identity)
        marks = Engine::Marks.profile_line(target)
        c.text_display(content: marks) if marks
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
        Engine::Badges.grant_active!(target)
        Engine::Badges.sync_staff!(target)
        badge_line = Engine::Badges.profile_line(target)
        c.text_display(content: badge_line) if badge_line
        if news.any?
          c.separator(divider: true, spacing: :small)
          c.text_display(content: news.join("\n"))
        end
        if own && target.character_name.to_s.empty?
          c.text_display(content: '-# Unnamed delvers are hidden from the leaderboard — open the menu and choose **Rename**.')
        end
        attach_nav(c, event.user.id, :profile, rename: own) if own
      end
    end

    KEEPSAKES_PER_PAGE = 5

    def show_collections(event, notice: nil, page: 0)
      player = ErosHelpers.require_player(event) or return
      if (defined?(Engine::Residents) && defined?(Engine::Quests) && defined?(Engine::BossFights))
        Engine::Residents.backfill_story_keepsakes!(player)
        Engine::Quests.backfill_wedding_keepsake!(player)
        Engine::BossFights.backfill_mementos!(player)
        player.refresh
      end
      all = player.keepsakes
      pages = [(all.size.to_f / KEEPSAKES_PER_PAGE).ceil, 1].max
      page = page.to_i.clamp(0, pages - 1)
      slice = all.slice(page * KEEPSAKES_PER_PAGE, KEEPSAKES_PER_PAGE) || []

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(
          content: "## Collections — #{player.display_name}\n" \
                   "_#{all.size} keepsake#{'s' unless all.size == 1}_"
        )
        c.text_display(content: notice) if notice
        if all.empty?
          c.text_display(
            content: '_Nothing kept yet. Admirers leave parting gifts as they wander off, finished stories ' \
                     'leave something small behind, and every boss and relic leaves a memento the first time you meet._'
          )
        else
          lines = slice.each_with_index.map do |text, i|
            n = (page * KEEPSAKES_PER_PAGE) + i + 1
            "**#{n}.** #{Player.keepsake_emoji(text)} #{text}"
          end
          c.text_display(content: lines.join("\n"))
        end

        attach_pager(c, 'eros:keepsakes:page', page, pages, event.user.id) if pages > 1
        attach_nav(c, event.user.id, :collections)
      end
    end

    def show_badges(event)
      player = ErosHelpers.require_player(event) or return
      Engine::Badges.grant_active!(player)
      Engine::Badges.sync_staff!(player)
      player.refresh

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(
          content: "## Badges — #{player.display_name}\n" \
                   '_Marks from seasons you played. They stay. A season you missed stays blank._'
        )
        c.text_display(content: Engine::Badges.page_lines(player).join("\n"))
        attach_nav(c, event.user.id, :badges)
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

        c.row do |row|
          row.string_select(
            custom_id: "eros:ach:pick:#{event.user.id}",
            placeholder: 'Choose a category…',
            min_values: 1,
            max_values: 1
          ) do |menu|
            cats.each do |key, label|
              in_cat = Engine::TitleSystem.achievements_in(key, player)
              got = in_cat.count { |a| done.include?(a[:id]) }
              menu.option(
                label: label,
                value: key,
                description: "#{got}/#{in_cat.size} unlocked",
                default: key == category
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

    def show_leaderboard(event, stat = nil, page: nil)
      return if ErosHelpers.guard_channel!(event)

      keys = Engine::ProfileSystem::STATS.keys
      # Paging wraps: Next on the last ranking cycles back to the first.
      stat = page.nil? ? Engine::ProfileSystem.normalize_stat(stat) : keys[page.to_i % keys.size]
      index = keys.index(stat)
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
          note = rank ? "Your rank: **##{rank}**" : 'Set a character name (`/profile` → **Rename** in the menu) to appear on the leaderboard.'
          c.text_display(content: "-# #{note}")
        end
        c.row do |row|
          row.button(label: '◀ Prev', style: :secondary, custom_id: "eros:lb:page:#{index - 1}:#{event.user.id}")
          row.button(label: "#{spec[:label]} (#{index + 1}/#{keys.size})", style: :primary,
                     custom_id: "eros:lb:page:info:#{event.user.id}", disabled: true)
          row.button(label: 'Next ▶', style: :secondary, custom_id: "eros:lb:page:#{index + 1}:#{event.user.id}")
        end
        attach_nav(c, event.user.id, :leaderboard) if viewer
      end
    end

    def set_name(event, raw)
      player = ErosHelpers.require_player(event) or return
      if raw.nil? || raw.strip.empty?
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'Usage: `e,name Your Character Name` — or `/profile` → **Rename** in the menu.')
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

    def attach_nav(container, owner_id, current, rename: true)
      container.row do |row|
        row.string_select(custom_id: "eros:profile:goto:#{owner_id}", placeholder: 'Open a panel…',
                          min_values: 1, max_values: 1) do |menu|
          menu.option(label: 'Profile', value: 'profile', description: 'Your delver card',
                      emoji: { name: '📜' }, default: current == :profile)
          menu.option(label: 'Titles', value: 'titles', description: 'Names you have earned',
                      emoji: { name: '🏷️' }, default: current == :titles)
          menu.option(label: 'Achievements', value: 'achievements', description: 'Feats and rewards',
                      emoji: { name: '🏆' }, default: current == :achievements)
          menu.option(label: 'Hybrids', value: 'hybrids', description: 'Forms you can wear',
                      emoji: { name: '🦋' }, default: current == :hybrids)
          menu.option(label: 'Collections', value: 'collections', description: 'Keepsakes you have kept',
                      emoji: { name: '🎁' }, default: current == :collections)
          menu.option(label: 'Badges', value: 'badges', description: 'Seasons you played',
                      emoji: { name: '🎖️' }, default: current == :badges)
          menu.option(label: 'Leaderboard', value: 'leaderboard', description: 'Named delvers',
                      emoji: { name: '📊' }, default: current == :leaderboard)
          if rename
            menu.option(label: 'Parlour', value: 'parlour', description: "Syn's bench",
                        emoji: { name: '🖤' })
            menu.option(label: 'Rename', value: 'rename', description: 'Choose a character name',
                        emoji: { name: '✏️' })
          end
        end
      end
    end

    def open_profile_panel(event, choice)
      case choice
      when 'profile' then show_profile(event)
      when 'titles' then show_titles(event)
      when 'achievements' then show_achievements(event)
      when 'hybrids' then Commands::Transformation.show(event)
      when 'collections' then show_collections(event)
      when 'badges' then show_badges(event)
      when 'leaderboard' then show_leaderboard(event)
      when 'parlour' then Commands::Parlour.show(event)
      when 'rename'
        player = Player[event.user.id]
        unless player
          ErosUI.reply_v2(event, ephemeral: true) { |c| c.text_display(content: 'No profile. `/create` first.') }
          return
        end
        ErosUI.show_name_modal(event, "eros:namemodal:rename:#{event.user.id}", current: player.character_name)
      end
    end

    string_select(custom_id: /^eros:profile:goto:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Profile.open_profile_panel(event, Array(event.values).first.to_s)
    end

    button(custom_id: /^eros:profile:view:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Profile.show_profile(event)
    end

    button(custom_id: /^eros:collections:view:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Profile.show_collections(event)
    end

    button(custom_id: /^eros:keepsakes:page:-?\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      page = event.custom_id[/\Aeros:keepsakes:page:(-?\d+):\d+\z/, 1].to_i
      Commands::Profile.show_collections(event, page: page)
    end

    button(custom_id: /^eros:keepsakes:pin:\d+:\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      index, page = event.custom_id.match(/\Aeros:keepsakes:pin:(\d+):(\d+):\d+\z/).captures.map(&:to_i)
      player = Player[event.user.id]
      next unless player

      text = player.keepsakes[index]
      result = text ? player.toggle_keepsake_pin!(text) : { ok: false, message: 'That keepsake is gone.' }
      player.refresh
      Commands::Profile.show_collections(event, page: page,
                                         notice: "#{result[:ok] ? '📌' : '❌'} #{result[:message]}")
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

    button(custom_id: /^eros:ach:cat:[a-z_]+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      cat = event.custom_id[/\Aeros:ach:cat:([a-z_]+):\d+\z/, 1]
      Commands::Profile.show_achievements(event, category: cat)
    end

    string_select(custom_id: /^eros:ach:pick:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Profile.show_achievements(event, category: Array(event.values).first.to_s, page: 0)
    end

    button(custom_id: /^eros:ach:page:[a-z_]+:-?\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      _, cat, page = event.custom_id.match(/\Aeros:ach:page:([a-z_]+):(-?\d+):\d+\z/).to_a
      Commands::Profile.show_achievements(event, category: cat, page: page.to_i)
    end

    button(custom_id: /^eros:lb:[a-z]+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      stat = event.custom_id[/\Aeros:lb:([a-z]+):\d+\z/, 1]
      Commands::Profile.show_leaderboard(event, stat)
    end

    button(custom_id: /^eros:lb:page:-?\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      page = event.custom_id[/\Aeros:lb:page:(-?\d+):\d+\z/, 1].to_i
      Commands::Profile.show_leaderboard(event, page: page)
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

    command(:leaderboard, description: 'Top delvers (cycles, depth, level, kills, lp, admirers)') do |event, stat|
      Commands::Profile.show_leaderboard(event, stat)
      nil
    end

    command(:name, description: 'Set your character name') do |event, *parts|
      Commands::Profile.set_name(event, parts.join(' '))
      nil
    end
  end
end
