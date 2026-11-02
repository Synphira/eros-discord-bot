# frozen_string_literal: true

module Commands
  module Dev
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0x2f3136

    FIELDS = {
      'level' => :level, 'lvl' => :level,
      'lp' => :lp, 'lust' => :lust, 'defiance' => :defiance, 'hp' => :defiance,
      'str' => :strength, 'strength' => :strength,
      'agi' => :agility, 'agility' => :agility,
      'res' => :resistance, 'resistance' => :resistance,
      'sub' => :submission, 'submission' => :submission,
      'floor' => :current_floor, 'cycle' => :current_cycle
    }.freeze

    HELP = <<~TXT.strip
      **Dev commands** (prefix only, developer + bug testers)
      `e,dev [user id] <command>` — that delver; leave the id off to target yourself
      `win`, `boss`, `relic`, `finalboss`, `elite`, `event`, and `npc` always play on your own screen
      `e,dev debug` — toggle debug mode (one-hit kills, monsters never act, guaranteed flee/satisfy, traps avoided)
      `e,dev syn` — grant and wear the whole Syn set (owner only)
      `e,dev synlock` — toggle the Syn lock: cursed gear stays in the pack, and the set survives defeat (owner only)
      `e,dev info` — one panel; the menu jumps between stats, run, combat, submissions, events, and lists
      `e,dev set <level|lp|lust|defiance|str|agi|res|sub|floor|cycle> <n>`
      `e,dev heal` — full defiance, base lust
      `e,dev curse <name>` · `e,dev uncurse <name|all>`
      `e,dev item <name>` · `e,dev unitem <name|all>` — grant / delete gear (cursed auto-binds)
      `e,dev tracker <key> <n>` — set any tracker
      `e,dev title <key|all>` · `e,dev achievement <id|all>` · `e,dev wipeprogress`
      `e,dev hybrid <key|all|none>` — unlock hybrid forms (none = lock them all)
      `e,dev unlockcursed` — unlock every Cursed Shop item
      `e,dev win` — kill the current monster (runs the normal victory path)
      `e,dev boss` — jump to the next boss floor and start the fight
      `e,dev relic <name>` — jump to a floor that relic can hold and start that fight
      `e,dev finalboss` — jump to Eros (final boss)
      `e,dev cycle` — complete the current cycle instantly
      `e,dev reset` — run a defeat reset (keeps progression)
      `e,dev event <key|list>` — start a specific random event (ignores content toggles)
      `e,dev npc <id> [stage]` · `e,dev npc reset` — start an NPC encounter (ignores floor; without a stage it continues from your progress), or wipe NPC progress
      `e,dev conditions [clear]` — show or clear temporary conditions
      `e,dev elite [rutting|slick|towering|insatiable|alluring]` — start a fight with an elite monster
      `e,dev week [key|auto]` — show or override this week's tower modifier (until restart)
    TXT

    module_function

    # These open a fight or a scene whose buttons follow the person who typed
    # the command. They cannot safely drive someone else's delver.
    SELF_ONLY = %w[win boss relic finalboss elite event npc].freeze

    def reply(event, text)
      note = Thread.current[:eros_dev_target]
      text = "#{note}\n#{text}" if note
      ErosUI.reply_v2(event, colour: COLOUR) { |c| c.text_display(content: text[0, 3900]) }
    end

    def snowflake(token)
      raw = token.to_s[/\A<@!?(\d+)>\z/, 1] || token.to_s
      raw.match?(/\A\d{17,20}\z/) ? raw.to_i : nil
    end

    def find_player(event, discord_id = event.user.id)
      player = Player[discord_id.to_i]
      return player if player

      if discord_id.to_i == event.user.id.to_i
        reply(event, 'No delver — `e,create` first.')
      else
        reply(event, "No delver for `#{discord_id}`.")
      end
      nil
    end

    def debug_for(event, target_id)
      unless Engine::Dev.developer?(target_id)
        return reply(event, 'Debug mode only applies to a developer, co-developer, or bug tester.')
      end

      on = Engine::Dev.toggle_debug!(target_id)
      whose = target_id.to_i == event.user.id.to_i ? 'you' : "`#{target_id}`"
      reply(event, "Debug mode **#{on ? 'ON' : 'OFF'}** for #{whose}.")
    end

    def dispatch(event, sub, args)
      sub = sub.to_s
      target_id = event.user.id.to_i
      if (id = snowflake(sub))
        target_id = id
        sub = args.shift.to_s
      end
      sub = sub.downcase
      return reply(event, HELP) if sub.empty? || sub == 'help'
      return debug_for(event, target_id) if sub == 'debug'
      return set_week(event, args[0].to_s.downcase) if sub == 'week'

      if SELF_ONLY.include?(sub) && target_id != event.user.id.to_i
        return reply(event, "`#{sub}` plays out on your own screen. Run it without a user id.")
      end

      player = find_player(event, target_id) or return
      if target_id != event.user.id.to_i
        Thread.current[:eros_dev_target] = "Target **#{player.display_name}** · `#{player.discord_id}`"
      end

      case sub
      when 'info' then info(event, player)
      when 'syn' then grant_syn_set(event, player)
      when 'synlock' then toggle_syn_lock(event, player)
      when 'set' then set_field(event, player, args[0], args[1])
      when 'heal'
        player.update(defiance: player.max_defiance, lust: player.base_lust)
        reply(event, "Healed: defiance #{player.defiance}/#{player.max_defiance}, lust #{player.lust}.")
      when 'curse' then give_curse(event, player, args.join(' '))
      when 'uncurse' then remove_curse(event, player, args.join(' '))
      when 'item' then give_item(event, player, args.join(' '))
      when 'unitem' then remove_item(event, player, args.join(' '))
      when 'tracker'
        player.set_tracker!(args[0].to_s, args[1].to_i)
        reply(event, "Tracker `#{args[0]}` = #{player.tracker(args[0])}.")
      when 'title' then grant_titles(event, player, args[0].to_s)
      when 'achievement', 'ach' then grant_achievements(event, player, args[0].to_s)
      when 'hybrid', 'transformation' then grant_hybrids(event, player, args[0].to_s.downcase)
      when 'wipeprogress'
        player.update(titles: [], achievements: [], selected_title: nil, trackers: {})
        reply(event, 'Titles, achievements, and trackers wiped.')
      when 'unlockcursed'
        Engine::Treasure.all_mimic_templates.each { |t| player.remember!('mimics_removed', t[:name]) }
        reply(event, 'Every Cursed Shop item unlocked.')
      when 'win' then win(event, player)
      when 'boss' then jump_to_boss(event, player, next_boss_floor(player))
      when 'relic' then force_relic(event, player, args.join(' '))
      when 'finalboss' then jump_to_boss(event, player, Engine::Tower::FINAL_BOSS_FLOOR)
      when 'cycle'
        Eros.clear_encounter!(player)
        player.clear_event!
        clear = player.complete_cycle!
        lines = ["Cycle #{clear[:cleared_cycle]} complete → now Cycle #{clear[:new_cycle]} (+#{clear[:lp]} LP)."]
        reply(event, (lines + player.check_progress!).join("\n"))
      when 'reset'
        Eros.clear_encounter!(player)
        loss = player.reset_run!
        reply(event, "Run reset. Lost: #{loss.inspect}")
      when 'event' then force_event(event, player, args[0].to_s.downcase)
      when 'npc' then force_npc(event, player, args[0].to_s.downcase, args[1])
      when 'elite' then force_elite(event, player, args[0].to_s.downcase)
      when 'conditions', 'condition'
        player.clear_conditions! if args[0].to_s.casecmp?('clear')
        list = player.condition_list.map { |c| "• **#{c['name']}** (#{c['floors']} floors) — #{c['summary']}" }
        reply(event, list.empty? ? 'No active conditions.' : list.join("\n"))
      else
        reply(event, "Unknown dev command `#{sub}`.\n\n#{HELP}")
      end
    ensure
      Thread.current[:eros_dev_target] = nil
    end

    # One text display, kept under Discord's 4000-character component cap.
    INFO_LIMIT = 3400
    INFO_BUCKETS = [
      ['run', 'Run', 'Floors, cycles, LP, traps, climaxes'],
      ['combat', 'Combat', 'Kills, defeats, bosses'],
      ['submissions', 'Submissions', 'Submissions by kind'],
      ['events', 'Events', 'Room and fetish counters'],
      ['lists', 'Lists', 'Bosses, curses, badges, and other stored names'],
      ['other', 'Other', 'Leftover counters']
    ].freeze

    def info(event, player)
      show_info(event, player, 'overview')
    end

    def show_info(event, player, page)
      player.refresh
      pages = info_catalog(player)
      current = pages.find { |entry| entry[:value] == page } || pages.first
      ErosUI.reply_v2(event, colour: COLOUR) do |container|
        container.text_display(content: current[:text])
        container.row do |row|
          row.string_select(
            custom_id: "eros:dev:info:#{player.discord_id}:#{event.user.id}",
            placeholder: 'Jump to a category…',
            min_values: 1, max_values: 1
          ) do |menu|
            pages.each do |entry|
              menu.option(
                label: entry[:label],
                value: entry[:value],
                description: entry[:blurb],
                default: entry[:value] == current[:value]
              )
            end
          end
        end
      end
    end

    def info_catalog(player)
      data = player.tracker_hash.transform_keys(&:to_s)
      grouped = Hash.new { |hash, key| hash[key] = [] }
      data.keys.sort.each { |key| grouped[info_bucket(key, data[key])] << key }

      pages = [{
        value: 'overview',
        label: 'Overview',
        blurb: 'Stats, body, and content options',
        text: info_header(player)
      }]
      INFO_BUCKETS.each do |key, label, blurb|
        keys = grouped[key]
        next if keys.empty?

        chunks = info_bucket_chunks(player, data, label, keys, key == 'lists')
        chunks.each_with_index do |text, index|
          suffix = chunks.size > 1 ? " #{index + 1}" : ''
          range = "#{keys.first} – #{keys.last}"
          pages << {
            value: "#{key}#{suffix.tr(' ', '-')}",
            label: "#{label}#{suffix}",
            blurb: (chunks.size > 1 ? range : blurb)[0, 100],
            text: text
          }
        end
      end
      pages
    end

    def info_bucket(key, value)
      return 'lists' if value.is_a?(Array) || value.is_a?(Hash)
      return 'submissions' if key.end_with?('_submissions') || key == 'submissions'
      return 'run' if key == 'events_escaped' || key.match?(/floor|cycle|depth|lp_earned|trap|treasure|climax|flee|chest|rooms_/)
      return 'combat' if key.end_with?('_defeats') || key.match?(/\A(?:monsters_killed|bosses_|tentacle_pit)/)
      return 'events' if key.include?('event') || key.end_with?('_encounters') || key.end_with?('_transformations')

      'other'
    end

    def info_bucket_chunks(player, data, label, keys, lists)
      heading = "**#{player.display_name}** · `#{player.discord_id}`\n**#{label}**\n"
      lines = lists ? info_list_lines(data, keys) : info_scalar_lines(data, keys)
      budget = INFO_LIMIT - heading.length - (lists ? 1 : 8)
      budget = 200 if budget < 200
      chunk_lines(lines, budget).map do |chunk|
        body = lists ? chunk.join("\n") : "```\n#{chunk.join("\n")}\n```"
        "#{heading}#{body}"[0, INFO_LIMIT]
      end
    end

    def info_scalar_lines(data, keys)
      width = keys.map(&:length).max
      keys.map { |key| "#{key.ljust(width)}  #{grouped_number(data[key])}" }
    end

    def info_list_lines(data, keys)
      lines = []
      keys.each do |key|
        value = data[key]
        items = value.is_a?(Hash) ? value.map { |child, child_value| "#{child}: #{child_value}" } : Array(value).map(&:to_s)
        next if items.empty?

        lines << "**#{key}** (#{items.size})"
        line = +''
        items.each do |item|
          item = item[0, 200]
          piece = line.empty? ? item : ", #{item}"
          if line.length + piece.length > 240 && !line.empty?
            lines << line
            line = item.dup
          else
            line << piece
          end
        end
        lines << line unless line.empty?
        lines << ''
      end
      lines
    end

    def chunk_lines(lines, budget)
      pages = []
      buf = []
      size = 0
      lines.each do |line|
        line = line[0, budget]
        addition = line.length + 1
        if size + addition > budget && buf.any?
          pages << buf
          buf = [line]
          size = addition
        else
          buf << line
          size += addition
        end
      end
      pages << buf unless buf.empty?
      pages.empty? ? [['_none_']] : pages
    end

    def info_header(player)
      [
        "**#{player.display_name}** · `#{player.discord_id}`",
        "Debug **#{Engine::Dev.debug?(player) ? 'on' : 'off'}** · Syn lock **#{player.syn_locked? ? 'on' : 'off'}**",
        '',
        "**Level** #{player.level}",
        "**STR** #{player.strength} → #{player.effective_strength} · " \
          "**AGI** #{player.agility} → #{player.effective_agility} · " \
          "**RES** #{player.resistance} → #{player.effective_resistance} · " \
          "**SUB** #{player.submission}",
        "**Defiance** #{player.defiance}/#{player.max_defiance} · **Lust** #{player.lust} · **LP** #{grouped_number(player.lp)}",
        "**Cycle** #{player.current_cycle} · **Floor** #{player.current_floor} · " \
          "**Highest boss** #{player.highest_boss_defeated}",
        "**Titles** #{player.earned_titles.size} · **Achievements** #{player.earned_achievements.size}",
        info_body(player),
        info_content(player)
      ].join("\n")
    end

    def info_body(player)
      sizes = player.body_sizes.is_a?(Hash) ? player.body_sizes.transform_keys(&:to_s) : {}
      return '**Body:** —' if sizes.empty?

      order = %w[breasts butt penis]
      keys = order.select { |key| sizes.key?(key) } + (sizes.keys.map(&:to_s) - order)
      parts = keys.filter_map do |key|
        next unless sizes.key?(key)

        label = Engine::ContentOptions::BODY_SIZES.dig(key, :label) || key.capitalize
        raw = sizes[key]
        shown = Engine::ContentOptions.size_label(key, raw)
        shown = shown.to_s.capitalize if shown.to_s == raw.to_s
        "#{label} #{shown}"
      end
      "**Body:** #{parts.join(' · ')}"
    end

    def info_content(player)
      catalog = Engine::ContentOptions::PREFERENCES
      off = catalog.filter_map { |key, spec| spec[:label] unless Engine::ContentOptions.enabled?(player, key) }
      stored = player.preferences.is_a?(Hash) ? player.preferences : {}
      extra = stored.keys.map(&:to_s) - catalog.keys
      line = off.empty? ? '**Content:** all on' : "**Content off:** #{off.join(', ')}"
      return line if extra.empty?

      "#{line}\n**Extra prefs:** #{extra.sort.join(', ')}"
    end

    def grouped_number(value)
      return value.to_s unless value.is_a?(Integer)

      sign = value.negative? ? '-' : ''
      digits = value.abs.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
      "#{sign}#{digits}"
    end

    def set_field(event, player, field, value)
      column = FIELDS[field.to_s.downcase]
      return reply(event, "Unknown field. Use: #{FIELDS.keys.uniq.join(', ')}") unless column
      return reply(event, 'Give a number.') unless value.to_s.match?(/\A-?\d+\z/)

      n = value.to_i
      n = [n, 1].max if %i[level current_floor current_cycle strength agility resistance].include?(column)
      n = [n, 0].max
      if column == :current_floor
        player.note_floor_reached!(n)
        player.update(highest_boss_defeated: [(n - 1) / 5 * 5, 0].max)
      else
        player.update(column => n)
      end
      player.clamp_defiance!
      reply(event, "Set **#{column}** = #{player.refresh[column]}.")
    end

    def give_curse(event, player, name)
      Engine::CurseCatalog.sync_to_db!
      if name.strip.casecmp?('all')
        added = Curse.all.count { |curse| player.afflict!(curse) }
        return reply(event, "Afflicted with **every curse in the catalogue** — #{added} newly applied. (Yes, all of them. Dev tools.)")
      end

      curse = Curse.where(Sequel.ilike(:name, "%#{name}%")).first
      return reply(event, "No curse matching `#{name}`.") if name.empty? || curse.nil?

      added = player.afflict!(curse)
      reply(event, added ? "Afflicted **#{curse.name}**." : "Already has **#{curse.name}**.")
    end

    def remove_curse(event, player, name)
      ds = DB[:player_curses].where(player_id: player.discord_id)
      unless name.casecmp?('all')
        curse = player.curses_dataset.where(Sequel.ilike(Sequel[:curses][:name], "%#{name}%")).first
        return reply(event, "No active curse matching `#{name}`.") unless curse

        ds = ds.where(curse_id: curse.id)
      end
      count = ds.delete
      player.clamp_defiance!
      reply(event, "Removed #{count} curse(s).")
    end

    MAKER_REFUSAL = "**Syn's gear** stirs, recognises that you are not its maker, and will not " \
                    'be worn. Some things have exactly one owner.'

    def grant_syn_set(event, player)
      return reply(event, MAKER_REFUSAL) unless Engine::Dev.owner?(event.user.id)

      Engine::Wardrobe.sync_dev_gear!
      lines = Engine::Wardrobe::DEV_GEAR.map { |spec| wear_syn_piece(player, spec[:name]) }
      reply(event, lines.join("\n"))
    end

    def wear_syn_piece(player, name)
      item = ::Equipment.where(name: name).first
      return "Missing **#{name}**." unless item

      unless player.owns_equipment?(item.id)
        grant = player.grant_equipment!(item, auto_equip: false)
        return grant[:message] unless grant[:ok]
      end

      current = player.equipment_for_slot(item.slot)
      lifted = nil
      if current && current.cursed && current.id != item.id
        DB[:player_equipment]
          .where(player_id: player.discord_id, equipment_id: current.id)
          .update(is_equipped: false)
        lifted = current.name
      end

      result = player.equip_item(item.id)
      line = result[:ok] ? "Wearing **#{item.name}**." : result[:message]
      lifted ? "#{line} **#{lifted}** is in the pack." : line
    end

    def toggle_syn_lock(event, player)
      return reply(event, MAKER_REFUSAL) unless Engine::Dev.owner?(event.user.id)

      on = !player.tracker('syn_lock').positive?
      player.set_tracker!('syn_lock', on ? 1 : 0)
      reply(event, "Syn lock **#{on ? 'ON' : 'OFF'}**.")
    end

    def give_item(event, player, name)
      Engine::Shop.sync_to_db!
      Engine::Treasure.sync_to_db!
      Engine::BossFights.sync_trophies!
      Engine::Wardrobe.sync_dev_gear!
      item = ::Equipment.where(Sequel.ilike(:name, "%#{name}%")).first
      return reply(event, "No item matching `#{name}`.") if name.empty? || item.nil?

      reply(event, player.grant_equipment!(item)[:message])
    end

    def remove_item(event, player, name)
      ds = DB[:player_equipment].where(player_id: player.discord_id)
      unless name.casecmp?('all')
        item = player.equipment_dataset.where(Sequel.ilike(Sequel[:equipment][:name], "%#{name}%")).first
        return reply(event, "You don't own an item matching `#{name}`.") unless item

        ds = ds.where(equipment_id: item.id)
      end
      count = ds.delete
      player.clamp_defiance!
      reply(event, "Deleted #{count} item(s).")
    end

    def grant_titles(event, player, key)
      keys = key == 'all' ? Engine::TitleSystem::TITLES.keys.dup : [key]
      unless Engine::Dev.owner?(event.user.id)
        if keys.include?('original_syn')
          return reply(event, '**The Original Syn** recognises one maker.') if key != 'all'

          keys -= ['original_syn']
        end
      end
      unknown = keys.reject { |k| Engine::TitleSystem::TITLES.key?(k) }
      return reply(event, "Unknown title `#{key}`. Keys: #{Engine::TitleSystem::TITLES.keys.join(', ')}") if unknown.any?

      player.update(titles: (player.earned_titles | keys))
      note = key == 'all' && !Engine::Dev.owner?(event.user.id) ? ' **The Original Syn** was left out.' : ''
      reply(event, "Granted #{keys.size} title(s).#{note}")
    end

    def grant_hybrids(event, player, key)
      all = Engine::TransformationSystem::TRANSFORMATIONS.keys
      return reply(event, 'Run `bundle exec rake db:migrate` first.') unless player.transformations_supported?

      if key == 'none'
        player.update(transformations: [], active_transformation: nil)
        return reply(event, 'All hybrid forms locked.')
      end

      keys = key == 'all' ? all.dup : [key]
      return reply(event, "Unknown form `#{key}`. Keys: #{all.join(', ')}") unless (keys - all).empty?

      unless Engine::Dev.owner?(event.user.id)
        if keys.include?('syn_fae')
          return reply(event, '**Syn Fae** recognises one maker.') if key != 'all'

          keys -= ['syn_fae']
        end
      end

      player.update(transformations: player.unlocked_transformations | keys)
      note = key == 'all' && !Engine::Dev.owner?(event.user.id) ? ' **Syn Fae** was left out.' : ''
      reply(event, "Unlocked #{keys.size} hybrid form(s).#{note}")
    end

    def grant_achievements(event, player, id)
      ids = id == 'all' ? Engine::TitleSystem::ACHIEVEMENTS.map { |a| a[:id] } : [id]
      unknown = ids.reject { |i| Engine::TitleSystem.achievement(i) }
      if unknown.any?
        return reply(event, "Unknown achievement `#{id}`. IDs: #{Engine::TitleSystem::ACHIEVEMENTS.map { |a| a[:id] }.join(', ')}")
      end

      player.update(achievements: (player.earned_achievements | ids))
      reply(event, "Granted #{ids.size} achievement(s) (no LP rewards).")
    end

    def win(event, player)
      enc = Eros.encounter_for(player)
      return reply(event, 'Not in combat.') unless enc

      debug_was = Engine::Dev.debug?(player)
      Eros.set_encounter!(player, enc.merge(hp: 1))
      Engine::Dev::DEBUG << player.discord_id
      begin
        Commands::Combat.run_action(event, :fight)
      ensure
        Engine::Dev::DEBUG.delete(player.discord_id) unless debug_was
      end
    end

    def force_event(event, player, key)
      keys = Engine::RandomEvents::EVENT_KEYS
      unless keys.include?(key)
        return reply(event, "Event keys:\n#{keys.map { |k| "`#{k}`" }.join(' ')}")
      end

      Eros.clear_encounter!(player)
      player.clear_event!
      result = Engine::RandomEvents.start!(player, key: key)
      Commands::Explore.render_event(event, player, result)
    end

    def force_npc(event, player, id, stage)
      if id == 'reset'
        player.set_tracker!(Engine::NPCSystem::PROGRESS_KEY, {})
        return reply(event, 'NPC progress wiped.')
      end
      spec = Engine::NPCSystem.npc(id)
      unless spec
        list = Engine::NPCSystem::NPCS.map { |k, s| "`#{k}` (#{s[:stages].size} stage#{'s' unless s[:stages].size == 1})" }
        progress = Engine::NPCSystem.progress(player).map { |k, v| "#{k}: #{v}" }
        finished = Engine::NPCSystem.finished_counts(player).map { |k, v| "#{k} ×#{v}" }
        return reply(event, "NPC ids:\n#{list.join(' ')}\n\nYour progress: #{progress.empty? ? 'none' : progress.join(', ')}\n" \
                            "Stories finished: #{finished.empty? ? 'none' : finished.join(', ')}")
      end

      note = nil
      if stage
        index = stage.to_i.clamp(1, spec[:stages].size) - 1
      else
        index = Engine::NPCSystem.next_stage_index(player, id)
        if index.nil?
          Engine::NPCSystem.set_progress!(player, id, nil)
          index = 0
          note = "#{spec[:name]}'s story was finished — restarting from stage 1."
        end
      end
      note ||= "#{spec[:name]}: stage #{index + 1}/#{spec[:stages].size}" \
               " _(progress: #{Engine::NPCSystem.progress(player)[id] || 'none'})_"
      reply(event, note)
      Eros.clear_encounter!(player)
      player.clear_event!
      result = Engine::NPCSystem.start!(player, id, index)
      Commands::Explore.render_event(event, player, result)
    end

    def next_boss_floor(player)
      floor = player.current_floor
      boss = ((floor + 4) / 5) * 5
      boss = [boss, 5].max
      boss += 5 if boss <= player.highest_boss_defeated.to_i
      [boss, Engine::Tower::FINAL_BOSS_FLOOR].min
    end

    def force_elite(event, player, key)
      key = Engine::Elites::AFFIXES.keys.sample if key.empty?
      unless Engine::Elites::AFFIXES.key?(key)
        return reply(event, "Elites: #{Engine::Elites::AFFIXES.keys.map { |k| "`#{k}`" }.join(', ')}")
      end

      Eros.clear_encounter!(player)
      player.clear_event!
      monster = Engine::MonsterTypes.generate_monster(player.current_floor, player: player, elite: false)
      Engine::Elites.apply!(monster, key)
      started = Engine::CombatEngine.start_encounter(player, monster: monster)
      Eros.set_encounter!(player, started[:encounter])
      ErosUI.reply_v2(event, colour: monster[:color], with_actions: :combat) do |c|
        c.text_display(content: started[:message])
      end
    end

    def set_week(event, key)
      if key.empty?
        list = Engine::Weekly.override_keys.map { |k| "`#{k}`" }.join(', ')
        return reply(event, "#{Engine::Weekly.status_line}\n\nOverride with `e,dev week <key>` (or `e,dev week auto`): #{list}")
      end

      Engine::Weekly.override!(key == 'auto' ? nil : key)
      reply(event, "#{Engine::Weekly.status_line}\n-# Override lasts until the bot restarts.")
    end

    def resolve_relic(text)
      raw = text.to_s.downcase.strip
      return nil if raw.empty?

      key = raw.gsub(/[^a-z0-9]+/, '_').gsub(/\Athe_/, '').gsub(/_+\z/, '')
      aliases = { 'saint' => 'drowned_saint', 'sin' => 'drowned_sin', 'bride' => 'pale_bride',
                  'mirror' => 'mirror_queen', 'confessional' => 'empty_confessional',
                  'chalice' => 'never_emptying_chalice', 'altar' => 'first_altar_stone',
                  'dragon' => 'hoardheart_dragon' }
      key = aliases[key] || key
      return key if Engine::BossFights::RELICS.key?(key)

      Engine::BossFights::RELICS.each do |relic_key, spec|
        name = spec[:name].to_s.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/\Athe_/, '').gsub(/_+\z/, '')
        return relic_key if name == key
      end
      nil
    end

    def relic_test_floor(player, key)
      spec = Engine::BossFights::RELICS[key]
      legal = [5, 10, 15, 20, 25, 30].reject { |floor| Engine::BossFights.dress_counsel_blocks_relic?(player, floor) }
      affinity = Array(spec[:affinity]).map(&:to_i)
      (affinity & legal).first || legal.first || affinity.first || 25
    end

    def force_relic(event, player, name)
      key = resolve_relic(name)
      unless key
        list = Engine::BossFights::RELICS.map { |relic_key, spec| "`#{relic_key}` — #{spec[:name]}" }
        head = name.to_s.strip.empty? ? 'Name a relic.' : "Unknown relic `#{name}`."
        return reply(event, "#{head}\n#{list.join("\n")}")
      end

      floor = relic_test_floor(player, key)
      raised = player.current_cycle.to_i < 2
      Eros.clear_encounter!(player)
      player.clear_event!
      player.update(current_cycle: 2) if raised
      player.note_floor_reached!(floor)
      player.update(highest_boss_defeated: floor - 5, sanctuary: false, pos_x: 0, pos_y: 0)
      Engine::BossFights.pin_relic!(player, floor, key)

      host = Engine::BossFights.boss_for_floor(floor)
      relic = Engine::BossFights::RELICS[key]
      started = Engine::BossFights.start_relic_encounter(player, floor, host, relic, key)
      enc = started[:encounter]
      enc = Engine::CombatEngine.encounter_snapshot(enc) unless enc.is_a?(Hash)
      Eros.set_encounter!(player, enc.merge(is_boss: true))

      forced = Engine::SaintQuest.forced_relic(player) if defined?(Engine::SaintQuest)
      aside = if raised
                "\n-# Cycle was under 2, so this jump set you to Cycle 2. Relics do not hold a throne before then."
              else
                ''
              end
      aside += "\n-# The story still calls **#{Engine::BossFights::RELICS.dig(forced, :name)}** on the next real boss floor." if forced && forced != key

      ErosUI.reply_v2(event, colour: relic[:color], with_actions: :combat) do |c|
        c.text_display(content: "#{started[:message]}#{aside}")
        c.separator(divider: true, spacing: :small)
        c.text_display(
          content: '**Boss fight!** Choose **Fight**, **Flee**, or **Submit**.' \
                   "\n-# Submitting is a gamble: land #{Engine::CombatEngine.boss_satisfy_needed(player)} successful " \
                   "submits to satisfy the boss for ×#{Engine::CombatEngine::BOSS_SATISFY_LP_MULT} LP — " \
                   "but it keeps attacking and you can't dodge while submitting."
        )
      end
    end

    def jump_to_boss(event, player, floor)
      Eros.clear_encounter!(player)
      player.clear_event!
      player.note_floor_reached!(floor)
      player.update(highest_boss_defeated: floor - 5, sanctuary: false)
      Commands::Explore.run(event)
    end

    string_select(custom_id: /^eros:dev:info:\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)
      next unless Engine::Dev.developer?(event.user.id)

      target_id = event.custom_id.split(':')[3].to_i
      player = Player[target_id]
      unless player
        ErosUI.reply_v2(event, ephemeral: true) { |container| container.text_display(content: "No delver for `#{target_id}`.") }
        next
      end

      Commands::Dev.show_info(event, player, Array(event.values).first.to_s)
    end

    command(:dev, help_available: false) do |event, sub, *args|
      next nil unless Engine::Dev.developer?(event.user.id)

      Commands::Dev.dispatch(event, sub, args)
      nil
    end
  end
end
