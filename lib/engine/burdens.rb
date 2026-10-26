# frozen_string_literal: true

module Engine
  # Cycle burdens. At the start of a cycle (floor 1), a delver may take on
  # or shed up to three torments for the whole cycle. Each one multiplies
  # every LP gain by +25%. Oaths and paid rerolls may be adjusted mid-climb;
  # the three carried burdens themselves stay locked once you leave floor 1.
  module Burdens
    TRACKER = 'cycle_burdens'
    OATH_TRACKER = 'oath_burdens'
    MAX_BURDENS = 3
    MAX_OATHS = 2
    LP_PER_BURDEN = 0.25
    LP_PER_OATH = 0.10

    BURDENS = {
      'hungry_tower' => { name: 'Hungry Tower', description: 'Monsters’ lust hits land 15% harder',
                          effects: { 'lust_mult' => 1.15 },
                          ritual: 'Somewhere above you, the tower notices your hunger and answers it with ' \
                                  'its own. Every candle in the entry hall leans toward you at once.' },
      'glass_defiance' => { name: 'Glass Defiance', description: 'Max Defiance capped at 30 — two orgasms without recovery will break you',
                            effects: { 'defiance_cap' => 30 },
                            ritual: 'A pane of something clear and cold settles behind your eyes. The world ' \
                                    'does not get quieter. You just hear exactly how close the breaking sounds are.' },
      'slow_feet' => { name: 'Slow Feet', description: 'You cannot flee from combat, and traps always catch you',
                       effects: { 'no_flee' => true, 'no_trap_dodge' => true },
                       ritual: 'The floor takes your measure and keeps it. Your steps come back to you a ' \
                               'half-second late, like walking through someone else\'s dream of you.' },
      'tempting_dark' => { name: 'Tempting Dark', description: 'Monster rooms are 25% more common',
                           effects: { 'encounter_rate' => 1.25 },
                           ritual: 'The corridor lights dim with intent, and the dark — appreciative, ' \
                                   'expectant — moves a little closer than dark should.' },
      'branded_start' => { name: 'Branded Start', description: 'Begin the cycle wearing a fresh curse',
                           effects: {},
                           ritual: 'A warmth blooms somewhere intimate and entirely uninvited. The tower ' \
                                   'has signed the first page of you before you have even begun.' }
    }.freeze

    module_function

    def active(player)
      Array(player.tracker_hash[TRACKER]).select { |k| BURDENS.key?(k.to_s) }
    end

    # Oaths are extra burdens sworn beyond the usual three, for a
    # smaller LP bonus each. They torment exactly like burdens, but
    # they are tracked apart so they never count toward the Burdens
    # Carried honours — devotion is its own category.
    def oaths(player)
      Array(player.tracker_hash[OATH_TRACKER]).select { |k| BURDENS.key?(k.to_s) } - active(player)
    end

    def carried(player)
      active(player) + oaths(player)
    end

    def active?(player, key)
      carried(player).include?(key.to_s)
    end

    def lp_multiplier(player)
      1.0 + (active(player).size * LP_PER_BURDEN) + (oaths(player).size * LP_PER_OATH)
    end

    def effects(player)
      merged = {}
      carried(player).each do |key|
        BURDENS[key][:effects].each { |k, v| merged[k.to_s] = v }
      end
      merged
    end

    def ritual_line(key)
      spec = BURDENS[key.to_s] or return nil

      "_#{spec[:ritual]}_"
    end

    def at_threshold?(player)
      player.current_floor.to_i <= 1
    end

    def free?(player)
      !player.in_combat && !player.active_event?
    end

    # Manual take/shed of the three cycle burdens — floor 1 only.
    def changeable?(player)
      at_threshold?(player) && free?(player)
    end

    # Oaths may be sworn or released on any floor (outside combat/events).
    def oaths_changeable?(player)
      free?(player)
    end

    # Paid shuffle of a carried burden — any floor (outside combat/events).
    def rerollable?(player)
      free?(player)
    end

    def toggle!(player, key)
      return { ok: false, message: 'Unknown burden.' } unless BURDENS.key?(key.to_s)
      unless changeable?(player)
        return { ok: false, message: 'Burdens are chosen at the start of a cycle. Yours are set until you clear the tower.' }
      end

      list = active(player)
      if list.include?(key.to_s)
        player.update(trackers: player.tracker_hash.merge(TRACKER => list - [key.to_s]))
        player.clamp_defiance!
        { ok: true, message: "Burden shed: **#{BURDENS[key.to_s][:name]}**. Eros pouts, but allows it — this once, at the threshold." }
      elsif list.size >= MAX_BURDENS
        { ok: false, message: "You may carry at most #{MAX_BURDENS} burdens." }
      else
        player.update(trackers: player.tracker_hash.merge(TRACKER => list + [key.to_s]))
        player.clamp_defiance!
        { ok: true, message: "Burden taken: **#{BURDENS[key.to_s][:name]}** — #{BURDENS[key.to_s][:description]}. " \
                              "Every LP gain this cycle is now ×#{format('%.2f', lp_multiplier(player))}.\n" \
                              "#{ritual_line(key)}" }
      end
    end

    def toggle_oath!(player, key)
      return { ok: false, message: 'Unknown burden.' } unless BURDENS.key?(key.to_s)
      unless oaths_changeable?(player)
        return { ok: false, message: 'Oaths cannot be changed mid-fight or mid-event. Finish that first.' }
      end

      list = oaths(player)
      if list.include?(key.to_s)
        player.update(trackers: player.tracker_hash.merge(OATH_TRACKER => list - [key.to_s]))
        player.clamp_defiance!
        { ok: true, message: "Oath released: **#{BURDENS[key.to_s][:name]}**. Devotion can be renegotiated — " \
                              'this once, she allows it.' }
      elsif active(player).include?(key.to_s)
        { ok: false, message: "**#{BURDENS[key.to_s][:name]}** is already a carried burden — an oath must be a new torment." }
      elsif list.size >= MAX_OATHS
        { ok: false, message: "You may swear at most #{MAX_OATHS} oaths." }
      else
        player.update(trackers: player.tracker_hash.merge(OATH_TRACKER => list + [key.to_s]))
        player.clamp_defiance!
        { ok: true, message: "Oath sworn: **#{BURDENS[key.to_s][:name]}** — #{BURDENS[key.to_s][:description]}. " \
                              "Every LP gain this cycle is now ×#{format('%.2f', lp_multiplier(player))}.\n" \
                              "#{ritual_line(key)}" }
      end
    end

    REROLL_BASE = 150
    REROLL_STEP = 50

    # Escalates mid-climb; resets to 0 on floor 1 (same window as manual burden select).
    def rerolls_this_climb(player)
      return 0 if at_threshold?(player)

      saved = player.tracker_hash['burden_rerolls']
      saved.is_a?(Hash) && saved['cycle'].to_i == player.current_cycle.to_i ? saved['count'].to_i : 0
    end

    def reroll_price(player)
      player.lp_price(REROLL_BASE + (REROLL_STEP * rerolls_this_climb(player)))
    end

    # Pool for a shuffle: never a burden already carried, never an oath,
    # never the one being lifted (still in `list` until replaced).
    def reroll_pool(player, list = active(player))
      BURDENS.keys - list - oaths(player)
    end

    # Shuffle one carried burden into a different one — any floor, for a
    # price that climbs with each mid-climb shuffle and resets on floor 1.
    def reroll!(player, key)
      return { ok: false, message: 'Unknown burden.' } unless BURDENS.key?(key.to_s)
      unless rerollable?(player)
        return { ok: false, message: 'Burdens cannot be shuffled mid-fight or mid-event. Finish that first.' }
      end

      list = active(player)
      unless list.include?(key.to_s)
        return { ok: false, message: "You are not carrying **#{BURDENS[key.to_s][:name]}**." }
      end

      pool = reroll_pool(player, list)
      if pool.empty?
        return { ok: false, message: 'Nothing left to shuffle into — every other torment is already a ' \
                                     'burden or an oath.' }
      end

      price = reroll_price(player)
      if player.lp < price
        return { ok: false, message: "Shuffling **#{BURDENS[key.to_s][:name]}** costs **#{price} LP** — you have #{player.lp}." }
      end

      new_key = pool.sample
      player.spend_lp!(price, already_priced: true)
      player.bump_tracker!('burden_rerolls_total')
      # Floor 1 keeps the escalator at 0; mid-climb increments.
      next_count = at_threshold?(player) ? 0 : rerolls_this_climb(player) + 1
      player.update(trackers: player.tracker_hash.merge(
                      TRACKER => (list - [key.to_s]) + [new_key],
                      'burden_rerolls' => { 'cycle' => player.current_cycle.to_i, 'count' => next_count }
                    ))
      player.clamp_defiance!
      { ok: true,
        message: "Eros shuffles your torment: **#{BURDENS[key.to_s][:name]}** is lifted, and " \
                 "**#{BURDENS[new_key][:name]}** settles in its place — #{BURDENS[new_key][:description]}. " \
                 "_(#{price} LP; the next shuffle costs #{reroll_price(player)} LP" \
                 "#{at_threshold?(player) ? ' — price resets while you are on floor 1' : ''}.)_" }
    end

    def apply_branded_start!(player)
      return nil unless active?(player, 'branded_start')

      player.apply_curse!(chance: 1.0)
    end
  end
end
