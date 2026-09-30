# frozen_string_literal: true

module Engine
  module Tower
    FLOORS_PER_BOSS = 5
    FINAL_BOSS_FLOOR = 35
    BOSS_FLOORS = [5, 10, 15, 20, 25, 30, FINAL_BOSS_FLOOR].freeze

    CYCLE_STEP = 0.2
    CLEAR_LP_PER_CYCLE = 500

    module_function

    def boss_floor?(floor)
      floor = floor.to_i
      floor >= FINAL_BOSS_FLOOR || BOSS_FLOORS.include?(floor)
    end

    def final_boss_floor?(floor)
      floor.to_i >= FINAL_BOSS_FLOOR
    end

    def cycle_multiplier(cycle)
      1.0 + (CYCLE_STEP * ([cycle.to_i, 1].max - 1))
    end

    def clear_reward_lp(cycle)
      CLEAR_LP_PER_CYCLE * [cycle.to_i, 1].max
    end
  end
end
