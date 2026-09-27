# frozen_string_literal: true

require_relative 'monster_types'

module Engine
  # Curses organized by the monster type that bestows them on defeat.
  module CurseCatalog
    CATEGORY_FOR_TYPE = {
      'beast' => 'Wild',
      'demon' => 'Infernal',
      'slime' => 'Viscous',
      'undead' => 'Necrotic',
      'plant' => 'Botanical'
    }.freeze

    CURSES = {
      'beast' => [
        {
          name: "Beast's Mark",
          description: 'Your strength increases by 3, but you take 25% more lust damage from beasts',
          effects: { 'strength' => 3, 'beast_lust_mult' => 1.25 }
        },
        {
          name: 'Animalistic Scent',
          description: 'Beasts are drawn to you, increasing beast encounter rate by 30%',
          effects: { 'beast_encounter_rate' => 1.3 }
        },
        {
          name: 'Primal Heat',
          description: 'You enter heat around beasts, taking 50% more lust damage but gaining 2 agility',
          effects: { 'beast_lust_mult' => 1.5, 'agility' => 2 }
        },
        {
          name: 'Feral Instincts',
          description: 'You gain 3 strength and 2 agility, but your lust builds 25% faster when near beasts',
          effects: { 'strength' => 3, 'agility' => 2, 'beast_lust_mult' => 1.25 }
        },
        {
          name: 'Beast Bait',
          description: 'Your scent becomes irresistible to beasts, increasing their encounter rate by 50% but you gain 2 LP from each beast victory',
          effects: { 'beast_encounter_rate' => 1.5, 'beast_lp_bonus' => 2 }
        },
      ],
      'mimic' => [
        {
        name: 'Mimic Tongue',
        description: 'Your tongue becomes prehensile, allowing you to please monsters better (reduces their lust damage by 15%) but makes it harder to speak (10% less chance to flee)',
        effects: { 'mimic_lust_mult' => 0.85, 'mimic_escape_penalty' => 0.9 }
        },
        {
        name: 'Object Desire',
        description: 'You find yourself attracted to inanimate objects, gaining 5 LP when finding treasure but taking 20% more damage from mimics',
        effects: { 'mimic_treasure_lp' => 5, 'mimic_damage_mult' => 1.2 }
        },
        {
          name: 'Mimic Flesh',
          description: "Your skin takes on a partially wood-and-flesh texture, sometimes forming small openings or appendages without your control. This makes you slightly more durable (10% less damage from all monsters) but your body's unnatural transformation causes constant arousal (15% more lust damage).",
          effects: { 'damage_reduction' => 0.9, 'mimic_lust_mult' => 1.15 }
        },
        {
          name: 'Box Cravings',
          description: 'You find yourself inexplicably drawn to boxes and containers, sometimes unable to resist opening them. This makes you more likely to discover hidden treasures (5 LP per container found) but also makes you vulnerable to mimic attacks (15% more damage from mimics).',
          effects: { 'mimic_treasure_lp' => 5, 'mimic_damage_mult' => 1.15 }
        },
        {
          name: 'Phantom Latch',
          description: 'A spectral connection sometimes forms between your body and nearby objects, causing them to temporarily merge with your flesh. This grants you limited object absorption abilities (10% chance to negate one attack per combat) but the merging sensation is intensely pleasurable (20% more lust damage).',
          effects: { 'negation_chance' => 0.1, 'mimic_lust_mult' => 1.2 }
        },
      ],
      'demon' => [
        {
          name: 'Demonic Taint',
          description: 'Your resistance increases by 2, but demons deal 30% more lust damage',
          effects: { 'resistance' => 2, 'demon_lust_mult' => 1.3 }
        },
        {
          name: 'Infernal Lust',
          description: 'You gain 4 LP from each demon defeated, but your lust meter starts 30% higher',
          effects: { 'demon_lp_bonus' => 4, 'lust_start_bonus' => 30}
        },
        {
          name: 'Hellfire Blood',
          description: 'Your blood burns with demonic energy, dealing 2 damage to demons each time you hit them but taking 10% more lust damage',
          effects: { 'demon_thorns' => 2, 'demon_lust_mult' => 1.1 }
        },
        {
          name: 'Soulbound',
          description: "Demons can't kill you, but you can't flee from them",
          effects: { 'demon_no_flee' => true, 'demon_no_death' => true }
        },
        {
          name: 'Infernal Desire',
          description: 'You gain 50% more Lust Points from demons, but start each run with 20% less defiance',
          effects: { 'demon_lp_mult' => 1.5, 'defiance_start' => 0.8 }
        }
      ],
      'slime' => [
        {
          name: 'Amorphous Body',
          description: 'You take 20% less damage from slimes, but your agility decreases by 1',
          effects: { 'slime_damage_mult' => 0.8, 'agility' => -1 }
        },
        {
          name: 'Absorbent',
          description: 'You gain 5 LP each time a slime fills your lust meter, but you take 10% more lust damage',
          effects: { 'slime_climax_lp' => 5, 'slime_lust_mult' => 1.1 }
        },
        {
          name: 'Oozing Pores',
          description: 'Your skin secretes slippery slime, making you 40% harder to grab but reducing your armor by 2',
          effects: { 'slime_escape_bonus' => 1.4, 'resistance' => -2 }
        },
        {
          name: 'Gelatinous Form',
          description: 'Your body becomes partially amorphous, reducing all damage by 15% but making you 25% more vulnerable to lust',
          effects: { 'damage_reduction' => 0.85, 'slime_lust_mult' => 1.25 }
        },
        {
          name: 'Fluid Form',
          description: 'You can escape from slimes 50% more easily, but take 15% more lust damage from them',
          effects: { 'slime_escape_bonus' => 1.5, 'slime_lust_mult' => 1.15 }
        }
      ],
      'undead' => [
        {
          name: 'Necrotic Touch',
          description: "Undead deal 25% less lust damage, but you can't gain LP from them",
          effects: { 'undead_lust_mult' => 0.75, 'undead_no_lp' => true }
        },
        {
          name: 'Spirit Ward',
          description: 'You take 30% less damage from undead, but they track you more easily',
          effects: { 'undead_damage_mult' => 0.7, 'undead_tracking' => 1.3 }
        },
        {
          name: 'Deathly Resilience',
          description: 'You gain 10 Defiance and 2 resistance, but healing effects are 30% less effective',
          effects: { 'max_hp_bonus' => 10, 'resistance' => 2, 'healing_mult' => 0.7 }
        },
        {
          name: 'Necrotic Aura',
          description: 'Your presence unnerves living foes, reducing their accuracy by 20% but attracting 30% more undead',
          effects: { 'accuracy' => 0.8, 'undead_encounter_rate' => 1.3 }
        },
        {
          name: 'Life Drain',
          description: 'You drain defiance from undead, but they deal 20% more lust damage',
          effects: { 'undead_drain' => true, 'undead_lust_mult' => 1.2 }
        }
      ],
      'plant' => [
        {
          name: 'Pollen Allergy',
          description: 'Plant monsters deal 30% more lust damage, but you gain 2 strength',
          effects: { 'plant_lust_mult' => 1.3, 'strength' => 2 }
        },
        {
          name: 'Thorned Skin',
          description: 'You take 25% less damage from plants, but they bind you more easily',
          effects: { 'plant_damage_mult' => 0.75, 'plant_bind_bonus' => 1.5 }
        },
        {
          name: 'Blooming Scent',
          description: 'Your scent atracts pollinators, reducing plant encounters by 30% but inscreasing all other encounter rates by 15%',
          effects: { 'plant_encounter_rate' => 0.7, 'encounter_rate' => 1.15 }
        },
        {
          name: 'Rooted Feet',
          description: 'Your feet partially transform into roots, giving you 3 resistance but reducing your agility by 2',
          effects: { 'resistance' => 3, 'agility' => -2 }
        },
        {
          name: 'Photosynthesis',
          description: 'You regain 10 defiance at the start of each combat with plants, but take 20% more lust damage',
          effects: { 'plant_defiance_regen' => 10, 'plant_lust_mult' => 1.2 }
        }
      ]
    }.freeze

    module_function

    def for_type(monster_type)
      CURSES[monster_type.to_s] || []
    end

    def definition_for(name)
      CURSES.each_value do |list|
        found = list.find { |c| c[:name] == name }
        return found if found
      end
      nil
    end

    def type_for(name)
      CURSES.each do |type, list|
        return type if list.any? { |c| c[:name] == name }
      end
      'unknown'
    end

    def type_label(type)
      return 'Unknown' if type.to_s == 'unknown'

      info = MonsterTypes.fetch(type)
      info ? info[:name] : type.to_s.capitalize
    end

    def sample_for(monster_type)
      pool = for_type(monster_type)
      pool = CURSES.values.flatten if pool.empty?
      pool.sample
    end

    # Upsert every catalog curse into the Sequel Curse table.
    def sync_to_db!
      CURSES.each do |type, list|
        category = CATEGORY_FOR_TYPE.fetch(type, 'Abyssal')
        list.each do |entry|
          curse = Curse.find_or_create(name: entry[:name]) do |c|
            c.category = category
            c.description = entry[:description]
            c.stat_modifiers = entry[:effects]
          end
          # Keep description / effects fresh on reboot.
          curse.update(
            category: category,
            description: entry[:description],
            stat_modifier_json: JSON.generate(entry[:effects])
          )
        end
      end
    end
  end
end
