# frozen_string_literal: true

require_relative 'seasons'

module Engine
  # Yule week (Dec 20–26). Gifts, mistletoe, ribbon — rewards keep forever.
  module Christmas
    KEY = 'christmas'
    CANDY_TRACKER = 'christmas_candy'
    CANDY_EATEN = 'christmas_candy_eaten'
    CANDY_MAX = 12
    SUBMIT_TRACKER = 'christmas_submits'
    NAUGHTY_OPTION = 'naughty_list'

    WEEKLY = {
      key: KEY,
      name: 'Yule of Surrender',
      description: 'The temple hangs mistletoe like a trap: undead and demons throng, lust runs hotter (×1.1), ' \
                   '+2 LP submitting to undead / +2 to demons, events 20% more often. Every hallway pest wears a ' \
                   'Yule name. Stocking candy and Vex\'s ribbon rack stay after the wrapping comes down. Syn ' \
                   'buckles jingle bells on her pupper. Ask her about Yule while it lasts.',
      effects: {
        'lust_mult' => 1.1,
        'undead_submit_lp' => 2,
        'demon_submit_lp' => 2,
        'satisfy_bonus' => 0.03
      },
      monsters: { undead: 1.75, demon: 1.6, mimic: 1.4, slime: 1.2 },
      special: { 'event_rate' => 1.2, 'elite_chance' => 1.2, 'mimic_chance' => 1.3 }
    }.freeze

    COSTUME_NAMES = [
      'Antler Circlet',
      'Ribbon-Wrapped Bodice',
      'Mistletoe Stockings'
    ].freeze

    COSTUMES = [
      { name: 'Antler Circlet', slot: 'head', type: 'armor', cost: 55, tier: :christmas,
        description: 'Gilt antlers and a velvet bow. You look like you came to be hunted under the tree.',
        stat_modifiers: { 'appearance' => 9, 'satisfy_bonus' => 0.03, 'submit_lp_bonus' => 1 } },
      { name: 'Ribbon-Wrapped Bodice', slot: 'chest', type: 'armor', cost: 95, tier: :christmas,
        description: 'Scarlet ribbon that frames the chest like a gift mid-unwrap. The bow is a suggestion.',
        stat_modifiers: { 'appearance' => 13, 'lust_mult' => 1.08, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.05 } },
      { name: 'Mistletoe Stockings', slot: 'legs', type: 'armor', cost: 65, tier: :christmas,
        description: 'Sheer evergreen silk with berry embroidery at the thigh. Standing under anything becomes a dare.',
        stat_modifiers: { 'appearance' => 10, 'agility' => 1, 'submit_lp_bonus' => 1 } }
    ].freeze

    DRESS = {
      'Mimic Broodmother' => 'Scrap ribbon stolen from Vex, wound around her lid until she looks gift-wrapped. One ' \
                            'broodling wears a bow on its tooth like a prize.',
      'Succubus Queen' => 'Wrapping-paper velvet and a mistletoe pendant that turns every doorway into an obligation. ' \
                         'She keeps score of kisses.',
      'Incubus King' => 'Tinsel on one horn, empty boxes under the tree with his name on the tags. The receipts are ' \
                       'in Syn\'s handwriting. He does not ask.',
      'Verdant Dryad' => 'Holly and pine. She smells like a forest that decorated itself for an audience of one — ' \
                        'and that audience is whoever kneels first.',
      'Lich Lord' => 'A paper star crooked in blue fire. He rotates slowly so it faces the wall. The star follows.',
      'Alpha Beast' => 'Syn has buckled a collar of jingle bells onto her pupper for Yule. He is delighted. Every ' \
                      'shake announces him three floors away.',
      'Eros' => 'Ribbon like a vow — red on white — and the patience of someone who unwraps slowly on purpose.',
      'Syn' => 'Pine-needle ink, a stack of finished bows, and the smug calm of the person who hung every sprig of ' \
              'mistletoe in this tower. Including the cruel ones.',
      'Berry' => 'Peppermint in the air, foil candy piled like treasure, and a "naughty" stamp she uses on receipts. ' \
                'Fondly. Aggressively.',
      'Covar' => 'His ledger is gift-wrapped in scrap paper and a bow. He swears it is seasonal packaging. The bow is ' \
                'crooked on purpose so customers ask.',
      'Madame Vex' => 'She is wearing the concept of wrapping paper — living cloth patterned like presents, scissors ' \
                     'on a silk belt. Bows cost extra. Undoing them costs more.',
      'Pip' => 'Santa hat, stockings under "scientific observation," and a solemn vow that chimney physics are real. ' \
              'Pants remain a spring tradition, apparently.',
      'Sister Nectar' => 'Red ribbon on the brass cups, peppermint oil in the shrine air, and a soft "unwrap first" that ' \
                        'is not about presents. Milking is holy. Gifts are optional. Kneeling is not.',
      'Fang' => 'Black paper, white ink, a tiny paper star stuck to one corner of the dream-map. He did not put it ' \
               'there. He left it. The next three rooms include a chimney that wants something.'
    }.freeze

    CLERGY_LINES = {
      'Mimic Broodmother' => {
        victory: 'The Broodmother\'s lid clacks under ribbon. "Unwrap," she croons. "My brood wrapped you first."',
        praise: 'Little mimics bounce with bows on their teeth. One offers you a sticky sweet from its mouth.'
      },
      'Succubus Queen' => {
        victory: 'The Queen lifts her mistletoe pendant. "Yule etiquette," she purrs. "Kiss. Then kneel."',
        praise: '"Good gifts stay open," she says, and takes her thanks from your mouth.'
      },
      'Incubus King' => {
        victory: 'Tinsel askew. "I wrapped it myself," the King lies brightly. "You\'re under the tree."',
        praise: 'He tips eggnog you did not ask for against your lips and watches you swallow.'
      },
      'Verdant Dryad' => {
        victory: 'Holly brushes your cheek. "The evergreen keeps what kneels," she murmurs.',
        praise: 'She tucks a pine sprig behind your ear. It smells like cold and permission.'
      },
      'Lich Lord' => {
        victory: 'The paper star tips. "Gifts are bindings," the Lich notes. "You accepted the ribbon."',
        praise: 'He stamps a cold sigil that looks, briefly, like a wrapped box of your remaining dignity.'
      },
      'Alpha Beast' => {
        victory: 'Syn\'s pupper shakes his jingle collar proudly. The hallway applauds whether it meant to or not.',
        praise: 'He drops a mouthful of foil-wrapped candy on your chest and looks enormously proud.'
      },
      'Eros' => {
        victory: 'The goddess tastes of peppermint and grace. "I let them wrap one week," Eros says. "They behave better tied."',
        praise: 'A white tentacle offers you a ribbon. Refusing is not among the options.'
      }
    }.freeze

    YULE_BLESSING = {
      key: 'yule_glow', name: 'Yule Glow', floors: 4,
      effects: { 'submit_lp_bonus' => 2, 'appearance' => 4, 'satisfy_bonus' => 0.04 },
      summary: 'Warm, ribbon-tight, and faintly gold — the temple likes a gift that stays open'
    }.freeze

  MONSTER_ALIASES = {
    "Alraune" => "Holly Alraune",
    "Amber Slime" => "Eggnog Amber Slime",
    "Balloon Mistress" => "Parade-Float Balloon Mistress",
    "Banshee" => "Ghost-of-Yule Banshee",
    "Basilisk" => "Ribbon-Tied Basilisk",
    "Bath Mimic" => "Gift-Wrapped Bath Mimic",
    "Bear" => "Sleigh Bear",
    "Bed Mimic" => "Stocking Bed Mimic",
    "Big-Shoe Brute" => "Elf-Clown Big-Shoe Brute",
    "Black Orchid" => "Holly Black Orchid",
    "Blood Rose" => "Mistletoe Blood Rose",
    "Bone Dancer" => "Caroling Bone Dancer",
    "Book Mimic" => "Ornament Book Mimic",
    "Broodmother" => "Frostbitten Broodmother",
    "Bubble Slime" => "Peppermint Bubble Slime",
    "Cambion" => "Tinsel Cambion",
    "Carnal Fiend" => "Coal Carnal Fiend",
    "Carnival Clown" => "Jingle Carnival Clown",
    "Centaur" => "Yule Centaur",
    "Chain Devil" => "Naughty Chain Devil",
    "Chair Mimic" => "Parcel Chair Mimic",
    "Champagne Slime" => "Sugar-Plum Champagne Slime",
    "Chandelier Mimic" => "Ribbon Chandelier Mimic",
    "Chest Mimic" => "Gift-Wrapped Chest Mimic",
    "Clock Mimic" => "Gift-Wrapped Clock Mimic",
    "Clothing Mimic" => "Stocking Clothing Mimic",
    "Corpse Flower" => "Pine Corpse Flower",
    "Cotton-Candy Imp" => "Feast-Fool Cotton-Candy Imp",
    "Couch Mimic" => "Ornament Couch Mimic",
    "Cream Slime" => "Snowmelt Cream Slime",
    "Crypt Keeper" => "Wreath Crypt Keeper",
    "Crystal Slime" => "Tinsel Crystal Slime",
    "Curtain Mimic" => "Parcel Curtain Mimic",
    "Demoness" => "Nice Demoness",
    "Djinn" => "Gift Djinn",
    "Door Mimic" => "Ribbon Door Mimic",
    "Dragon" => "Stocking Dragon",
    "Dream Eater" => "Tinsel Dream Eater",
    "Dryad" => "Yule Dryad",
    "Dullahan" => "Chimney Dullahan",
    "Ember Fiend" => "Coal Ember Fiend",
    "Fae Trickster" => "Naughty Fae Trickster",
    "Foam Slime" => "Eggnog Foam Slime",
    "Gargoyle" => "Ribbon-Tied Gargoyle",
    "Gelatinous Mass" => "Peppermint Gelatinous Mass",
    "Ghost" => "Silent-Night Ghost",
    "Ghoul" => "Ghost-of-Yule Ghoul",
    "Giant Bee" => "Sleigh Giant Bee",
    "Giant Moth" => "Frostbitten Giant Moth",
    "Giant Spider" => "Yule Giant Spider",
    "Glow Slime" => "Sugar-Plum Glow Slime",
    "Goblin" => "Stocking Goblin",
    "Gorgon Matron" => "Ribbon-Tied Gorgon Matron",
    "Green Slime" => "Snowmelt Green Slime",
    "Harpy" => "Sleigh Harpy",
    "Headless Knight" => "Caroling Headless Knight",
    "Hellhound" => "Nice Hellhound",
    "Honey Slime" => "Tinsel Honey Slime",
    "Honker" => "Carol Honker",
    "HuCow" => "Eggnog HuCow",
    "Ifrit" => "Gift Ifrit",
    "Imp" => "Tinsel Imp",
    "Incubus" => "Tinsel Incubus",
    "Item Pile Mimic" => "Gift-Wrapped Item Pile Mimic",
    "Jelly Cube" => "Eggnog Jelly Cube",
    "Jellyfish" => "Peppermint Jellyfish",
    "Jester" => "Parade-Float Jester",
    "Jiangshi" => "Wreath Jiangshi",
    "Kitsune" => "Frostbitten Kitsune",
    "Lamia" => "Yule Lamia",
    "Lich" => "Chimney Lich",
    "Living Ivy" => "Poinsettia Living Ivy",
    "Loom Mimic" => "Stocking Loom Mimic",
    "Man-Eating Flower" => "Evergreen Man-Eating Flower",
    "Mandrake" => "Holly Mandrake",
    "Marionette Mistress" => "Coal Marionette Mistress",
    "Mercury Slime" => "Sugar-Plum Mercury Slime",
    "Milk Slime" => "Snowmelt Milk Slime",
    "Minotaur" => "Stocking Minotaur",
    "Mirror Mimic" => "Ornament Mirror Mimic",
    "Moonflower" => "Mistletoe Moonflower",
    "Mummy" => "Silent-Night Mummy",
    "Mycelian" => "Pine Mycelian",
    "Naga" => "Ribbon-Tied Naga",
    "Night Hag" => "Naughty Night Hag",
    "Nightshade" => "Poinsettia Nightshade",
    "Ogre" => "Sleigh Ogre",
    "Oil Slime" => "Tinsel Oil Slime",
    "Oni" => "Nice Oni",
    "Orc" => "Frostbitten Orc",
    "Pale Bride" => "Ghost-of-Yule Pale Bride",
    "Piano Mimic" => "Parcel Piano Mimic",
    "Pie Clown" => "Elf-Clown Pie Clown",
    "Pit Fiend" => "Gift Pit Fiend",
    "Pitcher Plant" => "Evergreen Pitcher Plant",
    "Pollen Sprite" => "Holly Pollen Sprite",
    "Poltergeist" => "Caroling Poltergeist",
    "Pudding Slime" => "Eggnog Pudding Slime",
    "Purple Slime" => "Peppermint Purple Slime",
    "Rakshasa" => "Tinsel Rakshasa",
    "Revenant" => "Wreath Revenant",
    "Ringmaster" => "Jingle Ringmaster",
    "Rose Slime" => "Sugar-Plum Rose Slime",
    "Rubber Slime" => "Snowmelt Rubber Slime",
    "Rug Mimic" => "Ribbon Rug Mimic",
    "Sap Dryad" => "Mistletoe Sap Dryad",
    "Satyr" => "Yule Satyr",
    "Silkweaver" => "Stocking Silkweaver",
    "Sin Eater" => "Coal Sin Eater",
    "Siren" => "Naughty Siren",
    "Skeleton" => "Chimney Skeleton",
    "Specter" => "Silent-Night Specter",
    "Statue Mimic" => "Gift-Wrapped Statue Mimic",
    "Stone Golem" => "Stocking Stone Golem",
    "Strangler Fig" => "Pine Strangler Fig",
    "Succubus" => "Stocking Succubus",
    "Sundew" => "Poinsettia Sundew",
    "Syrup Slime" => "Tinsel Syrup Slime",
    "Tar Slime" => "Eggnog Tar Slime",
    "Tentacle Vine" => "Evergreen Tentacle Vine",
    "Thorn Vine" => "Holly Thorn Vine",
    "Throne Mimic" => "Ornament Throne Mimic",
    "Tomb Widow" => "Ghost-of-Yule Tomb Widow",
    "Treant" => "Mistletoe Treant",
    "Troll" => "Ribbon-Tied Troll",
    "Vampire" => "Caroling Vampire",
    "Velvet Devil" => "Nice Velvet Devil",
    "Venus Mantrap" => "Pine Venus Mantrap",
    "Wardrobe Mimic" => "Parcel Wardrobe Mimic",
    "Wight" => "Wreath Wight",
    "Wild Dog" => "Sleigh Wild Dog",
    "Wildcat" => "Frostbitten Wildcat",
    "Wolf" => "Ribbon-Tied Wolf",
    "Wraith" => "Chimney Wraith",
    "Zombie" => "Silent-Night Zombie"
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
      start = Time.new(now.year, 12, 20)
      finish = Time.new(now.year, 12, 27) # through Dec 26 inclusive
      now >= start && now < finish
    end

    def ends_at(now = Time.now)
      Time.new(now.year, 12, 27).to_i
    end

    def active?(now = Time.now)
      Engine::Seasons.active?(:christmas, now) ||
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

    def candy_count(player)
      player.tracker(CANDY_TRACKER)
    end

    def grant_candy!(player, amount = 1)
      have = candy_count(player)
      add = [[amount.to_i, 0].max, CANDY_MAX - have].min
      return 0 if add <= 0

      player.set_tracker!(CANDY_TRACKER, have + add)
      add
    end

    def eat_candy!(player)
      have = candy_count(player)
      return { ok: false, message: 'Your stocking is empty.' } if have <= 0

      player.set_tracker!(CANDY_TRACKER, have - 1)
      player.bump_tracker!(CANDY_EATEN)
      case rand(3)
      when 0
        gained = player.heal_defiance!(14)
        { ok: true, message: "Peppermint heat — **+#{gained} Defiance** " \
                             "(#{candy_count(player)} candy left)." }
      when 1
        player.gain_lp!(9)
        { ok: true, message: "A ribbon-sweet melts filthy — **+9 LP** (now `#{player.lp}`). " \
                             "#{candy_count(player)} candy left." }
      else
        before = player.lust
        player.update(lust: [player.lust - 10, 0].max)
        { ok: true, message: "Sugar settles the heat — **−#{before - player.lust} Lust** (now `#{player.lust}`). " \
                             "#{candy_count(player)} candy left." }
      end
    end

    def status_consumables(player)
      count = candy_count(player)
      return [] unless count.positive?

      [{ id: 'christmas_candy', label: 'Stocking Candy', count: count, max: CANDY_MAX }]
    end

    def biome_weight_mult(biome_key)
      case biome_key.to_s
      when 'ashen_court', 'flooded_grotto', 'masquerade_ball' then 1.55
      when 'verdant_grove', 'honeyed_hive' then 0.95
      else 1.05
      end
    end

    def presence_suffix
      ' — mistletoe hung; unwrap carefully.'
    end

    def costume_stock?
      active?
    end

    def yule_altar?
      active?
    end

    def syn_yule_unlocked?(player)
      player.tracker('syn_christmas_crumb').positive? || active?
    end

    def mark_syn_crumb!(player)
      player.set_tracker!('syn_christmas_crumb', 1)
    end

    def monster_alias(base_name)
      MONSTER_ALIASES[base_name.to_s]
    end

    def chest_bonus!(player)
      return [] unless active?

      lines = []
      added = grant_candy!(player, rand(1..2))
      if added.positive?
        lines << "Foil **Stocking Candy** tumbles out — stashed for later " \
                 "(**#{candy_count(player)}/#{CANDY_MAX}** in your stocking)."
      end
      if rand < 0.22
        Engine::Residents.sync_vex_outfits!
        piece = COSTUMES.reject { |s| (item = ::Equipment.first(name: s[:name])) && player.owns_equipment?(item.id) }.sample
        if piece && (item = ::Equipment.first(name: piece[:name]))
          grant = player.grant_equipment!(item, auto_equip: false)
          if grant[:ok]
            lines << "A Yule piece: **#{item.name}** — _#{item.description}_ " \
                     '(keeps forever; equip from `e,equipment` / reclaim free at Vex).'
          end
        end
      end
      lines
    end

    Engine::Seasons.register!(KEY, self)
  end
end
