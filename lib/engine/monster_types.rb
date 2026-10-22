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
                          'HuCow', 'Wildcat', 'Wild Dog', 'Basilisk', 'Gorgon Matron'],
        color: 0x8b4513
      },
      demon: {
        name: 'Demon',
        description: 'Otherworldly beings of dark energy',
        common_monsters: ['Imp', 'Succubus', 'Incubus', 'Hellhound', 'Demoness', 'Oni', 'Siren',
                          'Fae Trickster', 'Cambion', 'Rakshasa', 'Ifrit', 'Djinn', 'Night Hag',
                          'Pit Fiend', 'Chain Devil', 'Velvet Devil', 'Sin Eater', 'Dream Eater',
                          'Carnal Fiend', 'Ember Fiend', 'Marionette Mistress'],
        color: 0xff0000
      },
      slime: {
        name: 'Slime',
        description: 'Amorphous creatures that can change shape',
        common_monsters: ['Green Slime', 'Purple Slime', 'Jelly Cube', 'Gelatinous Mass',
                          'Amber Slime', 'Cream Slime', 'Crystal Slime', 'Rubber Slime', 'Jellyfish',
                          'Rose Slime', 'Honey Slime', 'Milk Slime', 'Oil Slime', 'Bubble Slime',
                          'Syrup Slime', 'Pudding Slime', 'Mercury Slime', 'Glow Slime', 'Tar Slime',
                          'Foam Slime', 'Champagne Slime'],
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
  },
      # Eldritch is deliberately pool-empty: only two eldritch things
      # exist in the tower — Eros herself, and the Drowned Saint she
      # keeps. Nothing eldritch is ever rolled as a random encounter.
      eldritch: {
        name: 'Eldritch',
        description: 'Things from outside the temple\'s categories — the goddess, and what she keeps',
        common_monsters: [],
        color: 0x5c0a2e
      }
}.freeze

    ENCOUNTER_KEYS = {
      beast: %w[beast_encounter_rate],
      undead: %w[undead_tracking undead_encounter_rate],
      plant: %w[plant_encounter_rate]
    }.freeze

    # Texture families: what a monster's body is actually like, so scene
    # text can match the creature in front of you instead of assuming
    # every beast is furry and every demon has the same tail. Names not
    # listed (bosses, pinned event monsters) fall back by monster type.
    TEXTURES = {
      # Beast
      'Wolf' => :furred, 'Bear' => :furred, 'Minotaur' => :furred, 'Gargoyle' => :stone,
      'Silkweaver' => :chitin, 'Giant Spider' => :chitin, 'Giant Moth' => :chitin,
      'Giant Bee' => :chitin, 'Broodmother' => :chitin, 'Lamia' => :scaled, 'Naga' => :scaled,
      'Basilisk' => :scaled, 'Gorgon Matron' => :scaled,
      'Centaur' => :equine, 'Harpy' => :feathered, 'Satyr' => :equine, 'Ogre' => :brute,
      'Troll' => :brute, 'Goblin' => :brute, 'Orc' => :brute, 'Kitsune' => :furred,
      'Dragon' => :scaled, 'HuCow' => :furred, 'Wildcat' => :furred, 'Wild Dog' => :furred,
      # Demon
      'Imp' => :hellish, 'Succubus' => :hellish, 'Incubus' => :hellish, 'Hellhound' => :hellish,
      'Marionette Mistress' => :hellish,
      'Demoness' => :hellish, 'Oni' => :hellish, 'Siren' => :aquatic, 'Fae Trickster' => :fae,
      'Cambion' => :hellish, 'Rakshasa' => :hellish, 'Ifrit' => :hellish, 'Djinn' => :fae,
      'Night Hag' => :hellish, 'Pit Fiend' => :hellish, 'Chain Devil' => :hellish,
      'Velvet Devil' => :hellish, 'Sin Eater' => :hellish, 'Dream Eater' => :hellish,
      'Carnal Fiend' => :hellish, 'Ember Fiend' => :hellish,
      # Slime
      'Green Slime' => :gelatinous, 'Purple Slime' => :gelatinous, 'Jelly Cube' => :gelatinous,
      'Gelatinous Mass' => :gelatinous, 'Amber Slime' => :gelatinous, 'Cream Slime' => :gelatinous,
      'Crystal Slime' => :gelatinous, 'Rubber Slime' => :gelatinous, 'Jellyfish' => :gelatinous,
      'Rose Slime' => :gelatinous, 'Honey Slime' => :gelatinous, 'Milk Slime' => :gelatinous,
      'Oil Slime' => :gelatinous, 'Bubble Slime' => :gelatinous, 'Syrup Slime' => :gelatinous,
      'Pudding Slime' => :gelatinous, 'Mercury Slime' => :gelatinous, 'Glow Slime' => :gelatinous,
      'Tar Slime' => :gelatinous, 'Foam Slime' => :gelatinous, 'Champagne Slime' => :gelatinous,
      # Undead
      'Zombie' => :corporeal, 'Skeleton' => :corporeal, 'Ghost' => :spectral, 'Wraith' => :spectral,
      'Vampire' => :corporeal, 'Lich' => :corporeal, 'Banshee' => :spectral, 'Ghoul' => :corporeal,
      'Mummy' => :corporeal, 'Revenant' => :corporeal, 'Specter' => :spectral, 'Wight' => :corporeal,
      'Poltergeist' => :spectral, 'Dullahan' => :corporeal, 'Jiangshi' => :corporeal,
      'Headless Knight' => :corporeal, 'Tomb Widow' => :corporeal, 'Pale Bride' => :corporeal,
      'Crypt Keeper' => :corporeal, 'Bone Dancer' => :corporeal,
      # Plant
      'Tentacle Vine' => :floral, 'Alraune' => :floral, 'Man-Eating Flower' => :floral,
      'Living Ivy' => :floral, 'Dryad' => :floral, 'Mycelian' => :floral, 'Black Orchid' => :floral,
      'Treant' => :floral, 'Mandrake' => :floral, 'Corpse Flower' => :floral, 'Blood Rose' => :floral,
      'Venus Mantrap' => :floral, 'Pitcher Plant' => :floral, 'Sundew' => :floral,
      'Moonflower' => :floral, 'Strangler Fig' => :floral, 'Thorn Vine' => :floral,
      'Pollen Sprite' => :floral, 'Sap Dryad' => :floral, 'Nightshade' => :floral,
      # Mimic
      'Chest Mimic' => :object, 'Door Mimic' => :object, 'Statue Mimic' => :object,
      'Item Pile Mimic' => :object, 'Chair Mimic' => :object, 'Wardrobe Mimic' => :object,
      'Couch Mimic' => :object, 'Clothing Mimic' => :object, 'Stone Golem' => :object,
      'Bed Mimic' => :object, 'Book Mimic' => :object, 'Mirror Mimic' => :object,
      'Bath Mimic' => :object, 'Throne Mimic' => :object, 'Curtain Mimic' => :object,
      'Rug Mimic' => :object, 'Chandelier Mimic' => :object, 'Clock Mimic' => :object,
      'Piano Mimic' => :object, 'Loom Mimic' => :object
    }.freeze

    DEFAULT_FAMILIES = {
      'beast' => :furred, 'demon' => :hellish, 'slime' => :gelatinous,
      'undead' => :corporeal, 'plant' => :floral, 'mimic' => :object,
      'eldritch' => :smooth
    }.freeze

    module_function

    def fetch(type)
      TYPES[type.to_sym]
    end

    def keys
      TYPES.keys
    end

    def family_for(name, type = nil)
      TEXTURES[name.to_s] || DEFAULT_FAMILIES[type.to_s] || :smooth
    end

    def all_names
      TYPES.values.flat_map { |t| t[:common_monsters] }
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
        name: info[:common_monsters].sample || 'Nameless Eldritch',
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
      # The Marionette Mistress opens every fight with her strings down.
      monster[:tangled] = true if monster[:name] == 'Marionette Mistress'
      player && elite ? Engine::Elites.roll!(monster, f) : monster
    end

    def weighted_type(player)
      # Pool-empty types (eldritch) are never rolled as encounters.
      weights = keys.reject { |t| TYPES[t][:common_monsters].empty? }.map do |type|
        weight = 1.0
        if player
          Array(ENCOUNTER_KEYS[type]).each do |key|
            weight *= player.curse_effect_product(key, default: 1.0)
          end
          weight *= Engine::TransformationSystem.monster_weight(player, type)
          weight *= Engine::Biomes.monster_weight(player, type)
        end
        weight *= Engine::Weekly.monster_weight(type)
        # Desire Magnet: the tower approves of honesty. A delver's
        # chosen kind simply turns up more often.
        weight *= 1.5 if player && player.tracker_hash['desire_magnet'].to_s == type.to_s
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
