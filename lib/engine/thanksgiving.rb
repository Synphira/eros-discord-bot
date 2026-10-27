# frozen_string_literal: true

require_relative 'seasons'

module Engine
  # Feast week (Nov 23–30). Hospitality, leftovers, harvest dress — rewards keep forever.
  module Thanksgiving
    KEY = 'thanksgiving'
    LEFTOVERS_TRACKER = 'thanksgiving_leftovers'
    LEFTOVERS_EATEN = 'thanksgiving_leftovers_eaten'
    LEFTOVERS_MAX = 10
    SUBMIT_TRACKER = 'thanksgiving_submits'
    FEAST_OPTION = 'feast_excess'

    WEEKLY = {
      key: KEY,
      name: 'Feast of the Willing',
      description: 'The temple sets a table: plants and beasts throng as guests, lust runs warmer (×1.1), ' \
                   '+2 LP submitting to plants / +2 to beasts, events 20% more often. Every hallway pest wears ' \
                   'a feast-week name. Leftovers and Vex\'s harvest rack stay after the plates are cleared. ' \
                   'Syn buckles a turkey hat on her pupper. Ask her about the feast while it lasts.',
      effects: {
        'lust_mult' => 1.1,
        'plant_submit_lp' => 2,
        'beast_submit_lp' => 2,
        'satisfy_bonus' => 0.03
      },
      monsters: { plant: 2.0, beast: 1.6, slime: 1.25 },
      special: { 'event_rate' => 1.2, 'elite_chance' => 1.15 }
    }.freeze

    COSTUME_NAMES = [
      'Cornucopia Circlet',
      'Basting-String Bodice',
      'Gravy-Silk Stockings'
    ].freeze

    COSTUMES = [
      { name: 'Cornucopia Circlet', slot: 'head', type: 'armor', cost: 55, tier: :thanksgiving,
        description: 'A circlet of gilt horn and silk leaves. It says you came to be served — and to serve.',
        stat_modifiers: { 'appearance' => 9, 'satisfy_bonus' => 0.03, 'explore_lp' => 1 } },
      { name: 'Basting-String Bodice', slot: 'chest', type: 'armor', cost: 95, tier: :thanksgiving,
        description: 'Lace and kitchen twine that frames the chest like a roast worth staring at. Warm butter fantasy.',
        stat_modifiers: { 'appearance' => 13, 'lust_mult' => 1.07, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.04 } },
      { name: 'Gravy-Silk Stockings', slot: 'legs', type: 'armor', cost: 65, tier: :thanksgiving,
        description: 'Sheer stockings the colour of good gravy — sticky implication, elegant lie.',
        stat_modifiers: { 'appearance' => 10, 'agility' => 1, 'submit_lp_bonus' => 1 } }
    ].freeze

    DRESS = {
      'Mimic Broodmother' => 'A paper pilgrim collar glued upside-down by her brood. They set places on her lid. She ' \
                            'pretends the place cards are not adorable.',
      'Succubus Queen' => 'Harvest velvet, sugar-pearl necklace, and a seating chart that puts you next to her. ' \
                         'Hospitality with teeth.',
      'Incubus King' => 'One turkey feather, a bottle he did not open, and a toast he did not write. Still, he stands ' \
                       'to speak. Syn mouths the corrections.',
      'Verdant Dryad' => 'Wheat and late roses. She smells like a kitchen garden after rain — generous, inevitable, ' \
                        'already deciding who gets seconds.',
      'Lich Lord' => 'A linen napkin tucked into his collar like a bib. He has not removed it. Removing it would ' \
                    'acknowledge it was placed there.',
      'Alpha Beast' => 'Syn has buckled a ridiculous turkey hat onto her pupper for the feast. He is delighted. ' \
                      'The wattle flaps. Guests will stare. Good.',
      'Eros' => 'A smile like a second course — cream lace, warm light, and permission to be greedy without apology.',
      'Syn' => 'Flour on one cheek, carving knife within reach, and the calm of someone who set every place card. ' \
              'She feeds people until they thank her with their mouths full.',
      'Berry' => 'Oven-warm shop, pies cooling on the counter, gravy simmering like a threat. She is not "hostess ' \
                'cosplay." She is running service. Tip her.',
      'Covar' => 'He folded guest napkins into swans until his fingers cramped. One swan is slightly better than the ' \
                'rest. He will not say which.',
      'Madame Vex' => 'Damask that used to be living cloth, place settings marked with silk thread, and a look that ' \
                     'says your posture at table is part of the fitting.',
      'Pip' => 'Pilgrim hat sliding over one eye, gravy boat under surveillance, pants optional and currently declined. ' \
              'She rates the gravy for "viscosity and spite."',
      'Sister Nectar' => 'Apron dusted with flour she will not explain, a gravy boat beside the cups "for after," and ' \
                        'hospitality that milks you first. The shrine provides. Seconds are for the soft.',
      'Fang' => 'Maps annotated with seating charts. He claims the land re-dreams dinner. He has redrawn the carving ' \
               'station four times. It keeps coming back hungrier.'
    }.freeze

    CLERGY_LINES = {
      'Mimic Broodmother' => {
        victory: 'The Broodmother\'s lid clacks. "Sit," she croons. "My brood set places. You\'re the course."',
        praise: 'Little mimics bounce in paper collars. One offers you a sticky sweet from its mouth.'
      },
      'Succubus Queen' => {
        victory: 'The Queen lifts a sugar-pearl necklace. "Feast etiquette," she purrs. "Open wider."',
        praise: '"Guests who thank the host properly get seconds," she says, and takes her thanks from your mouth.'
      },
      'Incubus King' => {
        victory: 'Turkey feather askew. "I carved," the King lies brightly. "You\'re dessert."',
        praise: 'He tips wine you did not ask for against your lips and watches you swallow.'
      },
      'Verdant Dryad' => {
        victory: 'Harvest roses brush your cheek. "The garden feeds what kneels," she murmurs.',
        praise: 'She tucks a wheat stalk behind your ear. It smells like butter and sap.'
      },
      'Lich Lord' => {
        victory: 'The napkin bib tips. "Hospitality is a binding," the Lich notes. "You accepted a seat."',
        praise: 'He stamps a cold sigil that looks, briefly, like a pie chart of your remaining dignity.'
      },
      'Alpha Beast' => {
        victory: 'Syn\'s pupper shakes his turkey hat proudly. Pass the gravy. Pass your dignity.',
        praise: 'He drops a mouthful of warm leftovers on your chest and looks enormously proud.'
      },
      'Eros' => {
        victory: 'The goddess tastes of gravy and grace. "I let them feast one week," Eros says. "They behave better stuffed."',
        praise: 'A white tentacle offers you a plate. Refusing is not among the options.'
      }
    }.freeze


  MONSTER_ALIASES = {
    "Alraune" => "Cornucopia Alraune",
    "Amber Slime" => "Gravy Amber Slime",
    "Balloon Mistress" => "Parade-Float Balloon Mistress",
    "Banshee" => "Leftover Banshee",
    "Basilisk" => "Roasted Basilisk",
    "Bath Mimic" => "Place-Setting Bath Mimic",
    "Bear" => "Stuffed Bear",
    "Bed Mimic" => "Serving Bed Mimic",
    "Big-Shoe Brute" => "Pie-Eating Big-Shoe Brute",
    "Black Orchid" => "Cornucopia Black Orchid",
    "Blood Rose" => "Wheat-Crowned Blood Rose",
    "Bone Dancer" => "Carved Bone Dancer",
    "Book Mimic" => "Sideboard Book Mimic",
    "Broodmother" => "Harvest Broodmother",
    "Bubble Slime" => "Cranberry Bubble Slime",
    "Cambion" => "Host\'s Cambion",
    "Carnal Fiend" => "Guest-List Carnal Fiend",
    "Carnival Clown" => "Guest-Clown Carnival Clown",
    "Centaur" => "Butter-Basted Centaur",
    "Chain Devil" => "Sugar-Glazed Chain Devil",
    "Chair Mimic" => "Linen Chair Mimic",
    "Champagne Slime" => "Butterscotch Champagne Slime",
    "Chandelier Mimic" => "Napkin Chandelier Mimic",
    "Chest Mimic" => "Serving-Dish Chest Mimic",
    "Clock Mimic" => "Place-Setting Clock Mimic",
    "Clothing Mimic" => "Serving Clothing Mimic",
    "Corpse Flower" => "Orchard Corpse Flower",
    "Cotton-Candy Imp" => "Feast-Fool Cotton-Candy Imp",
    "Couch Mimic" => "Sideboard Couch Mimic",
    "Cream Slime" => "Stuffing Cream Slime",
    "Crypt Keeper" => "Platter Crypt Keeper",
    "Crystal Slime" => "Custard Crystal Slime",
    "Curtain Mimic" => "Linen Curtain Mimic",
    "Demoness" => "Second-Helping Demoness",
    "Djinn" => "Host\'s Djinn",
    "Door Mimic" => "Napkin Door Mimic",
    "Dragon" => "Feast Dragon",
    "Dream Eater" => "Guest-List Dream Eater",
    "Dryad" => "Orchard Dryad",
    "Dullahan" => "Table-Grace Dullahan",
    "Ember Fiend" => "Sugar-Glazed Ember Fiend",
    "Fae Trickster" => "Second-Helping Fae Trickster",
    "Foam Slime" => "Gravy Foam Slime",
    "Gargoyle" => "Roasted Gargoyle",
    "Gelatinous Mass" => "Cranberry Gelatinous Mass",
    "Ghost" => "Cold-Plate Ghost",
    "Ghoul" => "Leftover Ghoul",
    "Giant Bee" => "Stuffed Giant Bee",
    "Giant Moth" => "Harvest Giant Moth",
    "Giant Spider" => "Butter-Basted Giant Spider",
    "Glow Slime" => "Butterscotch Glow Slime",
    "Goblin" => "Feast Goblin",
    "Gorgon Matron" => "Roasted Gorgon Matron",
    "Green Slime" => "Stuffing Green Slime",
    "Harpy" => "Stuffed Harpy",
    "Headless Knight" => "Carved Headless Knight",
    "Hellhound" => "Host\'s Hellhound",
    "Honey Slime" => "Custard Honey Slime",
    "Honker" => "Parade-Float Honker",
    "HuCow" => "Dairy Feast HuCow",
    "Ifrit" => "Guest-List Ifrit",
    "Imp" => "Sugar-Glazed Imp",
    "Incubus" => "Toastmaster Incubus",
    "Item Pile Mimic" => "Place-Setting Item Pile Mimic",
    "Jelly Cube" => "Gravy Jelly Cube",
    "Jellyfish" => "Cranberry Jellyfish",
    "Jester" => "Pie-Eating Jester",
    "Jiangshi" => "Platter Jiangshi",
    "Kitsune" => "Harvest Kitsune",
    "Lamia" => "Butter-Basted Lamia",
    "Lich" => "Table-Grace Lich",
    "Living Ivy" => "Pie-Spice Living Ivy",
    "Loom Mimic" => "Serving Loom Mimic",
    "Man-Eating Flower" => "Harvest Man-Eating Flower",
    "Mandrake" => "Cornucopia Mandrake",
    "Marionette Mistress" => "Second-Helping Marionette Mistress",
    "Mercury Slime" => "Butterscotch Mercury Slime",
    "Milk Slime" => "Stuffing Milk Slime",
    "Minotaur" => "Feast Minotaur",
    "Mirror Mimic" => "Sideboard Mirror Mimic",
    "Moonflower" => "Wheat-Crowned Moonflower",
    "Mummy" => "Cold-Plate Mummy",
    "Mycelian" => "Orchard Mycelian",
    "Naga" => "Roasted Naga",
    "Night Hag" => "Host\'s Night Hag",
    "Nightshade" => "Pie-Spice Nightshade",
    "Ogre" => "Stuffed Ogre",
    "Oil Slime" => "Custard Oil Slime",
    "Oni" => "Guest-List Oni",
    "Orc" => "Harvest Orc",
    "Pale Bride" => "Leftover Pale Bride",
    "Piano Mimic" => "Linen Piano Mimic",
    "Pie Clown" => "Guest-Clown Pie Clown",
    "Pit Fiend" => "Sugar-Glazed Pit Fiend",
    "Pitcher Plant" => "Harvest Pitcher Plant",
    "Pollen Sprite" => "Cornucopia Pollen Sprite",
    "Poltergeist" => "Carved Poltergeist",
    "Pudding Slime" => "Gravy Pudding Slime",
    "Purple Slime" => "Cranberry Purple Slime",
    "Rakshasa" => "Second-Helping Rakshasa",
    "Revenant" => "Platter Revenant",
    "Ringmaster" => "Feast-Fool Ringmaster",
    "Rose Slime" => "Butterscotch Rose Slime",
    "Rubber Slime" => "Stuffing Rubber Slime",
    "Rug Mimic" => "Napkin Rug Mimic",
    "Sap Dryad" => "Wheat-Crowned Sap Dryad",
    "Satyr" => "Butter-Basted Satyr",
    "Silkweaver" => "Feast Silkweaver",
    "Sin Eater" => "Host\'s Sin Eater",
    "Siren" => "Guest-List Siren",
    "Skeleton" => "Table-Grace Skeleton",
    "Specter" => "Cold-Plate Specter",
    "Statue Mimic" => "Place-Setting Statue Mimic",
    "Stone Golem" => "Serving Stone Golem",
    "Strangler Fig" => "Orchard Strangler Fig",
    "Succubus" => "Hostess Succubus",
    "Sundew" => "Pie-Spice Sundew",
    "Syrup Slime" => "Custard Syrup Slime",
    "Tar Slime" => "Gravy Tar Slime",
    "Tentacle Vine" => "Harvest Tentacle Vine",
    "Thorn Vine" => "Cornucopia Thorn Vine",
    "Throne Mimic" => "Sideboard Throne Mimic",
    "Tomb Widow" => "Leftover Tomb Widow",
    "Treant" => "Wheat-Crowned Treant",
    "Troll" => "Roasted Troll",
    "Vampire" => "Carved Vampire",
    "Velvet Devil" => "Sugar-Glazed Velvet Devil",
    "Venus Mantrap" => "Orchard Venus Mantrap",
    "Wardrobe Mimic" => "Linen Wardrobe Mimic",
    "Wight" => "Platter Wight",
    "Wild Dog" => "Stuffed Wild Dog",
    "Wildcat" => "Harvest Wildcat",
    "Wolf" => "Butter-Basted Wolf",
    "Wraith" => "Table-Grace Wraith",
    "Zombie" => "Cold-Plate Zombie"
  }.freeze

    FEAST_BLESSING = {
      key: 'feast_glow', name: 'Feast Glow', floors: 4,
      effects: { 'submit_lp_bonus' => 2, 'appearance' => 4, 'satisfy_bonus' => 0.04 },
      summary: 'Warm, butter-slick, and faintly golden — the temple likes a guest who stays for seconds'
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
      start = Time.new(now.year, 11, 23)
      finish = Time.new(now.year, 12, 1) # through Nov 30 inclusive
      now >= start && now < finish
    end

    def ends_at(now = Time.now)
      Time.new(now.year, 12, 1).to_i
    end

    def active?(now = Time.now)
      Engine::Seasons.active?(:thanksgiving, now) ||
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

    def leftovers_count(player)
      player.tracker(LEFTOVERS_TRACKER)
    end

    def grant_leftovers!(player, amount = 1)
      have = leftovers_count(player)
      add = [[amount.to_i, 0].max, LEFTOVERS_MAX - have].min
      return 0 if add <= 0

      player.set_tracker!(LEFTOVERS_TRACKER, have + add)
      add
    end

    def eat_leftovers!(player)
      have = leftovers_count(player)
      return { ok: false, message: 'Your leftovers tin is empty.' } if have <= 0

      player.set_tracker!(LEFTOVERS_TRACKER, have - 1)
      player.bump_tracker!(LEFTOVERS_EATEN)
      case rand(3)
      when 0
        gained = player.heal_defiance!(14)
        { ok: true, message: "Warm gravy and kindness — **+#{gained} Defiance** " \
                             "(#{leftovers_count(player)} leftovers left)." }
      when 1
        player.gain_lp!(9)
        { ok: true, message: "A plate of something sinful — **+9 LP** (now `#{player.lp}`). " \
                             "#{leftovers_count(player)} leftovers left." }
      else
        before = player.lust
        player.update(lust: [player.lust - 10, 0].max)
        { ok: true, message: "Comfort food settles the heat — **−#{before - player.lust} Lust** (now `#{player.lust}`). " \
                             "#{leftovers_count(player)} leftovers left." }
      end
    end

    def status_consumables(player)
      count = leftovers_count(player)
      return [] unless count.positive?

      [{ id: 'thanksgiving_leftovers', label: 'Leftovers', count: count, max: LEFTOVERS_MAX }]
    end

    def biome_weight_mult(biome_key)
      case biome_key.to_s
      when 'verdant_grove', 'honeyed_hive', 'milking_barns', 'pollen_gallery' then 1.65
      when 'ashen_court', 'flooded_grotto' then 0.9
      else 1.05
      end
    end

    def presence_suffix
      ' — the temple is feasting; bring an appetite.'
    end

    def costume_stock?
      active?
    end

    def feast_altar?
      active?
    end

    def syn_feast_unlocked?(player)
      player.tracker('syn_thanksgiving_crumb').positive? || active?
    end

    def mark_syn_crumb!(player)
      player.set_tracker!('syn_thanksgiving_crumb', 1)
    end

    def monster_alias(base_name)
      MONSTER_ALIASES[base_name.to_s]
    end

    def chest_bonus!(player)
      return [] unless active?

      lines = []
      added = grant_leftovers!(player, rand(1..2))
      if added.positive?
        lines << "Wrapped **Leftovers** tumble out — stashed for later " \
                 "(**#{leftovers_count(player)}/#{LEFTOVERS_MAX}** in your tin)."
      end
      if rand < 0.22
        Engine::Residents.sync_vex_outfits!
        piece = COSTUMES.reject { |s| (item = ::Equipment.first(name: s[:name])) && player.owns_equipment?(item.id) }.sample
        if piece && (item = ::Equipment.first(name: piece[:name]))
          grant = player.grant_equipment!(item, auto_equip: false)
          if grant[:ok]
            lines << "A feast piece: **#{item.name}** — _#{item.description}_ " \
                     '(keeps forever; equip from `e,equipment` / reclaim free at Vex).'
          end
        end
      end
      lines
    end

    Engine::Seasons.register!(KEY, self)
  end
end
