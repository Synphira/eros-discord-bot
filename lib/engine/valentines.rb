# frozen_string_literal: true

require_relative 'seasons'

module Engine
  # Heart week (Feb 12–15). Roses, chocolate, arrows — rewards keep forever.
  module Valentines
    KEY = 'valentines'
    HEARTS_TRACKER = 'valentines_hearts'
    HEARTS_EATEN = 'valentines_hearts_eaten'
    HEARTS_MAX = 12
    SUBMIT_TRACKER = 'valentines_submits'
    HEARTBREAK_OPTION = 'heartbreak'

    WEEKLY = {
      key: KEY,
      name: 'Heartstring Claim',
      description: 'The temple strings hearts like bait: demons throng, lust runs hotter (×1.15), ' \
                   '+3 LP submitting to demons, satisfy +0.05, events 25% more often. Every hallway pest ' \
                   'wears a Valentine name. Chocolate hearts and Vex\'s rose rack stay after the arrows stop. Syn ' \
                   'buckles a heart collar on her pupper. Ask her about Heartstring while it lasts.',
      effects: {
        'lust_mult' => 1.15,
        'demon_submit_lp' => 3,
        'satisfy_bonus' => 0.05
      },
      monsters: { demon: 2.0, beast: 1.35, slime: 1.25, mimic: 1.3 },
      special: { 'event_rate' => 1.25, 'elite_chance' => 1.2 }
    }.freeze

    COSTUME_NAMES = [
      'Rose Circlet',
      'Heart-Cut Bodice',
      'Arrow-Silk Stockings'
    ].freeze

    COSTUMES = [
      { name: 'Rose Circlet', slot: 'head', type: 'armor', cost: 55, tier: :valentines,
        description: 'Fresh roses and a silk bow. You look like you came to be aimed at.',
        stat_modifiers: { 'appearance' => 9, 'satisfy_bonus' => 0.03, 'submit_lp_bonus' => 1 } },
      { name: 'Heart-Cut Bodice', slot: 'chest', type: 'armor', cost: 95, tier: :valentines,
        description: 'Crimson silk cut in a heart over the chest — a target painted as fashion.',
        stat_modifiers: { 'appearance' => 13, 'lust_mult' => 1.1, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.05 } },
      { name: 'Arrow-Silk Stockings', slot: 'legs', type: 'armor', cost: 65, tier: :valentines,
        description: 'Sheer rose silk with tiny embroidered arrows climbing the thigh. Standing still becomes a dare.',
        stat_modifiers: { 'appearance' => 10, 'agility' => 1, 'submit_lp_bonus' => 1 } }
    ].freeze

    DRESS = {
      'Mimic Broodmother' => 'Paper hearts licked crooked onto her lid; one broodling in a bow like a stamp. She calls ' \
                            'it strategy. It is affection with teeth.',
      'Succubus Queen' => 'Rose velvet, heart-lock necklace, and a queue for opening people slowly. You are on it. ' \
                         'Near the top.',
      'Incubus King' => 'One paper cupid wing, a stack of unsigned cards, and confidence. Syn quietly corrects the ' \
                       'spelling on the ones he "wrote."',
      'Verdant Dryad' => 'Roses and thorns. Romance as hunting strategy — soft petals, patient waiting, sudden claim.',
      'Lich Lord' => 'A paper heart pinned to his collar. He has filed three formal objections. The heart remains. ' \
                    'So does the blush of blue fire.',
      'Alpha Beast' => 'Syn has buckled a ridiculous heart-shaped collar onto her pupper for Heartstring. He is delighted. ' \
                      'The charm clinks like a claim already filed.',
      'Eros' => 'A smile like a drawn bow — cut-red lace, and the patience of someone who already chose her target.',
      'Syn' => 'Rose-petal ink, a quiver of marking needles, and the look of someone who aims compliments like arrows. ' \
              'Cupids work for her. Not the other way around.',
      'Berry' => 'Chocolate stacked in careful pyramids, heart-boxes priced like ransom, and a soft smile that says ' \
                'she already knows who you are buying for.',
      'Covar' => 'A folded letter he will not open in public. The seal is unmarked. His ears are pink. The shop is ' \
                'silent with effort.',
      'Madame Vex' => 'Rose silk cut to the heart of the matter — literally. She measures cleavage like it is a love ' \
                     'language. It is.',
      'Pip' => 'Heart headband askew, chocolate box under "containment," and a theory that love is just a trap with ' \
              'better branding. She is testing this.',
      'Sister Nectar' => 'Rose oil on the cups, a heart stamped on the intake ledger, and shrine-professional warmth that ' \
                        'feels like being claimed. Milking is holy. Affection is the pressure setting.',
      'Fang' => 'Dream-maps edged in pink ink. He has redrawn a door that only opens for someone already soft. He ' \
               'will sell you the sketch. He will not meet your eyes.'
    }.freeze

    CLERGY_LINES = {
      'Mimic Broodmother' => {
        victory: 'The Broodmother\'s lid clacks under paper hearts. "Be mine," she croons. "My brood already licked the stamp."',
        praise: 'Little mimics bounce with bows. One offers you a sticky sweet from its mouth.'
      },
      'Succubus Queen' => {
        victory: 'The Queen lifts her heart-lock. "Valentine etiquette," she purrs. "Open. Then kneel."',
        praise: '"Good gifts stay claimed," she says, and takes her thanks from your mouth.'
      },
      'Incubus King' => {
        victory: 'Paper wing askew. "I wrote it myself," the King lies brightly. "You\'re under the arrow."',
        praise: 'He tips chocolate you did not ask for against your lips and watches you swallow.'
      },
      'Verdant Dryad' => {
        victory: 'Roses brush your cheek. "The garden keeps what it aims at," she murmurs.',
        praise: 'She tucks a thornless rose behind your ear. It smells like sugar and sap.'
      },
      'Lich Lord' => {
        victory: 'The paper heart tips. "Affection is a binding," the Lich notes. "You accepted the mark."',
        praise: 'He stamps a cold sigil that looks, briefly, like a heart drawn around your remaining dignity.'
      },
      'Alpha Beast' => {
        victory: 'Syn\'s pupper shakes his heart collar proudly. An arrow would be redundant.',
        praise: 'He drops a mouthful of foil chocolate hearts on your chest and looks enormously proud.'
      },
      'Eros' => {
        victory: 'The goddess tastes of chocolate and grace. "I let them aim one week," Eros says. "They behave better claimed."',
        praise: 'A white tentacle offers you a rose. Refusing is not among the options.'
      }
    }.freeze

    HEART_BLESSING = {
      key: 'heartstring_glow', name: 'Heartstring Glow', floors: 4,
      effects: { 'submit_lp_bonus' => 2, 'appearance' => 4, 'satisfy_bonus' => 0.05 },
      summary: 'Warm, rose-sweet, and faintly crimson — the temple likes a heart that stays open'
    }.freeze

  MONSTER_ALIASES = {
    "Alraune" => "Rose Alraune",
    "Amber Slime" => "Chocolate Amber Slime",
    "Balloon Mistress" => "Carnival-Heart Balloon Mistress",
    "Banshee" => "Lonely Banshee",
    "Basilisk" => "Lace-Collared Basilisk",
    "Bath Mimic" => "Heart-Box Bath Mimic",
    "Bear" => "Rose-Bitten Bear",
    "Bed Mimic" => "Love-Letter Bed Mimic",
    "Big-Shoe Brute" => "Balloon-Rose Big-Shoe Brute",
    "Black Orchid" => "Rose Black Orchid",
    "Blood Rose" => "Thorn Blood Rose",
    "Bone Dancer" => "Heartbroken Bone Dancer",
    "Book Mimic" => "Ribbon Book Mimic",
    "Broodmother" => "Heartstring Broodmother",
    "Bubble Slime" => "Cherry Bubble Slime",
    "Cambion" => "Cupid Cambion",
    "Carnal Fiend" => "Arrow Carnal Fiend",
    "Carnival Clown" => "Pie-Kiss Carnival Clown",
    "Centaur" => "Velvet Centaur",
    "Chain Devil" => "Heartstring Chain Devil",
    "Chair Mimic" => "Parcel Chair Mimic",
    "Champagne Slime" => "Rosewater Champagne Slime",
    "Chandelier Mimic" => "Lace Chandelier Mimic",
    "Chest Mimic" => "Heart-Box Chest Mimic",
    "Clock Mimic" => "Heart-Box Clock Mimic",
    "Clothing Mimic" => "Love-Letter Clothing Mimic",
    "Corpse Flower" => "Heartleaf Corpse Flower",
    "Cotton-Candy Imp" => "Lace Cotton-Candy Imp",
    "Couch Mimic" => "Ribbon Couch Mimic",
    "Cream Slime" => "Velvet Cream Slime",
    "Crypt Keeper" => "Lace-Shroud Crypt Keeper",
    "Crystal Slime" => "Fondant Crystal Slime",
    "Curtain Mimic" => "Parcel Curtain Mimic",
    "Demoness" => "Velvet Demoness",
    "Djinn" => "Desire Djinn",
    "Door Mimic" => "Lace Door Mimic",
    "Dragon" => "Cupids Dragon",
    "Dream Eater" => "Cupid Dream Eater",
    "Dryad" => "Valentine Dryad",
    "Dullahan" => "Rose-Wilted Dullahan",
    "Ember Fiend" => "Arrow Ember Fiend",
    "Fae Trickster" => "Heartstring Fae Trickster",
    "Foam Slime" => "Chocolate Foam Slime",
    "Gargoyle" => "Lace-Collared Gargoyle",
    "Gelatinous Mass" => "Cherry Gelatinous Mass",
    "Ghost" => "Eternal Ghost",
    "Ghoul" => "Lonely Ghoul",
    "Giant Bee" => "Rose-Bitten Giant Bee",
    "Giant Moth" => "Heartstring Giant Moth",
    "Giant Spider" => "Velvet Giant Spider",
    "Glow Slime" => "Rosewater Glow Slime",
    "Goblin" => "Cupids Goblin",
    "Gorgon Matron" => "Lace-Collared Gorgon Matron",
    "Green Slime" => "Velvet Green Slime",
    "Harpy" => "Rose-Bitten Harpy",
    "Headless Knight" => "Heartbroken Headless Knight",
    "Hellhound" => "Velvet Hellhound",
    "Honey Slime" => "Fondant Honey Slime",
    "Honker" => "Fool Honker",
    "HuCow" => "Chocolate HuCow",
    "Ifrit" => "Desire Ifrit",
    "Imp" => "Cupid Imp",
    "Incubus" => "Arrow Incubus",
    "Item Pile Mimic" => "Heart-Box Item Pile Mimic",
    "Jelly Cube" => "Chocolate Jelly Cube",
    "Jellyfish" => "Cherry Jellyfish",
    "Jester" => "Carnival-Heart Jester",
    "Jiangshi" => "Lace-Shroud Jiangshi",
    "Kitsune" => "Heartstring Kitsune",
    "Lamia" => "Velvet Lamia",
    "Lich" => "Rose-Wilted Lich",
    "Living Ivy" => "Bouquet Living Ivy",
    "Loom Mimic" => "Love-Letter Loom Mimic",
    "Man-Eating Flower" => "Valentine Man-Eating Flower",
    "Mandrake" => "Rose Mandrake",
    "Marionette Mistress" => "Arrow Marionette Mistress",
    "Mercury Slime" => "Rosewater Mercury Slime",
    "Milk Slime" => "Velvet Milk Slime",
    "Minotaur" => "Cupids Minotaur",
    "Mirror Mimic" => "Ribbon Mirror Mimic",
    "Moonflower" => "Thorn Moonflower",
    "Mummy" => "Eternal Mummy",
    "Mycelian" => "Heartleaf Mycelian",
    "Naga" => "Lace-Collared Naga",
    "Night Hag" => "Heartstring Night Hag",
    "Nightshade" => "Bouquet Nightshade",
    "Ogre" => "Rose-Bitten Ogre",
    "Oil Slime" => "Fondant Oil Slime",
    "Oni" => "Velvet Oni",
    "Orc" => "Heartstring Orc",
    "Pale Bride" => "Lonely Pale Bride",
    "Piano Mimic" => "Parcel Piano Mimic",
    "Pie Clown" => "Balloon-Rose Pie Clown",
    "Pit Fiend" => "Desire Pit Fiend",
    "Pitcher Plant" => "Valentine Pitcher Plant",
    "Pollen Sprite" => "Rose Pollen Sprite",
    "Poltergeist" => "Heartbroken Poltergeist",
    "Pudding Slime" => "Chocolate Pudding Slime",
    "Purple Slime" => "Cherry Purple Slime",
    "Rakshasa" => "Cupid Rakshasa",
    "Revenant" => "Lace-Shroud Revenant",
    "Ringmaster" => "Pie-Kiss Ringmaster",
    "Rose Slime" => "Rosewater Rose Slime",
    "Rubber Slime" => "Velvet Rubber Slime",
    "Rug Mimic" => "Lace Rug Mimic",
    "Sap Dryad" => "Thorn Sap Dryad",
    "Satyr" => "Velvet Satyr",
    "Silkweaver" => "Cupids Silkweaver",
    "Sin Eater" => "Arrow Sin Eater",
    "Siren" => "Heartstring Siren",
    "Skeleton" => "Rose-Wilted Skeleton",
    "Specter" => "Eternal Specter",
    "Statue Mimic" => "Heart-Box Statue Mimic",
    "Stone Golem" => "Love-Letter Stone Golem",
    "Strangler Fig" => "Heartleaf Strangler Fig",
    "Succubus" => "Cupid Succubus",
    "Sundew" => "Bouquet Sundew",
    "Syrup Slime" => "Fondant Syrup Slime",
    "Tar Slime" => "Chocolate Tar Slime",
    "Tentacle Vine" => "Valentine Tentacle Vine",
    "Thorn Vine" => "Rose Thorn Vine",
    "Throne Mimic" => "Ribbon Throne Mimic",
    "Tomb Widow" => "Lonely Tomb Widow",
    "Treant" => "Thorn Treant",
    "Troll" => "Lace-Collared Troll",
    "Vampire" => "Heartbroken Vampire",
    "Velvet Devil" => "Velvet Velvet Devil",
    "Venus Mantrap" => "Heartleaf Venus Mantrap",
    "Wardrobe Mimic" => "Parcel Wardrobe Mimic",
    "Wight" => "Lace-Shroud Wight",
    "Wild Dog" => "Rose-Bitten Wild Dog",
    "Wildcat" => "Heartstring Wildcat",
    "Wolf" => "Lace-Collared Wolf",
    "Wraith" => "Rose-Wilted Wraith",
    "Zombie" => "Eternal Zombie"
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
      start = Time.new(now.year, 2, 12)
      finish = Time.new(now.year, 2, 16) # through Feb 15 inclusive
      now >= start && now < finish
    end

    def ends_at(now = Time.now)
      Time.new(now.year, 2, 16).to_i
    end

    def active?(now = Time.now)
      Engine::Seasons.active?(:valentines, now) ||
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

    def hearts_count(player)
      player.tracker(HEARTS_TRACKER)
    end

    def grant_hearts!(player, amount = 1)
      have = hearts_count(player)
      add = [[amount.to_i, 0].max, HEARTS_MAX - have].min
      return 0 if add <= 0

      player.set_tracker!(HEARTS_TRACKER, have + add)
      add
    end

    def eat_hearts!(player)
      have = hearts_count(player)
      return { ok: false, message: 'Your chocolate tin is empty.' } if have <= 0

      player.set_tracker!(HEARTS_TRACKER, have - 1)
      player.bump_tracker!(HEARTS_EATEN)
      case rand(3)
      when 0
        gained = player.heal_defiance!(14)
        { ok: true, message: "Rose-sweet chocolate — **+#{gained} Defiance** " \
                             "(#{hearts_count(player)} hearts left)." }
      when 1
        player.gain_lp!(9)
        { ok: true, message: "A heart melts filthy — **+9 LP** (now `#{player.lp}`). " \
                             "#{hearts_count(player)} hearts left." }
      else
        before = player.lust
        player.update(lust: [player.lust - 10, 0].max)
        { ok: true, message: "Sugar settles the heat — **−#{before - player.lust} Lust** (now `#{player.lust}`). " \
                             "#{hearts_count(player)} hearts left." }
      end
    end

    def status_consumables(player)
      count = hearts_count(player)
      return [] unless count.positive?

      [{ id: 'valentines_hearts', label: 'Chocolate Hearts', count: count, max: HEARTS_MAX }]
    end

    def biome_weight_mult(biome_key)
      case biome_key.to_s
      when 'ashen_court', 'masquerade_ball' then 1.55
      when 'verdant_grove', 'pollen_gallery' then 1.35
      else 1.08
      end
    end

    def presence_suffix
      ' — hearts strung; aim carefully.'
    end

    def costume_stock?
      active?
    end

    def heart_altar?
      active?
    end

    def syn_heartstring_unlocked?(player)
      player.tracker('syn_valentines_crumb').positive? || active?
    end

    def mark_syn_crumb!(player)
      player.set_tracker!('syn_valentines_crumb', 1)
    end

    def monster_alias(base_name)
      MONSTER_ALIASES[base_name.to_s]
    end

    def chest_bonus!(player)
      return [] unless active?

      lines = []
      added = grant_hearts!(player, rand(1..2))
      if added.positive?
        lines << "Foil **Chocolate Hearts** tumble out — stashed for later " \
                 "(**#{hearts_count(player)}/#{HEARTS_MAX}** in your tin)."
      end
      if rand < 0.22
        Engine::Residents.sync_vex_outfits!
        piece = COSTUMES.reject { |s| (item = ::Equipment.first(name: s[:name])) && player.owns_equipment?(item.id) }.sample
        if piece && (item = ::Equipment.first(name: piece[:name]))
          grant = player.grant_equipment!(item, auto_equip: false)
          if grant[:ok]
            lines << "A Heartstring piece: **#{item.name}** — _#{item.description}_ " \
                     '(keeps forever; equip from `e,equipment` / reclaim free at Vex).'
          end
        end
      end
      lines
    end

    Engine::Seasons.register!(KEY, self)
  end
end
