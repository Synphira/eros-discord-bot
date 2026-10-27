# frozen_string_literal: true

require_relative 'seasons'

module Engine
  # Midnight turn (Dec 31–Jan 2). Resolutions, champagne, countdown — rewards keep forever.
  module NewYear
    KEY = 'new_year'
    BUBBLES_TRACKER = 'new_year_bubbles'
    BUBBLES_EATEN = 'new_year_bubbles_eaten'
    BUBBLES_MAX = 10
    SUBMIT_TRACKER = 'new_year_submits'
    RESOLUTION_OPTION = 'resolutions'

    WEEKLY = {
      key: KEY,
      name: 'Midnight Oath',
      description: 'The temple counts down: lust runs hotter (×1.12), +2 LP on every submit, events 25% more often, ' \
                   'elites lean in. Every hallway pest wears a midnight name. Champagne bubbles and Vex\'s glitter ' \
                   'rack stay after the clock strikes. Syn buckles a party hat on her pupper. Ask her about midnight.',
      effects: {
        'lust_mult' => 1.12,
        'submit_lp_bonus' => 2,
        'satisfy_bonus' => 0.04
      },
      monsters: { demon: 1.5, slime: 1.6, mimic: 1.25 },
      special: { 'event_rate' => 1.25, 'elite_chance' => 1.35 }
    }.freeze

    COSTUME_NAMES = [
      'Countdown Tiara',
      'Midnight Lace Bodice',
      'Champagne Sheer Hose'
    ].freeze

    COSTUMES = [
      { name: 'Countdown Tiara', slot: 'head', type: 'armor', cost: 55, tier: :new_year,
        description: 'Glitter and a tiny clock face. You look like a resolution that already failed beautifully.',
        stat_modifiers: { 'appearance' => 9, 'satisfy_bonus' => 0.03, 'explore_lp' => 1 } },
      { name: 'Midnight Lace Bodice', slot: 'chest', type: 'armor', cost: 95, tier: :new_year,
        description: 'Black lace for the last hour of the year — cut to make every toast a confession.',
        stat_modifiers: { 'appearance' => 13, 'lust_mult' => 1.08, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.05 } },
      { name: 'Champagne Sheer Hose', slot: 'legs', type: 'armor', cost: 65, tier: :new_year,
        description: 'Hose the colour of good bubbles. Standing for the countdown becomes a pose.',
        stat_modifiers: { 'appearance' => 10, 'agility' => 1, 'submit_lp_bonus' => 1 } }
    ].freeze

    DRESS = {
      'Mimic Broodmother' => 'Paper party hat stapled crooked; brood with noisemakers in a circle. She endures. When ' \
                            'they cheer, her lid lifts a fraction. That counts.',
      'Succubus Queen' => 'Midnight velvet, champagne pearls, and a list of resolutions she intends to break for you ' \
                         'personally. Starting with "behave."',
      'Incubus King' => 'Sparkler behind one horn, toast notes in someone else\'s handwriting. He still stands at ' \
                       'midnight like he wrote the year.',
      'Verdant Dryad' => 'New leaves and frost-lace. She smells like first snow and second chances with teeth — soft ' \
                        'until she isn\'t.',
      'Lich Lord' => 'A cardboard "NEW YEAR" banner across his ribs. He is counting down out of spite, and he will ' \
                    'not miss a second.',
      'Alpha Beast' => 'Syn has buckled a ridiculous glitter party hat onto her pupper for midnight. He is delighted. ' \
                      'Confetti sticks to his fur for days. She checked.',
      'Eros' => 'A smile like a countdown — night lace, citrus in the air, permission to begin again on your knees.',
      'Syn' => 'Glitter she will not wipe, corkscrew in reach, and the look of someone who collects vows like ' \
              'souvenirs. Midnights are her favourite trap.',
      'Berry' => 'Shop open past midnight, citrus in the air, free cork-pops for anyone who tips. She is not hosting. ' \
                'She is profiting from other people\'s resolutions.',
      'Covar' => 'A noisemaker he will not blow — until a customer tips well. Then once. Soft. He pretends it was the wind.',
      'Madame Vex' => 'Sequins that move when she does, a countdown pose priced as a consultation, and champagne ' \
                     'heels that should not work on stone. They do.',
      'Pip' => 'Year-hat on backwards, champagne cork under a glass for "evidence," pants forgotten in 2026. She is ' \
              'taking the new year personally.',
      'Sister Nectar' => 'A countdown chalked beside the pumps, citrus in the oil, and resolutions she will milk out of ' \
                        'you before midnight. The shrine does not do dry January.',
      'Fang' => 'Maps with midnight marked in gold leaf. He sells sketches of rooms that only exist for one minute. ' \
               'Buy fast. The year moves.'
    }.freeze

    CLERGY_LINES = {
      'Mimic Broodmother' => {
        victory: 'The Broodmother\'s lid clacks under a party hat. "Countdown," she croons. "You\'re the toast."',
        praise: 'Little mimics bounce with noisemakers. One offers you a sticky sweet from its mouth.'
      },
      'Succubus Queen' => {
        victory: 'The Queen lifts a champagne pearl. "Midnight etiquette," she purrs. "Kiss. Then swear."',
        praise: '"Resolutions that taste sweet last longer," she says, and takes hers from your mouth.'
      },
      'Incubus King' => {
        victory: 'Sparkler askew. "I poured," the King lies brightly. "You\'re the first course of the year."',
        praise: 'He tips bubbles you did not ask for against your lips and watches you swallow.'
      },
      'Verdant Dryad' => {
        victory: 'New leaves brush your cheek. "Begin again on your knees," she murmurs.',
        praise: 'She tucks a frost leaf behind your ear. It smells like snow and promise.'
      },
      'Lich Lord' => {
        victory: 'The sash tips. "Oaths are bindings," the Lich notes. "You accepted the year."',
        praise: 'He stamps a cold sigil that looks, briefly, like a calendar with your dignity marked spent.'
      },
      'Alpha Beast' => {
        victory: 'Syn\'s pupper shakes his party hat proudly. Someone starts a countdown they did not ask for.',
        praise: 'He drops a mouthful of foil-wrapped bubbles on your chest and looks enormously proud.'
      },
      'Eros' => {
        victory: 'The goddess tastes of champagne and grace. "I let them swear one night," Eros says. "They behave better vowed."',
        praise: 'A white tentacle offers you a glass. Refusing is not among the options.'
      }
    }.freeze

    MIDNIGHT_BLESSING = {
      key: 'midnight_glow', name: 'Midnight Glow', floors: 4,
      effects: { 'submit_lp_bonus' => 2, 'appearance' => 4, 'satisfy_bonus' => 0.04 },
      summary: 'Bright, bubbly, and faintly gold — the temple likes an oath that sticks to skin'
    }.freeze

  MONSTER_ALIASES = {
    "Alraune" => "Midnight Alraune",
    "Amber Slime" => "Champagne Amber Slime",
    "Balloon Mistress" => "Party-Horn Balloon Mistress",
    "Banshee" => "Last-Year's Banshee",
    "Basilisk" => "Countdown Basilisk",
    "Bath Mimic" => "Party-Favor Bath Mimic",
    "Bear" => "Confetti Bear",
    "Bed Mimic" => "Resolution Bed Mimic",
    "Big-Shoe Brute" => "Noisemaker Big-Shoe Brute",
    "Black Orchid" => "New-Leaf Black Orchid",
    "Blood Rose" => "Garland Blood Rose",
    "Bone Dancer" => "Ghost-of-December Bone Dancer",
    "Book Mimic" => "Clock Book Mimic",
    "Broodmother" => "Midnight Broodmother",
    "Bubble Slime" => "Sparkling Bubble Slime",
    "Cambion" => "Resolution Cambion",
    "Carnal Fiend" => "Oath Carnal Fiend",
    "Carnival Clown" => "Countdown Carnival Clown",
    "Centaur" => "Ball-Drop Centaur",
    "Chain Devil" => "Vow Chain Devil",
    "Chair Mimic" => "Champagne-Crate Chair Mimic",
    "Champagne Slime" => "Bubbly Champagne Slime",
    "Chandelier Mimic" => "Ball-Drop Chandelier Mimic",
    "Chest Mimic" => "Resolution Chest Mimic",
    "Clock Mimic" => "Party-Favor Clock Mimic",
    "Clothing Mimic" => "Resolution Clothing Mimic",
    "Corpse Flower" => "Midnight Corpse Flower",
    "Cotton-Candy Imp" => "Confetti Cotton-Candy Imp",
    "Couch Mimic" => "Clock Couch Mimic",
    "Cream Slime" => "Clock-Strike Cream Slime",
    "Crypt Keeper" => "Hangover Crypt Keeper",
    "Crystal Slime" => "Glitter Crystal Slime",
    "Curtain Mimic" => "Champagne-Crate Curtain Mimic",
    "Demoness" => "Champagne Demoness",
    "Djinn" => "Toast Djinn",
    "Door Mimic" => "Ball-Drop Door Mimic",
    "Dragon" => "Fresh-Year Dragon",
    "Dream Eater" => "Resolution Dream Eater",
    "Dryad" => "New-Leaf Dryad",
    "Dullahan" => "Calendar Dullahan",
    "Ember Fiend" => "Oath Ember Fiend",
    "Fae Trickster" => "Vow Fae Trickster",
    "Foam Slime" => "Champagne Foam Slime",
    "Gargoyle" => "Countdown Gargoyle",
    "Gelatinous Mass" => "Sparkling Gelatinous Mass",
    "Ghost" => "Forgotten Ghost",
    "Ghoul" => "Last-Year's Ghoul",
    "Giant Bee" => "Confetti Giant Bee",
    "Giant Moth" => "Midnight Giant Moth",
    "Giant Spider" => "Ball-Drop Giant Spider",
    "Glow Slime" => "Bubbly Glow Slime",
    "Goblin" => "Fresh-Year Goblin",
    "Gorgon Matron" => "Countdown Gorgon Matron",
    "Green Slime" => "Clock-Strike Green Slime",
    "Harpy" => "Confetti Harpy",
    "Headless Knight" => "Ghost-of-December Headless Knight",
    "Hellhound" => "Champagne Hellhound",
    "Honey Slime" => "Glitter Honey Slime",
    "Honker" => "Toast Honker",
    "HuCow" => "Champagne HuCow",
    "Ifrit" => "Toast Ifrit",
    "Imp" => "Resolution Imp",
    "Incubus" => "Midnight Incubus",
    "Item Pile Mimic" => "Party-Favor Item Pile Mimic",
    "Jelly Cube" => "Champagne Jelly Cube",
    "Jellyfish" => "Sparkling Jellyfish",
    "Jester" => "Party-Horn Jester",
    "Jiangshi" => "Hangover Jiangshi",
    "Kitsune" => "Midnight Kitsune",
    "Lamia" => "Ball-Drop Lamia",
    "Lich" => "Calendar Lich",
    "Living Ivy" => "Bloom Living Ivy",
    "Loom Mimic" => "Resolution Loom Mimic",
    "Man-Eating Flower" => "First-Frost Man-Eating Flower",
    "Mandrake" => "New-Leaf Mandrake",
    "Marionette Mistress" => "Oath Marionette Mistress",
    "Mercury Slime" => "Bubbly Mercury Slime",
    "Milk Slime" => "Clock-Strike Milk Slime",
    "Minotaur" => "Fresh-Year Minotaur",
    "Mirror Mimic" => "Clock Mirror Mimic",
    "Moonflower" => "Garland Moonflower",
    "Mummy" => "Forgotten Mummy",
    "Mycelian" => "Midnight Mycelian",
    "Naga" => "Countdown Naga",
    "Night Hag" => "Vow Night Hag",
    "Nightshade" => "Bloom Nightshade",
    "Ogre" => "Confetti Ogre",
    "Oil Slime" => "Glitter Oil Slime",
    "Oni" => "Champagne Oni",
    "Orc" => "Midnight Orc",
    "Pale Bride" => "Last-Year's Pale Bride",
    "Piano Mimic" => "Champagne-Crate Piano Mimic",
    "Pie Clown" => "Noisemaker Pie Clown",
    "Pit Fiend" => "Toast Pit Fiend",
    "Pitcher Plant" => "First-Frost Pitcher Plant",
    "Pollen Sprite" => "New-Leaf Pollen Sprite",
    "Poltergeist" => "Ghost-of-December Poltergeist",
    "Pudding Slime" => "Champagne Pudding Slime",
    "Purple Slime" => "Sparkling Purple Slime",
    "Rakshasa" => "Resolution Rakshasa",
    "Revenant" => "Hangover Revenant",
    "Ringmaster" => "Countdown Ringmaster",
    "Rose Slime" => "Bubbly Rose Slime",
    "Rubber Slime" => "Clock-Strike Rubber Slime",
    "Rug Mimic" => "Ball-Drop Rug Mimic",
    "Sap Dryad" => "Garland Sap Dryad",
    "Satyr" => "Ball-Drop Satyr",
    "Silkweaver" => "Fresh-Year Silkweaver",
    "Sin Eater" => "Oath Sin Eater",
    "Siren" => "Vow Siren",
    "Skeleton" => "Calendar Skeleton",
    "Specter" => "Forgotten Specter",
    "Statue Mimic" => "Party-Favor Statue Mimic",
    "Stone Golem" => "Resolution Stone Golem",
    "Strangler Fig" => "Midnight Strangler Fig",
    "Succubus" => "Toastmistress Succubus",
    "Sundew" => "Bloom Sundew",
    "Syrup Slime" => "Glitter Syrup Slime",
    "Tar Slime" => "Champagne Tar Slime",
    "Tentacle Vine" => "First-Frost Tentacle Vine",
    "Thorn Vine" => "New-Leaf Thorn Vine",
    "Throne Mimic" => "Clock Throne Mimic",
    "Tomb Widow" => "Last-Year's Tomb Widow",
    "Treant" => "Garland Treant",
    "Troll" => "Countdown Troll",
    "Vampire" => "Ghost-of-December Vampire",
    "Velvet Devil" => "Champagne Velvet Devil",
    "Venus Mantrap" => "Midnight Venus Mantrap",
    "Wardrobe Mimic" => "Champagne-Crate Wardrobe Mimic",
    "Wight" => "Hangover Wight",
    "Wild Dog" => "Confetti Wild Dog",
    "Wildcat" => "Midnight Wildcat",
    "Wolf" => "Countdown Wolf",
    "Wraith" => "Calendar Wraith",
    "Zombie" => "Forgotten Zombie"
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

    # Dec 31 through Jan 2 (morning of the 3rd ends it).
    def window?(now = Time.now)
      return true if now.month == 12 && now.day >= 31
      return true if now.month == 1 && now.day < 3

      false
    end

    def ends_at(now = Time.now)
      if now.month == 12
        Time.new(now.year + 1, 1, 3).to_i
      else
        Time.new(now.year, 1, 3).to_i
      end
    end

    def active?(now = Time.now)
      Engine::Seasons.active?(:new_year, now) ||
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

    def bubbles_count(player)
      player.tracker(BUBBLES_TRACKER)
    end

    def grant_bubbles!(player, amount = 1)
      have = bubbles_count(player)
      add = [[amount.to_i, 0].max, BUBBLES_MAX - have].min
      return 0 if add <= 0

      player.set_tracker!(BUBBLES_TRACKER, have + add)
      add
    end

    def eat_bubbles!(player)
      have = bubbles_count(player)
      return { ok: false, message: 'Your champagne tin is empty.' } if have <= 0

      player.set_tracker!(BUBBLES_TRACKER, have - 1)
      player.bump_tracker!(BUBBLES_EATEN)
      case rand(3)
      when 0
        gained = player.heal_defiance!(14)
        { ok: true, message: "A bright swallow — **+#{gained} Defiance** " \
                             "(#{bubbles_count(player)} bubbles left)." }
      when 1
        player.gain_lp!(9)
        { ok: true, message: "Midnight fizz goes straight to LP — **+9 LP** (now `#{player.lp}`). " \
                             "#{bubbles_count(player)} bubbles left." }
      else
        before = player.lust
        player.update(lust: [player.lust - 10, 0].max)
        { ok: true, message: "Bubbles cool the heat — **−#{before - player.lust} Lust** (now `#{player.lust}`). " \
                             "#{bubbles_count(player)} bubbles left." }
      end
    end

    def status_consumables(player)
      count = bubbles_count(player)
      return [] unless count.positive?

      [{ id: 'new_year_bubbles', label: 'Champagne Bubbles', count: count, max: BUBBLES_MAX }]
    end

    def biome_weight_mult(biome_key)
      case biome_key.to_s
      when 'ashen_court', 'masquerade_ball', 'flooded_grotto' then 1.45
      else 1.08
      end
    end

    def presence_suffix
      ' — countdown running; swear carefully.'
    end

    def costume_stock?
      active?
    end

    def midnight_altar?
      active?
    end

    def syn_midnight_unlocked?(player)
      player.tracker('syn_new_year_crumb').positive? || active?
    end

    def mark_syn_crumb!(player)
      player.set_tracker!('syn_new_year_crumb', 1)
    end

    def monster_alias(base_name)
      MONSTER_ALIASES[base_name.to_s]
    end

    def chest_bonus!(player)
      return [] unless active?

      lines = []
      added = grant_bubbles!(player, rand(1..2))
      if added.positive?
        lines << "Foil **Champagne Bubbles** tumble out — stashed for later " \
                 "(**#{bubbles_count(player)}/#{BUBBLES_MAX}** in your tin)."
      end
      if rand < 0.22
        Engine::Residents.sync_vex_outfits!
        piece = COSTUMES.reject { |s| (item = ::Equipment.first(name: s[:name])) && player.owns_equipment?(item.id) }.sample
        if piece && (item = ::Equipment.first(name: piece[:name]))
          grant = player.grant_equipment!(item, auto_equip: false)
          if grant[:ok]
            lines << "A midnight piece: **#{item.name}** — _#{item.description}_ " \
                     '(keeps forever; equip from `e,equipment` / reclaim free at Vex).'
          end
        end
      end
      lines
    end

    Engine::Seasons.register!(KEY, self)
  end
end
