# frozen_string_literal: true

require_relative 'seasons'

module Engine
  module Weekly
    module_function

    WEEK = 7 * 24 * 3600
    MONDAY_OFFSET = 4 * 24 * 3600

    MODIFIERS = [
      { key: 'heat_week', name: 'Heat Week',
        description: 'The whole tower is in heat. Lust taken ×1.15, and +2 LP every time you submit.',
        effects: { 'lust_mult' => 1.15, 'submit_lp_bonus' => 2 } },
      { key: 'hunting_season', name: 'Hunting Season',
        description: 'Elite monsters turn up three times as often.',
        special: { 'elite_chance' => 3.0 } },
      { key: 'full_moon', name: 'Full Moon',
        description: 'Beasts roam everywhere and rut harder: twice as many beasts, beast lust ×1.2, +3 LP submitting to beasts.',
        effects: { 'beast_lust_mult' => 1.2, 'beast_submit_lp' => 3 }, monsters: { beast: 2.0 } },
      { key: 'mimic_season', name: 'Mimic Season',
        description: 'Cursed gear stirs half again as often, but chests hold +5 LP more.',
        effects: { 'treasure_lp' => 5 }, special: { 'mimic_chance' => 1.5 } },
      { key: 'temptation_week', name: 'Week of Temptation',
        description: 'Random events turn up 50% more often.',
        special: { 'event_rate' => 1.5 } },
      { key: 'generous_tower', name: 'Generous Tower',
        description: '+3 LP every time a fight ends, and +1 LP for every floor you descend.',
        effects: { 'victory_lp_bonus' => 3, 'explore_lp' => 1 } },
      { key: 'slime_tide', name: 'Slime Tide',
        description: 'Slimes ooze out of every crack: slimes appear far more often, hit softer (lust ×0.85), and +3 LP submitting to them.',
        effects: { 'slime_lust_mult' => 0.85, 'slime_submit_lp' => 3 }, monsters: { slime: 2.5 } },
      { key: 'spring_bloom', name: 'Spring Bloom',
        description: 'The tower blossoms: plants appear far more often, and +3 LP submitting to them.',
        effects: { 'plant_submit_lp' => 3 }, monsters: { plant: 2.5 } }
    ].freeze

    @override = nil

    def override!(key)
      key = key&.to_s
      if key.nil? || key.empty? || key == 'auto'
        @override = nil
        Engine::Seasons.force!(nil)
        return nil
      end

      if key == 'friday_13' || Engine::Seasons.pack(key)
        @override = nil
        Engine::Seasons.force!(key)
        return key
      end

      Engine::Seasons.force!(nil)
      @override = MODIFIERS.find { |m| m[:key] == key } ? key : nil
    end

    def week_index(now = Time.now)
      (now.to_i - MONDAY_OFFSET) / WEEK
    end

    # Back-compat for anything still asking the old Halloween helper.
    def halloween_window?(now = Time.now)
      Engine::Seasons.active?(:halloween, now)
    end

    def halloween_ends_at(now = Time.now)
      pack = Engine::Seasons.pack('halloween')
      pack ? pack.ends_at(now) : Time.new(now.year, 11, 6).to_i
    end

    def current(now = Time.now)
      if @override
        return MODIFIERS.find { |m| m[:key] == @override }
      end

      seasonal = Engine::Seasons.weekly_for(now)
      return seasonal if seasonal

      MODIFIERS[week_index(now) % MODIFIERS.size]
    end

    def ends_at(now = Time.now)
      return ((week_index(now) + 1) * WEEK) + MONDAY_OFFSET if @override

      seasonal_end = Engine::Seasons.ends_at(now)
      return seasonal_end if seasonal_end

      ((week_index(now) + 1) * WEEK) + MONDAY_OFFSET
    end

    def effects
      current[:effects] || {}
    end

    def special(key, default = 1.0)
      base = current.dig(:special, key.to_s) || default
      return base unless Engine::Seasons.friday_13?

      # Unlucky Friday: lean into elites and events a little harder.
      case key.to_s
      when 'elite_chance', 'event_rate', 'mimic_chance' then base.to_f * 1.25
      else base
      end
    end

    def monster_weight(type)
      current.dig(:monsters, type.to_sym) || 1.0
    end

    def status_line
      mod = current
      seasonal = Engine::Seasons.active
      label = seasonal && mod[:key] == seasonal.key.to_s ? 'This season' : 'This week'
      line = "**#{label} — #{mod[:name]}:** #{mod[:description]}\n-# Changes <t:#{ends_at}:R>."
      if Engine::Seasons.friday_13?
        line += "\n**Also — Friday the 13th:** the temple is feeling unlucky (elites, events, and mimics lean harder today)."
      end
      line
    end

    def override_keys
      MODIFIERS.map { |m| m[:key] } + Engine::Seasons.season_keys + %w[friday_13]
    end
  end
end
