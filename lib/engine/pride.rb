# frozen_string_literal: true

require_relative 'seasons'

module Engine
  # June 25–July 1. Pride parade, rainbow glitter, found-family revel — rewards keep forever.
  module Pride
    KEY = 'pride'
    GLITTER_TRACKER = 'pride_glitter'
    GLITTER_EATEN = 'pride_glitter_eaten'
    GLITTER_MAX = 12
    SUBMIT_TRACKER = 'pride_submits'
    EXCESS_OPTION = 'pride_excess'

    WEEKLY = {
      key: KEY,
      name: 'Pride Parade',
      description: 'The temple throws a parade: slime and demons throng in colorful mess, lust runs warmer (×1.12), ' \
                   '+2 LP on every submit, events 25% more often, elites lean in. Every hallway pest wears a Pride ' \
                   'name. Pride glitter and Vex\'s flag rack stay after the floats roll out. Syn buckles a rainbow ' \
                   'bandana on her pupper. Ask her about Pride while it lasts.',
      effects: {
        'lust_mult' => 1.12,
        'submit_lp_bonus' => 2,
        'satisfy_bonus' => 0.04
      },
      monsters: { slime: 2.0, demon: 1.7, mimic: 1.25 },
      special: { 'event_rate' => 1.25, 'elite_chance' => 1.2 }
    }.freeze

    COSTUME_NAMES = [
      'Rainbow Bandana',
      'Flag-Draped Bodice',
      'Glitter Parade Hose'
    ].freeze

    COSTUMES = [
      { name: 'Rainbow Bandana', slot: 'head', type: 'armor', cost: 55, tier: :pride,
        description: 'Cheap silk in every colour, knotted like a claim. You look like you came to march — and be marched on.',
        stat_modifiers: { 'appearance' => 9, 'satisfy_bonus' => 0.03, 'submit_lp_bonus' => 1 } },
      { name: 'Flag-Draped Bodice', slot: 'chest', type: 'armor', cost: 95, tier: :pride,
        description: 'A flag worn as fashion — cut to show what the parade is celebrating. Soft bondage of found-family pride.',
        stat_modifiers: { 'appearance' => 13, 'lust_mult' => 1.08, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.05 } },
      { name: 'Glitter Parade Hose', slot: 'legs', type: 'armor', cost: 65, tier: :pride,
        description: 'Sheer hose dusted with edible-looking glitter. Standing on a float becomes a dare.',
        stat_modifiers: { 'appearance' => 10, 'agility' => 1, 'submit_lp_bonus' => 1 } }
    ].freeze

    DRESS = {
      'Mimic Broodmother' => 'Her entire lid is a float: foil rainbow scales, brood in tiny flags and glitter paste, ' \
                            'a banner that says OPEN WIDE strung between her teeth. She is not pretending this was ' \
                            'subtle. She is grand marshal of teeth.',
      'Succubus Queen' => 'Full runway — rainbow velvet split to the hip, cascade of beads that never stop moving, ' \
                         'platform heels that click like applause. Every guest is a float she intends to ride until ' \
                         'dawn, and she has already picked the music.',
      'Incubus King' => 'He went nuclear: rainbow body paint on the horns, sequin harness, a cape that sheds glitter ' \
                       'when he turns, sash reading INVENTED THIS in Syn\'s handwriting he has not noticed. He is ' \
                       'living his best incorrect life.',
      'Verdant Dryad' => 'She is a meadow mid-parade — wildflowers in every colour from crown to ankles, petals stuck ' \
                        'to bare skin with sweat and joy, the smell of crushed grass and sugar. Hunting strategy ' \
                        'upgraded to celebration strategy. Same teeth.',
      'Lich Lord' => 'Blue fire refracts through a prismatic cloak Syn pinned on him — rainbow light crawling his ribs, ' \
                    'foil stars in the flame, a look of profound academic suffering. He is still here. He is still ' \
                    'glowing. He hates that he does not hate it enough.',
      'Alpha Beast' => 'Syn went all-out on her pupper: rainbow bandana, glitter along his shoulders, a tiny flag ' \
                      'clipped to the collar that snaps when he trots. He is delighted. He thinks the parade is for ' \
                      'him. She has not corrected him. Nobody else will either.',
      'Eros' => 'The goddess did not phone it in — lace in every colour shifting as you look, white tentacles wound ' \
               'with silk flags, a smile like a banner just unfurled over a crowd. Permission to celebrate is written ' \
               'on her mouth. Kneeling is still the dress code.',
      'Syn' => 'Glitter from lashes to collarbones, ink in pride colours on her wrists, a flag pin and three backup ' \
              'pins, the quiet ownership of the person who hung every banner in this tower. She did the decorating. ' \
              'She will say so. Loudly. Fondly. With teeth.',
      'Berry' => 'The shop is a float that learned rent: rainbow bunting in the windows, glitter in the register ' \
                'drawer, foil sweets piled like treasure, Berry herself in a marshal\'s whistle and a top that sheds ' \
                'colour when she moves. She is not wearing a cute sash. She is running the parade through her till.',
      'Covar' => 'Rainbow thread on his cuffs, glitter he will deny until it catches the light, a flag folded at his ' \
                'belt. Living gear on the shelves wears temporary colour. He did that. For the week. For once he is ' \
                'not hiding it well.',
      'Madame Vex' => 'Living cloth gone full spectrum — a walking runway that shifts through every colour as she ' \
                     'walks, flag-draped mannequins in the rack, glitter that sticks to customers on purpose. She ' \
                     'charges for the flag-drape. She charges more for the afterparty fitting. Pride is couture.',
      'Pip' => 'Glitter crown, glitter chest, glitter everywhere pants are not, a clipboard covered in foil stars, ' \
              'and a float she is trying to trap mid-cheer. This is not a bit. This is a lifestyle. She rates ' \
              'confetti density like a sport.',
      'Sister Nectar' => 'Full out — rainbow stole over shrine whites, glitter on the brass cups, foil Pride sweets in ' \
                        'the tip jar, and a banner that says THE SHRINE PROVIDES in every colour. Milking is holy. ' \
                        'Loud is allowed. Arrive tense. Leave drained. Leave sparkling.',
      'Fang' => 'He went off-script: rainbow ink in the margins, glitter on the dream-maps, a tiny flag pinned to his ' \
               'cloak, sketches of parade floats that have not rolled yet. He still does not look up. The colour does ' \
               'the looking for him. Priced like celebration.'
    }.freeze

    CLERGY_LINES = {
      'Mimic Broodmother' => {
        victory: 'Her lid is a banner of teeth and foil. "March," she croons. "My brood claimed the front of the float. You\'re the cargo."',
        praise: 'Broodlings bounce in flags and glitter paste. One presses a sticky Pride sweet to your mouth like communion.'
      },
      'Succubus Queen' => {
        victory: 'Beads rain. Velvet parts. "Parade etiquette," she purrs. "Wave. Flash. Then kneel until the music stops — and after."',
        praise: '"Good floats stay ridden," she says, and takes her thanks from your mouth while the hallway cheers.'
      },
      'Incubus King' => {
        victory: 'Cape shedding glitter, sash askew. "I invented this," he lies beautifully. "You\'re the float. Try to keep up."',
        praise: 'He tips a fistful of foil glitter sweets against your lips and watches you swallow like it is a toast to him.'
      },
      'Verdant Dryad' => {
        victory: 'Petals and colour brush your cheek. "The meadow keeps what celebrates," she murmurs. "Stay loud."',
        praise: 'She tucks a rainbow of crushed blooms behind your ear. It smells like glitter, sap, and someone else\'s joy on your skin.'
      },
      'Lich Lord' => {
        victory: 'Prism-fire crawls his ribs. "Revelry is a binding," he notes. "You accepted the flag. The light is… adequate."',
        praise: 'He stamps a cold sigil that blooms, briefly, into every colour around your remaining dignity — and leaves it prettier.'
      },
      'Alpha Beast' => {
        victory: 'Syn\'s pupper shakes bandana and flag until confetti leans toward him. The hallway makes room. Of course it does.',
        praise: 'He drops a mouthful of foil Pride glitter on your chest like tribute and looks enormously, publicly proud.'
      },
      'Eros' => {
        victory: 'She tastes of glitter and grace. "I let them parade one week," Eros says. "They behave better celebrated — and louder."',
        praise: 'A white tentacle offers a silk flag wound like a leash. Refusing is not among the colours available.'
      }
    }.freeze

    PRIDE_BLESSING = {
      key: 'pride_glow', name: 'Pride Glow', floors: 4,
      effects: { 'submit_lp_bonus' => 2, 'appearance' => 4, 'satisfy_bonus' => 0.04 },
      summary: 'Warm, glitter-bright, and faintly rainbow — the temple likes a reveler who stays out and proud'
    }.freeze

  MONSTER_ALIASES = {
    "Alraune" => "Rainbow Alraune",
    "Amber Slime" => "Pride Amber Slime",
    "Balloon Mistress" => "Parade Balloon Mistress",
    "Banshee" => "Glitter Banshee",
    "Basilisk" => "Flag-Bearing Basilisk",
    "Bath Mimic" => "Bead Bath Mimic",
    "Bear" => "Parade Bear",
    "Bed Mimic" => "Rainbow Bed Mimic",
    "Big-Shoe Brute" => "Pride Big-Shoe Brute",
    "Black Orchid" => "Rainbow Black Orchid",
    "Blood Rose" => "Flag Blood Rose",
    "Bone Dancer" => "Parade Bone Dancer",
    "Book Mimic" => "Glitter Book Mimic",
    "Broodmother" => "Pride Broodmother",
    "Bubble Slime" => "Rainbow Bubble Slime",
    "Cambion" => "Parade Cambion",
    "Carnal Fiend" => "Pride Carnal Fiend",
    "Carnival Clown" => "Rainbow Carnival Clown",
    "Centaur" => "Flag Centaur",
    "Chain Devil" => "Bead Chain Devil",
    "Chair Mimic" => "Parade Chair Mimic",
    "Champagne Slime" => "Glitter Champagne Slime",
    "Chandelier Mimic" => "Rainbow Chandelier Mimic",
    "Chest Mimic" => "Pride Chest Mimic",
    "Clock Mimic" => "Parade Clock Mimic",
    "Clothing Mimic" => "Flag Clothing Mimic",
    "Corpse Flower" => "Rainbow Corpse Flower",
    "Cotton-Candy Imp" => "Pride Cotton-Candy Imp",
    "Couch Mimic" => "Glitter Couch Mimic",
    "Cream Slime" => "Rainbow Cream Slime",
    "Crypt Keeper" => "Parade Crypt Keeper",
    "Crystal Slime" => "Pride Crystal Slime",
    "Curtain Mimic" => "Flag Curtain Mimic",
    "Demoness" => "Rainbow Demoness",
    "Djinn" => "Parade Djinn",
    "Door Mimic" => "Pride Door Mimic",
    "Dragon" => "Rainbow Dragon",
    "Dream Eater" => "Glitter Dream Eater",
    "Dryad" => "Pride Dryad",
    "Dullahan" => "Parade Dullahan",
    "Ember Fiend" => "Rainbow Ember Fiend",
    "Fae Trickster" => "Pride Fae Trickster",
    "Foam Slime" => "Glitter Foam Slime",
    "Gargoyle" => "Parade Gargoyle",
    "Gelatinous Mass" => "Rainbow Gelatinous Mass",
    "Ghost" => "Pride Ghost",
    "Ghoul" => "Bead Ghoul",
    "Giant Bee" => "Rainbow Giant Bee",
    "Giant Moth" => "Parade Giant Moth",
    "Giant Spider" => "Pride Giant Spider",
    "Glow Slime" => "Rainbow Glow Slime",
    "Goblin" => "Flag Goblin",
    "Gorgon Matron" => "Parade Gorgon Matron",
    "Green Slime" => "Pride Green Slime",
    "Harpy" => "Rainbow Harpy",
    "Headless Knight" => "Parade Headless Knight",
    "Hellhound" => "Pride Hellhound",
    "Honey Slime" => "Glitter Honey Slime",
    "Honker" => "Rainbow Honker",
    "HuCow" => "Parade HuCow",
    "Ifrit" => "Pride Ifrit",
    "Imp" => "Rainbow Imp",
    "Incubus" => "Parade Incubus",
    "Item Pile Mimic" => "Glitter Item Pile Mimic",
    "Jelly Cube" => "Rainbow Jelly Cube",
    "Jellyfish" => "Pride Jellyfish",
    "Jester" => "Parade Jester",
    "Jiangshi" => "Rainbow Jiangshi",
    "Kitsune" => "Pride Kitsune",
    "Lamia" => "Flag Lamia",
    "Lich" => "Parade Lich",
    "Living Ivy" => "Rainbow Living Ivy",
    "Loom Mimic" => "Pride Loom Mimic",
    "Man-Eating Flower" => "Parade Man-Eating Flower",
    "Mandrake" => "Rainbow Mandrake",
    "Marionette Mistress" => "Pride Marionette Mistress",
    "Mercury Slime" => "Glitter Mercury Slime",
    "Milk Slime" => "Rainbow Milk Slime",
    "Minotaur" => "Parade Minotaur",
    "Mirror Mimic" => "Pride Mirror Mimic",
    "Moonflower" => "Rainbow Moonflower",
    "Mummy" => "Flag Mummy",
    "Mycelian" => "Parade Mycelian",
    "Naga" => "Pride Naga",
    "Night Hag" => "Rainbow Night Hag",
    "Nightshade" => "Glitter Nightshade",
    "Ogre" => "Parade Ogre",
    "Oil Slime" => "Rainbow Oil Slime",
    "Oni" => "Pride Oni",
    "Orc" => "Flag Orc",
    "Pale Bride" => "Parade Pale Bride",
    "Piano Mimic" => "Rainbow Piano Mimic",
    "Pie Clown" => "Pride Pie Clown",
    "Pit Fiend" => "Parade Pit Fiend",
    "Pitcher Plant" => "Rainbow Pitcher Plant",
    "Pollen Sprite" => "Pride Pollen Sprite",
    "Poltergeist" => "Glitter Poltergeist",
    "Pudding Slime" => "Rainbow Pudding Slime",
    "Purple Slime" => "Pride Purple Slime",
    "Rakshasa" => "Parade Rakshasa",
    "Revenant" => "Rainbow Revenant",
    "Ringmaster" => "Pride Ringmaster",
    "Rose Slime" => "Flag Rose Slime",
    "Rubber Slime" => "Parade Rubber Slime",
    "Rug Mimic" => "Rainbow Rug Mimic",
    "Sap Dryad" => "Pride Sap Dryad",
    "Satyr" => "Parade Satyr",
    "Silkweaver" => "Rainbow Silkweaver",
    "Sin Eater" => "Pride Sin Eater",
    "Siren" => "Flag Siren",
    "Skeleton" => "Parade Skeleton",
    "Specter" => "Rainbow Specter",
    "Statue Mimic" => "Pride Statue Mimic",
    "Stone Golem" => "Parade Stone Golem",
    "Strangler Fig" => "Rainbow Strangler Fig",
    "Succubus" => "Pride Succubus",
    "Sundew" => "Glitter Sundew",
    "Syrup Slime" => "Rainbow Syrup Slime",
    "Tar Slime" => "Pride Tar Slime",
    "Tentacle Vine" => "Parade Tentacle Vine",
    "Thorn Vine" => "Rainbow Thorn Vine",
    "Throne Mimic" => "Pride Throne Mimic",
    "Tomb Widow" => "Flag Tomb Widow",
    "Treant" => "Parade Treant",
    "Troll" => "Rainbow Troll",
    "Vampire" => "Pride Vampire",
    "Velvet Devil" => "Parade Velvet Devil",
    "Venus Mantrap" => "Rainbow Venus Mantrap",
    "Wardrobe Mimic" => "Flag Wardrobe Mimic",
    "Wight" => "Pride Wight",
    "Wild Dog" => "Parade Wild Dog",
    "Wildcat" => "Rainbow Wildcat",
    "Wolf" => "Pride Wolf",
    "Wraith" => "Glitter Wraith",
    "Zombie" => "Parade Zombie"
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

    # June 25 through July 1 inclusive.
    def window?(now = Time.now)
      start = Time.new(now.year, 6, 25)
      finish = Time.new(now.year, 7, 2)
      now >= start && now < finish
    end

    def ends_at(now = Time.now)
      Time.new(now.year, 7, 2).to_i
    end

    def active?(now = Time.now)
      Engine::Seasons.active?(:pride, now) ||
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

    def glitter_count(player)
      player.tracker(GLITTER_TRACKER)
    end

    def grant_glitter!(player, amount = 1)
      have = glitter_count(player)
      add = [[amount.to_i, 0].max, GLITTER_MAX - have].min
      return 0 if add <= 0

      player.set_tracker!(GLITTER_TRACKER, have + add)
      add
    end

    def eat_glitter!(player)
      have = glitter_count(player)
      return { ok: false, message: 'Your Pride-glitter tin is empty.' } if have <= 0

      player.set_tracker!(GLITTER_TRACKER, have - 1)
      player.bump_tracker!(GLITTER_EATEN)
      case rand(3)
      when 0
        gained = player.heal_defiance!(14)
        { ok: true, message: "Edible foil glitter — **+#{gained} Defiance** " \
                             "(#{glitter_count(player)} left)." }
      when 1
        player.gain_lp!(9)
        { ok: true, message: "A Pride sweet goes filthy — **+9 LP** (now `#{player.lp}`). " \
                             "#{glitter_count(player)} left." }
      else
        before = player.lust
        player.update(lust: [player.lust - 10, 0].max)
        { ok: true, message: "Glitter cools the heat — **−#{before - player.lust} Lust** (now `#{player.lust}`). " \
                             "#{glitter_count(player)} left." }
      end
    end

    def status_consumables(player)
      count = glitter_count(player)
      return [] unless count.positive?

      [{ id: 'pride_glitter', label: 'Pride Glitter', count: count, max: GLITTER_MAX }]
    end

    def biome_weight_mult(biome_key)
      case biome_key.to_s
      when 'flooded_grotto', 'ashen_court', 'masquerade_ball' then 1.55
      when 'verdant_grove', 'honeyed_hive' then 1.15
      else 1.08
      end
    end

    def presence_suffix
      ' — parade rolling; wave carefully.'
    end

    def costume_stock?
      active?
    end

    def pride_altar?
      active?
    end

    def syn_pride_unlocked?(player)
      player.tracker('syn_pride_crumb').positive? || active?
    end

    def mark_syn_crumb!(player)
      player.set_tracker!('syn_pride_crumb', 1)
    end

    def monster_alias(base_name)
      MONSTER_ALIASES[base_name.to_s]
    end

    def chest_bonus!(player)
      return [] unless active?

      lines = []
      added = grant_glitter!(player, rand(1..2))
      if added.positive?
        lines << "Foil **Pride Glitter** tumbles out — stashed for later " \
                 "(**#{glitter_count(player)}/#{GLITTER_MAX}** in your tin)."
      end
      if rand < 0.22
        Engine::Residents.sync_vex_outfits!
        piece = COSTUMES.reject { |s| (item = ::Equipment.first(name: s[:name])) && player.owns_equipment?(item.id) }.sample
        if piece && (item = ::Equipment.first(name: piece[:name]))
          grant = player.grant_equipment!(item, auto_equip: false)
          if grant[:ok]
            lines << "A Pride Parade piece: **#{item.name}** — _#{item.description}_ " \
                     '(keeps forever; equip from `e,equipment` / reclaim free at Vex).'
          end
        end
      end
      lines
    end

    Engine::Seasons.register!(KEY, self)
  end
end
