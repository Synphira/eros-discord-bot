# frozen_string_literal: true

require_relative 'seasons'

module Engine
  # All Hallows' Heat pack. Rewards earned here persist; the calendar only
  # gates earning and encounter rate.
  module Halloween
    KEY = 'halloween'
    CANDY_TRACKER = 'halloween_candy'
    CANDY_EATEN = 'halloween_candy_eaten'
    CANDY_MAX = 12
    SUBMIT_TRACKER = 'halloween_submits'
    SCARES_OPTION = 'halloween_scares'

    WEEKLY = {
      key: KEY,
      name: "All Hallows' Heat",
      description: 'The temple puts on a mask: undead and demons throng the halls, lust runs hotter (×1.1), ' \
                   'undead lust ×1.2, +3 LP submitting to undead / +2 to demons, elites ×1.5, and events 25% more often. ' \
                   'Every hallway pest wears an All Hallows name. Mimics stir, biomes lean haunted, pumpkin altars and ' \
                   'trick-or-treat rooms appear, Vex stocks costumes, named folk dress for the night, and candy/titles/gear ' \
                   'you earn stay after the season.',
      effects: {
        'lust_mult' => 1.1,
        'undead_lust_mult' => 1.2,
        'undead_submit_lp' => 3,
        'demon_submit_lp' => 2
      },
      monsters: { undead: 2.0, demon: 1.5, mimic: 1.35 },
      special: { 'elite_chance' => 1.5, 'event_rate' => 1.25, 'mimic_chance' => 1.25 }
    }.freeze

    COSTUME_NAMES = [
      'Masquerade Domino',
      'Pumpkin-Cut Bodice',
      'Cobweb Stockings'
    ].freeze

    COSTUMES = [
      { name: 'Masquerade Domino', slot: 'head', type: 'armor', cost: 55, tier: :halloween,
        description: 'A black lace half-mask. The temple loves a face that admits it came to play.',
        stat_modifiers: { 'appearance' => 9, 'satisfy_bonus' => 0.03, 'submit_lp_bonus' => 1 } },
      { name: 'Pumpkin-Cut Bodice', slot: 'chest', type: 'armor', cost: 95, tier: :halloween,
        description: 'Orange silk laced obscenely tight, carved like a jack-o\'-lantern\'s grin across the bust.',
        stat_modifiers: { 'appearance' => 13, 'lust_mult' => 1.08, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.05 } },
      { name: 'Cobweb Stockings', slot: 'legs', type: 'armor', cost: 65, tier: :halloween,
        description: 'Sheer black webs for thighs. Something always seems to catch in them.',
        stat_modifiers: { 'appearance' => 10, 'agility' => 1, 'submit_lp_bonus' => 1 } }
    ].freeze


  # Halloween — 135 aliases
  MONSTER_ALIASES = {
      "Alraune" => "Samhain Alraune",
      "Amber Slime" => "Candle Amber Slime",
      "Balloon Mistress" => "Grave Balloon Mistress",
      "Banshee" => "Masquerade Banshee",
      "Basilisk" => "Bone Basilisk",
      "Bath Mimic" => "Cauldron Bath Mimic",
      "Bear" => "Spectral Bear",
      "Bed Mimic" => "Coffin Bed Mimic",
      "Big-Shoe Brute" => "Bone-Shoe Brute",
      "Black Orchid" => "Funeral Black Orchid",
      "Blood Rose" => "All-Hallows Blood Rose",
      "Bone Dancer" => "Masque Bone Dancer",
      "Book Mimic" => "Grimoire Book Mimic",
      "Broodmother" => "Web-Lantern Broodmother",
      "Bubble Slime" => "Will-o'-Bubble Slime",
      "Cambion" => "Masquerade Cambion",
      "Carnal Fiend" => "Samhain Carnal Fiend",
      "Carnival Clown" => "Dead Carnival Clown",
      "Centaur" => "Night-Hunt Centaur",
      "Chain Devil" => "Pumpkin-Chain Devil",
      "Chair Mimic" => "Haunted Chair Mimic",
      "Champagne Slime" => "Cider Champagne Slime",
      "Chandelier Mimic" => "Jack-o'-Chandelier Mimic",
      "Chest Mimic" => "Jack-o'-Chest Mimic",
      "Clock Mimic" => "Doomsday Clock Mimic",
      "Clothing Mimic" => "Costume Clothing Mimic",
      "Corpse Flower" => "Harvest Corpse Flower",
      "Cotton-Candy Imp" => "Cobweb-Candy Imp",
      "Couch Mimic" => "Barrow Couch Mimic",
      "Cream Slime" => "Marshmallow Cream Slime",
      "Crypt Keeper" => "Lantern Crypt Keeper",
      "Crystal Slime" => "Candy-Crystal Slime",
      "Curtain Mimic" => "Veil Curtain Mimic",
      "Demoness" => "Masquerade Demoness",
      "Djinn" => "Smoke-and-Ember Djinn",
      "Door Mimic" => "Threshold Door Mimic",
      "Dragon" => "Bonefire Dragon",
      "Dream Eater" => "Nightmare Dream Eater",
      "Dryad" => "Autumn-Veil Dryad",
      "Dullahan" => "Pumpkin Dullahan",
      "Ember Fiend" => "Jack-o'-Ember Fiend",
      "Fae Trickster" => "Samhain Fae Trickster",
      "Foam Slime" => "Fog Foam Slime",
      "Gargoyle" => "Cathedral Gargoyle",
      "Gelatinous Mass" => "Wax Gelatinous Mass",
      "Ghost" => "Masquerade Ghost",
      "Ghoul" => "Treat-Basket Ghoul",
      "Giant Bee" => "Wasp-of-Hallows Giant Bee",
      "Giant Moth" => "Death's-Head Giant Moth",
      "Giant Spider" => "Cobweb Giant Spider",
      "Glow Slime" => "Jack-o'-Glow Slime",
      "Goblin" => "Trick Goblin",
      "Gorgon Matron" => "Stone-Lantern Gorgon Matron",
      "Green Slime" => "Poison-Apple Green Slime",
      "Harpy" => "Night-Cry Harpy",
      "Headless Knight" => "Lantern Headless Knight",
      "Hellhound" => "Hallow Hellhound",
      "Honey Slime" => "Candy-Corn Honey Slime",
      "Honker" => "Bone Honker",
      "HuCow" => "Harvest HuCow",
      "Ifrit" => "Bonfire Ifrit",
      "Imp" => "Candy Imp",
      "Incubus" => "Masquerade Incubus",
      "Item Pile Mimic" => "Offering-Pile Mimic",
      "Jelly Cube" => "Jelly-of-the-Dead Cube",
      "Jellyfish" => "Ghostlight Jellyfish",
      "Jester" => "Dead Jester",
      "Jiangshi" => "Paper-Talisman Jiangshi",
      "Kitsune" => "Foxfire Kitsune",
      "Lamia" => "Moonlit Lamia",
      "Lich" => "Candlecrown Lich",
      "Living Ivy" => "Grave Living Ivy",
      "Loom Mimic" => "Shroud Loom Mimic",
      "Man-Eating Flower" => "Funeral Man-Eating Flower",
      "Mandrake" => "Screaming Mandrake",
      "Marionette Mistress" => "Ghost-String Marionette Mistress",
      "Mercury Slime" => "Mirror Mercury Slime",
      "Milk Slime" => "Moon-Milk Slime",
      "Minotaur" => "Labyrinth Minotaur",
      "Mirror Mimic" => "Black-Mirror Mimic",
      "Moonflower" => "Blood Moonflower",
      "Mummy" => "Bandage-and-Bat Mummy",
      "Mycelian" => "Tomb Mycelian",
      "Naga" => "Serpent-Mask Naga",
      "Night Hag" => "Samhain Night Hag",
      "Nightshade" => "Witching Nightshade",
      "Ogre" => "Harvest Ogre",
      "Oil Slime" => "Black-Candle Oil Slime",
      "Oni" => "Festival Oni",
      "Orc" => "Raid-Night Orc",
      "Pale Bride" => "Veiled Pale Bride",
      "Piano Mimic" => "Dirge Piano Mimic",
      "Pie Clown" => "Grave-Pie Clown",
      "Pit Fiend" => "Infernal Pit Fiend",
      "Pitcher Plant" => "Offering Pitcher Plant",
      "Pollen Sprite" => "Ash Pollen Sprite",
      "Poltergeist" => "Rattle Poltergeist",
      "Pudding Slime" => "Pumpkin Pudding Slime",
      "Purple Slime" => "Grape-Poison Purple Slime",
      "Rakshasa" => "Tiger-Mask Rakshasa",
      "Revenant" => "Unfinished Revenant",
      "Ringmaster" => "Carnival-of-Bones Ringmaster",
      "Rose Slime" => "Wilted Rose Slime",
      "Rubber Slime" => "Mask Rubber Slime",
      "Rug Mimic" => "Flying-Carpet Grave Rug Mimic",
      "Sap Dryad" => "Amber Sap Dryad",
      "Satyr" => "Revel Satyr",
      "Silkweaver" => "Shroud Silkweaver",
      "Sin Eater" => "Confession Sin Eater",
      "Siren" => "Foghorn Siren",
      "Skeleton" => "Dancing Skeleton",
      "Specter" => "Veil Specter",
      "Statue Mimic" => "Gargoyle Statue Mimic",
      "Stone Golem" => "Tomb Stone Golem",
      "Strangler Fig" => "Noose Strangler Fig",
      "Succubus" => "Masquerade Succubus",
      "Sundew" => "Night-Dew Sundew",
      "Syrup Slime" => "Molasses Syrup Slime",
      "Tar Slime" => "Pitch Tar Slime",
      "Tentacle Vine" => "Grasping Tentacle Vine",
      "Thorn Vine" => "Briar Thorn Vine",
      "Throne Mimic" => "Bone Throne Mimic",
      "Tomb Widow" => "Veiled Tomb Widow",
      "Treant" => "Withered Treant",
      "Troll" => "Bridge-of-Bones Troll",
      "Vampire" => "Crimson-Mask Vampire",
      "Velvet Devil" => "Midnight Velvet Devil",
      "Venus Mantrap" => "Hungry Venus Mantrap",
      "Wardrobe Mimic" => "Costume Wardrobe Mimic",
      "Wight" => "Barrow Wight",
      "Wild Dog" => "Hellhound Wild Dog",
      "Wildcat" => "Black-Cat Wildcat",
      "Wolf" => "Bone Wolf",
      "Wraith" => "Lantern Wraith",
      "Zombie" => "Shambling Zombie"
  }.freeze

    PUMPKIN_BLESSING = {
      key: 'pumpkin_glow', name: 'Pumpkin Glow', floors: 4,
      effects: { 'submit_lp_bonus' => 2, 'appearance' => 4, 'satisfy_bonus' => 0.04 },
      summary: 'Candle-warm and faintly orange — the temple likes your costume'
    }.freeze

    # Named characters only — not random encounter monsters. Alpha is always
    # Syn's handiwork.
    DRESS = {
      'Mimic Broodmother' => 'The Broodmother\'s lid is draped in tattered lace and paper bats her brood glued on crooked. ' \
                            'She looks absurd. She looks delighted.',
      'Succubus Queen' => 'The Queen wears a jewelled half-mask and a gown cut for All Hallows — costume as throne, ' \
                         'every hallway a ballroom she owns.',
      'Incubus King' => 'Gold paint on his horns, a cape that fights him, and a pose he practiced in three mirrors. ' \
                       'He is having the time of his unlife.',
      'Verdant Dryad' => 'Autumn leaves instead of summer flowers — a harvest halo, soft and inevitable. She sheds one ' \
                        'on purpose when you look.',
      'Lich Lord' => 'A paper crown sits atop blue fire. He did not ask for it. He will not remove it. Spite, now, ' \
                    'is the outfit.',
      'Alpha Beast' => 'Syn has buckled a ridiculous bat-wing collar onto her pupper for All Hallows. He is delighted. ' \
                      'The wings flap. Dignity left the hallway.',
      'Eros' => 'Even the goddess has indulged — black lace somewhere a goddess should not need lace, and a smile that ' \
               'says the temple is allowed to play dress-up.',
      'Syn' => 'Ink-smudged bat wings at the corners of her eyes. She keeps catching her reflection and looking pleased ' \
              'with herself. Tonight she is the holiday\'s author, not its guest.',
      'Berry' => 'A witch\'s hat at a practical angle, black lipstick, and a cauldron of foil candy by the till. She ' \
                'swears the hat is "branding." Syn knows better.',
      'Covar' => 'A velvet half-mask he claims is for anonymity. It fits him far too well. Living gear on the shelves ' \
                'leans toward him like they want one too.',
      'Madame Vex' => 'Cobweb silk, pale powder, and a fitting-room that smells like old perfume and new fear. She looks ' \
                     'like a ghost who bills by the hour.',
      'Pip' => 'A bedsheet ghost with eyeholes cut by someone who hates symmetry. She floats (she does not float) and ' \
              'is extremely proud of the craftsmanship.',
      'Sister Nectar' => 'Black lace apron over shrine whites, a tiny pumpkin cup among the brass, and a look that says ' \
                        'milking is still holy even when the pumps wear bat stickers. Arrive tense. Leave drained. ' \
                        'Spooked optional.',
      'Fang' => 'White ink gone orange at the margins — maps of rooms that scream. He has sketched three haunted ' \
               'hallways that do not exist yet. One of them has already moved.'
    }.freeze

    CLERGY_LINES = {
      'Mimic Broodmother' => {
        victory: 'The Broodmother\'s lid clacks like a laugh. "Dress-up night," she croons. "My brood loves costumes. Especially the ones that scream."',
        praise: 'Little mimics bounce in paper masks. One of them is wearing your discarded dignity.'
      },
      'Succubus Queen' => {
        victory: 'The Queen adjusts her jewelled half-mask. "Samhain etiquette," she purrs. "Kneel prettier."',
        praise: '"Masks make everyone honest," she says, and kisses the spot yours would cover.'
      },
      'Incubus King' => {
        victory: 'Gold-painted horns catch the light. "Trick or treat," the King says, already deciding you are both.',
        praise: 'He tugs a candy ribbon from nowhere and ties it around your wrist like a claim.'
      },
      'Verdant Dryad' => {
        victory: 'Autumn leaves crown her. "The garden dies beautifully this week," she murmurs. "So can you."',
        praise: 'She tucks a dried leaf behind your ear. It smells like smoke and sap.'
      },
      'Lich Lord' => {
        victory: 'The paper crown tips. "All Hallows is when the living remember they are temporary," the Lich notes. "Useful curriculum."',
        praise: 'He stamps your skin with a cold sigil that looks, briefly, like a candy skull.'
      },
      'Alpha Beast' => {
        victory: 'Syn\'s pupper shakes his bat-wing collar proudly. Somewhere a mask smiles back.',
        praise: 'He drops a mouthful of foil-wrapped candy on your chest and looks enormously proud.'
      },
      'Eros' => {
        victory: 'The goddess tastes of caramel and endings. "I let the temple play dress-up one week a year," Eros says. "It behaves better after."',
        praise: 'A white tentacle offers you a sweet. Refusing is not among the options.'
      }
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
      start = Time.new(now.year, 10, 30)
      finish = Time.new(now.year, 11, 6)
      now >= start && now < finish
    end

    def ends_at(now = Time.now)
      Time.new(now.year, 11, 6).to_i
    end

    def active?(now = Time.now)
      Engine::Seasons.active?(:halloween, now) ||
        (Engine::Seasons.forced_key == KEY)
    end

    # Called only while this pack is the active season (or forced) — do not
    # re-gate on Time.now here (Seasons may be probing a simulated date).
    def dress_line(who)
      DRESS[who.to_s]
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
      return { ok: false, message: 'Your candy pouch is empty.' } if have <= 0

      player.set_tracker!(CANDY_TRACKER, have - 1)
      player.bump_tracker!(CANDY_EATEN)
      case rand(3)
      when 0
        gained = player.heal_defiance!(12)
        { ok: true, message: "You unwrap a sticky sweet. Warmth knits through you — **+#{gained} Defiance** " \
                             "(#{candy_count(player)} candy left)." }
      when 1
        player.gain_lp!(8)
        { ok: true, message: "Sugar and lust-light burst on your tongue — **+8 LP** (now `#{player.lp}`). " \
                             "#{candy_count(player)} candy left." }
      else
        before = player.lust
        player.update(lust: [player.lust - 8, 0].max)
        { ok: true, message: "Cool caramel settles the heat — **−#{before - player.lust} Lust** (now `#{player.lust}`). " \
                             "#{candy_count(player)} candy left." }
      end
    end

    def status_consumables(player)
      count = candy_count(player)
      return [] unless count.positive?

      [{ id: 'halloween_candy', label: 'Halloween Candy', count: count, max: CANDY_MAX }]
    end

    def biome_weight_mult(biome_key)
      case biome_key.to_s
      when 'ashen_court', 'masquerade_ball', 'clockwork_brothel', 'bell_choir' then 1.75
      when 'flooded_grotto', 'honeyed_hive', 'milking_barns' then 0.85
      else 1.1
      end
    end

    def presence_suffix
      ' — masked delvers in the temple for All Hallows.'
    end

    def presence_text(users, towers)
      Engine::Seasons.presence_text(users, towers)
    end

    def clergy_line(boss_name, kind = :victory)
      key = kind.to_sym == :praise ? :praise : :victory
      CLERGY_LINES.dig(boss_name.to_s, key)
    end

    def syn_halloween_unlocked?(player)
      player.tracker('syn_halloween_crumb').positive? || active?
    end

    def mark_syn_crumb!(player)
      player.set_tracker!('syn_halloween_crumb', 1)
    end

    def costume_stock?
      active?
    end

    def pumpkin_altar?
      active?
    end

    def chest_bonus!(player)
      return [] unless active?

      lines = []
      added = grant_candy!(player, rand(1..2))
      if added.positive?
        lines << "Foil-wrapped **Halloween Candy** tumbles out — stashed for later " \
                 "(**#{candy_count(player)}/#{CANDY_MAX}** in your pouch)."
      end
      if rand < 0.22
        Engine::Residents.sync_vex_outfits!
        piece = COSTUMES.reject { |s| (item = ::Equipment.first(name: s[:name])) && player.owns_equipment?(item.id) }.sample
        if piece && (item = ::Equipment.first(name: piece[:name]))
          grant = player.grant_equipment!(item, auto_equip: false)
          if grant[:ok]
            lines << "A costume piece: **#{item.name}** — _#{item.description}_ " \
                     '(keeps forever; equip from `e,equipment`).'
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
