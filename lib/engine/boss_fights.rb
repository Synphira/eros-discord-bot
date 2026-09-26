module Engine
  module BossFights
    # Define boss encounters for every 5 floors
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
      }
    }.freeze

    module_function

    def boss_for_floor(floor)
      return nil unless (floor % 5).zero?
      BOSSES[floor]
    end

    def start_boss_encounter(player, floor)
      boss = boss_for_floor(floor)
      return nil unless boss

      threat = ThreatCalculator.monster_modifiers(player)
      strength = [(boss[:strength] * threat.stat_mult).round, 1].max
      agility = [(boss[:agility] * threat.stat_mult).round, 1].max
      hp = [(boss[:hp] * threat.stat_mult).round, 20].max
      lust_damage = [(boss[:lust_damage] * threat.lust_mult).round, 1].max

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

      message = <<~MSG.strip
        **Floor #{floor}** — the air grows heavy.

        You stand before the **#{boss[:name]}**!
        _#{boss[:description]}_

        This foe is far more dangerous than any you've faced before.
        _(Threat #{threat.category.to_s.upcase} — ×#{threat.stat_mult} power · ×#{threat.lust_mult} lust)_
        HP #{hp}/#{hp} · STR #{strength} · AGI #{agility} · Lust hit #{lust_damage}
      MSG

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
        if rand(100) < 30  # 30% chance each turn
          log << "The #{encounter[:name]} spawns smaller mimics to assist it!"
          # Increase damage this turn
          encounter[:lust_damage] = (encounter[:lust_damage] * 1.2).round
        end

      when 'seductive_gaze'
        if action == :fight && rand(100) < 40  # 40% chance when fighting
          log << "The #{encounter[:name]} catches your eye with her seductive gaze! Your will wavers!"
          player.gain_lust!(10)
          log << "Lust +10! (now #{player.lust})"
        end

      when 'dominating_presence'
        if action == :flee && rand(100) < 60  # 60% chance when fleeing
          log << "The #{encounter[:name]}'s dominating presence paralyzes you with fear!"
          return :blocked
        end

      when 'root_grasp'
        if rand(100) < 25  # 25% chance each turn
          log << "The #{encounter[:name]}'s roots grasp at your ankles, reducing your agility!"
          player.update(agility: [player.agility - 1, 1].max)
          log << "Agility -1! (now #{player.agility})"
        end

      when 'soul_drain'
        if action == :submit && rand(100) < 50  # 50% chance when submitting
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
      end

      nil
    end

    def boss_defeat_reward(player, encounter)
      floor = player.current_floor
      
      # Boss-specific rewards
      case floor
      when 5  # Mimic Broodmother
        {
          lp: 100,
          special_item: 'Mimic Tongue Amulet',
          description: 'An amulet made from a mimic\'s tongue, allowing you to please monsters better'
        }
      when 10  # Succubus Queen
        {
          lp: 150,
          special_item: 'Queen\'s Favor',
          description: 'A blessed item that reduces all lust damage by 20%'
        }
      when 15  # Incubus King
        {
          lp: 200,
          special_item: 'King\'s Crown',
          description: 'A crown that grants you 3 strength and 3 agility'
        }
      when 20  # Ancient Treant
        {
          lp: 250,
          special_item: 'Treant Heartwood',
          description: 'A piece of living wood that grants you 10 max HP and 2 resistance'
        }
      when 25  # Lich Lord
        {
          lp: 300,
          special_item: 'Lich\'s Phylactery',
          description: 'A magical artifact that allows you to cheat death once per run'
        }
      when 30  # Alpha Beast
        {
          lp: 500,
          special_item: 'Alpha Beast Trophy',
          description: 'A trophy that marks you as the apex predator, reducing all monster encounters by 30%'
        }
      else
        {
          lp: 100 * (floor / 5),
          special_item: 'Boss Trophy',
          description: 'A trophy from your victory over the boss'
        }
      end
    end
  end
end