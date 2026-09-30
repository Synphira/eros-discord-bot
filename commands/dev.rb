# frozen_string_literal: true

module Commands
  module Dev
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
      `!dev debug` — toggle debug mode (one-hit kills, monsters never act, guaranteed flee/satisfy, traps avoided)
      `!dev info` — raw player + tracker dump
      `!dev set <level|lp|lust|defiance|str|agi|res|sub|floor|cycle> <n>`
      `!dev heal` — full defiance, base lust
      `!dev curse <name>` · `!dev uncurse <name|all>`
      `!dev item <name>` · `!dev unitem <name|all>` — grant / delete gear (cursed auto-binds)
      `!dev tracker <key> <n>` — set any tracker
      `!dev title <key|all>` · `!dev achievement <id|all>` · `!dev wipeprogress`
      `!dev hybrid <key|all|none>` — unlock hybrid forms (none = lock them all)
      `!dev unlockcursed` — unlock every Cursed Shop item
      `!dev win` — kill the current monster (runs the normal victory path)
      `!dev boss` — jump to the next boss floor and start the fight
      `!dev finalboss` — jump to the Tower Lord
      `!dev cycle` — complete the current cycle instantly
      `!dev reset` — run a defeat reset (keeps progression)
      `!dev event <key|list>` — start a specific random event (ignores content toggles)
      `!dev conditions [clear]` — show or clear temporary conditions
    TXT

    module_function

    def reply(event, text)
      ErosUI.reply_v2(event, colour: COLOUR) { |c| c.text_display(content: text[0, 3900]) }
    end

    def find_player(event)
      player = Player[event.user.id]
      reply(event, 'No delver — `!create` first.') unless player
      player
    end

    def dispatch(event, sub, args)
      sub = sub.to_s.downcase
      return reply(event, HELP) if sub.empty? || sub == 'help'

      if sub == 'debug'
        on = Engine::Dev.toggle_debug!(event.user.id)
        return reply(event, "Debug mode **#{on ? 'ON' : 'OFF'}**.")
      end

      player = find_player(event) or return
      case sub
      when 'info' then info(event, player)
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
      when 'conditions', 'condition'
        player.clear_conditions! if args[0].to_s.casecmp?('clear')
        list = player.condition_list.map { |c| "• **#{c['name']}** (#{c['floors']} floors) — #{c['summary']}" }
        reply(event, list.empty? ? 'No active conditions.' : list.join("\n"))
      else
        reply(event, "Unknown dev command `#{sub}`.\n\n#{HELP}")
      end
    end

    def info(event, player)
      player.refresh
      lines = [
        "**#{player.display_name}** (#{player.discord_id}) · debug #{Engine::Dev.debug?(player) ? 'ON' : 'off'}",
        "Lv #{player.level} · STR #{player.strength} AGI #{player.agility} RES #{player.resistance} SUB #{player.submission}",
        "Effective STR #{player.effective_strength} AGI #{player.effective_agility} RES #{player.effective_resistance}",
        "Defiance #{player.defiance}/#{player.max_defiance} · Lust #{player.lust} · LP #{player.lp}",
        "Cycle #{player.current_cycle} · Floor #{player.current_floor} · Highest boss #{player.highest_boss_defeated}",
        "Titles #{player.earned_titles.size} · Achievements #{player.earned_achievements.size}",
        "Preferences #{player.preferences.inspect}",
        "Sizes #{player.body_sizes.inspect}",
        "```json\n#{JSON.pretty_generate(player.tracker_hash)[0, 2500]}\n```"
      ]
      reply(event, lines.join("\n"))
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

    def give_item(event, player, name)
      Engine::Shop.sync_to_db!
      Engine::Treasure.sync_to_db!
      Engine::BossFights.sync_trophies!
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
      keys = key == 'all' ? Engine::TitleSystem::TITLES.keys : [key]
      unknown = keys.reject { |k| Engine::TitleSystem::TITLES.key?(k) }
      return reply(event, "Unknown title `#{key}`. Keys: #{Engine::TitleSystem::TITLES.keys.join(', ')}") if unknown.any?

      player.update(titles: (player.earned_titles | keys))
      reply(event, "Granted #{keys.size} title(s).")
    end

    def grant_hybrids(event, player, key)
      all = Engine::TransformationSystem::TRANSFORMATIONS.keys
      return reply(event, 'Run `bundle exec rake db:migrate` first.') unless player.transformations_supported?

      if key == 'none'
        player.update(transformations: [], active_transformation: nil)
        return reply(event, 'All hybrid forms locked.')
      end

      keys = key == 'all' ? all : [key]
      return reply(event, "Unknown form `#{key}`. Keys: #{all.join(', ')}") unless (keys - all).empty?

      player.update(transformations: player.unlocked_transformations | keys)
      reply(event, "Unlocked #{keys.size} hybrid form(s).")
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

    def next_boss_floor(player)
      floor = player.current_floor
      boss = ((floor + 4) / 5) * 5
      boss = [boss, 5].max
      boss += 5 if boss <= player.highest_boss_defeated.to_i
      [boss, Engine::Tower::FINAL_BOSS_FLOOR].min
    end

    def jump_to_boss(event, player, floor)
      Eros.clear_encounter!(player)
      player.clear_event!
      player.note_floor_reached!(floor)
      player.update(highest_boss_defeated: floor - 5, sanctuary: false)
      Commands::Explore.run(event)
    end

    command(:dev, help_available: false) do |event, sub, *args|
      next nil unless Engine::Dev.developer?(event.user.id)

      Commands::Dev.dispatch(event, sub, args)
      nil
    end
  end
end
