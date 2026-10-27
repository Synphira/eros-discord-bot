# frozen_string_literal: true

require_relative 'seasons'

module Engine
  # June 20–22. Solstice, sun, fae, fairy rings — rewards keep forever.
  module Midsummer
    KEY = 'midsummer'
    HONEY_TRACKER = 'midsummer_honey'
    HONEY_EATEN = 'midsummer_honey_eaten'
    HONEY_MAX = 12
    SUBMIT_TRACKER = 'midsummer_submits'
    RING_OPTION = 'fairy_rings'

    WEEKLY = {
      key: KEY,
      name: 'Longest Day',
      description: 'The temple holds the sun: plants and demons throng, lust runs warmer (×1.12), ' \
                   '+2 LP submitting to plants / +2 to demons, events 20% more often. Every hallway pest wears a ' \
                   'Midsummer name. Sun honey and Vex\'s golden-hour rack stay after the solstice. Syn buckles a ' \
                   'sunburst collar on her pupper. Ask her about Longest Day while it lasts.',
      effects: {
        'lust_mult' => 1.12,
        'plant_submit_lp' => 2,
        'demon_submit_lp' => 2,
        'satisfy_bonus' => 0.04
      },
      monsters: { plant: 2.0, demon: 1.6, slime: 1.2 },
      special: { 'event_rate' => 1.2, 'elite_chance' => 1.15 }
    }.freeze

    COSTUME_NAMES = [
      'Sun Halo',
      'Honey-Gold Bodice',
      'Glow-Silk Stockings'
    ].freeze

    COSTUMES = [
      { name: 'Sun Halo', slot: 'head', type: 'armor', cost: 55, tier: :midsummer,
        description: 'A thin gold circlet that catches every lamp. You look like you came to be worshipped — and kept.',
        stat_modifiers: { 'appearance' => 9, 'satisfy_bonus' => 0.03, 'submit_lp_bonus' => 1 } },
      { name: 'Honey-Gold Bodice', slot: 'chest', type: 'armor', cost: 95, tier: :midsummer,
        description: 'Sheer gold silk that frames the chest like a fairy ring worth stepping into. Soft midsummer fantasy.',
        stat_modifiers: { 'appearance' => 13, 'lust_mult' => 1.08, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.05 } },
      { name: 'Glow-Silk Stockings', slot: 'legs', type: 'armor', cost: 65, tier: :midsummer,
        description: 'Sheer stockings the colour of late sunlight. Standing still becomes golden hour.',
        stat_modifiers: { 'appearance' => 10, 'agility' => 1, 'submit_lp_bonus' => 1 } }
    ].freeze

    DRESS = {
      'Mimic Broodmother' => 'Sun-dried petals licked crooked onto her lid; a broodling wearing a fairy ring like a ' \
                            'halo. She pretends dusk is optional. The brood already circled you.',
      'Succubus Queen' => 'Honey velvet Midsummer Queen — rings she intends to close at dusk, starting with your ' \
                         'ankles if you stand still too long.',
      'Incubus King' => 'A daisy behind one horn and a myth about holding up the sun. Syn has the light charts. He ' \
                       'has the daisy.',
      'Verdant Dryad' => 'Solstice blooms. She smells like a meadow that decided night was optional and kept dancing ' \
                        'anyway.',
      'Lich Lord' => 'A paper sun in blue fire. Longest light offends him personally. He endures it facing east, on ' \
                    'principle.',
      'Alpha Beast' => 'Syn has buckled a ridiculous sunburst collar onto her pupper for Longest Day. He is delighted. ' \
                      'The rays clink when he shakes. He thinks the sun follows him.',
      'Eros' => 'Late light on wet skin — honey lace, and permission to stay until dawn fails and still want more.',
      'Syn' => 'Gold-dust at her lashes, chalk marks for fairy rings on the stone, and the calm of someone who ' \
              'scheduled the longest day personally.',
      'Berry' => 'Jars of sun honey glowing on the shelves, fairy lights she denies installing, and a soft "stay for ' \
                'dusk" that is not a suggestion.',
      'Covar' => 'A jar of sun honey he will only open for the right customer. He practices the angle of the pour when ' \
                'alone. It is a craft.',
      'Madame Vex' => 'Golden-hour silk that looks wet with light, halos that sit like crowns, and fittings timed ' \
                     'to the sun\'s slide. Couture dusk.',
      'Pip' => 'Sunburst askew, chalk on her fingers from "mapping" rings, pants somewhere in spring. She wants to ' \
              'know if a fairy ring can be sprung like a trap. Of course she does.',
      'Sister Nectar' => 'Honey on the brass, gold cloth on the bench, fairy-ring chalk at the shrine threshold. Stay ' \
                        'until dusk. Leave drained. The longest day has enough time for both.',
      'Fang' => 'Dream-maps painted with late light. Fairy rings marked where the stone will forget itself. He sells ' \
               'the circle. He does not step in. Smart boy.'
    }.freeze

    CLERGY_LINES = {
      'Mimic Broodmother' => {
        victory: 'The Broodmother\'s lid clacks under petals. "Circle," she croons. "My brood closed the ring first."',
        praise: 'Little mimics bounce with sun-dust. One offers you a sticky sweet from its mouth.'
      },
      'Succubus Queen' => {
        victory: 'The Queen lifts a daisy. "Solstice etiquette," she purrs. "Step in. Then kneel."',
        praise: '"Good rings stay closed," she says, and takes her thanks from your mouth.'
      },
      'Incubus King' => {
        victory: 'Daisy askew. "I held the sun," the King lies brightly. "You\'re the dusk."',
        praise: 'He tips sun honey you did not ask for against your lips and watches you swallow.'
      },
      'Verdant Dryad' => {
        victory: 'Blooms brush your cheek. "The meadow keeps what circles," she murmurs.',
        praise: 'She tucks a daisy behind your ear. It smells like honey and sap.'
      },
      'Lich Lord' => {
        victory: 'The paper sun tips. "Light is a binding," the Lich notes. "You accepted the longest hour."',
        praise: 'He stamps a cold sigil that looks, briefly, like a fairy ring around your remaining dignity.'
      },
      'Alpha Beast' => {
        victory: 'Syn\'s pupper shakes his sunburst collar proudly. The rays lean toward him of their own accord.',
        praise: 'He drops a mouthful of foil Sun Honey sweets on your chest and looks enormously proud.'
      },
      'Eros' => {
        victory: 'The goddess tastes of honey and grace. "I let them keep one weekend," Eros says. "They behave better circled."',
        praise: 'A white tentacle offers you a daisy. Refusing is not among the options.'
      }
    }.freeze

    MIDSUMMER_BLESSING = {
      key: 'midsummer_glow', name: 'Midsummer Glow', floors: 4,
      effects: { 'submit_lp_bonus' => 2, 'appearance' => 4, 'satisfy_bonus' => 0.04 },
      summary: 'Warm, honey-sweet, and faintly gold — the temple likes a delver who stays in the ring'
    }.freeze

    MONSTER_ALIASES = {
      'Alraune' => 'Solstice Alraune',
      'Amber Slime' => 'Sun-Honey Amber Slime',
      'Balloon Mistress' => 'Fairy-Ring Balloon Mistress',
      'Banshee' => 'Twilight Banshee',
      'Basilisk' => 'Solstice Basilisk',
      'Bath Mimic' => 'Honey-Jar Bath Mimic',
      'Bear' => 'Meadow Bear',
      'Bed Mimic' => 'Golden-Hour Bed Mimic',
      'Big-Shoe Brute' => 'Parade Big-Shoe Brute',
      'Black Orchid' => 'Solstice Black Orchid',
      'Blood Rose' => 'Midsummer Blood Rose',
      'Bone Dancer' => 'Dawn Bone Dancer',
      'Book Mimic' => 'Daisy Book Mimic',
      'Broodmother' => 'Midsummer Broodmother',
      'Bubble Slime' => 'Glow Bubble Slime',
      'Cambion' => 'Fae-Queen Cambion',
      'Carnal Fiend' => 'Solstice-King Carnal Fiend',
      'Carnival Clown' => 'Daisy Carnival Clown',
      'Centaur' => 'Meadow Centaur',
      'Chain Devil' => 'Sunburst Chain Devil',
      'Chair Mimic' => 'Garland Chair Mimic',
      'Champagne Slime' => 'Sun-Honey Champagne Slime',
      'Chandelier Mimic' => 'Solstice Chandelier Mimic',
      'Chest Mimic' => 'Fairy-Ring Chest Mimic',
      'Clock Mimic' => 'Longest-Day Clock Mimic',
      'Clothing Mimic' => 'Golden-Hour Clothing Mimic',
      'Corpse Flower' => 'Sunlit Corpse Flower',
      'Cotton-Candy Imp' => 'Honey Cotton-Candy Imp',
      'Couch Mimic' => 'Daisy Couch Mimic',
      'Cream Slime' => 'Glow Cream Slime',
      'Crypt Keeper' => 'Twilight Crypt Keeper',
      'Crystal Slime' => 'Sunburst Crystal Slime',
      'Curtain Mimic' => 'Golden Curtain Mimic',
      'Demoness' => 'Midsummer Demoness',
      'Djinn' => 'Solstice Djinn',
      'Door Mimic' => 'Fairy-Ring Door Mimic',
      'Dragon' => 'Sunburst Dragon',
      'Dream Eater' => 'Fae-Queen Dream Eater',
      'Dryad' => 'Solstice Dryad',
      'Dullahan' => 'Twilight Dullahan',
      'Ember Fiend' => 'Solstice-King Ember Fiend',
      'Fae Trickster' => 'Midsummer Fae Trickster',
      'Foam Slime' => 'Sun-Honey Foam Slime',
      'Gargoyle' => 'Solstice Gargoyle',
      'Gelatinous Mass' => 'Glow Gelatinous Mass',
      'Ghost' => 'Golden-Hour Ghost',
      'Ghoul' => 'Twilight Ghoul',
      'Giant Bee' => 'Sun-Honey Giant Bee',
      'Giant Moth' => 'Midsummer Giant Moth',
      'Giant Spider' => 'Fairy-Ring Giant Spider',
      'Glow Slime' => 'Solstice Glow Slime',
      'Goblin' => 'Meadow Goblin',
      'Gorgon Matron' => 'Solstice Gorgon Matron',
      'Green Slime' => 'Daisy Green Slime',
      'Harpy' => 'Sunburst Harpy',
      'Headless Knight' => 'Dawn Headless Knight',
      'Hellhound' => 'Midsummer Hellhound',
      'Honey Slime' => 'Sun-Honey Slime',
      'Honker' => 'Meadow Honker',
      'HuCow' => 'Golden-Hour HuCow',
      'Ifrit' => 'Solstice Ifrit',
      'Imp' => 'Fae Imp',
      'Incubus' => 'Solstice King Incubus',
      'Item Pile Mimic' => 'Fairy-Ring Item Pile Mimic',
      'Jelly Cube' => 'Sun-Honey Jelly Cube',
      'Jellyfish' => 'Glow Jellyfish',
      'Jester' => 'Daisy Jester',
      'Jiangshi' => 'Midsummer Jiangshi',
      'Kitsune' => 'Solstice Kitsune',
      'Lamia' => 'Meadow Lamia',
      'Lich' => 'Dawn Lich',
      'Living Ivy' => 'Sunlit Living Ivy',
      'Loom Mimic' => 'Golden-Hour Loom Mimic',
      'Man-Eating Flower' => 'Solstice Man-Eating Flower',
      'Mandrake' => 'Fairy-Ring Mandrake',
      'Marionette Mistress' => 'Solstice-King Marionette Mistress',
      'Mercury Slime' => 'Sunburst Mercury Slime',
      'Milk Slime' => 'Honey Milk Slime',
      'Minotaur' => 'Meadow Minotaur',
      'Mirror Mimic' => 'Golden Mirror Mimic',
      'Moonflower' => 'Shortest-Night Moonflower',
      'Mummy' => 'Sunlit Mummy',
      'Mycelian' => 'Fairy-Ring Mycelian',
      'Naga' => 'Solstice Naga',
      'Night Hag' => 'Twilight Night Hag',
      'Nightshade' => 'Shortest-Night Nightshade',
      'Ogre' => 'Meadow Ogre',
      'Oil Slime' => 'Golden Oil Slime',
      'Oni' => 'Midsummer Oni',
      'Orc' => 'Solstice Orc',
      'Pale Bride' => 'Daisy Pale Bride',
      'Piano Mimic' => 'Golden-Hour Piano Mimic',
      'Pie Clown' => 'Honey Pie Clown',
      'Pit Fiend' => 'Solstice Pit Fiend',
      'Pitcher Plant' => 'Sun-Honey Pitcher Plant',
      'Pollen Sprite' => 'Midsummer Pollen Sprite',
      'Poltergeist' => 'Dawn Poltergeist',
      'Pudding Slime' => 'Sun-Honey Pudding Slime',
      'Purple Slime' => 'Glow Purple Slime',
      'Rakshasa' => 'Fae-Queen Rakshasa',
      'Revenant' => 'Twilight Revenant',
      'Ringmaster' => 'Fairy-Ring Ringmaster',
      'Rose Slime' => 'Daisy Rose Slime',
      'Rubber Slime' => 'Glow Rubber Slime',
      'Rug Mimic' => 'Meadow Rug Mimic',
      'Sap Dryad' => 'Solstice Sap Dryad',
      'Satyr' => 'Midsummer Satyr',
      'Silkweaver' => 'Golden Silkweaver',
      'Sin Eater' => 'Solstice-King Sin Eater',
      'Siren' => 'Sunburst Siren',
      'Skeleton' => 'Dawn Skeleton',
      'Specter' => 'Golden-Hour Specter',
      'Statue Mimic' => 'Fairy-Ring Statue Mimic',
      'Stone Golem' => 'Sunlit Stone Golem',
      'Strangler Fig' => 'Solstice Strangler Fig',
      'Succubus' => 'Midsummer Queen Succubus',
      'Sundew' => 'Longest-Day Sundew',
      'Syrup Slime' => 'Sun-Honey Syrup Slime',
      'Tar Slime' => 'Golden Tar Slime',
      'Tentacle Vine' => 'Meadow Tentacle Vine',
      'Thorn Vine' => 'Solstice Thorn Vine',
      'Throne Mimic' => 'Daisy Throne Mimic',
      'Tomb Widow' => 'Twilight Tomb Widow',
      'Treant' => 'Midsummer Treant',
      'Troll' => 'Solstice Troll',
      'Vampire' => 'Shortest-Night Vampire',
      'Velvet Devil' => 'Golden-Hour Velvet Devil',
      'Venus Mantrap' => 'Sunlit Venus Mantrap',
      'Wardrobe Mimic' => 'Fairy-Ring Wardrobe Mimic',
      'Wight' => 'Dawn Wight',
      'Wild Dog' => 'Meadow Wild Dog',
      'Wildcat' => 'Solstice Wildcat',
      'Wolf' => 'Midsummer Wolf',
      'Wraith' => 'Golden-Hour Wraith',
      'Zombie' => 'Sunlit Zombie'
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

    # June 20 through June 22 inclusive.
    def window?(now = Time.now)
      start = Time.new(now.year, 6, 20)
      finish = Time.new(now.year, 6, 23)
      now >= start && now < finish
    end

    def ends_at(now = Time.now)
      Time.new(now.year, 6, 23).to_i
    end

    def active?(now = Time.now)
      Engine::Seasons.active?(:midsummer, now) ||
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

    def honey_count(player)
      player.tracker(HONEY_TRACKER)
    end

    def grant_honey!(player, amount = 1)
      have = honey_count(player)
      add = [[amount.to_i, 0].max, HONEY_MAX - have].min
      return 0 if add <= 0

      player.set_tracker!(HONEY_TRACKER, have + add)
      add
    end

    def eat_honey!(player)
      have = honey_count(player)
      return { ok: false, message: 'Your Sun Honey tin is empty.' } if have <= 0

      player.set_tracker!(HONEY_TRACKER, have - 1)
      player.bump_tracker!(HONEY_EATEN)
      case rand(3)
      when 0
        gained = player.heal_defiance!(14)
        { ok: true, message: "Sun-warm honey — **+#{gained} Defiance** " \
                             "(#{honey_count(player)} left)." }
      when 1
        player.gain_lp!(9)
        { ok: true, message: "A Midsummer sip goes filthy — **+9 LP** (now `#{player.lp}`). " \
                             "#{honey_count(player)} left." }
      else
        before = player.lust
        player.update(lust: [player.lust - 10, 0].max)
        { ok: true, message: "Honey cools the heat — **−#{before - player.lust} Lust** (now `#{player.lust}`). " \
                             "#{honey_count(player)} left." }
      end
    end

    def status_consumables(player)
      count = honey_count(player)
      return [] unless count.positive?

      [{ id: 'midsummer_honey', label: 'Sun Honey', count: count, max: HONEY_MAX }]
    end

    def biome_weight_mult(biome_key)
      case biome_key.to_s
      when 'verdant_grove', 'pollen_gallery', 'honeyed_hive', 'ashen_court' then 1.7
      when 'flooded_grotto' then 0.9
      else 1.08
      end
    end

    def presence_suffix
      ' — longest day; step carefully into the rings.'
    end

    def costume_stock?
      active?
    end

    def midsummer_altar?
      active?
    end

    def syn_midsummer_unlocked?(player)
      player.tracker('syn_midsummer_crumb').positive? || active?
    end

    def mark_syn_crumb!(player)
      player.set_tracker!('syn_midsummer_crumb', 1)
    end

    def monster_alias(base_name)
      MONSTER_ALIASES[base_name.to_s]
    end

    def chest_bonus!(player)
      return [] unless active?

      lines = []
      added = grant_honey!(player, rand(1..2))
      if added.positive?
        lines << "Foil **Sun Honey** tumbles out — stashed for later " \
                 "(**#{honey_count(player)}/#{HONEY_MAX}** in your tin)."
      end
      if rand < 0.22
        Engine::Residents.sync_vex_outfits!
        piece = COSTUMES.reject { |s| (item = ::Equipment.first(name: s[:name])) && player.owns_equipment?(item.id) }.sample
        if piece && (item = ::Equipment.first(name: piece[:name]))
          grant = player.grant_equipment!(item, auto_equip: false)
          if grant[:ok]
            lines << "A Midsummer piece: **#{item.name}** — _#{item.description}_ " \
                     '(keeps forever; equip from `e,equipment` / reclaim free at Vex).'
          end
        end
      end
      lines
    end

    Engine::Seasons.register!(KEY, self)
  end
end
