# frozen_string_literal: true

module Engine
  module ProfileSystem
    STATS = {
      'cycles' => {
        label: 'Cycles Completed',
        value: ->(p) { p.tracker('cycles_completed') },
        format: ->(v) { "#{v} cycle#{'s' unless v == 1}" }
      },
      'depth' => {
        label: 'Deepest Reached',
        value: ->(p) { [p.tracker('deepest_depth'), p.depth_for(1, p.highest_floor_reached)].max },
        format: ->(v) { Player.depth_label(v) }
      },
      'kills' => {
        label: 'Monsters Defeated',
        value: ->(p) { p.tracker('monsters_killed') },
        format: ->(v) { "#{v} kills" }
      },
      'lp' => {
        label: 'LP Earned',
        value: ->(p) { p.tracker('lp_earned') },
        format: ->(v) { "#{v} LP" }
      }
    }.freeze

    DEFAULT_STAT = 'cycles'

    module_function

    def normalize_stat(stat)
      STATS.key?(stat.to_s) ? stat.to_s : DEFAULT_STAT
    end

    def ranked(stat)
      spec = STATS.fetch(normalize_stat(stat))
      Player.exclude(character_name: nil).all
            .map { |p| { player: p, value: spec[:value].call(p) } }
            .sort_by { |row| [-row[:value], row[:player].character_name.downcase] }
    end

    def leaderboard(stat, limit: 10)
      ranked(stat).first(limit)
    end

    def rank_of(player, stat)
      index = ranked(stat).index { |row| row[:player].discord_id == player.discord_id }
      index && index + 1
    end

    def format_value(stat, value)
      STATS.fetch(normalize_stat(stat))[:format].call(value)
    end
  end
end
