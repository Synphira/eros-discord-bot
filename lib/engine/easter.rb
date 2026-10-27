# frozen_string_literal: true

require 'date'
require_relative 'seasons'

module Engine
  # Easter weekend (Good Friday through Easter Monday). Eggs, hares, spring — rewards keep forever.
  module Easter
    KEY = 'easter'
    EGGS_TRACKER = 'easter_eggs'
    EGGS_EATEN = 'easter_eggs_eaten'
    EGGS_MAX = 12
    SUBMIT_TRACKER = 'easter_submits'
    NEST_OPTION = 'spring_rut'

    WEEKLY = {
      key: KEY,
      name: "Hare's Hunt",
      description: 'The temple blooms for spring: beasts and plants throng, lust runs warmer (×1.12), ' \
                   '+2 LP submitting to beasts / +2 to plants, events 20% more often. Every hallway pest wears a ' \
                   'spring name. Chocolate eggs and Vex\'s warren rack stay after Monday. Syn buckles bunny ears on ' \
                   'her pupper. Ask her about Hare\'s Hunt while it lasts.',
      effects: {
        'lust_mult' => 1.12,
        'beast_submit_lp' => 2,
        'plant_submit_lp' => 2,
        'satisfy_bonus' => 0.04
      },
      monsters: { beast: 1.75, plant: 1.75, slime: 1.25 },
      special: { 'event_rate' => 1.2, 'elite_chance' => 1.15 }
    }.freeze

    COSTUME_NAMES = [
      'Bunny-Ear Circlet',
      'Pastel Nest Bodice',
      'Spring-Silk Stockings'
    ].freeze

    COSTUMES = [
      { name: 'Bunny-Ear Circlet', slot: 'head', type: 'armor', cost: 55, tier: :easter,
        description: 'Soft ears and a silk bow. You look like you came to be hunted in the garden.',
        stat_modifiers: { 'appearance' => 9, 'satisfy_bonus' => 0.03, 'submit_lp_bonus' => 1 } },
      { name: 'Pastel Nest Bodice', slot: 'chest', type: 'armor', cost: 95, tier: :easter,
        description: 'Pastel silk cut to frame the chest like a nest worth filling. Spring fantasy, temple honesty.',
        stat_modifiers: { 'appearance' => 13, 'lust_mult' => 1.08, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.05 } },
      { name: 'Spring-Silk Stockings', slot: 'legs', type: 'armor', cost: 65, tier: :easter,
        description: 'Sheer stockings the colour of new leaves — delicate lie, fertile implication.',
        stat_modifiers: { 'appearance' => 10, 'agility' => 1, 'submit_lp_bonus' => 1 } }
    ].freeze

    DRESS = {
      'Mimic Broodmother' => 'Painted eggshell glued crooked; one broodling in bunny ears conducting a hunt across her ' \
                            'lid. She calls it liturgy. The brood calls it lunch.',
      'Succubus Queen' => 'Pastel velvet, lily necklace, and nests she intends to fill — starting with whoever looks ' \
                         'softest in the hallway.',
      'Incubus King' => 'Chocolate on one horn, three eggs "hidden" in obvious places. Syn already moved them. He is ' \
                       'still bragging.',
      'Verdant Dryad' => 'Lilies and new leaves. Garden-after-rain smell — fertile, patient, already deciding where ' \
                        'you will kneel to search.',
      'Lich Lord' => 'One paper bunny ear in blue fire. It will not burn. He has tried. Spring is undignified and ' \
                    'winning.',
      'Alpha Beast' => 'Syn has buckled ridiculous bunny ears onto her pupper for Hare\'s Hunt. He is delighted. ' \
                      'The ears flop. The hunt just got louder.',
      'Eros' => 'A smile like a found egg — cream lace, quiet hunger, permission to hunt on your knees.',
      'Syn' => 'Pollen-ink, a basket of decoy eggs, and the satisfaction of someone who hid people better than ' \
              'chocolate. The hunt is hers.',
      'Berry' => 'Windows full of foil eggs, chocolate stacked like a warren, and a soft "look harder" when customers ' \
                'miss the good ones. She is the hunt.',
      'Covar' => 'A painted egg he will not crack — his own careful work. He keeps it in a drawer lined with velvet. ' \
                'Nobody is allowed to ask.',
      'Madame Vex' => 'Pastel silk, bunny-ear fittings that somehow look couture, and a warren of mannequins posed ' \
                     'mid-hunt. Soft. Expensive. Predatory.',
      'Pip' => 'Bunny ears sliding, egg basket under lockdown, and a hypothesis that eggs hatch into traps. Pants ' \
              'would slow her. She refuses.',
      'Sister Nectar' => 'Pastel cloth on the shrine bench, foil eggs in the tip jar, and bunny-ear clips she swears ' \
                        'are "for the children of the tower." There are no children. There is you.',
      'Fang' => 'White ink, a warren sketched in the margin, eggs marked where the land will hide them. He has already ' \
               'found two. He will not say where. Buy the map.'
    }.freeze

    CLERGY_LINES = {
      'Mimic Broodmother' => {
        victory: 'The Broodmother\'s lid clacks under eggshell. "Nest," she croons. "My brood hid you first."',
        praise: 'Little mimics bounce with bunny ears. One offers you a sticky sweet from its mouth.'
      },
      'Succubus Queen' => {
        victory: 'The Queen lifts her lily. "Spring etiquette," she purrs. "Kneel. Then fill."',
        praise: '"Good nests stay open," she says, and takes her thanks from your mouth.'
      },
      'Incubus King' => {
        victory: 'Chocolate smear askew. "I hid them myself," the King lies brightly. "You\'re the prize."',
        praise: 'He tips chocolate you did not ask for against your lips and watches you swallow.'
      },
      'Verdant Dryad' => {
        victory: 'Lilies brush your cheek. "The garden keeps what blooms," she murmurs.',
        praise: 'She tucks a lily behind your ear. It smells like rain and permission.'
      },
      'Lich Lord' => {
        victory: 'The paper ear tips. "Spring is a binding," the Lich notes. "You accepted the hunt."',
        praise: 'He stamps a cold sigil that looks, briefly, like an egg with your dignity as the yolk.'
      },
      'Alpha Beast' => {
        victory: 'Syn\'s pupper shakes his bunny ears proudly. An egg rolls out of somewhere it shouldn\'t.',
        praise: 'He drops a mouthful of foil chocolate eggs on your chest and looks enormously proud.'
      },
      'Eros' => {
        victory: 'The goddess tastes of chocolate and grace. "I let them hunt one weekend," Eros says. "They behave better nested."',
        praise: 'A white tentacle offers you an egg. Refusing is not among the options.'
      }
    }.freeze

    HARE_BLESSING = {
      key: 'hare_glow', name: 'Hare Glow', floors: 4,
      effects: { 'submit_lp_bonus' => 2, 'appearance' => 4, 'satisfy_bonus' => 0.04 },
      summary: 'Warm, pollen-sweet, and faintly gold — the temple likes a nest that stays open'
    }.freeze

  MONSTER_ALIASES = {
    "Alraune" => "Lily Alraune",
    "Amber Slime" => "Chocolate Amber Slime",
    "Balloon Mistress" => "Parade-Egg Balloon Mistress",
    "Banshee" => "Risen Banshee",
    "Basilisk" => "Spring-Hare Basilisk",
    "Bath Mimic" => "Egg-Basket Bath Mimic",
    "Bear" => "Pastel Bear",
    "Bed Mimic" => "Nest Bed Mimic",
    "Big-Shoe Brute" => "Bunny-Clown Big-Shoe Brute",
    "Black Orchid" => "Lily Black Orchid",
    "Blood Rose" => "Bloom Blood Rose",
    "Bone Dancer" => "Empty-Tomb Bone Dancer",
    "Book Mimic" => "Bonnet Book Mimic",
    "Broodmother" => "Nest Broodmother",
    "Bubble Slime" => "Marshmallow Bubble Slime",
    "Cambion" => "Hare Cambion",
    "Carnal Fiend" => "Spring Carnal Fiend",
    "Carnival Clown" => "Pastel Carnival Clown",
    "Centaur" => "Bunny Centaur",
    "Chain Devil" => "Lily Chain Devil",
    "Chair Mimic" => "Basket Chair Mimic",
    "Champagne Slime" => "Pastel Champagne Slime",
    "Chandelier Mimic" => "Spring Chandelier Mimic",
    "Chest Mimic" => "Egg-Basket Chest Mimic",
    "Clock Mimic" => "Egg-Basket Clock Mimic",
    "Clothing Mimic" => "Nest Clothing Mimic",
    "Corpse Flower" => "Spring Corpse Flower",
    "Cotton-Candy Imp" => "Nest Cotton-Candy Imp",
    "Couch Mimic" => "Bonnet Couch Mimic",
    "Cream Slime" => "Honey Cream Slime",
    "Crypt Keeper" => "Lily Crypt Keeper",
    "Crystal Slime" => "Egg Crystal Slime",
    "Curtain Mimic" => "Basket Curtain Mimic",
    "Demoness" => "Pastel Demoness",
    "Djinn" => "Nest Djinn",
    "Door Mimic" => "Spring Door Mimic",
    "Dragon" => "Warren Dragon",
    "Dream Eater" => "Hare Dream Eater",
    "Dryad" => "Spring Dryad",
    "Dullahan" => "Spring Dullahan",
    "Ember Fiend" => "Spring Ember Fiend",
    "Fae Trickster" => "Lily Fae Trickster",
    "Foam Slime" => "Chocolate Foam Slime",
    "Gargoyle" => "Spring-Hare Gargoyle",
    "Gelatinous Mass" => "Marshmallow Gelatinous Mass",
    "Ghost" => "Pale Ghost",
    "Ghoul" => "Risen Ghoul",
    "Giant Bee" => "Pastel Giant Bee",
    "Giant Moth" => "Nest Giant Moth",
    "Giant Spider" => "Bunny Giant Spider",
    "Glow Slime" => "Pastel Glow Slime",
    "Goblin" => "Warren Goblin",
    "Gorgon Matron" => "Spring-Hare Gorgon Matron",
    "Green Slime" => "Honey Green Slime",
    "Harpy" => "Pastel Harpy",
    "Headless Knight" => "Empty-Tomb Headless Knight",
    "Hellhound" => "Pastel Hellhound",
    "Honey Slime" => "Egg Honey Slime",
    "Honker" => "Spring Honker",
    "HuCow" => "Pastel HuCow",
    "Ifrit" => "Nest Ifrit",
    "Imp" => "Hare Imp",
    "Incubus" => "Spring Incubus",
    "Item Pile Mimic" => "Egg-Basket Item Pile Mimic",
    "Jelly Cube" => "Chocolate Jelly Cube",
    "Jellyfish" => "Marshmallow Jellyfish",
    "Jester" => "Parade-Egg Jester",
    "Jiangshi" => "Lily Jiangshi",
    "Kitsune" => "Nest Kitsune",
    "Lamia" => "Bunny Lamia",
    "Lich" => "Spring Lich",
    "Living Ivy" => "Nest Living Ivy",
    "Loom Mimic" => "Nest Loom Mimic",
    "Man-Eating Flower" => "Egg Man-Eating Flower",
    "Mandrake" => "Lily Mandrake",
    "Marionette Mistress" => "Spring Marionette Mistress",
    "Mercury Slime" => "Pastel Mercury Slime",
    "Milk Slime" => "Honey Milk Slime",
    "Minotaur" => "Warren Minotaur",
    "Mirror Mimic" => "Bonnet Mirror Mimic",
    "Moonflower" => "Bloom Moonflower",
    "Mummy" => "Pale Mummy",
    "Mycelian" => "Spring Mycelian",
    "Naga" => "Spring-Hare Naga",
    "Night Hag" => "Lily Night Hag",
    "Nightshade" => "Nest Nightshade",
    "Ogre" => "Pastel Ogre",
    "Oil Slime" => "Egg Oil Slime",
    "Oni" => "Pastel Oni",
    "Orc" => "Nest Orc",
    "Pale Bride" => "Risen Pale Bride",
    "Piano Mimic" => "Basket Piano Mimic",
    "Pie Clown" => "Bunny-Clown Pie Clown",
    "Pit Fiend" => "Nest Pit Fiend",
    "Pitcher Plant" => "Egg Pitcher Plant",
    "Pollen Sprite" => "Lily Pollen Sprite",
    "Poltergeist" => "Empty-Tomb Poltergeist",
    "Pudding Slime" => "Chocolate Pudding Slime",
    "Purple Slime" => "Marshmallow Purple Slime",
    "Rakshasa" => "Hare Rakshasa",
    "Revenant" => "Lily Revenant",
    "Ringmaster" => "Pastel Ringmaster",
    "Rose Slime" => "Pastel Rose Slime",
    "Rubber Slime" => "Honey Rubber Slime",
    "Rug Mimic" => "Spring Rug Mimic",
    "Sap Dryad" => "Bloom Sap Dryad",
    "Satyr" => "Bunny Satyr",
    "Silkweaver" => "Warren Silkweaver",
    "Sin Eater" => "Spring Sin Eater",
    "Siren" => "Lily Siren",
    "Skeleton" => "Spring Skeleton",
    "Specter" => "Pale Specter",
    "Statue Mimic" => "Egg-Basket Statue Mimic",
    "Stone Golem" => "Nest Stone Golem",
    "Strangler Fig" => "Spring Strangler Fig",
    "Succubus" => "Hare Succubus",
    "Sundew" => "Nest Sundew",
    "Syrup Slime" => "Egg Syrup Slime",
    "Tar Slime" => "Chocolate Tar Slime",
    "Tentacle Vine" => "Egg Tentacle Vine",
    "Thorn Vine" => "Lily Thorn Vine",
    "Throne Mimic" => "Bonnet Throne Mimic",
    "Tomb Widow" => "Risen Tomb Widow",
    "Treant" => "Bloom Treant",
    "Troll" => "Spring-Hare Troll",
    "Vampire" => "Empty-Tomb Vampire",
    "Velvet Devil" => "Pastel Velvet Devil",
    "Venus Mantrap" => "Spring Venus Mantrap",
    "Wardrobe Mimic" => "Basket Wardrobe Mimic",
    "Wight" => "Lily Wight",
    "Wild Dog" => "Pastel Wild Dog",
    "Wildcat" => "Nest Wildcat",
    "Wolf" => "Spring Hare Wolf",
    "Wraith" => "Spring Wraith",
    "Zombie" => "Pale Zombie"
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

    # Good Friday through Easter Monday.
    def window?(now = Time.now)
      easter = easter_day(now.year)
      start = Time.new(easter.year, easter.month, easter.day) - (2 * 24 * 3600)
      finish = Time.new(easter.year, easter.month, easter.day) + (2 * 24 * 3600)
      now >= start && now < finish
    end

    def ends_at(now = Time.now)
      easter = easter_day(now.year)
      (Time.new(easter.year, easter.month, easter.day) + (2 * 24 * 3600)).to_i
    end

    def easter_day(year)
      e = Engine::Seasons.easter_sunday(year)
      Date.new(e.year, e.month, e.day)
    end
    module_function :easter_day

    def active?(now = Time.now)
      Engine::Seasons.active?(:easter, now) ||
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

    def eggs_count(player)
      player.tracker(EGGS_TRACKER)
    end

    def grant_eggs!(player, amount = 1)
      have = eggs_count(player)
      add = [[amount.to_i, 0].max, EGGS_MAX - have].min
      return 0 if add <= 0

      player.set_tracker!(EGGS_TRACKER, have + add)
      add
    end

    def eat_eggs!(player)
      have = eggs_count(player)
      return { ok: false, message: 'Your egg basket is empty.' } if have <= 0

      player.set_tracker!(EGGS_TRACKER, have - 1)
      player.bump_tracker!(EGGS_EATEN)
      case rand(3)
      when 0
        gained = player.heal_defiance!(14)
        { ok: true, message: "Chocolate shell, soft center — **+#{gained} Defiance** " \
                             "(#{eggs_count(player)} eggs left)." }
      when 1
        player.gain_lp!(9)
        { ok: true, message: "A spring sweet melts filthy — **+9 LP** (now `#{player.lp}`). " \
                             "#{eggs_count(player)} eggs left." }
      else
        before = player.lust
        player.update(lust: [player.lust - 10, 0].max)
        { ok: true, message: "Sugar settles the heat — **−#{before - player.lust} Lust** (now `#{player.lust}`). " \
                             "#{eggs_count(player)} eggs left." }
      end
    end

    def status_consumables(player)
      count = eggs_count(player)
      return [] unless count.positive?

      [{ id: 'easter_eggs', label: 'Chocolate Eggs', count: count, max: EGGS_MAX }]
    end

    def biome_weight_mult(biome_key)
      case biome_key.to_s
      when 'verdant_grove', 'honeyed_hive', 'pollen_gallery', 'milking_barns' then 1.65
      when 'ashen_court' then 0.9
      else 1.08
      end
    end

    def presence_suffix
      ' — spring hunt running; nest carefully.'
    end

    def costume_stock?
      active?
    end

    def hare_altar?
      active?
    end

    def syn_hare_unlocked?(player)
      player.tracker('syn_easter_crumb').positive? || active?
    end

    def mark_syn_crumb!(player)
      player.set_tracker!('syn_easter_crumb', 1)
    end

    def monster_alias(base_name)
      MONSTER_ALIASES[base_name.to_s]
    end

    def chest_bonus!(player)
      return [] unless active?

      lines = []
      added = grant_eggs!(player, rand(1..2))
      if added.positive?
        lines << "Foil **Chocolate Eggs** tumble out — stashed for later " \
                 "(**#{eggs_count(player)}/#{EGGS_MAX}** in your basket)."
      end
      if rand < 0.22
        Engine::Residents.sync_vex_outfits!
        piece = COSTUMES.reject { |s| (item = ::Equipment.first(name: s[:name])) && player.owns_equipment?(item.id) }.sample
        if piece && (item = ::Equipment.first(name: piece[:name]))
          grant = player.grant_equipment!(item, auto_equip: false)
          if grant[:ok]
            lines << "A Hare's Hunt piece: **#{item.name}** — _#{item.description}_ " \
                     '(keeps forever; equip from `e,equipment` / reclaim free at Vex).'
          end
        end
      end
      lines
    end

    Engine::Seasons.register!(KEY, self)
  end
end
