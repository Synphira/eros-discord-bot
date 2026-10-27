# frozen_string_literal: true

require_relative 'seasons'

module Engine
  # April 1. Pranks, fake chests, Pip's favourite day — rewards keep forever.
  module AprilFools
    KEY = 'april_fools'
    SWEETS_TRACKER = 'april_fools_sweets'
    SWEETS_EATEN = 'april_fools_sweets_eaten'
    SWEETS_MAX = 12
    SUBMIT_TRACKER = 'april_fools_submits'
    CRUEL_OPTION = 'cruel_pranks'

    WEEKLY = {
      key: KEY,
      name: "Fool's Trap",
      description: 'The temple lies for a day: mimics and clowns throng, traps lean harder, events 30% more often, ' \
                   'lust ×1.1. Every hallway pest wears a prank name. Fool\'s sweets and Vex\'s jester rack stay after ' \
                   'midnight. Pip is having the time of her life. Syn is enduring it. Ask her about Fool\'s Trap.',
      effects: {
        'lust_mult' => 1.1,
        'submit_lp_bonus' => 1,
        'satisfy_bonus' => 0.03
      },
      monsters: { mimic: 2.0, clown: 1.75, slime: 1.3 },
      special: { 'event_rate' => 1.3, 'mimic_chance' => 1.5, 'elite_chance' => 1.2 }
    }.freeze

    COSTUME_NAMES = [
      'Askew Jester Cap',
      'Whoopee Harness',
      'Striped Fool Hose'
    ].freeze

    COSTUMES = [
      { name: 'Askew Jester Cap', slot: 'head', type: 'armor', cost: 55, tier: :april_fools,
        description: 'Bells that never quite hang even. You look like you came to be the joke — and to enjoy it.',
        stat_modifiers: { 'appearance' => 8, 'explore_lp' => 1, 'submit_lp_bonus' => 1 } },
      { name: 'Whoopee Harness', slot: 'chest', type: 'armor', cost: 90, tier: :april_fools,
        description: 'Straps and a cushion panel that sighs when squeezed. Pip swears it is art. The traps agree.',
        stat_modifiers: { 'appearance' => 12, 'lust_mult' => 1.06, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.03 } },
      { name: 'Striped Fool Hose', slot: 'legs', type: 'armor', cost: 65, tier: :april_fools,
        description: 'Loud stripes for thighs. Standing still becomes a punchline.',
        stat_modifiers: { 'appearance' => 10, 'agility' => 1, 'submit_lp_bonus' => 1 } }
    ].freeze

    DRESS = {
      'Mimic Broodmother' => 'A "KICK ME" sign glued upside-down by her brood. They are proud. She is pretending the ' \
                            'sign is a liturgical text.',
      'Succubus Queen' => 'Motley velvet and a smile that makes every compliment a setup. Laugh with her. Then check ' \
                         'your pockets. Then your dignity.',
      'Incubus King' => 'Whoopee cushion on the throne, denials ready. Pip planned the bit. He is still taking credit ' \
                       'between squeaks.',
      'Verdant Dryad' => 'A flower crown that squirts water when hugged. She pretends it is seasonal. She times the ' \
                        'hugs.',
      'Lich Lord' => 'A rubber nose perched in blue fire. It squeaks when he turns his head. He has not spoken in ' \
                    'an hour. Progress.',
      'Alpha Beast' => 'Syn has buckled a ridiculous jester collar onto her pupper for Fool\'s Trap. He is delighted. ' \
                      'The bells jingle. Pip has already taken notes.',
      'Eros' => 'A smile like a punchline — lace that looks serious until it isn\'t, and never was.',
      'Syn' => 'Ink-smudged laugh lines she did not draw, jaw tight, counting hours until April 2. She is enduring ' \
              'Pip\'s holiday like a penance with good lighting.',
      'Berry' => 'Shop door says CLOSED FOR RENOVATIONS. Behind it: normal shop, whoopee mat, and Berry laughing into ' \
                'her sleeve. Gotcha is a business model.',
      'Covar' => 'A ledger page stamped FREE in red. Customers reach. He flips it. The other side says STILL NOT FREE. ' \
                'His grin is the real prize.',
      'Madame Vex' => 'Motley that jingles when she walks, bells on the hems, prices that change if you blink. She ' \
                     'charges double for dignity restoration.',
      'Pip' => 'Jester hat that finally fits. Zero pants. Vibrating. Clipboard. This is her Super Bowl and everyone ' \
              'else is the half-time show.',
      'Sister Nectar' => 'A whoopee cushion on the shrine stool, a rubber nose she removes for the actual milking, and ' \
                        'a fond "the joke ends when the cups seal." Holy is still holy. Pip rated the cushion.',
      'Fang' => 'A map that unfolds into a fake dead end. The real sketch is on the back. He waits for you to notice. ' \
               'Patient. Pink at the tips of his ears when you do.'
    }.freeze

    CLERGY_LINES = {
      'Mimic Broodmother' => {
        victory: 'The Broodmother\'s lid clacks under the sign. "Gotcha," she croons. "My brood wrote it."',
        praise: 'Little mimics bounce with rubber noses. One offers you a sticky sweet from its mouth.'
      },
      'Succubus Queen' => {
        victory: 'The Queen tips her motley. "Fool etiquette," she purrs. "Laugh. Then kneel."',
        praise: '"Best jokes land wet," she says, and takes her thanks from your mouth.'
      },
      'Incubus King' => {
        victory: 'Whoopee cushion sigh. "I staged it," the King lies brightly. "You\'re the punchline."',
        praise: 'He tips a joke sweet you did not ask for against your lips and watches you swallow.'
      },
      'Verdant Dryad' => {
        victory: 'The flower crown squirts. "Spring has a sense of humour," she murmurs.',
        praise: 'She tucks a fake flower behind your ear. It smells like sugar and setup.'
      },
      'Lich Lord' => {
        victory: 'The rubber nose tips. "Humour is a binding," the Lich notes. "You accepted the bit."',
        praise: 'He stamps a cold sigil that looks, briefly, like a whoopee cushion of your remaining dignity.'
      },
      'Alpha Beast' => {
        victory: 'Syn\'s pupper shakes his jester collar proudly. Somewhere a whoopee cushion answers.',
        praise: 'He drops a mouthful of foil fool\'s sweets on your chest and looks enormously proud.'
      },
      'Eros' => {
        victory: 'The goddess tastes of sugar and grace. "I let them lie one day," Eros says. "They behave better fooled."',
        praise: 'A white tentacle offers you a whoopee cushion. Refusing is not among the options.'
      }
    }.freeze

    FOOL_BLESSING = {
      key: 'fool_glow', name: 'Fool Glow', floors: 4,
      effects: { 'submit_lp_bonus' => 2, 'appearance' => 3, 'explore_lp' => 1 },
      summary: 'Warm, bell-slick, and faintly gold — the temple likes a punchline that stays kneeling'
    }.freeze

  MONSTER_ALIASES = {
    "Alraune" => "Joker Alraune",
    "Amber Slime" => "Whoopee Amber Slime",
    "Balloon Mistress" => "April Balloon Mistress",
    "Banshee" => "Gotcha Banshee",
    "Basilisk" => "Whoopee Basilisk",
    "Bath Mimic" => "Fake-Treasure Bath Mimic",
    "Bear" => "Prank Bear",
    "Bed Mimic" => "Whoopee Bed Mimic",
    "Big-Shoe Brute" => "Whoopee Big-Shoe Brute",
    "Black Orchid" => "Prank Black Orchid",
    "Blood Rose" => "Fool Blood Rose",
    "Bone Dancer" => "Fake-Out Bone Dancer",
    "Book Mimic" => "Prank Book Mimic",
    "Broodmother" => "Fool Broodmother",
    "Bubble Slime" => "Joke Bubble Slime",
    "Cambion" => "Jester Cambion",
    "Carnal Fiend" => "Prank Carnal Fiend",
    "Carnival Clown" => "April Carnival Clown",
    "Centaur" => "Jester Centaur",
    "Chain Devil" => "Fool Chain Devil",
    "Chair Mimic" => "Joke Chair Mimic",
    "Champagne Slime" => "Rubber-Chicken Champagne Slime",
    "Chandelier Mimic" => "Fool Chandelier Mimic",
    "Chest Mimic" => "Fake-Treasure Chest Mimic",
    "Clock Mimic" => "Fake-Treasure Clock Mimic",
    "Clothing Mimic" => "Whoopee Clothing Mimic",
    "Corpse Flower" => "Joke Corpse Flower",
    "Cotton-Candy Imp" => "Prank Cotton-Candy Imp",
    "Couch Mimic" => "Prank Couch Mimic",
    "Cream Slime" => "Fake Cream Slime",
    "Crypt Keeper" => "Prank Crypt Keeper",
    "Crystal Slime" => "Honey Crystal Slime",
    "Curtain Mimic" => "Joke Curtain Mimic",
    "Demoness" => "Trick Demoness",
    "Djinn" => "April Djinn",
    "Door Mimic" => "Fool Door Mimic",
    "Dragon" => "Trick Dragon",
    "Dream Eater" => "Jester Dream Eater",
    "Dryad" => "Fool Dryad",
    "Dullahan" => "Fool Dullahan",
    "Ember Fiend" => "Prank Ember Fiend",
    "Fae Trickster" => "Fool Fae Trickster",
    "Foam Slime" => "Whoopee Foam Slime",
    "Gargoyle" => "Whoopee Gargoyle",
    "Gelatinous Mass" => "Joke Gelatinous Mass",
    "Ghost" => "April Ghost",
    "Ghoul" => "Gotcha Ghoul",
    "Giant Bee" => "Prank Giant Bee",
    "Giant Moth" => "Fool Giant Moth",
    "Giant Spider" => "Jester Giant Spider",
    "Glow Slime" => "Rubber-Chicken Glow Slime",
    "Goblin" => "Trick Goblin",
    "Gorgon Matron" => "Whoopee Gorgon Matron",
    "Green Slime" => "Fake Green Slime",
    "Harpy" => "Prank Harpy",
    "Headless Knight" => "Fake-Out Headless Knight",
    "Hellhound" => "Trick Hellhound",
    "Honey Slime" => "Honey Honey Slime",
    "Honker" => "Fool Honker",
    "HuCow" => "Prank HuCow",
    "Ifrit" => "April Ifrit",
    "Imp" => "Jester Imp",
    "Incubus" => "Prank Incubus",
    "Item Pile Mimic" => "Fake-Treasure Item Pile Mimic",
    "Jelly Cube" => "Whoopee Jelly Cube",
    "Jellyfish" => "Joke Jellyfish",
    "Jester" => "Royal April Jester",
    "Jiangshi" => "Prank Jiangshi",
    "Kitsune" => "Fool Kitsune",
    "Lamia" => "Jester Lamia",
    "Lich" => "Fool Lich",
    "Living Ivy" => "Trick Living Ivy",
    "Loom Mimic" => "Whoopee Loom Mimic",
    "Man-Eating Flower" => "April Man-Eating Flower",
    "Mandrake" => "Prank Mandrake",
    "Marionette Mistress" => "Prank Marionette Mistress",
    "Mercury Slime" => "Rubber-Chicken Mercury Slime",
    "Milk Slime" => "Fake Milk Slime",
    "Minotaur" => "Trick Minotaur",
    "Mirror Mimic" => "Prank Mirror Mimic",
    "Moonflower" => "Fool Moonflower",
    "Mummy" => "April Mummy",
    "Mycelian" => "Joke Mycelian",
    "Naga" => "Whoopee Naga",
    "Night Hag" => "Fool Night Hag",
    "Nightshade" => "Trick Nightshade",
    "Ogre" => "Prank Ogre",
    "Oil Slime" => "Honey Oil Slime",
    "Oni" => "Trick Oni",
    "Orc" => "Fool Orc",
    "Pale Bride" => "Gotcha Pale Bride",
    "Piano Mimic" => "Joke Piano Mimic",
    "Pie Clown" => "Whoopee Pie Clown",
    "Pit Fiend" => "April Pit Fiend",
    "Pitcher Plant" => "April Pitcher Plant",
    "Pollen Sprite" => "Prank Pollen Sprite",
    "Poltergeist" => "Fake-Out Poltergeist",
    "Pudding Slime" => "Whoopee Pudding Slime",
    "Purple Slime" => "Joke Purple Slime",
    "Rakshasa" => "Jester Rakshasa",
    "Revenant" => "Prank Revenant",
    "Ringmaster" => "Gotcha Ringmaster",
    "Rose Slime" => "Rubber-Chicken Rose Slime",
    "Rubber Slime" => "Fake Rubber Slime",
    "Rug Mimic" => "Fool Rug Mimic",
    "Sap Dryad" => "Fool Sap Dryad",
    "Satyr" => "Jester Satyr",
    "Silkweaver" => "Trick Silkweaver",
    "Sin Eater" => "Prank Sin Eater",
    "Siren" => "Fool Siren",
    "Skeleton" => "Fool Skeleton",
    "Specter" => "April Specter",
    "Statue Mimic" => "Fake-Treasure Statue Mimic",
    "Stone Golem" => "Whoopee Stone Golem",
    "Strangler Fig" => "Joke Strangler Fig",
    "Succubus" => "Jester Succubus",
    "Sundew" => "Trick Sundew",
    "Syrup Slime" => "Honey Syrup Slime",
    "Tar Slime" => "Whoopee Tar Slime",
    "Tentacle Vine" => "April Tentacle Vine",
    "Thorn Vine" => "Prank Thorn Vine",
    "Throne Mimic" => "Prank Throne Mimic",
    "Tomb Widow" => "Gotcha Tomb Widow",
    "Treant" => "Fool Treant",
    "Troll" => "Whoopee Troll",
    "Vampire" => "Fake-Out Vampire",
    "Velvet Devil" => "Trick Velvet Devil",
    "Venus Mantrap" => "Joke Venus Mantrap",
    "Wardrobe Mimic" => "Joke Wardrobe Mimic",
    "Wight" => "Prank Wight",
    "Wild Dog" => "Prank Wild Dog",
    "Wildcat" => "Fool Wildcat",
    "Wolf" => "Whoopee Wolf",
    "Wraith" => "Fool Wraith",
    "Zombie" => "April Zombie"
  }.freeze

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
      start = Time.new(now.year, 4, 1)
      finish = Time.new(now.year, 4, 2)
      now >= start && now < finish
    end

    def ends_at(now = Time.now)
      Time.new(now.year, 4, 2).to_i
    end

    def active?(now = Time.now)
      Engine::Seasons.active?(:april_fools, now) ||
        (Engine::Seasons.forced_key == KEY)
    end

    def dress_line(who)
      DRESS[who.to_s]
    end

    def clergy_line(boss_name, kind = :victory)
      key = kind.to_sym == :praise ? :praise : :victory
      CLERGY_LINES.dig(boss_name.to_s, key)
    end

    def note_submit!(player)
      return unless player && (active? || Engine::Seasons.forced_key == KEY)

      player.bump_tracker!(SUBMIT_TRACKER)
    end

    def room_weight_mult(kind)
      case kind.to_s
      when 'trap' then 1.75
      when 'treasure' then 1.25
      when 'monster' then 1.1
      else 1.0
      end
    end

    def sweets_count(player)
      player.tracker(SWEETS_TRACKER)
    end

    def grant_sweets!(player, amount = 1)
      have = sweets_count(player)
      add = [[amount.to_i, 0].max, SWEETS_MAX - have].min
      return 0 if add <= 0

      player.set_tracker!(SWEETS_TRACKER, have + add)
      add
    end

    def eat_sweets!(player)
      have = sweets_count(player)
      return { ok: false, message: 'Your fool\'s tin is empty.' } if have <= 0

      player.set_tracker!(SWEETS_TRACKER, have - 1)
      player.bump_tracker!(SWEETS_EATEN)
      case rand(3)
      when 0
        gained = player.heal_defiance!(14)
        { ok: true, message: "Joke sweet, real warmth — **+#{gained} Defiance** " \
                             "(#{sweets_count(player)} sweets left)." }
      when 1
        player.gain_lp!(9)
        { ok: true, message: "A prank candy melts filthy — **+9 LP** (now `#{player.lp}`). " \
                             "#{sweets_count(player)} sweets left." }
      else
        before = player.lust
        player.update(lust: [player.lust - 10, 0].max)
        { ok: true, message: "Sugar settles the heat — **−#{before - player.lust} Lust** (now `#{player.lust}`). " \
                             "#{sweets_count(player)} sweets left." }
      end
    end

    def status_consumables(player)
      count = sweets_count(player)
      return [] unless count.positive?

      [{ id: 'april_fools_sweets', label: "Fool's Sweets", count: count, max: SWEETS_MAX }]
    end

    def biome_weight_mult(biome_key)
      case biome_key.to_s
      when 'masquerade_ball' then 1.7
      when 'ashen_court', 'flooded_grotto' then 1.2
      else 1.05
      end
    end

    def presence_suffix
      ' — April 1; trust nothing, especially Pip.'
    end

    def costume_stock?
      active?
    end

    def fool_altar?
      active?
    end

    def syn_fool_unlocked?(player)
      player.tracker('syn_april_fools_crumb').positive? || active?
    end

    def mark_syn_crumb!(player)
      player.set_tracker!('syn_april_fools_crumb', 1)
    end

    def monster_alias(base_name)
      MONSTER_ALIASES[base_name.to_s]
    end

    def chest_bonus!(player)
      return [] unless active?

      lines = []
      added = grant_sweets!(player, rand(1..2))
      if added.positive?
        lines << "Foil **Fool's Sweets** tumble out — stashed for later " \
                 "(**#{sweets_count(player)}/#{SWEETS_MAX}** in your tin)."
      end
      if rand < 0.22
        Engine::Residents.sync_vex_outfits!
        piece = COSTUMES.reject { |s| (item = ::Equipment.first(name: s[:name])) && player.owns_equipment?(item.id) }.sample
        if piece && (item = ::Equipment.first(name: piece[:name]))
          grant = player.grant_equipment!(item, auto_equip: false)
          if grant[:ok]
            lines << "A Fool's piece: **#{item.name}** — _#{item.description}_ " \
                     '(keeps forever; equip from `e,equipment` / reclaim free at Vex).'
          end
        end
      end
      # Classic April bit: sometimes the "treasure" was the joke — still leave a sweet.
      if rand < 0.15
        lines << '_A tiny card flutters out in Pip\'s handwriting: "GOTCHA. (Also keep the candy.)"_'
      end
      lines
    end

    Engine::Seasons.register!(KEY, self)
  end
end
