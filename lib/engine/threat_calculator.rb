# frozen_string_literal: true

module Engine
  class ThreatCalculator
    LOW_THRESHOLD = 40
    HIGH_THRESHOLD = 75

    LP_MAX = 60.0
    LP_SCALE_BASE = 300.0
    LP_SCALE_PER_LEVEL = 40.0
    CURSE_WEIGHT = 8
    CURSE_MAX = 40

    Result = Struct.new(
      :percent, :category, :lp_component, :curse_component,
      :stat_mult, :lust_mult, :encounter_bonus,
      keyword_init: true
    )

    def self.calculate(player)
      new(player).calculate
    end

    def self.monster_modifiers(player)
      calculate(player)
    end

    def initialize(player)
      @player = player
    end

    def calculate
      scale = LP_SCALE_BASE + (LP_SCALE_PER_LEVEL * @player.level.to_i)
      lp_component = LP_MAX * (1 - Math.exp(-[@player.lp.to_f, 0].max / scale))
      curse_component = [@player.active_curse_count * CURSE_WEIGHT, CURSE_MAX].min
      percent = [(lp_component + curse_component), 100].min.round(1)
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

    def stat_multiplier(percent, category)
      continuous = 0.85 + (percent / 100.0) * 0.75
      floor =
        case category
        when :low then 0.85
        when :medium then 1.0
        when :high then 1.25
        else 1.0
        end
      [[continuous, floor].max, 1.85].min.round(3)
    end

    def lust_multiplier(percent, category)
      continuous = 0.9 + (percent / 100.0) * 1.0
      floor =
        case category
        when :low then 0.9
        when :medium then 1.05
        when :high then 1.35
        else 1.0
        end
      [[continuous, floor].max, 2.25].min.round(3)
    end

    def encounter_bonus(percent, category)
      bonus = (percent / 5.0).round
      category_floor = { low: 0, medium: 5, high: 12 }.fetch(category, 0)
      [[bonus, category_floor].max, 25].min
    end
  end
end
