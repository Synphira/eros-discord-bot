# frozen_string_literal: true

require_relative 'seasons'

module Engine
  # Labor Day weekend — Pip slowed the monster-spawn spell; the tower answered
  # with traps. Syn does not approve and is trying to fix the cadence herself —
  # she will not ask the Incubus King. Three days (Sun–Tue around Labor Day Monday).
  module LaborDay
    KEY = 'labor_day'
    SUBMIT_TRACKER = 'labor_day_submits'

    WEEKLY = {
      key: KEY,
      name: "Pip's Slow Spell",
      description: 'Pip jammed a wrench into the monster-spawn spell — fewer hallway pests — and the tower ' \
                   'answered with traps. Every pest that does show wears a field-test name from her catalogue. ' \
                   'Syn does **not** approve; she is trying to restore the cadence herself and refuses to ask ' \
                   'the Incubus King for help. Vex stocks Pip\'s Field Sample kit while it lasts.',
      effects: {},
      special: { 'event_rate' => 1.0 }
    }.freeze

    # Delver-only seasonal rack. Named folk inside the tower do not dress up for Labor Day.
    COSTUME_NAMES = [
      'Askew Field Goggles',
      "Trapwright's Open Harness",
      'Seatless Tool Chaps',
      'Catalogue Crotch Window'
    ].freeze

    COSTUMES = [
      { name: 'Askew Field Goggles', slot: 'head', type: 'armor', cost: 50, tier: :labor_day,
        description: 'Pip\'s signature goggles, one lens smudged, strap never quite even. You look like you ' \
                     'came to measure hinges — and stayed to be measured.',
        stat_modifiers: { 'appearance' => 8, 'explore_lp' => 1 } },
      { name: "Trapwright's Open Harness", slot: 'chest', type: 'armor', cost: 90, tier: :labor_day,
        description: 'Scavenged straps and sprung-plate panels that cover collarbones, ribs, and back — and ' \
                     'leave both breasts bare, framed like samples for the catalogue.',
        stat_modifiers: { 'appearance' => 12, 'lust_mult' => 1.06, 'submit_lp_bonus' => 1, 'satisfy_bonus' => 0.03 } },
      { name: 'Seatless Tool Chaps', slot: 'legs', type: 'armor', cost: 70, tier: :labor_day,
        description: 'Heavy chaps for thigh and shin, tool loops clinking — and nothing whatsoever over the ' \
                     'ass. Pip swears the airflow helps her think. The traps agree.',
        stat_modifiers: { 'appearance' => 10, 'agility' => 1, 'submit_lp_bonus' => 1 } },
      { name: 'Catalogue Crotch Window', slot: 'groin', type: 'armor', cost: 75, tier: :labor_day,
        description: 'A reinforced ring and short apron that cover hips and nothing that matters. Cock or ' \
                     'cunt sits framed, labeled only by how eager the next plate will be to test it.',
        stat_modifiers: { 'appearance' => 11, 'lust_mult' => 1.08, 'submit_lp_bonus' => 2 } }
    ].freeze


  # Labor Day — 135 aliases
  MONSTER_ALIASES = {
      "Alraune" => "Field-Test Alraune",
      "Amber Slime" => "Grease Amber Slime",
      "Balloon Mistress" => "Wedge Balloon Mistress",
      "Banshee" => "Whistle Banshee",
      "Basilisk" => "Load-Bearing Basilisk",
      "Bath Mimic" => "Wash-Station Bath Mimic",
      "Bear" => "Hard-Hat Bear",
      "Bed Mimic" => "Break-Room Bed Mimic",
      "Big-Shoe Brute" => "Steel-Toe Big-Shoe Brute",
      "Black Orchid" => "Catalogue Black Orchid",
      "Blood Rose" => "Shift-Rose Blood Rose",
      "Bone Dancer" => "Breaktime Bone Dancer",
      "Book Mimic" => "Manual Book Mimic",
      "Broodmother" => "Site-Boss Broodmother",
      "Bubble Slime" => "Soap Bubble Slime",
      "Cambion" => "Apprentice Cambion",
      "Carnal Fiend" => "Overtime Carnal Fiend",
      "Carnival Clown" => "Union Carnival Clown",
      "Centaur" => "Draft-Horse Centaur",
      "Chain Devil" => "Safety-Chain Devil",
      "Chair Mimic" => "Folding-Chair Mimic",
      "Champagne Slime" => "Breakroom Champagne Slime",
      "Chandelier Mimic" => "Shop-Light Chandelier Mimic",
      "Chest Mimic" => "Toolbox Chest Mimic",
      "Clock Mimic" => "Punch-Clock Mimic",
      "Clothing Mimic" => "Coverall Clothing Mimic",
      "Corpse Flower" => "Compost Corpse Flower",
      "Cotton-Candy Imp" => "Insulation Imp",
      "Couch Mimic" => "Lounge Couch Mimic",
      "Cream Slime" => "Joint-Compound Cream Slime",
      "Crypt Keeper" => "Inventory Crypt Keeper",
      "Crystal Slime" => "Quartz Crystal Slime",
      "Curtain Mimic" => "Drop-Cloth Curtain Mimic",
      "Demoness" => "Foreman Demoness",
      "Djinn" => "Steam Djinn",
      "Door Mimic" => "Hinged Door Mimic",
      "Dragon" => "Forge Dragon",
      "Dream Eater" => "Nap-Room Dream Eater",
      "Dryad" => "Timber Dryad",
      "Dullahan" => "Decapitated Dullahan",
      "Ember Fiend" => "Welding Ember Fiend",
      "Fae Trickster" => "Practical-Joke Fae Trickster",
      "Foam Slime" => "Insulation Foam Slime",
      "Gargoyle" => "Cornice Gargoyle",
      "Gelatinous Mass" => "Sealant Gelatinous Mass",
      "Ghost" => "Punch-Out Ghost",
      "Ghoul" => "Scavenger Ghoul",
      "Giant Bee" => "Hive-Shift Giant Bee",
      "Giant Moth" => "Dust-Moth Giant Moth",
      "Giant Spider" => "Scaffold Giant Spider",
      "Glow Slime" => "High-Vis Glow Slime",
      "Goblin" => "Pip's Cousin Goblin",
      "Gorgon Matron" => "Stonework Gorgon Matron",
      "Green Slime" => "Coolant Green Slime",
      "Harpy" => "Whistle-Break Harpy",
      "Headless Knight" => "Hard-Hat Headless Knight",
      "Hellhound" => "Guard-Dog Hellhound",
      "Honey Slime" => "Epoxy Honey Slime",
      "Honker" => "Air-Horn Honker",
      "HuCow" => "Dairy-Shift HuCow",
      "Ifrit" => "Furnace Ifrit",
      "Imp" => "Errand Imp",
      "Incubus" => "Union Incubus",
      "Item Pile Mimic" => "Parts-Pile Mimic",
      "Jelly Cube" => "Packing Jelly Cube",
      "Jellyfish" => "Cable Jellyfish",
      "Jester" => "Shop-Floor Jester",
      "Jiangshi" => "Stiff Jiangshi",
      "Kitsune" => "Nine-Tool Kitsune",
      "Lamia" => "Hose Lamia",
      "Lich" => "Blueprint Lich",
      "Living Ivy" => "Climbing Living Ivy",
      "Loom Mimic" => "Cable-Loom Mimic",
      "Man-Eating Flower" => "Mulch Man-Eating Flower",
      "Mandrake" => "Root-Crop Mandrake",
      "Marionette Mistress" => "Pulley Marionette Mistress",
      "Mercury Slime" => "Solder Mercury Slime",
      "Milk Slime" => "Primer Milk Slime",
      "Minotaur" => "Warehouse Minotaur",
      "Mirror Mimic" => "Inspection-Mirror Mimic",
      "Moonflower" => "Night-Shift Moonflower",
      "Mummy" => "Wrapped-for-Shipping Mummy",
      "Mycelian" => "Mold Mycelian",
      "Naga" => "Conduit Naga",
      "Night Hag" => "Graveyard-Shift Night Hag",
      "Nightshade" => "Herbicide Nightshade",
      "Ogre" => "Demolition Ogre",
      "Oil Slime" => "Machine Oil Slime",
      "Oni" => "Club-Hammer Oni",
      "Orc" => "Crew Orc",
      "Pale Bride" => "Safety-Sash Pale Bride",
      "Piano Mimic" => "Breakroom Piano Mimic",
      "Pie Clown" => "Cafeteria Pie Clown",
      "Pit Fiend" => "Foundation Pit Fiend",
      "Pitcher Plant" => "Catch-Basin Pitcher Plant",
      "Pollen Sprite" => "Sawdust Pollen Sprite",
      "Poltergeist" => "Loose-Tool Poltergeist",
      "Pudding Slime" => "Grout Pudding Slime",
      "Purple Slime" => "Hydraulic Purple Slime",
      "Rakshasa" => "Shift-Boss Rakshasa",
      "Revenant" => "Unfinished-Job Revenant",
      "Ringmaster" => "Site Ringmaster",
      "Rose Slime" => "Cutting-Oil Rose Slime",
      "Rubber Slime" => "Gasket Rubber Slime",
      "Rug Mimic" => "Drop-Cloth Rug Mimic",
      "Sap Dryad" => "Resin Sap Dryad",
      "Satyr" => "Pipe-and-Horn Satyr",
      "Silkweaver" => "Cable Silkweaver",
      "Sin Eater" => "Liability Sin Eater",
      "Siren" => "Shift-Siren",
      "Skeleton" => "Scaffold Skeleton",
      "Specter" => "Punch-Clock Specter",
      "Statue Mimic" => "Mannequin Statue Mimic",
      "Stone Golem" => "Masonry Stone Golem",
      "Strangler Fig" => "Tie-Down Strangler Fig",
      "Succubus" => "Union Succubus",
      "Sundew" => "Catch-Pad Sundew",
      "Syrup Slime" => "Flux Syrup Slime",
      "Tar Slime" => "Roofing Tar Slime",
      "Tentacle Vine" => "Cable Tentacle Vine",
      "Thorn Vine" => "Barbed Thorn Vine",
      "Throne Mimic" => "Foreman's Throne Mimic",
      "Tomb Widow" => "Black-Widow Tomb Widow",
      "Treant" => "Timber Treant",
      "Troll" => "Bridge-Crew Troll",
      "Vampire" => "Night-Shift Vampire",
      "Velvet Devil" => "Soft-Grip Velvet Devil",
      "Venus Mantrap" => "Clamp Venus Mantrap",
      "Wardrobe Mimic" => "Locker Wardrobe Mimic",
      "Wight" => "Grave-Shift Wight",
      "Wild Dog" => "Site Wild Dog",
      "Wildcat" => "Shop Wildcat",
      "Wolf" => "Spring-Loaded Wolf",
      "Wraith" => "Smoke Wraith",
      "Zombie" => "Overtime Zombie"
  }.freeze

    # Traps + trap-like events Pip can be caught in while the season runs.
    PIP_TRAPS = [
      { name: 'Lust Rune',
        line: 'sprawled on a glowing pink rune, hips twitching, trying to sketch the pattern with a shaking hand' },
      { name: 'Binding Vines',
        line: 'hoisted midair by Binding Vines, goggles askew, muttering hinge measurements into the leaves' },
      { name: 'Aphrodisiac Gas',
        line: 'coughing sweetly into a handkerchief while Aphrodisiac Gas curls out of a vent she *definitely* opened on purpose' },
      { name: 'Pleasure Seal',
        line: 'stuck kneeling in a Pleasure Seal, taking furious notes between gasps' },
      { name: 'Kiss Ward',
        line: 'blowing kisses at a Kiss Ward that keeps blowing them back harder' },
      { name: 'Honey Floor',
        line: 'ankle-deep in Honey Floor, boots making sticky *schlick* sounds every time she shifts' },
      { name: 'Shrinking Doorway',
        line: 'wedged halfway through a Shrinking Doorway, hard hat stuck, legs kicking cheerfully' },
      { name: 'Compliment Ward',
        line: 'covered in fresh Compliment Ward ink, reading the filth on her thighs like a performance review' },
      { name: 'Feather Array',
        line: 'giggling helplessly in a Feather Array, tools scattered, insisting this is "field research"' },
      { name: 'Alarm Bells',
        line: 'tangled in Alarm Bells, every squirm ringing the corridor like a break whistle' },
      { name: 'Waxworks',
        line: 'shin-deep in warm Waxworks, posing between the statues "for science"' },
      { name: 'Dildo Trap',
        line: 'straddling a sprung Dildo Trap she is rating out of ten between gritted teeth' },
      { name: 'Edging Altar',
        line: 'cuffed to an Edging Altar, hips rolling, swearing she only meant to calibrate the timers' },
      { name: 'Tentacle Pit',
        line: 'half-swallowed by a Tentacle Pit, still somehow holding a clipboard' },
      { name: 'Glory Hole Wall',
        line: 'stuck at a glory-hole wall she swears she was "inspecting the masonry of"' }
    ].freeze

    module_function

    def key
      KEY
    end

    def name
      WEEKLY[:name]
    end

    def weekly
      WEEKLY
    end

    def window?(now = Time.now)
      monday = Engine::Seasons.labor_day_monday(now.year)
      start = monday - (24 * 3600)
      finish = monday + (2 * 24 * 3600)
      now >= start && now < finish
    end

    def ends_at(now = Time.now)
      monday = Engine::Seasons.labor_day_monday(now.year)
      (monday + (2 * 24 * 3600)).to_i
    end

    def active?(now = Time.now)
      Engine::Seasons.active?(:labor_day, now) ||
        (Engine::Seasons.forced_key == KEY)
    end

    # Fewer monsters, more traps — Pip slowed the spawn spell; the tower stuffed traps in the gap.
    def room_weight_mult(kind)
      case kind.to_s
      when 'monster' then 0.55
      when 'trap' then 2.15
      else 1.0
      end
    end

    def presence_suffix
      ' — fewer monsters, more traps; Pip is "working."'
    end

    def costume_stock?
      active?
    end

    def pip_trap_intro
      sample = PIP_TRAPS.sample
      "_Hard hat crooked, no pants (as always), Pip is #{sample[:line]}. " \
        "She spots you and grins like this is a triumph. " \
        "\"Labor Day! I slowed the spawn spell. Tower got *petty*. Syn is *furious* — " \
        "she's trying to put it back without asking the King, which is adorable and doomed. " \
        "Mind the floor — and if you free me, rate the **#{sample[:name]}** out of ten. For the catalogue.\"_"
    end

    def note_submit!(player)
      return unless player && (active? || Engine::Seasons.forced_key == KEY)

      player.bump_tracker!(SUBMIT_TRACKER)
    end

    def syn_labor_unlocked?(player)
      player.tracker('syn_labor_crumb').positive? || active?
    end

    def mark_syn_crumb!(player)
      player.set_tracker!('syn_labor_crumb', 1)
    end

    def chest_bonus!(player)
      return [] unless active?

      lines = []
      if rand < 0.22
        Engine::Residents.sync_vex_outfits!
        piece = COSTUMES.reject { |s| (item = ::Equipment.first(name: s[:name])) && player.owns_equipment?(item.id) }.sample
        if piece && (item = ::Equipment.first(name: piece[:name]))
          grant = player.grant_equipment!(item, auto_equip: false)
          if grant[:ok]
            lines << "A field-kit scrap: **#{item.name}** — _#{item.description}_ " \
                     '(keeps forever; equip from `e,equipment` / reclaim free at Vex).'
          end
        end
      end
      lines
    end

def monster_alias(base_name)
  MONSTER_ALIASES[base_name.to_s]
end

    Engine::Seasons.register!(KEY, self)
  end
end
