# frozen_string_literal: true

module Engine
  # ThreatCalculator — how dangerous the dungeon currently treats this player.
  #
  # Formula (from design bible):
  #   Threat % = (Current LP / Max LP Base * 100) + (Active Curses Count * 15)
  #   Active = curses where is_suppressed is false.
  #
  # Categories (sensible thresholds):
  #   :low    — Threat < 40   Quiet corridors; weaker encounters.
  #   :medium — 40 ≤ Threat < 75   Standard pressure; balanced risks.
  #   :high   — Threat ≥ 75   The Abyss notices you; brutal encounters.
  #
  class ThreatCalculator
    LOW_THRESHOLD = 40
    HIGH_THRESHOLD = 75

    Result = Struct.new(
      :percent, :category, :lp_component, :curse_component,
      :stat_mult, :lust_mult, :encounter_bonus,
      keyword_init: true
    )

    def self.calculate(player)
      new(player).calculate
    end

    # Convenience: modifiers used when spawning / weighting monsters.
    def self.monster_modifiers(player)
      calculate(player)
    end

    def initialize(player)
      @player = player
    end

    def calculate
      base = [@player.max_lp_base, 1].max
      lp_component = (@player.lp.to_f / base * 100)
      curse_component = @player.active_curse_count * 15
      percent = (lp_component + curse_component).round(1)
      category = categorize(percent)

      Result.new(
        percent: percent,
        category: category,
        lp_component: lp_component.round(1),
        curse_component: curse_component,
        stat_mult: stat_multiplier(percent, category),
        lust_mult: lust_multiplier(percent, category),
        encounter_bonus: encounter_bonus(percent, category)
      )
    end

    def categorize(percent)
      if percent < LOW_THRESHOLD
        :low
      elsif percent < HIGH_THRESHOLD
        :medium
      else
        :high
      end
    end

    # HP / STR / AGI — high threat makes foes tankier and hit harder.
    def stat_multiplier(percent, category)
      continuous = 0.85 + (percent / 100.0) * 0.75 # ~0.85 at 0 → ~1.6 at 100
      floor =
        case category
        when :low then 0.85
        when :medium then 1.0
        when :high then 1.25
        else 1.0
        end
      [[continuous, floor].max, 1.85].min.round(3)
    end

    # Lust hits — high threat means more aggressive assaults.
    def lust_multiplier(percent, category)
      continuous = 0.9 + (percent / 100.0) * 1.0 # ~0.9 at 0 → ~1.9 at 100
      floor =
        case category
        when :low then 0.9
        when :medium then 1.05
        when :high then 1.35
        else 1.0
        end
      [[continuous, floor].max, 2.25].min.round(3)
    end

    # Extra percentage points toward monster rooms on explore.
    def encounter_bonus(percent, category)
      bonus = (percent / 5.0).round
      category_floor = { low: 0, medium: 5, high: 12 }.fetch(category, 0)
      [[bonus, category_floor].max, 25].min
    end
  end
end
