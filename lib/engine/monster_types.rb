# frozen_string_literal: true

require_relative 'threat_calculator'

module Engine
  module MonsterTypes
    TYPES = {
      beast: {
        name: 'Beast',
        description: 'Animalistic creatures driven by instinct',
        common_monsters: ['Wolf', 'Bear', 'Minotaur', 'Gargoyle', 'Silkweaver', 'Giant Spider',
                          'Giant Moth', 'Giant Bee', 'Broodmother', 'Lamia', 'Naga', 'Centaur',
                          'Harpy', 'Satyr', 'Ogre', 'Troll', 'Goblin', 'Orc', 'Kitsune', 'Dragon',
                          'HuCow', 'Wildcat', 'Wild Dog'],
        color: 0x8b4513
      },
      demon: {
        name: 'Demon',
        description: 'Otherworldly beings of dark energy',
        common_monsters: ['Imp', 'Succubus', 'Incubus', 'Hellhound', 'Demoness', 'Oni', 'Siren',
                          'Fae Trickster', 'Cambion', 'Rakshasa', 'Ifrit', 'Djinn', 'Night Hag',
                          'Pit Fiend', 'Chain Devil', 'Velvet Devil', 'Sin Eater', 'Dream Eater',
                          'Carnal Fiend', 'Ember Fiend'],
        color: 0xff0000
      },
      slime: {
        name: 'Slime',
        description: 'Amorphous creatures that can change shape',
        common_monsters: ['Green Slime', 'Purple Slime', 'Jelly Cube', 'Gelatinous Mass',
                          'Amber Slime', 'Cream Slime', 'Crystal Slime', 'Rubber Slime', 'Jellyfish',
                          'Rose Slime', 'Honey Slime', 'Milk Slime', 'Oil Slime', 'Bubble Slime',
                          'Syrup Slime', 'Pudding Slime', 'Mercury Slime', 'Glow Slime', 'Tar Slime',
                          'Foam Slime'],
        color: 0x00ff00
      },
      undead: {
        name: 'Undead',
        description: 'Reanimated corpses and spirits',
        common_monsters: ['Zombie', 'Skeleton', 'Ghost', 'Wraith', 'Vampire', 'Lich', 'Banshee',
                          'Ghoul', 'Mummy', 'Revenant', 'Specter', 'Wight', 'Poltergeist', 'Dullahan',
                          'Jiangshi', 'Headless Knight', 'Tomb Widow', 'Pale Bride', 'Crypt Keeper',
                          'Bone Dancer'],
        color: 0x9370db
      },
      plant: {
        name: 'Plant',
        description: 'Carnivorous flora and nature spirits',
        common_monsters: ['Tentacle Vine', 'Alraune', 'Man-Eating Flower', 'Living Ivy', 'Dryad',
                          'Mycelian', 'Black Orchid', 'Treant', 'Mandrake', 'Corpse Flower',
                          'Blood Rose', 'Venus Mantrap', 'Pitcher Plant', 'Sundew', 'Moonflower',
                          'Strangler Fig', 'Thorn Vine', 'Pollen Sprite', 'Sap Dryad', 'Nightshade'],
        color: 0x228b22
      },
      mimic: {
    name: 'Mimic',
    description: 'Shape-shifting creatures that disguise themselves as objects',
    common_monsters: ['Chest Mimic', 'Door Mimic', 'Statue Mimic', 'Item Pile Mimic', 'Chair Mimic',
                      'Wardrobe Mimic', 'Couch Mimic', 'Clothing Mimic', 'Stone Golem', 'Bed Mimic',
                      'Book Mimic', 'Mirror Mimic', 'Bath Mimic', 'Throne Mimic', 'Curtain Mimic',
                      'Rug Mimic', 'Chandelier Mimic', 'Clock Mimic', 'Piano Mimic', 'Loom Mimic'],
    color: 0x696969
  }
}.freeze

    ENCOUNTER_KEYS = {
      beast: %w[beast_encounter_rate],
      undead: %w[undead_tracking undead_encounter_rate],
      plant: %w[plant_encounter_rate]
    }.freeze

    module_function

    def fetch(type)
      TYPES[type.to_sym]
    end

    def keys
      TYPES.keys
    end

    def generate_monster(floor, player: nil, type: nil, elite: true)
      f = [floor.to_i, 1].max
      type = type && TYPES.key?(type.to_sym) ? type.to_sym : weighted_type(player)
      info = TYPES.fetch(type)

      strength = 2 + (f / 2)
      agility = 1 + (f / 3)
      lust_damage = 5 + f
      hp = 18 + (f * 4)

      if player
        threat = ThreatCalculator.monster_modifiers(player)
        cycle = player.cycle_multiplier
        strength = [(strength * threat.stat_mult * cycle).round, 1].max
        agility = [(agility * threat.stat_mult * cycle).round, 1].max
        hp = [(hp * threat.stat_mult * cycle).round, 8].max
        lust_damage = [(lust_damage * threat.lust_mult * cycle).round, 1].max
      end

      monster = {
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
      player && elite ? Engine::Elites.roll!(monster, f) : monster
    end

    def weighted_type(player)
      weights = keys.map do |type|
        weight = 1.0
        if player
          Array(ENCOUNTER_KEYS[type]).each do |key|
            weight *= player.curse_effect_product(key, default: 1.0)
          end
          weight *= Engine::TransformationSystem.monster_weight(player, type)
          weight *= Engine::Biomes.monster_weight(player, type)
        end
        weight *= Engine::Weekly.monster_weight(type)
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
