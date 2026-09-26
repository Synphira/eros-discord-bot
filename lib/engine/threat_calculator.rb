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

    Result = Struct.new(:percent, :category, :lp_component, :curse_component, keyword_init: true)

    def self.calculate(player)
      new(player).calculate
    end

    def initialize(player)
      @player = player
    end

    def calculate
      base = [@player.max_lp_base, 1].max
      lp_component = (@player.lp.to_f / base * 100)
      curse_component = @player.active_curse_count * 15
      percent = (lp_component + curse_component).round(1)

      Result.new(
        percent: percent,
        category: categorize(percent),
        lp_component: lp_component.round(1),
        curse_component: curse_component
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
  end
end
