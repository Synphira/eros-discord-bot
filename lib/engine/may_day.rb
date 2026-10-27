# frozen_string_literal: true

require_relative 'seasons'

module Engine
  # May 1–2. Maypole, ribbons, Beltane bloom — rewards keep forever.
  module MayDay
    KEY = 'may_day'
    WINE_TRACKER = 'may_day_wine'
    WINE_EATEN = 'may_day_wine_eaten'
    WINE_MAX = 12
    SUBMIT_TRACKER = 'may_day_submits'
    BIND_OPTION = 'maypole_bind'

    WEEKLY = {
      key: KEY,
      name: 'Maypole Raising',
      description: 'The temple raises a pole: plants and beasts throng, lust runs warmer (×1.12), ' \
                   '+2 LP submitting to plants / +2 to beasts, events 20% more often. Every hallway pest wears a ' \
                   'May name. May wine and Vex\'s ribbon rack stay after the dance. Syn buckles a flower crown on ' \
                   'her pupper. Ask her about Maypole while it lasts.',
      effects: {
        'lust_mult' => 1.12,
        'plant_submit_lp' => 2,
        'beast_submit_lp' => 2,
        'satisfy_bonus' => 0.04
      },
      monsters: { plant: 2.0, beast: 1.6, slime: 1.2 },
      special: { 'event_rate' => 1.2, 'elite_chance' => 1.15 }
    }.freeze

    COSTUME_NAMES = [
      'Flower Crown',
      'Maypole Ribbon Bodice',
      'Petal-Silk Stockings'
    ].freeze

    COSTUMES = [
      { name: 'Flower Crown', slot: 'head', type: 'armor', cost: 55, tier: :may_day,
        description: 'Fresh blooms and a ribbon bow. You look like you came to be crowned — and claimed.',
        stat_modifiers: { 'appearance' => 9, 'satisfy_bonus' => 0.03, 'submit_lp_bonus' => 1 } },
      { name: 'Maypole Ribbon Bodice', slot: 'chest', type: 'armor', cost: 95, tier: :may_day,
        description: 'Streaming ribbons that frame the chest like a pole worth dancing around. Soft bondage fantasy.',
        stat_modifiers: { 'appearance' => 13, 'lust_mult' => 1.08, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.05 } },
      { name: 'Petal-Silk Stockings', slot: 'legs', type: 'armor', cost: 65, tier: :may_day,
        description: 'Sheer stockings the colour of crushed petals. Standing still becomes a dance.',
        stat_modifiers: { 'appearance' => 10, 'agility' => 1, 'submit_lp_bonus' => 1 } }
    ].freeze

    DRESS = {
      'Mimic Broodmother' => 'Maypole ribbons wound crooked by her brood; one flower perched like a crown on a tooth. ' \
                            'She calls it tradition. The brood calls it practice.',
      'Succubus Queen' => 'May Queen in blossom velvet — ribbons already choosing wrists. The dance starts when she ' \
                         'says so.',
      'Incubus King' => 'A flower behind one horn and a speech about raising the pole. Syn\'s hands still smell like ' \
                       'wood and rope. Nobody interrupts him. Syn smiles.',
      'Verdant Dryad' => 'Beltane blooms. She smells like a meadow that danced until dawn and kept the sweat as perfume.',
      'Lich Lord' => 'A paper flower in blue fire. It will not ash. He is considering fire as a personality flaw.',
      'Alpha Beast' => 'Syn has buckled a ridiculous flower crown onto her pupper for Maypole. He is delighted. ' \
                      'Petals stick when he shakes. He thinks it\'s a parade.',
      'Eros' => 'A smile like a wound ribbon — new-leaf lace, and permission to dance on your knees until the ribbons ' \
               'decide you are done.',
      'Syn' => 'Petal-ink, rope burns she is proud of, and the quiet ownership of the person who raised the pole. ' \
              'Pretty bondage was always her idea of spring.',
      'Berry' => 'May wine samples on the counter, flower crowns for sale (and for wearing), and a look that says ' \
                'she will crown you whether you ask or not.',
      'Covar' => 'A single ribbon looped around his fingers. He practices knots when he thinks nobody is watching. ' \
                'Somebody is always watching the cursed shop.',
      'Madame Vex' => 'Streaming ribbon from shoulder to floor, crowns that lace into the hair, and fittings that ' \
                     'feel like being wound on purpose.',
      'Pip' => 'Flower crown sliding, measuring tape around the maypole, pants still "in the lab." She rates ribbon ' \
              'tension like a sport.',
      'Sister Nectar' => 'Flower crown hooked on the pump rack, May wine for aftercare she will not call aftercare, and ' \
                        'ribbons that somehow end up around wrists mid-session. Liturgy with a dance count.',
      'Fang' => 'Maps wound with a scrap of maypole ribbon. He claims it marks ley lines. It marks where the pole ' \
               'will be. He already sold three seats at the circle.'
    }.freeze

    CLERGY_LINES = {
      'Mimic Broodmother' => {
        victory: 'The Broodmother\'s lid clacks under ribbon. "Dance," she croons. "My brood wound you first."',
        praise: 'Little mimics bounce with flowers. One offers you a sticky sweet from its mouth.'
      },
      'Succubus Queen' => {
        victory: 'The Queen lifts a blossom. "May etiquette," she purrs. "Wind. Then kneel."',
        praise: '"Good poles stay circled," she says, and takes her thanks from your mouth.'
      },
      'Incubus King' => {
        victory: 'Flower askew. "I raised it," the King lies brightly. "You\'re the dance."',
        praise: 'He tips May wine you did not ask for against your lips and watches you swallow.'
      },
      'Verdant Dryad' => {
        victory: 'Blooms brush your cheek. "The meadow keeps what dances," she murmurs.',
        praise: 'She tucks a petal behind your ear. It smells like wine and sap.'
      },
      'Lich Lord' => {
        victory: 'The paper flower tips. "Revelry is a binding," the Lich notes. "You accepted the ribbon."',
        praise: 'He stamps a cold sigil that looks, briefly, like a maypole of your remaining dignity.'
      },
      'Alpha Beast' => {
        victory: 'Syn\'s pupper shakes his flower crown proudly. Ribbons lean toward him of their own accord.',
        praise: 'He drops a mouthful of foil May-wine sweets on your chest and looks enormously proud.'
      },
      'Eros' => {
        victory: 'The goddess tastes of wine and grace. "I let them pole one weekend," Eros says. "They behave better wound."',
        praise: 'A white tentacle offers you a ribbon. Refusing is not among the options.'
      }
    }.freeze

    MAY_BLESSING = {
      key: 'maypole_glow', name: 'Maypole Glow', floors: 4,
      effects: { 'submit_lp_bonus' => 2, 'appearance' => 4, 'satisfy_bonus' => 0.04 },
      summary: 'Warm, petal-sweet, and faintly gold — the temple likes a dancer who stays wound'
    }.freeze

  MONSTER_ALIASES = {
    "Alraune" => "Maypole Alraune",
    "Amber Slime" => "May-Wine Amber Slime",
    "Balloon Mistress" => "Maypole Balloon Mistress",
    "Banshee" => "Wicker Banshee",
    "Basilisk" => "Maypole Basilisk",
    "Bath Mimic" => "Ribbon-Pole Bath Mimic",
    "Bear" => "Ribbon Bear",
    "Bed Mimic" => "May-Basket Bed Mimic",
    "Big-Shoe Brute" => "Parade Big-Shoe Brute",
    "Black Orchid" => "Maypole Black Orchid",
    "Blood Rose" => "Beltane Blood Rose",
    "Bone Dancer" => "Pale Bone Dancer",
    "Book Mimic" => "Flower Book Mimic",
    "Broodmother" => "Beltane Broodmother",
    "Bubble Slime" => "Petal Bubble Slime",
    "Cambion" => "May-Queen Cambion",
    "Carnal Fiend" => "May-King Carnal Fiend",
    "Carnival Clown" => "Flower Carnival Clown",
    "Centaur" => "Flower Centaur",
    "Chain Devil" => "Ribbon Chain Devil",
    "Chair Mimic" => "Garland Chair Mimic",
    "Champagne Slime" => "Honey Champagne Slime",
    "Chandelier Mimic" => "Beltane Chandelier Mimic",
    "Chest Mimic" => "Ribbon-Pole Chest Mimic",
    "Clock Mimic" => "Ribbon-Pole Clock Mimic",
    "Clothing Mimic" => "May-Basket Clothing Mimic",
    "Corpse Flower" => "Ribbon Corpse Flower",
    "Cotton-Candy Imp" => "Fool Cotton-Candy Imp",
    "Couch Mimic" => "Flower Couch Mimic",
    "Cream Slime" => "Flower Cream Slime",
    "Crypt Keeper" => "Beltane Crypt Keeper",
    "Crystal Slime" => "Garland Crystal Slime",
    "Curtain Mimic" => "Garland Curtain Mimic",
    "Demoness" => "Beltane Demoness",
    "Djinn" => "Garland Djinn",
    "Door Mimic" => "Beltane Door Mimic",
    "Dragon" => "Garland Dragon",
    "Dream Eater" => "May-Queen Dream Eater",
    "Dryad" => "Beltane Dryad",
    "Dullahan" => "Flower Dullahan",
    "Ember Fiend" => "May-King Ember Fiend",
    "Fae Trickster" => "Ribbon Fae Trickster",
    "Foam Slime" => "May-Wine Foam Slime",
    "Gargoyle" => "Maypole Gargoyle",
    "Gelatinous Mass" => "Petal Gelatinous Mass",
    "Ghost" => "Garland Ghost",
    "Ghoul" => "Wicker Ghoul",
    "Giant Bee" => "Ribbon Giant Bee",
    "Giant Moth" => "Beltane Giant Moth",
    "Giant Spider" => "Flower Giant Spider",
    "Glow Slime" => "Honey Glow Slime",
    "Goblin" => "Garland Goblin",
    "Gorgon Matron" => "Maypole Gorgon Matron",
    "Green Slime" => "Flower Green Slime",
    "Harpy" => "Ribbon Harpy",
    "Headless Knight" => "Pale Headless Knight",
    "Hellhound" => "Beltane Hellhound",
    "Honey Slime" => "Garland Honey Slime",
    "Honker" => "Garland Honker",
    "HuCow" => "May Queen HuCow",
    "Ifrit" => "Garland Ifrit",
    "Imp" => "May-Queen Imp",
    "Incubus" => "May King Incubus",
    "Item Pile Mimic" => "Ribbon-Pole Item Pile Mimic",
    "Jelly Cube" => "May-Wine Jelly Cube",
    "Jellyfish" => "Petal Jellyfish",
    "Jester" => "Maypole Jester",
    "Jiangshi" => "Beltane Jiangshi",
    "Kitsune" => "Beltane Kitsune",
    "Lamia" => "Flower Lamia",
    "Lich" => "Flower Lich",
    "Living Ivy" => "Bloom Living Ivy",
    "Loom Mimic" => "May-Basket Loom Mimic",
    "Man-Eating Flower" => "Garland Man-Eating Flower",
    "Mandrake" => "Maypole Mandrake",
    "Marionette Mistress" => "May-King Marionette Mistress",
    "Mercury Slime" => "Honey Mercury Slime",
    "Milk Slime" => "Flower Milk Slime",
    "Minotaur" => "Garland Minotaur",
    "Mirror Mimic" => "Flower Mirror Mimic",
    "Moonflower" => "Beltane Moonflower",
    "Mummy" => "Garland Mummy",
    "Mycelian" => "Ribbon Mycelian",
    "Naga" => "Maypole Naga",
    "Night Hag" => "Ribbon Night Hag",
    "Nightshade" => "Bloom Nightshade",
    "Ogre" => "Ribbon Ogre",
    "Oil Slime" => "Garland Oil Slime",
    "Oni" => "Beltane Oni",
    "Orc" => "Beltane Orc",
    "Pale Bride" => "Wicker Pale Bride",
    "Piano Mimic" => "Garland Piano Mimic",
    "Pie Clown" => "Parade Pie Clown",
    "Pit Fiend" => "Garland Pit Fiend",
    "Pitcher Plant" => "Garland Pitcher Plant",
    "Pollen Sprite" => "Maypole Pollen Sprite",
    "Poltergeist" => "Pale Poltergeist",
    "Pudding Slime" => "May-Wine Pudding Slime",
    "Purple Slime" => "Petal Purple Slime",
    "Rakshasa" => "May-Queen Rakshasa",
    "Revenant" => "Beltane Revenant",
    "Ringmaster" => "Flower Ringmaster",
    "Rose Slime" => "Honey Rose Slime",
    "Rubber Slime" => "Flower Rubber Slime",
    "Rug Mimic" => "Beltane Rug Mimic",
    "Sap Dryad" => "Beltane Sap Dryad",
    "Satyr" => "Flower Satyr",
    "Silkweaver" => "Garland Silkweaver",
    "Sin Eater" => "May-King Sin Eater",
    "Siren" => "Ribbon Siren",
    "Skeleton" => "Flower Skeleton",
    "Specter" => "Garland Specter",
    "Statue Mimic" => "Ribbon-Pole Statue Mimic",
    "Stone Golem" => "May-Basket Stone Golem",
    "Strangler Fig" => "Ribbon Strangler Fig",
    "Succubus" => "May Queen Succubus",
    "Sundew" => "Bloom Sundew",
    "Syrup Slime" => "Garland Syrup Slime",
    "Tar Slime" => "May-Wine Tar Slime",
    "Tentacle Vine" => "Garland Tentacle Vine",
    "Thorn Vine" => "Maypole Thorn Vine",
    "Throne Mimic" => "Flower Throne Mimic",
    "Tomb Widow" => "Wicker Tomb Widow",
    "Treant" => "Beltane Treant",
    "Troll" => "Maypole Troll",
    "Vampire" => "Pale Vampire",
    "Velvet Devil" => "Beltane Velvet Devil",
    "Venus Mantrap" => "Ribbon Venus Mantrap",
    "Wardrobe Mimic" => "Garland Wardrobe Mimic",
    "Wight" => "Beltane Wight",
    "Wild Dog" => "Ribbon Wild Dog",
    "Wildcat" => "Beltane Wildcat",
    "Wolf" => "Maypole Wolf",
    "Wraith" => "Flower Wraith",
    "Zombie" => "Garland Zombie"
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

    # May 1 through May 2 inclusive.
    def window?(now = Time.now)
      start = Time.new(now.year, 5, 1)
      finish = Time.new(now.year, 5, 3)
      now >= start && now < finish
    end

    def ends_at(now = Time.now)
      Time.new(now.year, 5, 3).to_i
    end

    def active?(now = Time.now)
      Engine::Seasons.active?(:may_day, now) ||
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

    def wine_count(player)
      player.tracker(WINE_TRACKER)
    end

    def grant_wine!(player, amount = 1)
      have = wine_count(player)
      add = [[amount.to_i, 0].max, WINE_MAX - have].min
      return 0 if add <= 0

      player.set_tracker!(WINE_TRACKER, have + add)
      add
    end

    def eat_wine!(player)
      have = wine_count(player)
      return { ok: false, message: 'Your May-wine tin is empty.' } if have <= 0

      player.set_tracker!(WINE_TRACKER, have - 1)
      player.bump_tracker!(WINE_EATEN)
      case rand(3)
      when 0
        gained = player.heal_defiance!(14)
        { ok: true, message: "Petal-sweet wine — **+#{gained} Defiance** " \
                             "(#{wine_count(player)} left)." }
      when 1
        player.gain_lp!(9)
        { ok: true, message: "A May sip goes filthy — **+9 LP** (now `#{player.lp}`). " \
                             "#{wine_count(player)} left." }
      else
        before = player.lust
        player.update(lust: [player.lust - 10, 0].max)
        { ok: true, message: "Wine cools the heat — **−#{before - player.lust} Lust** (now `#{player.lust}`). " \
                             "#{wine_count(player)} left." }
      end
    end

    def status_consumables(player)
      count = wine_count(player)
      return [] unless count.positive?

      [{ id: 'may_day_wine', label: 'May Wine', count: count, max: WINE_MAX }]
    end

    def biome_weight_mult(biome_key)
      case biome_key.to_s
      when 'verdant_grove', 'pollen_gallery', 'honeyed_hive', 'milking_barns' then 1.7
      when 'ashen_court' then 0.9
      else 1.08
      end
    end

    def presence_suffix
      ' — maypole raised; wind carefully.'
    end

    def costume_stock?
      active?
    end

    def may_altar?
      active?
    end

    def syn_maypole_unlocked?(player)
      player.tracker('syn_may_day_crumb').positive? || active?
    end

    def mark_syn_crumb!(player)
      player.set_tracker!('syn_may_day_crumb', 1)
    end

    def monster_alias(base_name)
      MONSTER_ALIASES[base_name.to_s]
    end

    def chest_bonus!(player)
      return [] unless active?

      lines = []
      added = grant_wine!(player, rand(1..2))
      if added.positive?
        lines << "Foil **May Wine** tumbles out — stashed for later " \
                 "(**#{wine_count(player)}/#{WINE_MAX}** in your tin)."
      end
      if rand < 0.22
        Engine::Residents.sync_vex_outfits!
        piece = COSTUMES.reject { |s| (item = ::Equipment.first(name: s[:name])) && player.owns_equipment?(item.id) }.sample
        if piece && (item = ::Equipment.first(name: piece[:name]))
          grant = player.grant_equipment!(item, auto_equip: false)
          if grant[:ok]
            lines << "A Maypole piece: **#{item.name}** — _#{item.description}_ " \
                     '(keeps forever; equip from `e,equipment` / reclaim free at Vex).'
          end
        end
      end
      lines
    end

    Engine::Seasons.register!(KEY, self)
  end
end
