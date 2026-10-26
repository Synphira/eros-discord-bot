# frozen_string_literal: true

module Engine
  module Weekly
    module_function

    WEEK = 7 * 24 * 3600
    MONDAY_OFFSET = 4 * 24 * 3600

    # Day before Halloween (Oct 30) through Nov 5 inclusive — seven nights.
    HALLOWEEN = {
      key: 'halloween',
      name: "All Hallows' Heat",
      description: 'The temple puts on a mask: undead and demons throng the halls, lust runs hotter (×1.1), ' \
                   'undead lust ×1.2, +3 LP submitting to undead / +2 to demons, elites ×1.5, and events 25% more often. ' \
                   'Mimics stir, biomes lean haunted, pumpkin altars and trick-or-treat rooms appear, Vex stocks costumes, ' \
                   'and candy/titles/gear you earn stay after the season.',
      effects: {
        'lust_mult' => 1.1,
        'undead_lust_mult' => 1.2,
        'undead_submit_lp' => 3,
        'demon_submit_lp' => 2
      },
      monsters: { undead: 2.0, demon: 1.5, mimic: 1.35 },
      special: { 'elite_chance' => 1.5, 'event_rate' => 1.25, 'mimic_chance' => 1.25 }
    }.freeze

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
        effects: { 'plant_submit_lp' => 3 }, monsters: { plant: 2.5 } },
      HALLOWEEN
    ].freeze

    @override = nil

    def override!(key)
      @override = key && MODIFIERS.find { |m| m[:key] == key.to_s } ? key.to_s : nil
    end

    def week_index(now = Time.now)
      (now.to_i - MONDAY_OFFSET) / WEEK
    end

    # Oct 30 00:00 … Nov 6 00:00 (local server time) — day-before Halloween + one week.
    def halloween_window?(now = Time.now)
      start = Time.new(now.year, 10, 30)
      finish = Time.new(now.year, 11, 6)
      now >= start && now < finish
    end

    def halloween_ends_at(now = Time.now)
      Time.new(now.year, 11, 6).to_i
    end

    def current(now = Time.now)
      return MODIFIERS.find { |m| m[:key] == @override } if @override
      return HALLOWEEN if halloween_window?(now)

      MODIFIERS.reject { |m| m[:key] == 'halloween' }[week_index(now) % (MODIFIERS.size - 1)]
    end

    def ends_at(now = Time.now)
      return halloween_ends_at(now) if !@override && halloween_window?(now)

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
      label = mod[:key] == 'halloween' ? 'This season' : 'This week'
      "**#{label} — #{mod[:name]}:** #{mod[:description]}\n-# Changes <t:#{ends_at}:R>."
    end
  end
end
