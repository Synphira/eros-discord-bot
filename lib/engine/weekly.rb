# frozen_string_literal: true

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
      @override = key && MODIFIERS.find { |m| m[:key] == key.to_s } ? key.to_s : nil
    end

    def week_index(now = Time.now)
      (now.to_i - MONDAY_OFFSET) / WEEK
    end

    def current(now = Time.now)
      return MODIFIERS.find { |m| m[:key] == @override } if @override

      MODIFIERS[week_index(now) % MODIFIERS.size]
    end

    def ends_at(now = Time.now)
      ((week_index(now) + 1) * WEEK) + MONDAY_OFFSET
    end

    def effects
      current[:effects] || {}
    end

    def special(key, default = 1.0)
      current.dig(:special, key.to_s) || default
    end

    def monster_weight(type)
      current.dig(:monsters, type.to_sym) || 1.0
    end

    def status_line
      mod = current
      "**This week — #{mod[:name]}:** #{mod[:description]}\n-# Changes <t:#{ends_at}:R>."
    end
  end
end
