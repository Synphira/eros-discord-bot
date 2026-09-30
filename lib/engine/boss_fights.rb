require_relative 'tower'

module Engine
  module BossFights
    BOSSES = {
      5 => {
        name: 'Mimic Broodmother',
        type: 'mimic',
        type_name: 'Mimic',
        description: 'A massive mimic that spawns smaller mimics to defend it',
        color: 0x696969,
        strength: 12,
        agility: 4,
        lust_damage: 15,
        hp: 80,
        max_hp: 80,
        special: 'spawns_minions'
      },
      10 => {
        name: 'Succubus Queen',
        type: 'demon',
        type_name: 'Demon',
        description: 'The ruler of all succubi, she dominates all who approach',
        color: 0xff00ff,
        strength: 15,
        agility: 12,
        lust_damage: 20,
        hp: 100,
        max_hp: 100,
        special: 'seductive_gaze'
      },
      15 => {
        name: 'Incubus King',
        type: 'demon',
        type_name: 'Demon',
        description: 'A powerful incubus who claims all who enter his domain',
        color: 0x800080,
        strength: 18,
        agility: 10,
        lust_damage: 25,
        hp: 120,
        max_hp: 120,
        special: 'dominating_presence'
      },
      20 => {
        name: 'Ancient Treant',
        type: 'plant',
        type_name: 'Plant',
        description: 'An ancient tree-like being that roots itself in its victims',
        color: 0x228b22,
        strength: 20,
        agility: 6,
        lust_damage: 18,
        hp: 150,
        max_hp: 150,
        special: 'root_grasp'
      },
      25 => {
        name: 'Lich Lord',
        type: 'undead',
        type_name: 'Undead',
        description: 'An immortal master of necromancy who commands the dead',
        color: 0x4b0082,
        strength: 22,
        agility: 8,
        lust_damage: 22,
        hp: 180,
        max_hp: 180,
        special: 'soul_drain'
      },
      30 => {
        name: 'Alpha Beast',
        type: 'beast',
        type_name: 'Beast',
        description: 'The largest and most dangerous beast in the dungeon',
        color: 0x8b4513,
        strength: 25,
        agility: 14,
        lust_damage: 30,
        hp: 200,
        max_hp: 200,
        special: 'primal_rage'
      },
      Tower::FINAL_BOSS_FLOOR => {
        name: 'The Tower Lord',
        type: 'demon',
        type_name: 'Archdemon',
        description: 'The ancient sovereign of the Endless Ruins. Every sin in the tower flows up into its throne.',
        color: 0x5c0a2e,
        strength: 28,
        agility: 16,
        lust_damage: 35,
        hp: 260,
        max_hp: 260,
        special: 'tower_dominion',
        final: true
      }
    }.freeze

    TROPHIES = {
      'Mimic Tongue Amulet' => {
        description: "An amulet made from a mimic's tongue. +2 Submission — monsters are far easier to satisfy.",
        stat_modifiers: { 'submission' => 2 }
      },
      "Queen's Favor" => {
        description: 'A blessed token from the Succubus Queen. All lust damage −20%.',
        stat_modifiers: { 'lust_mult' => 0.8 }
      },
      "King's Crown" => {
        description: 'The Incubus King\'s crown. +3 STR, +3 AGI.',
        stat_modifiers: { 'strength' => 3, 'agility' => 3 }
      },
      'Treant Heartwood' => {
        description: 'A piece of living wood. +10 max Defiance, +2 RES.',
        stat_modifiers: { 'max_hp' => 10, 'resistance' => 2 }
      },
      "Lich's Phylactery" => {
        description: 'Once per run, survive a finishing blow with half your Defiance restored.',
        stat_modifiers: { 'cheat_death' => true }
      },
      'Alpha Beast Trophy' => {
        description: 'Marks you as the apex predator. Monster encounters −30%.',
        stat_modifiers: { 'encounter_rate' => 0.7 }
      },
      'Boss Trophy' => {
        description: 'A trophy from a deep boss. +1 STR, +1 AGI, +1 RES.',
        stat_modifiers: { 'strength' => 1, 'agility' => 1, 'resistance' => 1 }
      }
    }.freeze

    module_function

    def sync_trophies!
      TROPHIES.each do |name, tpl|
        item = ::Equipment.find_or_create(name: name) do |e|
          apply_trophy!(e, tpl)
        end
        apply_trophy!(item, tpl)
        item.save_changes
      end
    end

    def apply_trophy!(record, tpl)
      record.type = 'accessory'
      record.slot = Player::TROPHY_SLOT
      record.description = tpl[:description]
      record.stat_modifiers = tpl[:stat_modifiers]
      record.cost = 0
      record.rarity = 5
      record.cursed = false
      record.violation_type = nil
      record.removal_cost = 0
    end

    def boss_for_floor(floor)
      return nil unless Tower.boss_floor?(floor)
      return BOSSES[Tower::FINAL_BOSS_FLOOR] if Tower.final_boss_floor?(floor)

      BOSSES[floor.to_i]
    end

    def start_boss_encounter(player, floor)
      boss = boss_for_floor(floor)
      return nil unless boss

      threat = ThreatCalculator.monster_modifiers(player)
      cycle = player.cycle_multiplier
      strength = [(boss[:strength] * threat.stat_mult * cycle).round, 1].max
      agility = [(boss[:agility] * threat.stat_mult * cycle).round, 1].max
      hp = [(boss[:hp] * threat.stat_mult * cycle).round, 20].max
      lust_damage = [(boss[:lust_damage] * threat.lust_mult * cycle).round, 1].max

      encounter = CombatEngine::Encounter.new(
        name: boss[:name],
        type: boss[:type],
        type_name: boss[:type_name],
        color: boss[:color],
        strength: strength,
        agility: agility,
        lust_damage: lust_damage,
        hp: hp,
        max_hp: hp,
        special: boss[:special],
        is_boss: true
      )

      player.store_encounter!(CombatEngine.encounter_snapshot(encounter))
      start_lines = player.apply_combat_start_effects!(boss[:type])

      intro =
        if boss[:final]
          "**Floor #{floor} — The Tower Lord's Chamber.** Treasure glitters in the dark around an ancient throne."
        else
          "**Floor #{floor}** — the air grows heavy."
        end
      warning =
        if boss[:final]
          'This is the final guardian. Defeat it to conquer the tower and begin the next cycle.'
        else
          "This foe is far more dangerous than any you've faced before."
        end
      cycle_note = player.current_cycle.to_i > 1 ? " · Cycle #{player.current_cycle} ×#{cycle.round(2)}" : ''

      message = <<~MSG.strip
        #{intro}

        You stand before **#{boss[:name]}**!
        _#{boss[:description]}_

        #{warning}
        _(Threat #{threat.category.to_s.upcase} — ×#{threat.stat_mult} power · ×#{threat.lust_mult} lust#{cycle_note})_
        HP #{hp}/#{hp} · STR #{strength} · AGI #{agility} · Lust hit #{lust_damage}
      MSG
      message += "\n#{start_lines.join("\n")}" if start_lines.any?

      {
        ok: true,
        encounter: encounter,
        message: message,
        is_boss: true
      }
    end

    def apply_boss_special(player, encounter, action, log)
      case encounter[:special]
      when 'spawns_minions'
        if rand(100) < 30
          log << "The #{encounter[:name]} spawns smaller mimics to assist it!"
          encounter[:lust_damage] = (encounter[:lust_damage] * 1.2).round
        end

      when 'seductive_gaze'
        if action == :fight && rand(100) < 40
          log << "The #{encounter[:name]} catches your eye with her seductive gaze! Your will wavers!"
          player.gain_lust!(10)
          log << "Lust +10! (now #{player.lust})"
        end

      when 'dominating_presence'
        if action == :flee && rand(100) < 60
          log << "The #{encounter[:name]}'s dominating presence paralyzes you with fear!"
          return :blocked
        end

      when 'root_grasp'
        if rand(100) < 25
          log << "The #{encounter[:name]}'s roots grasp at your ankles, reducing your agility!"
          player.update(agility: [player.agility - 1, 1].max)
          log << "Agility -1! (now #{player.agility})"
        end

      when 'soul_drain'
        if action == :submit && rand(100) < 50
          log << "The #{encounter[:name]} drains your soul as you submit!"
          player.adjust_defiance!(-5)
          log << "Defiance -5! (now #{player.defiance})"
        end

      when 'primal_rage'
        if encounter[:hp] < (encounter[:max_hp] * 0.5) && !encounter[:enraged]
          log << "The #{encounter[:name]} enters a primal rage! Its attacks become more ferocious!"
          encounter[:lust_damage] = (encounter[:lust_damage] * 1.5).round
          encounter[:enraged] = true
        end

      when 'tower_dominion'
        if action == :flee && rand(100) < 50
          log << "#{encounter[:name]} raises a hand — the chamber doors slam shut!"
          return :blocked
        end
        if rand(100) < 30
          log << "The tower itself pulses with #{encounter[:name]}'s will, flooding you with heat!"
          player.gain_lust!(12)
          log << "Lust +12! (now #{player.lust})"
        end
        if encounter[:hp] < (encounter[:max_hp] * 0.3) && !encounter[:enraged]
          log << "#{encounter[:name]} rises from its throne in fury — its touch burns hotter!"
          encounter[:lust_damage] = (encounter[:lust_damage] * 1.3).round
          encounter[:enraged] = true
        end
      end

      nil
    end

    def boss_defeat_reward(player, _encounter)
      floor = player.current_floor
      return { lp: 0, tower_clear: true } if Tower.final_boss_floor?(floor)

      base =
        case floor
        when 5 then { lp: 100, special_item: 'Mimic Tongue Amulet' }
        when 10 then { lp: 150, special_item: "Queen's Favor" }
        when 15 then { lp: 200, special_item: "King's Crown" }
        when 20 then { lp: 250, special_item: 'Treant Heartwood' }
        when 25 then { lp: 300, special_item: "Lich's Phylactery" }
        when 30 then { lp: 500, special_item: 'Alpha Beast Trophy' }
        else { lp: 100 * (floor / 5), special_item: 'Boss Trophy' }
        end
      base.merge(lp: (base[:lp] * player.cycle_multiplier).round)
    end
  end
end