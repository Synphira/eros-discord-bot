# frozen_string_literal: true

module Engine
  # Permanent "I was there" marks. A season badge is granted only when one of
  # that season's counters increases while the pack is active. Nothing removes
  # a season key. Staff badges follow the role and are rewritten on view.
  module Badges
    STAFF = %w[developer debugger].freeze

    # Shown only when held. A locked row would spoil how it was earned.
    STORY = [
      { key: 'saint_returned', name: 'The Pull', emoji: '<:Dark_Secrets:1567992033937854639>' }
    ].freeze

    SEASONS = [
      { key: 'valentines', name: 'Heartstring', emoji: '<:Heartstring_Claim:1567996693255823511>',
        trackers: %w[valentines_submits valentines_hearts_eaten valentine_events heartbreak_events] },
      { key: 'mardi_gras', name: 'Carnival', emoji: '<:Carnival_of_Beads:1567996617951416451>',
        trackers: %w[mardi_gras_submits mardi_gras_cake_eaten carnival_events parade_filth_events] },
      { key: 'easter', name: "Hare's Hunt", emoji: '<:Hares_Hunt:1567996544207032530>',
        trackers: %w[easter_submits easter_eggs_eaten easter_hunt_events spring_rut_events] },
      { key: 'april_fools', name: "Fool's Trap", emoji: '<:Fools_Trap:1567996477505151137>',
        trackers: %w[april_fools_submits april_fools_sweets_eaten april_prank_events cruel_prank_events] },
      { key: 'may_day', name: 'Maypole', emoji: '<:Maypole_Raising:1567996410778099743>',
        trackers: %w[may_day_submits may_day_wine_eaten maypole_events maypole_bind_events] },
      { key: 'midsummer', name: 'Longest Day', emoji: '<:Longest_Day:1567996047312298095>',
        trackers: %w[midsummer_submits midsummer_honey_eaten midsummer_events fairy_ring_events] },
      { key: 'pride', name: 'Parade', emoji: '<:Pride_Parade:1567995360570245201>',
        trackers: %w[pride_submits pride_glitter_eaten pride_events pride_excess_events] },
      { key: 'labor_day', name: 'Field Test', emoji: '<:Pips_Slow_Spell:1567996288245440643>',
        trackers: %w[labor_day_submits] },
      { key: 'halloween', name: 'All Hallows', emoji: '<:All_Hallows_Heat:1567991700704460831>',
        trackers: %w[halloween_submits halloween_candy_eaten trick_or_treat_events halloween_scare_events] },
      { key: 'thanksgiving', name: 'The Feast', emoji: '<:Feast_of_the_Willing:1567992335109853407>',
        trackers: %w[thanksgiving_submits thanksgiving_leftovers_eaten feast_table_events feast_excess_events] },
      { key: 'christmas', name: 'Yule', emoji: '<:Yule_of_Surrender:1567996211737403423>',
        trackers: %w[christmas_submits christmas_candy_eaten mistletoe_events naughty_list_events] },
      { key: 'new_year', name: 'Midnight', emoji: '<:Midnight_Oath:1567996158444568726>',
        trackers: %w[new_year_submits new_year_bubbles_eaten midnight_events resolution_events] }
    ].freeze

    STAFF_MARKS = {
      'developer' => { name: 'Developer', emoji: '<:Developer:1567991747462697060>' },
      'debugger' => { name: 'Debugger', emoji: '<:Debugger:1567991787836936334>' }
    }.freeze

    SEASON_BY_TRACKER = SEASONS.each_with_object({}) do |row, map|
      row[:trackers].each { |tracker| map[tracker] = row[:key] }
    end.freeze

    module_function

    def held(player)
      Array(player.tracker_hash['badges']).map(&:to_s)
    end

    def holds?(player, key)
      held(player).include?(key.to_s)
    end

    # Called from Player#bump_tracker! after the counter increases.
    # Seasonal counters only move while their pack is active, so this does
    # not check the calendar itself.
    def note_tracker!(player, key)
      season = SEASON_BY_TRACKER[key.to_s]
      return unless season
      return unless player.tracker(key).positive?
      return if holds?(player, season)

      player.remember!('badges', season)
    end

    # While a season is the one currently running, progress already on the
    # delver counts. Counters only move during the event, and they are not
    # read once that event is over, so a past season does not grant itself
    # in the off-week.
    def grant_active!(player)
      return unless player

      pack = Engine::Seasons.active
      return unless pack.respond_to?(:key)

      row = SEASONS.find { |season| season[:key] == pack.key.to_s }
      return unless row
      return if holds?(player, row[:key])
      return unless row[:trackers].any? { |tracker| player.tracker(tracker).positive? }

      player.remember!('badges', row[:key])
    end

    def sync_staff!(player)
      return unless player

      id = player.discord_id
      staff = []
      dev = Engine::Dev.owner?(id) || Engine::Dev.co_developer?(id)
      staff << 'developer' if dev
      staff << 'debugger' if dev || Engine::Dev.bug_tester?(id)
      seasons = held(player) - STAFF
      updated = staff + seasons
      return if updated == held(player)

      player.set_tracker!('badges', updated)
    end

    def ordered(player)
      keys = held(player)
      staff = STAFF.select { |key| keys.include?(key) }
      story = STORY.map { |row| row[:key] }.select { |key| keys.include?(key) }
      seasons = SEASONS.map { |row| row[:key] }.select { |key| keys.include?(key) }
      staff + story + seasons
    end

    def emoji_for(key)
      STAFF_MARKS.dig(key, :emoji) ||
        SEASONS.find { |row| row[:key] == key }&.dig(:emoji) ||
        STORY.find { |row| row[:key] == key }&.dig(:emoji)
    end

    def profile_line(player)
      marks = ordered(player).filter_map { |key| emoji_for(key) }
      return nil if marks.empty?

      "**Badges** #{marks.join(' ')}"
    end

    def season_title(key)
      pack = Engine::Seasons.pack(key)
      pack.respond_to?(:name) ? pack.name : key
    end

    def page_lines(player)
      lines = []
      ordered(player).each do |key|
        mark = STAFF_MARKS[key]
        lines << "#{mark[:emoji]} **#{mark[:name]}**" if mark
      end
      STORY.each do |row|
        lines << "#{row[:emoji]} **#{row[:name]}**" if holds?(player, row[:key])
      end
      SEASONS.each do |row|
        title = season_title(row[:key])
        if holds?(player, row[:key])
          lines << "#{row[:emoji]} **#{row[:name]}** — _#{title}_"
        else
          lines << "_#{title}_ — not earned"
        end
      end
      lines
    end
  end
end
