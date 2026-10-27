# frozen_string_literal: true

require_relative 'seasons'

module Engine
  # Carnival weekend through Fat Tuesday (Sat–Tue). Masks, beads, king cake — rewards keep forever.
  module MardiGras
    KEY = 'mardi_gras'
    CAKE_TRACKER = 'mardi_gras_cake'
    CAKE_EATEN = 'mardi_gras_cake_eaten'
    CAKE_MAX = 12
    SUBMIT_TRACKER = 'mardi_gras_submits'
    PARADE_OPTION = 'parade_filth'

    WEEKLY = {
      key: KEY,
      name: 'Carnival of Beads',
      description: 'The temple throws a parade: clowns and demons throng, lust runs hotter (×1.12), ' \
                   '+2 LP submitting to demons / +2 to clowns, events 25% more often, elites lean in. Every hallway ' \
                   'pest wears a carnival name. King cake and Vex\'s mask rack stay after Fat Tuesday. Syn buckles ' \
                   'a feathered mask on her pupper. Ask her about Carnival while it lasts.',
      effects: {
        'lust_mult' => 1.12,
        'demon_submit_lp' => 2,
        'clown_submit_lp' => 2,
        'satisfy_bonus' => 0.04
      },
      monsters: { demon: 1.6, clown: 2.0, slime: 1.3, mimic: 1.25 },
      special: { 'event_rate' => 1.25, 'elite_chance' => 1.25 }
    }.freeze

    COSTUME_NAMES = [
      'Feathered Domino',
      'Bead-Draped Bodice',
      'Parade Sheer Hose'
    ].freeze

    COSTUMES = [
      { name: 'Feathered Domino', slot: 'head', type: 'armor', cost: 55, tier: :mardi_gras,
        description: 'A half-mask of gilt and plumes. You look like you came to be thrown beads at — and to catch them.',
        stat_modifiers: { 'appearance' => 9, 'satisfy_bonus' => 0.03, 'submit_lp_bonus' => 1 } },
      { name: 'Bead-Draped Bodice', slot: 'chest', type: 'armor', cost: 95, tier: :mardi_gras,
        description: 'Purple-gold-green silk under a cascade of cheap beads that somehow look expensive on you.',
        stat_modifiers: { 'appearance' => 13, 'lust_mult' => 1.08, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.05 } },
      { name: 'Parade Sheer Hose', slot: 'legs', type: 'armor', cost: 65, tier: :mardi_gras,
        description: 'Sheer hose the colour of parade dusk. Standing on a float becomes a pose.',
        stat_modifiers: { 'appearance' => 10, 'agility' => 1, 'submit_lp_bonus' => 1 } }
    ].freeze

    DRESS = {
      'Mimic Broodmother' => 'Stolen beads flung crooked across her lid; one broodling in a feather like a krewe captain. ' \
                            'She pretends she is not leading a parade of teeth.',
      'Succubus Queen' => 'Purple velvet, gilt mask, and the posture of a float that rides you until dawn. Flash is ' \
                         'not optional. It is etiquette.',
      'Incubus King' => 'Feather behind one horn, beads he keeps throwing at himself in mirrors. Syn\'s krewe has better ' \
                       'aim. He does not notice.',
      'Verdant Dryad' => 'Carnival feathers and late roses — a garden that joined the march and brought the smell of ' \
                        'sweat and sugar with it.',
      'Lich Lord' => 'A paper mask crooked over blue fire. He cannot see. He can still judge. He is judging the music.',
      'Alpha Beast' => 'Syn has buckled a ridiculous feathered mask onto her pupper for Carnival. He is delighted. ' \
                      'The plumes bounce. Berry has already rated the look.',
      'Eros' => 'A smile like a thrown bead — purple-gold-green lace, and permission to flash back without shame.',
      'Syn' => 'Glitter at her lashes, krewe colours on her wrists, and the calm of the person who scheduled every ' \
              'unmasking. Fat Tuesday answers to her.',
      'Berry' => 'Purple lipstick, sugar dusted on the counter, beads for sale and for throwing. She shouts for tips ' \
                'in two languages and means both.',
      'Covar' => 'Beads wound around his wrist three times. He will not throw them. He lets customers guess how many ' \
                'he is wearing under the cuff.',
      'Madame Vex' => 'Carnival silk that shifts purple-gold-green as you watch, masks priced like confessions, and ' \
                     'a smile that says flash first, fit later.',
      'Pip' => 'Jester bells, king-cake crumbs on her chin, and a map of which floats have the best traps. Science. ' \
              'Obviously.',
      'Sister Nectar' => 'Purple-gold-green ribbons on the frame, beads hanging from the pumps, and a smile that says ' \
                        'flash is liturgy today. Arrive tense. Leave drained. Leave decorated.',
      'Fang' => 'Maps dusted with glitter he pretends is "dust from the dreaming land." Three float-rooms that do ' \
               'not exist yet. One throws beads. He priced that one higher.'
    }.freeze

    CLERGY_LINES = {
      'Mimic Broodmother' => {
        victory: 'The Broodmother\'s lid clacks under beads. "Show me," she croons. "My brood already threw for you."',
        praise: 'Little mimics bounce with feathers. One offers you a sticky sweet from its mouth.'
      },
      'Succubus Queen' => {
        victory: 'The Queen lifts her gilt mask. "Carnival etiquette," she purrs. "Flash. Then kneel."',
        praise: '"Good revels stay open," she says, and takes her thanks from your mouth.'
      },
      'Incubus King' => {
        victory: 'Feather askew. "I threw these myself," the King lies brightly. "You\'re on the float."',
        praise: 'He tips king-cake sugar you did not ask for against your lips and watches you swallow.'
      },
      'Verdant Dryad' => {
        victory: 'Feathers brush your cheek. "The parade keeps what dances," she murmurs.',
        praise: 'She tucks a plume behind your ear. It smells like sugar and sap.'
      },
      'Lich Lord' => {
        victory: 'The paper mask tips. "Revelry is a binding," the Lich notes. "You accepted the beads."',
        praise: 'He stamps a cold sigil that looks, briefly, like a king cake with your dignity as the baby.'
      },
      'Alpha Beast' => {
        victory: 'Syn\'s pupper shakes his feathered mask proudly. Beads appear from nowhere. Physics shrugged.',
        praise: 'He drops a mouthful of foil king-cake bites on your chest and looks enormously proud.'
      },
      'Eros' => {
        victory: 'The goddess tastes of sugar and grace. "I let them parade one weekend," Eros says. "They behave better masked."',
        praise: 'A white tentacle offers you beads. Refusing is not among the options.'
      }
    }.freeze

    CARNIVAL_BLESSING = {
      key: 'carnival_glow', name: 'Carnival Glow', floors: 4,
      effects: { 'submit_lp_bonus' => 2, 'appearance' => 4, 'satisfy_bonus' => 0.04 },
      summary: 'Warm, glitter-slick, and faintly gold — the temple likes a mask that stays on'
    }.freeze

  MONSTER_ALIASES = {
    "Alraune" => "Feathered Alraune",
    "Amber Slime" => "King-Cake Amber Slime",
    "Balloon Mistress" => "Rex Balloon Mistress",
    "Banshee" => "Parade Banshee",
    "Basilisk" => "Bead-Draped Basilisk",
    "Bath Mimic" => "Float Bath Mimic",
    "Bear" => "Parade Bear",
    "Bed Mimic" => "King-Cake Bed Mimic",
    "Big-Shoe Brute" => "Krewe Big-Shoe Brute",
    "Black Orchid" => "Feathered Black Orchid",
    "Blood Rose" => "Parade Blood Rose",
    "Bone Dancer" => "Ghost Bone Dancer",
    "Book Mimic" => "Bead Book Mimic",
    "Broodmother" => "Masked Broodmother",
    "Bubble Slime" => "Purple-Gold Bubble Slime",
    "Cambion" => "Masked Cambion",
    "Carnal Fiend" => "Bead Carnal Fiend",
    "Carnival Clown" => "Rex Carnival Clown",
    "Centaur" => "Feathered Centaur",
    "Chain Devil" => "Parade Chain Devil",
    "Chair Mimic" => "Masked Chair Mimic",
    "Champagne Slime" => "Absinthe Champagne Slime",
    "Chandelier Mimic" => "Parade Chandelier Mimic",
    "Chest Mimic" => "King-Cake Chest Mimic",
    "Clock Mimic" => "Float Clock Mimic",
    "Clothing Mimic" => "King-Cake Clothing Mimic",
    "Corpse Flower" => "Float Corpse Flower",
    "Cotton-Candy Imp" => "Float Cotton-Candy Imp",
    "Couch Mimic" => "Bead Couch Mimic",
    "Cream Slime" => "Bead Cream Slime",
    "Crypt Keeper" => "Masked Crypt Keeper",
    "Crystal Slime" => "Sugar Crystal Slime",
    "Curtain Mimic" => "Masked Curtain Mimic",
    "Demoness" => "Carnival Demoness",
    "Djinn" => "Jazz Djinn",
    "Door Mimic" => "Parade Door Mimic",
    "Dragon" => "Float Dragon",
    "Dream Eater" => "Masked Dream Eater",
    "Dryad" => "Carnival Dryad",
    "Dullahan" => "Jazz-Funeral Dullahan",
    "Ember Fiend" => "Bead Ember Fiend",
    "Fae Trickster" => "Parade Fae Trickster",
    "Foam Slime" => "King-Cake Foam Slime",
    "Gargoyle" => "Bead-Draped Gargoyle",
    "Gelatinous Mass" => "Purple-Gold Gelatinous Mass",
    "Ghost" => "Carnival Ghost",
    "Ghoul" => "Parade Ghoul",
    "Giant Bee" => "Parade Giant Bee",
    "Giant Moth" => "Masked Giant Moth",
    "Giant Spider" => "Feathered Giant Spider",
    "Glow Slime" => "Absinthe Glow Slime",
    "Goblin" => "Float Goblin",
    "Gorgon Matron" => "Bead-Draped Gorgon Matron",
    "Green Slime" => "Bead Green Slime",
    "Harpy" => "Parade Harpy",
    "Headless Knight" => "Ghost Headless Knight",
    "Hellhound" => "Carnival Hellhound",
    "Honey Slime" => "Sugar Honey Slime",
    "Honker" => "Parade Honker",
    "HuCow" => "Parade HuCow",
    "Ifrit" => "Jazz Ifrit",
    "Imp" => "Masked Imp",
    "Incubus" => "Parade Incubus",
    "Item Pile Mimic" => "Float Item Pile Mimic",
    "Jelly Cube" => "King-Cake Jelly Cube",
    "Jellyfish" => "Purple-Gold Jellyfish",
    "Jester" => "Bead Jester",
    "Jiangshi" => "Masked Jiangshi",
    "Kitsune" => "Masked Kitsune",
    "Lamia" => "Feathered Lamia",
    "Lich" => "Jazz-Funeral Lich",
    "Living Ivy" => "Garland Living Ivy",
    "Loom Mimic" => "King-Cake Loom Mimic",
    "Man-Eating Flower" => "Carnival Man-Eating Flower",
    "Mandrake" => "Feathered Mandrake",
    "Marionette Mistress" => "Bead Marionette Mistress",
    "Mercury Slime" => "Absinthe Mercury Slime",
    "Milk Slime" => "Bead Milk Slime",
    "Minotaur" => "Float Minotaur",
    "Mirror Mimic" => "Bead Mirror Mimic",
    "Moonflower" => "Parade Moonflower",
    "Mummy" => "Carnival Mummy",
    "Mycelian" => "Float Mycelian",
    "Naga" => "Bead-Draped Naga",
    "Night Hag" => "Parade Night Hag",
    "Nightshade" => "Garland Nightshade",
    "Ogre" => "Parade Ogre",
    "Oil Slime" => "Sugar Oil Slime",
    "Oni" => "Carnival Oni",
    "Orc" => "Masked Orc",
    "Pale Bride" => "Parade Pale Bride",
    "Piano Mimic" => "Masked Piano Mimic",
    "Pie Clown" => "King-Cake Pie Clown",
    "Pit Fiend" => "Jazz Pit Fiend",
    "Pitcher Plant" => "Carnival Pitcher Plant",
    "Pollen Sprite" => "Feathered Pollen Sprite",
    "Poltergeist" => "Ghost Poltergeist",
    "Pudding Slime" => "King-Cake Pudding Slime",
    "Purple Slime" => "Purple-Gold Purple Slime",
    "Rakshasa" => "Masked Rakshasa",
    "Revenant" => "Masked Revenant",
    "Ringmaster" => "Rex Ringmaster",
    "Rose Slime" => "Absinthe Rose Slime",
    "Rubber Slime" => "Bead Rubber Slime",
    "Rug Mimic" => "Parade Rug Mimic",
    "Sap Dryad" => "Parade Sap Dryad",
    "Satyr" => "Feathered Satyr",
    "Silkweaver" => "Float Silkweaver",
    "Sin Eater" => "Bead Sin Eater",
    "Siren" => "Parade Siren",
    "Skeleton" => "Jazz-Funeral Skeleton",
    "Specter" => "Carnival Specter",
    "Statue Mimic" => "Float Statue Mimic",
    "Stone Golem" => "King-Cake Stone Golem",
    "Strangler Fig" => "Float Strangler Fig",
    "Succubus" => "Masked Succubus",
    "Sundew" => "Garland Sundew",
    "Syrup Slime" => "Sugar Syrup Slime",
    "Tar Slime" => "King-Cake Tar Slime",
    "Tentacle Vine" => "Carnival Tentacle Vine",
    "Thorn Vine" => "Feathered Thorn Vine",
    "Throne Mimic" => "Bead Throne Mimic",
    "Tomb Widow" => "Parade Tomb Widow",
    "Treant" => "Parade Treant",
    "Troll" => "Bead-Draped Troll",
    "Vampire" => "Ghost Vampire",
    "Velvet Devil" => "Carnival Velvet Devil",
    "Venus Mantrap" => "Float Venus Mantrap",
    "Wardrobe Mimic" => "Masked Wardrobe Mimic",
    "Wight" => "Masked Wight",
    "Wild Dog" => "Parade Wild Dog",
    "Wildcat" => "Masked Wildcat",
    "Wolf" => "Bead-Draped Wolf",
    "Wraith" => "Jazz-Funeral Wraith",
    "Zombie" => "Carnival Zombie"
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

    # Saturday through Fat Tuesday (ends Wednesday 00:00).
    def window?(now = Time.now)
      fat = Engine::Seasons.fat_tuesday(now.year)
      # fat_tuesday returns a Time at Easter-47d; normalize to local midnight of that calendar day.
      fat_day = Time.new(fat.year, fat.month, fat.day)
      start = fat_day - (3 * 24 * 3600)
      finish = fat_day + (24 * 3600)
      now >= start && now < finish
    end

    def ends_at(now = Time.now)
      fat = Engine::Seasons.fat_tuesday(now.year)
      fat_day = Time.new(fat.year, fat.month, fat.day)
      (fat_day + (24 * 3600)).to_i
    end

    def active?(now = Time.now)
      Engine::Seasons.active?(:mardi_gras, now) ||
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

    def cake_count(player)
      player.tracker(CAKE_TRACKER)
    end

    def grant_cake!(player, amount = 1)
      have = cake_count(player)
      add = [[amount.to_i, 0].max, CAKE_MAX - have].min
      return 0 if add <= 0

      player.set_tracker!(CAKE_TRACKER, have + add)
      add
    end

    def eat_cake!(player)
      have = cake_count(player)
      return { ok: false, message: 'Your king-cake tin is empty.' } if have <= 0

      player.set_tracker!(CAKE_TRACKER, have - 1)
      player.bump_tracker!(CAKE_EATEN)
      case rand(3)
      when 0
        gained = player.heal_defiance!(14)
        { ok: true, message: "Sugar and spice — **+#{gained} Defiance** " \
                             "(#{cake_count(player)} cake left)." }
      when 1
        player.gain_lp!(9)
        { ok: true, message: "A king-cake bite goes filthy — **+9 LP** (now `#{player.lp}`). " \
                             "#{cake_count(player)} cake left." }
      else
        before = player.lust
        player.update(lust: [player.lust - 10, 0].max)
        { ok: true, message: "Sweetness settles the heat — **−#{before - player.lust} Lust** (now `#{player.lust}`). " \
                             "#{cake_count(player)} cake left." }
      end
    end

    def status_consumables(player)
      count = cake_count(player)
      return [] unless count.positive?

      [{ id: 'mardi_gras_cake', label: 'King Cake', count: count, max: CAKE_MAX }]
    end

    def biome_weight_mult(biome_key)
      case biome_key.to_s
      when 'masquerade_ball', 'ashen_court' then 1.6
      when 'flooded_grotto' then 1.2
      else 1.08
      end
    end

    def presence_suffix
      ' — carnival running; flash carefully.'
    end

    def costume_stock?
      active?
    end

    def carnival_altar?
      active?
    end

    def syn_carnival_unlocked?(player)
      player.tracker('syn_mardi_gras_crumb').positive? || active?
    end

    def mark_syn_crumb!(player)
      player.set_tracker!('syn_mardi_gras_crumb', 1)
    end

    def monster_alias(base_name)
      MONSTER_ALIASES[base_name.to_s]
    end

    def chest_bonus!(player)
      return [] unless active?

      lines = []
      added = grant_cake!(player, rand(1..2))
      if added.positive?
        lines << "Foil **King Cake** tumbles out — stashed for later " \
                 "(**#{cake_count(player)}/#{CAKE_MAX}** in your tin)."
      end
      if rand < 0.22
        Engine::Residents.sync_vex_outfits!
        piece = COSTUMES.reject { |s| (item = ::Equipment.first(name: s[:name])) && player.owns_equipment?(item.id) }.sample
        if piece && (item = ::Equipment.first(name: piece[:name]))
          grant = player.grant_equipment!(item, auto_equip: false)
          if grant[:ok]
            lines << "A Carnival piece: **#{item.name}** — _#{item.description}_ " \
                     '(keeps forever; equip from `e,equipment` / reclaim free at Vex).'
          end
        end
      end
      lines
    end

    Engine::Seasons.register!(KEY, self)
  end
end
