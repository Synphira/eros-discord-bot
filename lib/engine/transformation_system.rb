# frozen_string_literal: true

module Engine
  module TransformationSystem
    PETKIN = {
      requirement: { petplay_events: 5, beast_submissions: 10 }
    }.freeze

    TRANSFORMATIONS = {
      'kitten' => PETKIN.merge(
        name: 'Kitten', group: 'Beast',
        description: "You've developed feline features — soft ears, a swishing tail, and heightened senses",
        appearance: ['cat ears', 'flexible spine', 'retractable claws', 'cat tail'],
        buff: 'Feline Agility', buff_description: '+20% dodge chance, +10% seduction chance',
        effects: { 'dodge_bonus' => 0.2, 'satisfy_bonus' => 0.1 }
      ),
      'puppy' => PETKIN.merge(
        name: 'Puppy', group: 'Beast',
        description: "You've developed canine features — floppy ears, a wagging tail, and an eager-to-please heart",
        appearance: ['floppy ears', 'wagging tail', 'keen nose', 'padded palms'],
        buff: 'Canine Loyalty', buff_description: 'Take 25% less lust damage, +15% LP gain from submission',
        effects: { 'damage_reduction' => 0.75, 'submit_lp_mult' => 1.15 }
      ),
      'hucow' => {
        name: 'HuCow', group: 'Beast',
        description: "You've developed bovine features — heavy, leaking breasts and a docile, milkable body",
        requirement: { being_milked_events: 3, lactation_events: 3, weight_gain_events: 3 },
        appearance: ['multiple breasts', 'udder', 'small horns', 'cow tail'],
        events: { 'lactation' => 35, 'weight_gain' => 25 },
        buff: 'Bovine Endurance', buff_description: 'Take 30% less lust damage, +20% LP from being milked',
        effects: { 'damage_reduction' => 0.7, 'lactation_event_lp_mult' => 1.2 }
      },
      'harpy' => {
        name: 'Harpy', group: 'Beast',
        description: "You've developed avian features including wings and clawed feet",
        requirement: { petplay_events: 5, body_growth_events: 3, exhibitionism_events: 3 },
        appearance: ['feathered arms/wings', 'clawed feet', 'lighter bones'],
        buff: 'Avian Grace', buff_description: '+25% dodge chance, +15% flee chance',
        effects: { 'dodge_bonus' => 0.25, 'flee_bonus' => 0.15 },
        special_event: 'Wing Display',
        special_event_description: 'Sometimes your wings unfurl dramatically, and the monster forgets to attack',
        special: { kind: :stun, chance: 0.12,
                   text: 'Your wings unfurl in a dramatic display — the %<name>s stares, transfixed, and forgets to attack!' }
      },
      'slimekin' => {
        name: 'Slimekin', group: 'Beast',
        description: 'Your body has become partially gelatinous and amorphous',
        requirement: { slime_submissions: 10, inflation_events: 3 },
        appearance: ['semi-translucent skin', 'amorphous limbs', 'no fixed shape'],
        buff: 'Amorphous Form', buff_description: 'Take 20% less lust damage, can squeeze through small openings',
        effects: { 'damage_reduction' => 0.8 },
        special_event: 'Absorption',
        special_event_description: "When struck, you sometimes partially absorb the attacker and regain defiance",
        special: { kind: :absorb, chance: 0.2,
                   text: 'Your gelatinous body swallows part of the %<name>s as it grabs you — you absorb **%<amount>s** defiance!' }
      },
      'succubus' => {
        name: 'Succubus', group: 'Demon',
        description: "You've transformed into a creature of seduction and dreams",
        requirement: { demon_submissions: 15, futanari_events: 3 },
        appearance: ['small wings', 'small horns', 'supernatural beauty', 'tail'],
        buff: 'Seductive Power', buff_description: '+30% seduction chance, +10 LP from sexual acts',
        effects: { 'satisfy_bonus' => 0.3, 'submit_lp_bonus' => 10 },
        special_event: 'Dream Walking',
        special_event_description: "Sometimes you slip into the monster's dreams, gaining LP without being touched",
        special: { kind: :dream, chance: 0.15,
                   text: "You slip into the %<name>s's waking dreams and feed on its fantasies — **+%<amount>s LP**." }
      },
      'incubus' => {
        name: 'Incubus', group: 'Demon',
        description: "You've transformed into a creature of seduction and desire",
        requirement: { demon_submissions: 15, futanari_events: 3 },
        appearance: ['supernatural charm', 'small wings', 'small horns'],
        buff: 'Incubus Charm', buff_description: '+30% seduction chance, +10 LP from sexual acts',
        effects: { 'satisfy_bonus' => 0.3, 'submit_lp_bonus' => 10 },
        special_event: 'Shadow Form',
        special_event_description: 'Sometimes you melt into shadow and the monster loses you entirely',
        special: { kind: :stun, chance: 0.12,
                   text: 'You melt into shadow — the %<name>s lunges at nothing and loses its turn!' }
      },
      'imp' => {
        name: 'Imp', group: 'Demon',
        description: "You've transformed into a small, mischievous lesser demon",
        requirement: { demon_submissions: 10, body_reduction_events: 3, mind_control_events: 3 },
        appearance: ['small stature', 'wings', 'horns', 'tail'],
        buff: 'Impish Agility', buff_description: '+20% dodge chance, +15% surprise attack chance (double damage)',
        effects: { 'dodge_bonus' => 0.2, 'crit_chance' => 0.15 },
        special_event: 'Prank',
        special_event_description: 'Sometimes you play a prank on the monster, stunning it',
        special: { kind: :stun, chance: 0.12,
                   text: 'You pull a wicked prank on the %<name>s — it reels, stunned, and loses its turn!' }
      },
      'dryad' => {
        name: 'Dryad', group: 'Plant',
        description: "You've become one with the plant life of the tower",
        requirement: { plant_submissions: 10, objectification_events: 3 },
        appearance: ['bark skin', 'leaves in hair', 'root-like feet'],
        buff: 'Plant Resilience', buff_description: 'Take 25% less lust damage, heal 5 defiance at the start of each fight',
        effects: { 'damage_reduction' => 0.75, 'combat_start_regen' => 5 },
        special_event: 'Root Network',
        special_event_description: "Sometimes the tower's roots warn you about a foe, lowering its AGI for the fight",
        special: { kind: :insight, chance: 0.3,
                   text: "The tower's roots whisper the %<name>s's every move to you — its AGI drops by **%<amount>s** this fight." }
      },
      'alraune' => {
        name: 'Alraune', group: 'Plant',
        description: "You've become a predatory plant creature focused on luring prey",
        requirement: { plant_submissions: 10, futanari_events: 3, mind_control_events: 3 },
        appearance: ['petal-like skin', 'sweet scent', 'vine hair'],
        buff: 'Luring Scent', buff_description: '+25% seduction chance, +15% trap avoidance',
        effects: { 'satisfy_bonus' => 0.25, 'trap_avoid_bonus' => 0.15 },
        special_event: 'Digestive Trap',
        special_event_description: 'Sometimes your vines snare the monster, weakening it for the rest of the fight',
        special: { kind: :weaken, chance: 0.15,
                   text: 'Sticky vines snare the %<name>s and sap its strength — its attacks weaken!' }
      },
      'living_doll' => {
        name: 'Living Doll', group: 'Object',
        description: "You've become more object than person, with porcelain skin and jointed limbs",
        requirement: { objectification_events: 5, petplay_events: 3, mind_control_events: 3 },
        appearance: ['porcelain skin', 'jointed limbs', 'glass eyes'],
        buff: "Doll's Stillness", buff_description: 'Take 20% less lust damage, can feign death',
        effects: { 'damage_reduction' => 0.8 },
        special_event: 'Toy Box',
        special_event_description: 'Sometimes you go perfectly still as a toy, and the monster loses interest for a turn',
        special: { kind: :stun, chance: 0.12,
                   text: 'You freeze into a lifeless doll — the %<name>s pokes you, confused, then startles when you move again!' }
      },
      'furniture' => {
        name: 'Furniture', group: 'Object',
        description: "You've lost your humanity, becoming literally functional furniture",
        requirement: { objectification_events: 10, slavery_events: 5, bondage_events: 3 },
        appearance: ['wood-like skin', 'functional shape'],
        events: { 'objectification' => 40, 'slavery' => 30, 'bondage' => 25 },
        buff: 'Functional Form', buff_description: 'Take 30% less lust damage, can feign death perfectly',
        effects: { 'damage_reduction' => 0.7 },
        special_event: 'Furniture Surprise',
        special_event_description: 'Sometimes you trap the monster inside your furniture form, stopping its attack',
        special: { kind: :stun, chance: 0.12,
                   text: 'The %<name>s sits on you without thinking — and you clamp shut around it, trapping it for a turn!' }
      },
      'vampire' => {
        name: 'Vampire', group: 'Supernatural',
        description: "You've become a creature of the night — a thrall-maker with undead hunger",
        requirement: { undead_submissions: 15, mind_control_events: 3, slavery_events: 3 },
        appearance: ['pale skin', 'fangs', 'red eyes'],
        buff: 'Vampiric Charm', buff_description: '+25% seduction chance, heal 25% of the damage you deal',
        effects: { 'satisfy_bonus' => 0.25, 'lifesteal' => 0.25 },
        special_event: 'Thrall Making',
        special_event_description: 'Sometimes you briefly enthrall the monster and it attacks itself',
        special: { kind: :thrall, chance: 0.12,
                   text: 'Your red eyes catch the %<name>s — enthralled, it turns on itself for **%<amount>s** damage!' }
      },
      'ghost' => {
        name: 'Ghost', group: 'Supernatural',
        description: "You've become ethereal, partially intangible",
        requirement: { undead_submissions: 10, sensory_deprivation_events: 3, bondage_events: 3 },
        appearance: ['translucent body', 'floats', 'cold touch'],
        buff: 'Ethereal Form', buff_description: '+20% dodge chance, can pass through solid objects briefly',
        effects: { 'dodge_bonus' => 0.2 },
        special_event: 'Haunting',
        special_event_description: 'Sometimes you phase through the monster, draining it as you pass',
        special: { kind: :drain, chance: 0.15,
                   text: 'You phase straight through the %<name>s, draining **%<amount>s** HP and drinking it in as defiance!' }
      },
      'latexdoll' => {
        name: 'Latexdoll', group: 'Synthetic',
        description: 'Your skin has become shiny and synthetic, erasing your human features',
        requirement: { latex_events: 10, mind_control_events: 3 },
        appearance: ['rubber skin', 'featureless face', 'seamless body'],
        buff: 'Synthetic Skin', buff_description: 'Take 25% less lust damage, immune to corrosion (half lust damage from slimes)',
        effects: { 'damage_reduction' => 0.75, 'slime_lust_mult' => 0.5 },
        special_event: 'Living Latex',
        special_event_description: 'Sometimes your skin wraps around the monster, restraining it for a turn',
        special: { kind: :stun, chance: 0.12,
                   text: 'Your glossy skin flows over the %<name>s and squeezes tight — it is restrained and loses its turn!' }
      },
      'rubberslime' => {
        name: 'Rubberslime', group: 'Synthetic',
        description: "You've become a hybrid of slime and rubber properties",
        requirement: { latex_events: 7, inflation_events: 3, slime_submissions: 7 },
        appearance: ['shiny translucent skin', 'amorphous shape'],
        buff: 'Elastic Form', buff_description: 'Take 20% less lust damage, can stretch limbs',
        effects: { 'damage_reduction' => 0.8 },
        special_event: 'Encase',
        special_event_description: 'Sometimes you encase the monster in your rubbery body, crushing it',
        special: { kind: :crush, chance: 0.12,
                   text: 'You stretch over the %<name>s and encase it in rubber, squeezing for **%<amount>s** damage!' }
      },
      'angel' => {
        name: 'Angel', group: 'Holy',
        description: 'Your untouched purity has lifted you above the ruins — monsters shy from your light',
        requirement: { pure_title: true },
        appearance: ['feathered wings', 'soft halo', 'radiant skin'],
        monster_rate: 0.7,
        event_rate: 1.35,
        buff: 'Divine Presence', buff_description: 'Take 20% less lust damage, +15% chance to intimidate monsters',
        effects: { 'damage_reduction' => 0.8, 'intimidate_chance' => 0.15 },
        special_event: 'Divine Intervention',
        special_event_description: 'When your defiance runs low, your light sometimes flares, driving the monster back and restoring you',
        special: { kind: :divine, chance: 0.35,
                   text: 'Your halo erupts in blinding light! The %<name>s recoils, and you recover **%<amount>s** defiance as your lust cools.' }
      },
      'eldritch_bride' => {
        name: 'Eldritch Bride', group: 'Eldritch',
        description: "The deep places of the tower have claimed you as theirs — and something in the dark keeps answering",
        requirement: { tentacle_events: 8, possession_events: 3 },
        appearance: ['tentacle hair', 'suckered fingertips', 'star-flecked eyes', 'a whispering second shadow'],
        events: { 'tentacles' => 35 },
        buff: 'Beloved of the Deep', buff_description: '+20% seduction chance, take 15% less lust damage — and Eros looks at you differently',
        effects: { 'satisfy_bonus' => 0.2, 'damage_reduction' => 0.85 },
        special_event: 'Grasping Devotion',
        special_event_description: 'Sometimes your tentacle hair lashes out on its own, weakening the monster for the rest of the fight',
        special: { kind: :weaken, chance: 0.15,
                   text: 'Your tentacle hair lashes around the %<name>s and squeezes — its strength ebbs as it struggles!' }
      },
      'weaver' => {
        name: 'Weaver', group: 'Arachnid',
        description: "Silk glands and eight knowing eyes — the tower's traps have started checking for *you*",
        requirement: { bondage_events: 8, objectification_events: 3 },
        appearance: ['silk spinnerets', 'eight dark eyes', 'chitin-kissed forearms', 'thread always on your fingertips'],
        buff: 'Silk and Patience', buff_description: '+20% trap avoidance, +10% dodge chance',
        effects: { 'trap_avoid_bonus' => 0.2, 'dodge_bonus' => 0.1 },
        special_event: 'Silk Snare',
        special_event_description: 'Sometimes you web the monster mid-lunge, costing it a turn',
        special: { kind: :stun, chance: 0.14,
                   text: 'Silk sprays from your fingertips and webs the %<name>s mid-lunge — it loses its turn tearing free!' }
      },
      'lamia' => {
        name: 'Lamia', group: 'Beast',
        description: 'Below the waist you are all serpent — long, scaled, and made for coiling around problems',
        requirement: { mind_control_events: 5, size_events: 3 },
        appearance: ['long serpent tail', 'scaled hips', 'forked tongue', 'heat-sensing gaze'],
        buff: 'Constrictor', buff_description: '+20% seduction chance, +1 submission',
        effects: { 'satisfy_bonus' => 0.2, 'submission' => 1 },
        special_event: 'Coils',
        special_event_description: 'Sometimes your tail crushes the fight out of the monster',
        special: { kind: :crush, chance: 0.13,
                   text: 'Your great tail coils around the %<name>s and squeezes for **%<amount>s** damage — it goes limp and pliant!' }
      },
      'kitsune' => {
        name: 'Kitsune', group: 'Supernatural',
        description: 'Fox ears, multiplying tails, and a trickster’s delight in being underestimated',
        requirement: { furry_events: 5, mind_control_events: 5 },
        appearance: ['fox ears', 'three flourishing tails', 'quick golden eyes'],
        buff: 'Trickster', buff_description: '+15% dodge chance, +10% surprise-hit chance',
        effects: { 'dodge_bonus' => 0.15, 'crit_chance' => 0.1 },
        special_event: 'Ninefold Illusion',
        special_event_description: 'Sometimes your illusions feed on the monster’s fantasies, gaining LP untouched',
        special: { kind: :dream, chance: 0.15,
                   text: 'Your illusions bloom around the %<name>s, feeding on its fantasies — **+%<amount>s LP** while it grasps at foxfire.' }
      },
      'hoard_dragon' => {
        name: 'Hoard Dragon', group: 'Dragon',
        description: 'Scales, gem-bright eyes, and a possessive certainty that every shining thing is yours',
        requirement: { treasure_found: 25 },
        appearance: ['scaled forearms', 'curved horns', 'gem-bright eyes', 'smoke on your breath'],
        buff: 'Hoard Sense', buff_description: '+3 LP from treasure, take 15% less lust damage',
        effects: { 'treasure_lp' => 3, 'damage_reduction' => 0.85 },
        special_event: 'Territorial Roar',
        special_event_description: 'Sometimes your roar reminds the monster whose hoard this is, stunning it',
        special: { kind: :stun, chance: 0.12,
                   text: 'Your roar shakes the chamber and flashes your fangs — the %<name>s freezes, stunned!' }
      },
      'gargoyle' => {
        name: 'Gargoyle', group: 'Stone',
        description: 'Stone skin and statuesque patience — you were made to be looked at, and to outlast it',
        requirement: { exhibitionism_events: 6, objectification_events: 5 },
        appearance: ['smooth stone skin', 'small folded wings', 'chiseled features', 'a perch-worthy stillness'],
        buff: 'Living Statue', buff_description: 'Take 35% less lust damage, +10% chance monsters back off',
        effects: { 'damage_reduction' => 0.65, 'intimidate_chance' => 0.1 },
        special_event: 'Statue Stillness',
        special_event_description: 'Sometimes you simply become a statue, and the monster loses its turn to confusion',
        special: { kind: :stun, chance: 0.12,
                   text: 'You go perfectly still — a statue on a plinth. The %<name>s circles you, baffled, and loses its turn!' }
      },
      'mycelian' => {
        name: 'Mycelian', group: 'Plant',
        description: 'A soft cap of mushroom hair and a cloud of sweet spores follow you through the damp dark',
        requirement: { plant_submissions: 8, aphrodisiac_events: 5 },
        appearance: ['mushroom-cap hair', 'spore-dusted skin', 'glowing gill patterns'],
        events: { 'aphrodisiacs' => 30 },
        buff: 'Spore Cloud', buff_description: '+15% seduction chance, take 15% less lust damage',
        effects: { 'satisfy_bonus' => 0.15, 'damage_reduction' => 0.85 },
        special_event: 'Intoxicating Spores',
        special_event_description: 'Sometimes your spores intoxicate the monster, weakening it for the rest of the fight',
        special: { kind: :weaken, chance: 0.15,
                   text: 'Your spores burst sweet and thick around the %<name>s — it sways, intoxicated and weakened!' }
      },
      'centaur' => {
        name: 'Centaur', group: 'Beast',
        description: 'Below the waist you are all horse — proud, powerful, and built to be ridden',
        requirement: { pony_events: 5, body_growth_events: 3 },
        appearance: ['sleek equine lower body', 'a glossy tail', 'hooves that ring on stone'],
        buff: 'Wild Gallop', buff_description: '+20% flee chance, +10% dodge chance',
        effects: { 'flee_bonus' => 0.2, 'dodge_bonus' => 0.1 },
        special_event: 'Thunder Kick',
        special_event_description: 'Sometimes your hind hooves lash out and stun the monster',
        special: { kind: :stun, chance: 0.13,
                   text: 'Your hind hooves crack out like thunder — the %<name>s reels, stunned!' }
      },
      'siren' => {
        name: 'Siren', group: 'Supernatural',
        description: 'Your voice has learned to reach into dreams and pull them toward the rocks',
        requirement: { mind_control_events: 5, exhibitionism_events: 5 },
        appearance: ['iridescent scale flecks', 'hair that moves like water', 'a voice with harmonics'],
        buff: 'Rocksong', buff_description: '+20% seduction chance',
        effects: { 'satisfy_bonus' => 0.2 },
        special_event: 'Dreamtide',
        special_event_description: 'Sometimes your song drags the monster into a fantasy it never wants to leave, gaining LP',
        special: { kind: :dream, chance: 0.15,
                   text: 'Your song pours over the %<name>s like warm tide — it sighs into its favourite fantasy, and you drink in **+%<amount>s LP**.' }
      },
      'minotaur' => {
        name: 'Minotaur', group: 'Beast',
        description: 'Horns, muscle, and a labyrinth hunger — the maze of the tower answers to you now',
        requirement: { being_milked_events: 5, beast_submissions: 10 },
        appearance: ['broad curved horns', 'a heavy gold nose ring', 'corded muscle under soft hide'],
        buff: 'Labyrinth Bulk', buff_description: 'Take 25% less lust damage, +10% surprise-hit chance',
        effects: { 'damage_reduction' => 0.75, 'crit_chance' => 0.1 },
        special_event: 'Crushing Charge',
        special_event_description: 'Sometimes you simply charge, and the monster folds',
        special: { kind: :crush, chance: 0.13,
                   text: 'You lower your horns and charge — the %<name>s folds around you with a crunch, taking **%<amount>s** damage and going pliant!' }
      },
      'clockwork_maid' => {
        name: 'Clockwork Maid', group: 'Synthetic',
        description: 'Wound brass, perfect posture, and a devotion to service that ticks in perfect time',
        requirement: { maid_events: 5, objectification_events: 5 },
        appearance: ['brass key turning slowly at your back', 'porcelain-smooth joints', 'a frilled apron worn over plate'],
        buff: 'Perfect Service', buff_description: '+15% trap avoidance, take 20% less lust damage',
        effects: { 'trap_avoid_bonus' => 0.15, 'damage_reduction' => 0.8 },
        special_event: 'Service Interruption',
        special_event_description: 'Sometimes you curtsey so perfectly the monster forgets its turn',
        special: { kind: :stun, chance: 0.13,
                   text: 'You curtsey with clockwork grace, tea tray steady. The %<name>s hesitates, utterly disarmed, and loses its turn!' }
      },
      'porcelain_muse' => {
        name: 'Porcelain Muse', group: 'Object',
        description: 'Glazed, posed, and priceless — a work of art the tower keeps putting on display',
        requirement: { objectification_events: 8, exhibitionism_events: 5 },
        appearance: ['glazed porcelain skin', 'painted lashes', 'fine cracks healed with gold'],
        buff: 'Priceless Object', buff_description: 'Take 30% less lust damage, +10% chance monsters back off',
        effects: { 'damage_reduction' => 0.7, 'intimidate_chance' => 0.1 },
        special_event: 'Gallery Stillness',
        special_event_description: 'Sometimes you hold your pose, and the monster cannot bring itself to mar the art',
        special: { kind: :stun, chance: 0.12,
                   text: 'You hold your pose, flawless and still. The %<name>s lowers its hands — some things are too fine to spoil — and loses its turn!' }
      },
      'bone_marionette' => {
        name: 'Bone Marionette', group: 'Supernatural',
        description: 'Strings you cannot see move limbs you only partly own, and the dead hold the other ends',
        requirement: { undead_submissions: 10, bondage_events: 5 },
        appearance: ['visible string-lines at your joints', 'ball-jointed wrists', 'a painted smile'],
        buff: 'Dancing Strings', buff_description: '+25% dodge chance',
        effects: { 'dodge_bonus' => 0.25 },
        special_event: 'Dead Hands',
        special_event_description: 'Sometimes the strings yank you through the monster, draining it as you pass',
        special: { kind: :drain, chance: 0.15,
                   text: 'Invisible strings jerk you straight through the %<name>s — cold fingers drain **%<amount>s** HP from it into your defiance!' }
      },
      'syn_fae' => {
        name: 'Syn Fae', group: 'Fae',
        description: 'Platinum hair, violet eyes, and smoked-glass wings — the tower keeps a fairy shaped like the one who first imagined it',
        requirement: { is_developer: true },
        appearance: ['waist-length platinum-blonde hair, forever artfully messy', 'heavy-lidded violet eyes with smudged dark makeup',
                     'drooping smoked-glass black wings', 'skin inked and pierced like a parlour catalogue', 'an exhausted, knowing smirk'],
        buff: 'The Original', buff_description: '+25% seduction chance, +15% dodge chance — and Eros looks at you very differently',
        effects: { 'satisfy_bonus' => 0.25, 'dodge_bonus' => 0.15 },
        special_event: 'Parlour Needle',
        special_event_description: 'Sometimes you ink a binding sigil mid-fight, and the monster holds still to be decorated',
        special: { kind: :stun, chance: 0.15,
                   text: 'Your needle kisses the %<name>s with a binding sigil — it holds perfectly still, stunned and preening!' }
      }
    }.freeze

    MONSTER_LABELS = {
      beast: 'Beast', demon: 'Demon', slime: 'Slime', undead: 'Undead', plant: 'Plant', mimic: 'Mimic',
      eldritch: 'Eldritch'
    }.freeze

    SKIP_KINDS = %i[stun thrall drain crush divine].freeze

    CHIMERA_KEY = 'chimera'
    FUSION_COST = 100
    CHIMERA_PRIMARY_TRACKER = 'chimera_primary'
    CHIMERA_SECONDARY_TRACKER = 'chimera_secondary'

    module_function

    def get(key)
      TRANSFORMATIONS[key.to_s]
    end

    def find(query)
      q = query.to_s.strip.downcase
      return nil if q.empty?
      return CHIMERA_KEY if q == CHIMERA_KEY

      TRANSFORMATIONS.find { |k, t| k == q || t[:name].downcase == q || k.tr('_', ' ') == q }&.first
    end

    # --- Chimera: two unlocked forms fused into one body -----------------
    # The primary form keeps its full effects and its combat special; the
    # secondary echoes at half strength. Stored in trackers, so a fused
    # body survives defeats, restarts and cycles like everything else.

    def chimera_combo(player)
      primary = player.tracker_hash[CHIMERA_PRIMARY_TRACKER].to_s
      secondary = player.tracker_hash[CHIMERA_SECONDARY_TRACKER].to_s
      owned = player.unlocked_transformations
      return nil unless TRANSFORMATIONS.key?(primary) && TRANSFORMATIONS.key?(secondary)
      return nil if primary == secondary
      return nil unless owned.include?(primary) && owned.include?(secondary)

      [primary, secondary]
    end

    def chimera_form(player)
      combo = chimera_combo(player) or return nil
      primary = TRANSFORMATIONS[combo[0]]
      secondary = TRANSFORMATIONS[combo[1]]

      {
        name: "#{primary[:name]}-#{secondary[:name]} Chimera",
        group: 'Chimera',
        description: "A fused hybrid: #{primary[:description]} — woven through with another shape: #{secondary[:description]}",
        appearance: (Array(primary[:appearance]) + Array(secondary[:appearance])).uniq,
        buff: "#{primary[:buff]} (with echoes of #{secondary[:name]})",
        buff_description: "#{primary[:buff_description]}; at half strength: #{secondary[:buff_description]}",
        effects: blend_effects(primary[:effects], secondary[:effects]),
        monsters: blend_weights(primary[:monsters], secondary[:monsters]),
        events: blend_weights(primary[:events], secondary[:events]),
        all_events: primary[:all_events].to_i + (secondary[:all_events].to_i / 2),
        monster_rate: ((primary[:monster_rate] || 1.0) + (secondary[:monster_rate] || 1.0)) / 2.0,
        event_rate: ((primary[:event_rate] || 1.0) + (secondary[:event_rate] || 1.0)) / 2.0,
        special: primary[:special],
        special_event: primary[:special_event],
        special_event_description: primary[:special_event_description],
        chimera: true,
        combo: combo
      }
    end

    def blend_effects(primary_effects, secondary_effects)
      merged = {}
      Hash(primary_effects).each { |k, v| merged[k.to_s] = v }
      Hash(secondary_effects).each do |k, v|
        key = k.to_s
        half = half_effect(key, v)
        merged[key] =
          if !merged.key?(key) then half
          elsif mult_like?(key) then merged[key]
          elsif merged[key].is_a?(Numeric) && half.is_a?(Numeric) then (merged[key] + half).round(3)
          else merged[key]
          end
      end
      merged
    end

    def mult_like?(key)
      key.include?('mult') || key == 'damage_reduction'
    end

    def half_effect(key, value)
      return value if value == true || value == false
      return value unless value.is_a?(Numeric)

      if mult_like?(key)
        value >= 1 ? (1.0 + ((value - 1.0) / 2.0)).round(3) : (1.0 - ((1.0 - value) / 2.0)).round(3)
      else
        (value / 2.0).round(3)
      end
    end

    def blend_weights(primary_weights, secondary_weights)
      merged = {}
      Hash(primary_weights).each { |k, v| merged[k.to_sym] = v.to_i }
      Hash(secondary_weights).each do |k, v|
        key = k.to_sym
        merged[key] = merged.fetch(key, 0) + (v.to_i / 2)
      end
      merged
    end

    # --- Deepening: a form grows into itself -------------------------------
    # Winning fights or satisfying monsters while wearing a form deepens it
    # (Stage I at 3, II at 8, III at 15). Each stage lets the delver choose
    # one of three mutations; chosen mutations apply only in that form.

    DEEPEN_THRESHOLDS = [3, 8, 15].freeze
    MUTATIONS = {
      'keener_senses' => { name: 'Keener Senses', description: '+3% dodge chance', effects: { 'dodge_bonus' => 0.03 } },
      'thicker_hide' => { name: 'Thicker Hide', description: 'Take 5% less lust damage', effects: { 'damage_reduction' => 0.95 } },
      'hungrier_heart' => { name: 'Hungrier Heart', description: '+3% chance to satisfy monsters', effects: { 'satisfy_bonus' => 0.03 } },
      'tireless_body' => { name: 'Tireless Body', description: '+1 strength', effects: { 'strength' => 1 } },
      'silken_voice' => { name: 'Silken Voice', description: '+2 LP whenever you submit', effects: { 'submit_lp_bonus' => 2 } },
      'predator_grace' => { name: 'Predator Grace', description: '+1 agility', effects: { 'agility' => 1 } }
    }.freeze

    def deepen_key(player)
      player.active_transformation_key&.to_s
    end

    def deepen_count(player, key = deepen_key(player))
      key.nil? || key.empty? ? 0 : player.tracker("form_deepen_#{key}")
    end

    def deepen_stage(player, key = deepen_key(player))
      count = deepen_count(player, key)
      DEEPEN_THRESHOLDS.count { |t| count >= t }
    end

    def mutations_for(player, key = deepen_key(player))
      return [] if key.nil? || key.empty?

      Array(player.tracker_hash["form_mutations_#{key}"]).select { |m| MUTATIONS.key?(m.to_s) }
    end

    def pending_mutations(player, key = deepen_key(player))
      [deepen_stage(player, key) - mutations_for(player, key).size, 0].max
    end

    def mutation_choices(player, key = deepen_key(player))
      stage = mutations_for(player, key).size
      MUTATIONS.keys.rotate(stage * 2).first(3) - mutations_for(player, key)
    end

    def choose_mutation!(player, mutation_key)
      key = deepen_key(player)
      return { ok: false, message: 'Take a hybrid form first.' } if key.nil? || key.empty?
      return { ok: false, message: 'Unknown mutation.' } unless MUTATIONS.key?(mutation_key.to_s)
      return { ok: false, message: 'Your form has not deepened enough for another mutation yet.' } if pending_mutations(player, key) <= 0
      return { ok: false, message: 'Choose one of the mutations your form is offering.' } unless mutation_choices(player, key).include?(mutation_key.to_s)

      player.update(trackers: player.tracker_hash.merge("form_mutations_#{key}" => mutations_for(player, key) + [mutation_key.to_s]))
      { ok: true, message: "Your form deepens — **#{MUTATIONS[mutation_key.to_s][:name]}**: #{MUTATIONS[mutation_key.to_s][:description]}." }
    end

    def record_deepen!(player, log)
      key = deepen_key(player)
      return if key.nil? || key.empty?

      before = deepen_stage(player, key)
      player.bump_tracker!("form_deepen_#{key}")
      after = deepen_stage(player, key)
      return unless after > before

      form = active(player)
      log << "🧬 Your **#{form[:name]}** deepens (Stage #{after}) — choose a mutation in `/transformation`."
    end

    # --- Resonance: monsters know their own kind ---------------------------

    GROUP_AFFINITIES = {
      'Beast' => 'beast', 'Demon' => 'demon', 'Plant' => 'plant', 'Supernatural' => 'undead',
      'Eldritch' => 'eldritch', 'Arachnid' => 'beast', 'Dragon' => 'beast', 'Stone' => 'undead',
      'Object' => 'mimic', 'Synthetic' => 'slime', 'Holy' => 'demon', 'Fae' => 'demon'
    }.freeze

    def resonance?(player, monster_type)
      form = active(player)
      return false unless form && monster_type

      GROUP_AFFINITIES[form[:group].to_s] == monster_type.to_s
    end

    def fuse!(player, primary_key, secondary_key)
      primary = get(primary_key)
      secondary = get(secondary_key)
      return { ok: false, message: 'Choose two real hybrid forms to fuse.' } unless primary && secondary
      return { ok: false, message: 'A chimera needs two *different* forms.' } if primary_key.to_s == secondary_key.to_s

      owned = player.unlocked_transformations
      unless owned.include?(primary_key.to_s) && owned.include?(secondary_key.to_s)
        return { ok: false, message: 'You can only fuse forms you have unlocked.' }
      end
      unless player.spend_lp!(FUSION_COST)
        return { ok: false, message: "Fusing two forms costs **#{FUSION_COST} LP** — you have #{player.lp}." }
      end

      player.set_tracker!(CHIMERA_PRIMARY_TRACKER, primary_key.to_s)
      player.set_tracker!(CHIMERA_SECONDARY_TRACKER, secondary_key.to_s)
      player.update(active_transformation: CHIMERA_KEY)
      form = chimera_form(player)
      { ok: true, form: form,
        message: "Your two shapes weave together — you are now a **#{form[:name]}**! " \
                 "#{primary[:name]} leads at full strength; #{secondary[:name]} echoes at half. (−#{FUSION_COST} LP)" }
    end

    def eligible?(player, key)
      entry = get(key)
      entry ? Engine::TitleSystem.met?(player, entry[:requirement]) : false
    end

    def visible(player)
      owned = player.unlocked_transformations
      TRANSFORMATIONS.select { |k, t| owned.include?(k) || Engine::TitleSystem.visible?(player, t) }
    end

    def active(player)
      key = player.active_transformation_key
      key.to_s == CHIMERA_KEY ? chimera_form(player) : get(key)
    end

    def effects(player)
      merged = {}
      Hash(active(player)&.dig(:effects)).each { |k, v| merged[k.to_s] = v }
      mutations_for(player).each do |m|
        MUTATIONS[m][:effects].each do |k, v|
          key = k.to_s
          merged[key] =
            if !merged.key?(key) then v
            elsif mult_like?(key) then (merged[key].to_f * v.to_f).round(3)
            elsif merged[key].is_a?(Numeric) && v.is_a?(Numeric) then (merged[key] + v).round(3)
            else merged[key]
            end
        end
      end
      merged
    end

    def monster_rate(player)
      active(player)&.dig(:monster_rate) || 1.0
    end

    def event_rate(player)
      active(player)&.dig(:event_rate) || 1.0
    end

    def monster_weight(player, type)
      form = active(player)
      return 1.0 unless form

      1.0 + (Hash(form[:monsters])[type.to_sym].to_i / 100.0)
    end

    def event_weight(player, tag)
      form = active(player)
      return 1.0 unless form

      bonus = form[:all_events].to_i
      bonus += Hash(form[:events])[tag.to_s].to_i if tag
      1.0 + (bonus / 100.0)
    end

    def combat_start!(player, enc, lines)
      special = active(player)&.dig(:special)
      return unless special && special[:kind] == :insight && rand < special[:chance]

      drop = [enc[:agility].to_i, 3].min
      return unless drop.positive?

      enc[:agility] = enc[:agility].to_i - drop
      lines << format("_#{special[:text]}_", name: enc[:name], amount: drop)
    end

    def combat_special!(player, enc, log)
      special = active(player)&.dig(:special)
      return nil unless special
      return nil if special[:kind] == :insight
      return nil if special[:kind] == :divine && player.defiance > (player.max_defiance * 0.3)
      return nil unless rand < special[:chance]

      amount = resolve_special!(player, enc, special[:kind])
      log << format("**#{active(player)[:special_event]}** — #{special[:text]}", name: enc[:name], amount: amount)
      SKIP_KINDS.include?(special[:kind]) ? :skip : :continue
    end

    def resolve_special!(player, enc, kind)
      floor = player.current_floor.to_i
      case kind
      when :absorb then player.heal_defiance!(5 + (floor / 2))
      when :dream
        lp = 3 + (floor / 3)
        player.gain_lp!(lp)
        lp
      when :weaken
        enc[:strength] = [(enc[:strength].to_i * 0.8).round, 1].max
        enc[:lust_damage] = [(enc[:lust_damage].to_i * 0.8).round, 1].max
        nil
      when :thrall then hurt!(enc, [enc[:strength].to_i, 1].max)
      when :crush then hurt!(enc, [(player.effective_strength * 1.5).round, 1].max)
      when :drain
        dealt = hurt!(enc, [(player.effective_strength / 2.0).round + (floor / 2), 1].max)
        player.heal_defiance!(dealt)
        dealt
      when :divine
        healed = player.heal_defiance!(15)
        player.update(lust: [player.lust - 15, player.base_lust].max)
        healed
      end
    end

    def hurt!(enc, damage)
      dealt = [damage, enc[:hp].to_i].min
      enc[:hp] = enc[:hp].to_i - dealt
      dealt
    end

    def effect_lines(entry)
      lines = []
      if entry[:monster_rate] && entry[:monster_rate] != 1.0
        lines << "Monster rooms #{signed_pct(entry[:monster_rate])}"
      end
      lines << "Random events #{signed_pct(entry[:event_rate])}" if entry[:event_rate] && entry[:event_rate] != 1.0
      lines << "Every event type +#{entry[:all_events]}%" if entry[:all_events].to_i.positive?
      Hash(entry[:monsters]).each { |type, pct| lines << "#{MONSTER_LABELS.fetch(type, type.to_s.capitalize)} monsters +#{pct}%" }
      Hash(entry[:events]).each do |tag, pct|
        label = Engine::ContentOptions.preference(tag)&.dig(:label) || tag.tr('_', ' ').capitalize
        lines << "#{label} events +#{pct}%"
      end
      lines << "**#{entry[:buff]}:** #{entry[:buff_description]}" if entry[:buff]
      lines << "**#{entry[:special_event]}:** #{entry[:special_event_description]}" if entry[:special_event]
      lines
    end

    def signed_pct(mult)
      pct = ((mult.to_f - 1) * 100).round
      pct.negative? ? "#{pct}%" : "+#{pct}%"
    end
  end
end
