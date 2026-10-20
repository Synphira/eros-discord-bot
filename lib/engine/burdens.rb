# frozen_string_literal: true

module Engine
  # Cycle burdens. At the start of a cycle (floor 1), a delver may take on
  # up to three torments for the whole cycle. Each one multiplies every LP
  # gain by +25%. They can only be chosen or shed at a cycle's start —
  # Eros does not let her pets renegotiate mid-climb.
  module Burdens
    TRACKER = 'cycle_burdens'
    MAX_BURDENS = 3
    LP_PER_BURDEN = 0.25

    BURDENS = {
      'hungry_tower' => { name: 'Hungry Tower', description: 'Monsters’ lust hits land 15% harder',
                          effects: { 'lust_mult' => 1.15 } },
      'glass_defiance' => { name: 'Glass Defiance', description: '−10 max Defiance',
                            effects: { 'max_hp' => -10 } },
      'slow_feet' => { name: 'Slow Feet', description: '−1 agility', effects: { 'agility' => -1 } },
      'tempting_dark' => { name: 'Tempting Dark', description: 'Monster rooms are 25% more common',
                           effects: { 'encounter_rate' => 1.25 } },
      'branded_start' => { name: 'Branded Start', description: 'Begin the cycle wearing a fresh curse',
                           effects: {} }
    }.freeze

    module_function

    def active(player)
      Array(player.tracker_hash[TRACKER]).select { |k| BURDENS.key?(k.to_s) }
    end

    def active?(player, key)
      active(player).include?(key.to_s)
    end

    def lp_multiplier(player)
      1.0 + (active(player).size * LP_PER_BURDEN)
    end

    def effects(player)
      merged = {}
      active(player).each do |key|
        BURDENS[key][:effects].each { |k, v| merged[k.to_s] = v }
      end
      merged
    end

    def changeable?(player)
      player.current_floor.to_i <= 1 && !player.in_combat && !player.active_event?
    end

    def toggle!(player, key)
      return { ok: false, message: 'Unknown burden.' } unless BURDENS.key?(key.to_s)
      unless changeable?(player)
        return { ok: false, message: 'Burdens are chosen at the start of a cycle. Yours are set until you clear the tower.' }
      end

      list = active(player)
      if list.include?(key.to_s)
        player.update(trackers: player.tracker_hash.merge(TRACKER => list - [key.to_s]))
        { ok: true, message: "Burden shed: **#{BURDENS[key.to_s][:name]}**. Eros pouts, but allows it — this once, at the threshold." }
      elsif list.size >= MAX_BURDENS
        { ok: false, message: "You may carry at most #{MAX_BURDENS} burdens." }
      else
        player.update(trackers: player.tracker_hash.merge(TRACKER => list + [key.to_s]))
        { ok: true, message: "Burden taken: **#{BURDENS[key.to_s][:name]}** — #{BURDENS[key.to_s][:description]}. " \
                              "Every LP gain this cycle is now ×#{format('%.2f', lp_multiplier(player))}." }
      end
    end

    def apply_branded_start!(player)
      return nil unless active?(player, 'branded_start')

      player.apply_curse!(chance: 1.0)
    end
  end
end
