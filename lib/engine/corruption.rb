# frozen_string_literal: true

module Engine
  module Corruption
    module_function

    KEY = 'corruption'
    MAX = 20
    STAGES = [
      [5, 'Tainted',
       'A slow heat settles under your skin and stays there. You catch yourself staring at the next monster\'s crotch ' \
       'before you remember you are supposed to fight it.'],
      [10, 'Lewd',
       'Your body has stopped pretending. You are wet or hard almost all the time now, and every touch from the ' \
       'tower\'s creatures makes you lean in instead of pulling away.'],
      [15, 'Depraved',
       'Filthy thoughts fill every quiet moment. You find your legs parting before a monster even reaches you, ' \
       'and you have to drag yourself back to your senses.'],
      [20, 'Fully Corrupted',
       'The tower owns you now. Resisting feels foreign and begging feels natural, and every creature on the floor ' \
       'can smell how badly you want it.']
    ].freeze

    def enabled?(player)
      Engine::ContentOptions.enabled?(player, KEY)
    end

    def level(player)
      player.tracker(KEY)
    end

    def stage(value)
      STAGES.reverse.find { |threshold, _, _| value >= threshold }
    end

    def effects(value)
      tier = value / 5
      fx = { 'submit_lp_bonus' => value / 2, 'lust_mult' => (1 + (value * 0.015)).round(2) }
      fx['submission'] = tier if tier.positive?
      fx['resistance'] = -tier if tier.positive?
      fx
    end

    def status_line(player)
      return nil unless enabled?(player)

      value = level(player)
      name = stage(value)&.at(1) || (value.zero? ? 'Untouched' : 'Touched')
      line = "**Corruption — #{name}** `#{value}/#{MAX}`"
      line += " _(#{FetishEvents.describe_effects(effects(value))})_" if value.positive?
      line += "\n-# +1 each time you submit to a monster · resets on defeat"
      line
    end

    def add!(player, amount, log)
      return unless enabled?(player)

      old = level(player)
      value = (old + amount).clamp(0, MAX)
      return if value == old

      player.set_tracker!(KEY, value)
      refresh!(player)
      old_stage = stage(old)
      new_stage = stage(value)
      if new_stage && new_stage != old_stage && value > old
        log << { scene: new_stage[2] }
        log << "**Corruption — #{new_stage[1]}** _(#{value}/#{MAX})_: #{FetishEvents.describe_effects(effects(value))}"
      elsif amount.abs > 1
        log << "_Corruption **#{old} → #{value}**/#{MAX}._"
      end
    end

    def refresh!(player)
      value = level(player)
      list = player.condition_list.reject { |c| c['key'] == KEY }
      player.update(conditions: list)
      return if value.zero?

      name = stage(value)&.at(1) || 'Touched'
      fx = effects(value)
      player.add_condition!(KEY, name: "Corruption: #{name} (#{value}/#{MAX})", floors: 999, effects: fx,
                                 summary: FetishEvents.describe_effects(fx))
    end
  end
end
