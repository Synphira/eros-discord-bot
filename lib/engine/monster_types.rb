# frozen_string_literal: true

require_relative 'threat_calculator'

module Engine
  # Weighted monster type picks based on active curse encounter/tracking rates.
  module MonsterTypes
    TYPES = {
      beast: {
        name: 'Beast',
        description: 'Animalistic creatures driven by instinct',
        common_monsters: ['Wolf', 'Bear', 'Minotaur', 'Gargoyle'],
        color: 0x8b4513
      },
      demon: {
        name: 'Demon',
        description: 'Otherworldly beings of dark energy',
        common_monsters: ['Imp', 'Succubus', 'Incubus', 'Hellhound'],
        color: 0xff0000
      },
      slime: {
        name: 'Slime',
        description: 'Amorphous creatures that can change shape',
        common_monsters: ['Green Slime', 'Purple Slime', 'Jelly Cube', 'Gelatinous Mass'],
        color: 0x00ff00
      },
      undead: {
        name: 'Undead',
        description: 'Reanimated corpses and spirits',
        common_monsters: ['Zombie', 'Skeleton', 'Ghost', 'Wraith'],
        color: 0x9370db
      },
      plant: {
        name: 'Plant',
        description: 'Carnivorous flora and nature spirits',
        common_monsters: ['Tentacle Vine', 'Alraune', 'Man-Eating Flower', 'Living Ivy'],
        color: 0x228b22
      },
      mimic: {
    name: 'Mimic',
    description: 'Shape-shifting creatures that disguise themselves as objects',
    common_monsters: ['Chest Mimic', 'Door Mimic', 'Statue Mimic', 'Item Pile Mimic'],
    color: 0x696969
  }
}.freeze

    ENCOUNTER_KEYS = {
      beast: 'beast_encounter_rate',
      undead: 'undead_tracking'
    }.freeze

    module_function

    def fetch(type)
      TYPES[type.to_sym]
    end

    def keys
      TYPES.keys
    end

    def generate_monster(floor, player: nil)
      f = [floor.to_i, 1].max
      type = weighted_type(player)
      info = TYPES.fetch(type)

      strength = 2 + (f / 2)
      agility = 1 + (f / 3)
      lust_damage = 5 + f
      hp = 18 + (f * 4)

      if player
        threat = ThreatCalculator.monster_modifiers(player)
        strength = [(strength * threat.stat_mult).round, 1].max
        agility = [(agility * threat.stat_mult).round, 1].max
        hp = [(hp * threat.stat_mult).round, 8].max
        lust_damage = [(lust_damage * threat.lust_mult).round, 1].max
      end

      {
        name: info[:common_monsters].sample,
        type: type.to_s,
        type_name: info[:name],
        type_description: info[:description],
        color: info[:color],
        strength: strength,
        agility: agility,
        lust_damage: lust_damage,
        hp: hp,
        max_hp: hp
      }
    end

    def weighted_type(player)
      weights = keys.map do |type|
        weight = 1.0
        if player && ENCOUNTER_KEYS[type]
          weight *= player.curse_effect_product(ENCOUNTER_KEYS[type], default: 1.0)
        end
        [type, [weight, 0.01].max]
      end
      total = weights.sum { |(_, w)| w }
      roll = rand * total
      weights.each do |type, weight|
        roll -= weight
        return type if roll <= 0
      end
      keys.sample
    end
  end
end
