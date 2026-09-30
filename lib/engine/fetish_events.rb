# frozen_string_literal: true

module Engine
  module FetishEvents
    COLOUR = 0xc2185b

    EVENTS = {
      'bimbo_transformation' => {
        name: 'Bimbo Transformation', tag: 'bimbofication', tracker: 'bimbo_transformations',
        blurb: 'a pink crystal pulses invitingly.',
        intro: 'A heart-shaped crystal glows bubblegum pink. Its whisper promises that thinking is *so* overrated, ' \
               'and that you would look *amazing* with a few more curves...',
        accept: {
          label: 'Touch it', text: 'Let the pink glow in',
          scenes: ['Pink light floods your head like warm fizz. Your thoughts go giggly and soft, your lips plump, ' \
                   'and your hips sway with a new bounce.',
                   'You catch yourself twirling your hair and giggling at nothing. Everything feels *so* good.'],
          parts: { 'breasts' => 'Your chest swells heavy and perky, straining your top.' },
          lp: 6, lust: 14, special: :bimbo,
          condition: { key: 'bimbo_brain', name: 'Bimbo Brain', floors: 3,
                       effects: { 'submission' => 1, 'satisfy_bonus' => 0.1, 'submit_lp_bonus' => 2, 'resistance' => -1 } }
        },
        decline: { label: 'Walk away', text: 'Keep your wits', lust: 3,
                   scene: 'You tear your eyes away. The crystal pouts — and for a moment, so do you.' }
      },
      'inflation_trap' => {
        name: 'Inflation Trap', tag: 'inflation', tracker: 'inflation_events',
        blurb: 'a hose-like vine drips warm syrup.',
        intro: 'Slick nozzles unfurl from the walls, dripping sweet warm fluid. They sway toward you, ready to fill.',
        accept: {
          label: 'Let it fill you', text: 'Get pumped full',
          scenes: ['The nozzles latch on and pump you full of warm syrup until your belly rounds out, taut and sloshing.',
                   'Every movement makes you gurgle and blush — you feel stuffed, heavy, and oddly sturdy.'],
          lp: 5, lust: 12,
          condition: { key: 'stuffed', name: 'Stuffed Full', floors: 2,
                       effects: { 'agility' => -2, 'max_hp_bonus' => 10 } }
        },
        decline: { label: 'Dodge', text: 'Try to dodge the nozzles (AGI)', lust: 2, escape: true,
                   scene: 'You slip between the nozzles before they can latch on.' },
        fight: { label: 'Burst it', type: :slime, text: 'The nozzles belong to a bloated slime — and it wants you!' }
      },
      'living_clothing' => {
        name: 'Living Clothing', tag: 'living_clothing', tracker: nil,
        blurb: 'an outfit hangs on an invisible mannequin.',
        intro: 'A gorgeous outfit floats in the air, fabric shimmering and rippling as if breathing. It seems to be sizing you up.',
        accept: {
          label: 'Try it on', text: 'Wear the living outfit (cursed gear)',
          scenes: ['The fabric leaps onto you before you finish undressing, sealing itself to your skin with a satisfied shiver.'],
          lp: 4, lust: 10, special: :living_clothing
        },
        decline: { label: 'Leave it', text: 'Leave it hanging', lust: 2,
                   scene: 'The outfit droops sadly as you walk past.' },
        fight: { label: 'Rip it apart', type: :mimic, text: 'The outfit lunges — it was a mimic all along!' }
      },
      'beast_taming' => {
        name: 'Beast Taming', tag: 'petplay', tracker: 'petplay_events',
        blurb: 'a leather collar hangs from a hook.',
        intro: 'A studded collar and leash wait by a pack of watchful beasts. Their alpha pads forward, curious whether you are master — or pet.',
        accept: {
          label: 'Wear the collar', text: 'Become the pack\'s pet',
          scenes: ['The collar clicks shut. The alpha nuzzles you onto all fours and leads you in a slow, proud circle on the leash.',
                   'Every scratch behind your ears makes you melt. *Good pet.*'],
          lp: 5, lust: 12,
          condition: { key: 'good_pet', name: 'Good Pet', floors: 3,
                       effects: { 'beast_lust_mult' => 0.8, 'beast_submit_lp' => 3, 'flee_bonus' => -0.1 } }
        },
        decline: { label: 'Back away', text: 'Leave the pack be', lust: 2,
                   scene: 'The alpha huffs and lets you go.' },
        fight: { label: 'Challenge the alpha', type: :beast, text: 'The alpha bares its teeth and charges!' }
      },
      'rubber_chamber' => {
        name: 'Rubber Chamber', tag: 'latex', tracker: 'latex_events',
        blurb: 'the walls gleam with black gloss.',
        intro: 'Glossy liquid latex pools on the floor, rising in slow tendrils that reflect your silhouette.',
        accept: {
          label: 'Be encased', text: 'Let the latex coat you',
          scenes: ['The latex flows up your body and tightens into a flawless, squeaking second skin.',
                   'Every touch through the rubber feels muffled yet electric.'],
          lp: 5, lust: 10,
          condition: { key: 'latex_skin', name: 'Latex Skin', floors: 3,
                       effects: { 'resistance' => 2, 'lust_mult' => 1.1 } }
        },
        decline: { label: 'Step around', text: 'Avoid the puddle', lust: 1,
                   scene: 'You edge around the gleaming pool.' },
        fight: { label: 'Fight it', type: :slime, text: 'The latex surges up into a hungry rubber slime!' }
      },
      'oviposition_chamber' => {
        name: 'Oviposition Chamber', tag: 'oviposition', tracker: 'oviposition_events',
        blurb: 'a nest of warm, glistening eggs.',
        intro: 'A gentle, many-legged broodmother chirps from a nest of soft eggs. She seems to think you would make a lovely nursery.',
        accept: {
          label: 'Carry her eggs', text: 'Let her fill you with eggs',
          scenes: ['Her ovipositor slides in slowly, and one by one warm, smooth eggs settle deep inside you.',
                   'You waddle away heavy and full, each step a reminder.'],
          lp: 6, lust: 14,
          condition: { key: 'egg_laden', name: 'Egg-Laden', floors: 2,
                       effects: { 'agility' => -1, 'explore_lp' => 2 } }
        },
        decline: { label: 'Refuse', text: 'Politely decline', lust: 2,
                   scene: 'The broodmother clicks, disappointed, and returns to her nest.' },
        fight: { label: 'Fight', type: :beast, text: 'The broodmother rears up, defending her nest!' }
      },
      'chastity_trap' => {
        name: 'Chastity Trap', tag: 'chastity', tracker: 'chastity_events',
        blurb: 'a gleaming belt lies on a pedestal.',
        intro: 'A steel belt humming with rune-light rests on a velvet pedestal. A tag reads: *"Wear me. Earn your release."*',
        accept: {
          label: 'Lock it on', text: 'Wear the belt (cursed gear: climaxes denied)',
          scenes: ['The belt snaps around your hips and locks with a heavy, final click.'],
          parts: { 'penis' => 'Your cock is caged snugly away, twitching uselessly.',
                   'vagina' => 'A smooth shield seals over your folds, humming faintly.' },
          lp: 8, lust: 12, special: :chastity
        },
        decline: { label: 'Back off', text: 'Leave it (AGI to avoid the trap)', lust: 2, escape: true,
                   scene: 'The belt lunges — and snaps shut on empty air as you twist away.' }
      },
      'hypnotic_mist' => {
        name: 'Hypnotic Mist', tag: 'mind_control', tracker: 'mind_control_events',
        blurb: 'violet mist swirls in hypnotic spirals.',
        intro: 'Violet mist spirals around you, and a soothing voice counts slowly down from ten...',
        accept: {
          label: 'Listen', text: 'Let the voice sink in',
          scenes: ['*Nine... eight...* Your thoughts slow. *Obey... relax... submit...*',
                   'You come to swaying, feeling floaty and eager to please.'],
          lp: 5, lust: 12,
          condition: { key: 'entranced', name: 'Entranced', floors: 2,
                       effects: { 'submission' => 2, 'no_flee' => true, 'submit_lp_bonus' => 3 } }
        },
        decline: { label: 'Hold your breath', text: 'Try to push through (AGI)', lust: 2, escape: true,
                   scene: 'You dash through the mist with your breath held.' },
        fight: { label: 'Find the hypnotist', type: :demon, text: 'You spot the demon weaving the mist!' }
      },
      'glory_room' => {
        name: 'Glory Room', tag: 'bukkake', tracker: 'bukkake_events',
        blurb: 'a ring of holes lines the walls.',
        intro: 'A circular room lined with holes. Eager shapes wait behind every one — far too many to count.',
        accept: {
          label: 'Kneel in the centre', text: 'Take them all',
          scenes: ['You kneel in the middle as they finish on you one after another, until you are dripping and glazed.',
                   'The crowd behind the walls cheers. You feel absurdly proud.'],
          lp: 7, lust: 14,
          condition: { key: 'glazed', name: 'Glazed', floors: 2,
                       effects: { 'hit_lp' => 1, 'lust_mult' => 1.1 } }
        },
        decline: { label: 'Leave', text: 'Leave the room', lust: 3,
                   scene: 'Disappointed groans follow you out.' }
      },
      'observation_deck' => {
        name: 'Observation Deck', tag: 'exhibitionism', tracker: 'exhibitionism_events',
        blurb: 'a lit stage faces rows of hidden eyes.',
        intro: 'A spotlight snaps on over a small stage. You can feel an unseen audience waiting for a show.',
        accept: {
          label: 'Perform', text: 'Give them a show',
          scenes: ['You strip slowly under the spotlight, posing and teasing as the hidden audience murmurs.',
                   'Coins of lust-light rain onto the stage when you finish.'],
          lp: 7, lust: 10,
          condition: { key: 'on_display', name: 'On Display', floors: 3,
                       effects: { 'victory_lp_bonus' => 3, 'encounter_rate' => 1.2 } }
        },
        decline: { label: 'Stay hidden', text: 'Slip off the stage', lust: 2,
                   scene: 'The spotlight flickers off as you duck away.' }
      },
      'giants_chamber' => {
        name: 'Giant\'s Chamber', tag: 'giant', tracker: 'body_growth_events',
        blurb: 'a colossal throne and a glowing mushroom.',
        intro: 'A glowing mushroom sits beside a colossal throne. A note reads: *"Eat me, and fit the seat."*',
        accept: {
          label: 'Eat it', text: 'Grow huge',
          scenes: ['You shoot upward, towering and thick-limbed, every inch of you swollen with strength.',
                   'Your clothes strain and you feel impossibly powerful — and impossibly sensitive.'],
          lp: 5, lust: 10,
          condition: { key: 'towering', name: 'Towering', floors: 3,
                       effects: { 'strength' => 3, 'agility' => -2 } }
        },
        decline: { label: 'Leave it', text: 'Stay your size', lust: 1,
                   scene: 'The mushroom glows forlornly.' }
      },
      'shrinking_chamber' => {
        name: 'Shrinking Chamber', tag: 'shrinking', tracker: 'body_reduction_events',
        blurb: 'a tiny doorway and a bottle labelled "Drink me".',
        intro: 'A little bottle waits by a door no taller than your knee. The label says *Drink me*.',
        accept: {
          label: 'Drink it', text: 'Shrink down',
          scenes: ['The world balloons around you. A curious giantess scoops you up and plays with you like a doll before setting you gently down.',
                   'Small, quick, and flushed, you slip through the tiny door.'],
          lp: 5, lust: 10,
          condition: { key: 'pocket_sized', name: 'Pocket-Sized', floors: 3,
                       effects: { 'agility' => 3, 'strength' => -2, 'dodge_bonus' => 0.1 } }
        },
        decline: { label: 'Leave it', text: 'Stay your size', lust: 1,
                   scene: 'You leave the bottle for someone smaller.' }
      },
      'futa_fountain' => {
        name: 'Futa Fountain', tag: 'futanari', tracker: 'futanari_events',
        blurb: 'a fountain shaped like a well-endowed goddess.',
        intro: 'Warm, shimmering water flows from a statue of a gloriously endowed goddess. Drinkers, it is said, share her gift.',
        accept: {
          label: 'Drink', text: 'Receive the goddess\'s gift',
          scenes: ['Heat blooms between your legs as the magic takes hold. You gasp at the new, heavy weight there.'],
          lp: 6, lust: 14, special: :futa
        },
        decline: { label: 'Refuse', text: 'Don\'t drink', lust: 2,
                   scene: 'You splash your face and move on.' }
      },
      'living_furniture' => {
        name: 'Living Furniture', tag: 'objectification', tracker: 'objectification_events',
        blurb: 'a room of eerily lifelike furniture.',
        intro: 'Chairs, tables, and lamps here are shaped suspiciously like people. An empty pedestal waits for a new piece.',
        accept: {
          label: 'Become furniture', text: 'Take your place on the pedestal',
          scenes: ['You freeze in position as a footstool. Passers-by rest their feet on you, set drinks on your back, and admire the craftsmanship.',
                   'When the spell lifts, you are stiff, flushed, and strangely serene.'],
          lp: 6, lust: 10,
          condition: { key: 'furniture_mindset', name: 'Furniture Mindset', floors: 2,
                       effects: { 'resistance' => 3, 'agility' => -2, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Walk through', text: 'Ignore the pedestal', lust: 1,
                   scene: 'The furniture watches you leave.' },
        fight: { label: 'Smash it', type: :mimic, text: 'A chair lurches up on too many legs!' }
      },
      'mirror_of_change' => {
        name: 'Mirror of Change', tag: 'gender_bending', tracker: 'gender_bending_events',
        blurb: 'a mirror shows someone almost like you.',
        intro: 'Your reflection winks — but it is *different*. It reaches a hand out of the glass, offering to trade places.',
        requires: :swappable,
        accept: {
          label: 'Take its hand', text: 'Swap bodies with your reflection (temporary)',
          scenes: ['You step through the glass and out the other side — your body reshaped into its mirror image.'],
          lp: 6, lust: 12, special: :gender_swap
        },
        decline: { label: 'Refuse', text: 'Stay as you are', lust: 1,
                   scene: 'The reflection shrugs and becomes normal again.' }
      },
      'milking_chamber' => {
        name: 'Milking Chamber', tag: 'lactation', tracker: 'being_milked_events',
        blurb: 'brass pumps hiss rhythmically.',
        intro: 'A padded milking stall with brass pumps and suction cups. A little plaque promises generous payment.',
        accept: {
          label: 'Get milked', text: 'Strap in and be milked',
          scenes: ['The pumps latch on and pull in a slow, relentless rhythm, drawing out everything you have.'],
          parts: { 'breasts' => 'Your breasts ache and leak as the cups tug, milk streaming into the tubes.',
                   'penis' => 'A sleeve seals around your cock and milks you dry, again and again.' },
          lp: 10, lust: 12,
          condition: { key: 'drained', name: 'Drained', floors: 2,
                       effects: { 'max_hp_bonus' => -10, 'treasure_lp' => 3 } }
        },
        decline: { label: 'Leave', text: 'Leave the stall', lust: 2,
                   scene: 'The pumps sigh to a stop.' }
      },
      'breeding_chamber' => {
        name: 'Breeding Chamber', tag: 'breeding', tracker: 'impregnation_events',
        blurb: 'a fertility altar hums with warm light.',
        intro: 'A soft altar glows with fertility runes. A powerful beast waits beside it, snorting eagerly.',
        accept: {
          label: 'Lie on the altar', text: 'Let the beast breed you',
          scenes: ['The beast mounts you and fills you deep, the runes flaring bright as its seed takes root.',
                   'Your belly glows faintly afterward. You feel warm, nurturing, and blissfully bred.'],
          lp: 7, lust: 14,
          condition: { key: 'bred', name: 'Bred', floors: 3,
                       effects: { 'healing_mult' => 1.25, 'agility' => -1, 'beast_submit_lp' => 2 } }
        },
        decline: { label: 'Refuse', text: 'Leave the altar', lust: 2,
                   scene: 'The beast snorts and lies back down.' },
        fight: { label: 'Fight the beast', type: :beast, text: 'The beast rears up, refusing to let you go!' }
      },
      'nectar_fountain' => {
        name: 'Nectar Fountain', tag: 'lactation', tracker: 'lactation_events',
        blurb: 'a fountain of sweet, milky nectar.',
        intro: 'A fountain burbles with sweet, creamy nectar. One sip, a sign says, and you will *overflow*.',
        requires: 'breasts',
        accept: {
          label: 'Drink deep', text: 'Drink the nectar',
          scenes: ['Your breasts swell heavy and full, and soon sweet milk beads at your nipples with every step.'],
          lp: 6, lust: 12,
          condition: { key: 'nectar_swollen', name: 'Nectar-Swollen', floors: 3,
                       effects: { 'max_hp_bonus' => 10, 'lust_mult' => 1.1 } }
        },
        decline: { label: 'Walk away', text: 'Don\'t drink', lust: 1,
                   scene: 'You resist the sweet smell.' }
      },
      'golden_chamber' => {
        name: 'Golden Chamber', tag: 'watersports', tracker: 'watersports_events',
        blurb: 'a tiled room with a golden drain.',
        intro: 'A tiled room with a golden drain. A grinning demon offers to *mark* you as its own.',
        accept: {
          label: 'Be marked', text: 'Accept the golden shower',
          scenes: ['Warm streams splash over you as the demon marks you thoroughly. Its scent clings to you like a claim.'],
          lp: 6, lust: 10,
          condition: { key: 'marked', name: 'Marked', floors: 2,
                       effects: { 'satisfy_bonus' => 0.1, 'demon_lust_mult' => 0.9 } }
        },
        decline: { label: 'Refuse', text: 'Leave', lust: 1,
                   scene: 'The demon shrugs and lets you go.' }
      },
      'binding_room' => {
        name: 'Binding Room', tag: 'bondage', tracker: 'bondage_events',
        blurb: 'silken ropes hang from the ceiling.',
        intro: 'Coils of silk rope hang from hooks. They slither toward you, eager to tie something pretty.',
        accept: {
          label: 'Be tied', text: 'Let the ropes bind you',
          scenes: ['The ropes wrap you in an intricate harness, hoisting you gently and holding you helpless while they tease every inch.',
                   'When they finally let go, beautiful rope marks remain.'],
          lp: 6, lust: 12,
          condition: { key: 'rope_marks', name: 'Rope Marks', floors: 2,
                       effects: { 'resistance' => 2, 'agility' => -2, 'flee_bonus' => -0.1 } }
        },
        decline: { label: 'Slip past', text: 'Dodge the ropes (AGI)', lust: 2, escape: true,
                   scene: 'You dart between the ropes before they catch you.' }
      },
      'discipline_room' => {
        name: 'Discipline Room', tag: 'spanking', tracker: 'discipline_events',
        blurb: 'a stern figure taps a riding crop.',
        intro: 'A stern demon mistress taps a crop against her palm. *"You have been naughty, haven\'t you?"*',
        accept: {
          label: 'Accept punishment', text: 'Bend over and take it',
          scenes: ['She bends you over and lays into you with crisp, stinging strokes, counting each one aloud.',
                   'When she finishes, you thank her — and mean it.'],
          lp: 7, lust: 10, defiance: -5,
          condition: { key: 'disciplined', name: 'Well-Disciplined', floors: 3,
                       effects: { 'strength' => 1, 'resistance' => 1, 'submission' => 1 } }
        },
        decline: { label: 'Refuse', text: 'Refuse her', lust: 2,
                   scene: 'She tuts and lets you go — this time.' },
        fight: { label: 'Defy her', type: :demon, text: 'Her eyes flash. *"Oh, a brat. Wonderful."*' }
      },
      'public_shame' => {
        name: 'Public Shame', tag: 'humiliation', tracker: 'humiliation_events',
        blurb: 'a pillory stands in a crowded square.',
        intro: 'A pillory stands in an illusory town square full of jeering phantoms. A sign invites volunteers.',
        accept: {
          label: 'Step into the stocks', text: 'Endure the crowd',
          scenes: ['Locked in the stocks, you blush as phantoms laugh, tease, and grope, calling you every lewd name they know.',
                   'By the end your face burns — and so does the rest of you.'],
          lp: 7, lust: 12,
          condition: { key: 'shamed', name: 'Shamed', floors: 2,
                       effects: { 'lust_mult' => 1.1, 'victory_lp_bonus' => 2, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Walk away', text: 'Ignore the jeers', lust: 2,
                   scene: 'Boos follow you out of the square.' }
      },
      'whispering_chamber' => {
        name: 'Whispering Chamber', tag: 'mindbreak', tracker: 'mindbreak_events',
        blurb: 'a thousand soft voices whisper at once.',
        intro: 'The walls whisper sweet, filthy nothings, promising that if you stop thinking, it will all feel so good.',
        accept: {
          label: 'Stop thinking', text: 'Let your thoughts melt',
          scenes: ['The whispers pour in until there is no room for anything else. Pleasure. Obedience. Pleasure.',
                   'You drift out blissed and blank, with a dopey smile.'],
          lp: 7, lust: 14,
          condition: { key: 'hollow_thoughts', name: 'Hollow Thoughts', floors: 3,
                       effects: { 'submission' => 2, 'resistance' => -1, 'submit_lp_bonus' => 4, 'satisfy_bonus' => 0.1 } }
        },
        decline: { label: 'Cover your ears', text: 'Run through (AGI)', lust: 2, escape: true,
                   scene: 'You clamp your hands over your ears and sprint through.' },
        fight: { label: 'Silence them', type: :undead, text: 'The whispers coalesce into a lustful wraith!' }
      },
      'sensory_void' => {
        name: 'Sensory Void', tag: 'sensory_deprivation', tracker: 'sensory_deprivation_events',
        blurb: 'a padded room of total darkness and silence.',
        intro: 'A padded, lightless, soundless room. A blindfold and earplugs sit by the door.',
        accept: {
          label: 'Put them on', text: 'Surrender to touch alone',
          scenes: ['Blind and deaf, you float in nothing — until unseen hands begin to touch you, every caress magnified tenfold.'],
          lp: 6, lust: 14,
          condition: { key: 'heightened_touch', name: 'Heightened Touch', floors: 2,
                       effects: { 'lust_mult' => 1.15, 'dodge_bonus' => 0.05, 'hit_lp' => 2 } }
        },
        decline: { label: 'Leave', text: 'Keep your senses', lust: 1,
                   scene: 'You leave the eerie silence behind.' }
      },
      'auction_block' => {
        name: 'Auction Block', tag: 'slavery', tracker: 'slavery_events',
        blurb: 'a demon auctioneer bangs a gavel.',
        intro: 'A demon auctioneer beckons you onto a stage before an eager crowd. *"Such a fine specimen! Shall we start the bidding?"*',
        accept: {
          label: 'Step up', text: 'Be sold (for a night)',
          scenes: ['The bidding is fierce. The winner leads you off by a chain and enjoys their purchase thoroughly.',
                   'At dawn you are released with a cut of your own sale price.'],
          lp: 12, lust: 12,
          condition: { key: 'owned', name: 'Owned', floors: 3,
                       effects: { 'submission' => 1, 'submit_lp_bonus' => 3, 'flee_bonus' => -0.15 } }
        },
        decline: { label: 'Refuse', text: 'Walk off the stage', lust: 2,
                   scene: 'The crowd groans.' },
        fight: { label: 'Fight the auctioneer', type: :demon, text: 'The auctioneer snarls and lunges!' }
      },
      'strap_on_chamber' => {
        name: 'Strap-On Chamber', tag: 'pegging', tracker: 'strap_on_events',
        blurb: 'a rack of enchanted harnesses.',
        intro: 'A rack of enchanted strap-ons hums on the wall. An eager succubus waits, happy to give — or receive.',
        accept: {
          label: 'Wear one', text: 'Strap on and take charge',
          scenes: ['You buckle on a harness; the toy warms and *feels*. The succubus moans as you take her hard.'],
          lp: 6, lust: 10,
          condition: { key: 'strapped', name: 'Strapped', floors: 3,
                       effects: { 'strength' => 2, 'victory_lp_bonus' => 2 } }
        },
        alt: {
          label: 'Receive', text: 'Let her peg you', needs_tag: 'anal',
          scenes: ['She buckles on a thick toy and bends you over, taking you slow and deep until you are babbling.'],
          lp: 7, lust: 14,
          condition: { key: 'well_pegged', name: 'Well-Pegged', floors: 3,
                       effects: { 'submission' => 1, 'submit_lp_bonus' => 3 } }
        },
        decline: { label: 'Leave', text: 'Leave the rack', lust: 2,
                   scene: 'The succubus waves you off with a pout.' }
      },
      'glory_booth' => {
        name: 'Glory Booth', tag: 'facials', tracker: 'facial_events',
        blurb: 'a velvet booth with a single stool.',
        intro: 'A velvet booth with a stool at face height. A voice outside promises a generous tip.',
        accept: {
          label: 'Take a seat', text: 'Take it on the face',
          scenes: ['You sit, eyes closed, as your visitor finishes across your face in hot, thick ropes.',
                   'A tip jingles into the booth as you wipe your eyes.'],
          lp: 6, lust: 10,
          condition: { key: 'glazed_face', name: 'Glazed Face', floors: 2,
                       effects: { 'submit_lp_bonus' => 2, 'agility' => -1 } }
        },
        decline: { label: 'Leave', text: 'Leave the booth', lust: 1,
                   scene: 'You pass by the booth.' }
      },
      'foot_worship_chamber' => {
        name: 'Foot Worship Chamber', tag: 'feet', tracker: 'foot_fetish_events',
        blurb: 'a plush chair beside a basin of warm oil.',
        intro: 'A plush chair and a basin of fragrant oil. Kneeling attendants look up hopefully at your boots.',
        accept: {
          label: 'Sit back', text: 'Have your feet worshipped',
          scenes: ['The attendants oil, knead, kiss, and suck your toes until your whole body hums with relaxed pleasure.'],
          lp: 5, lust: 8,
          condition: { key: 'pampered_soles', name: 'Pampered Soles', floors: 3,
                       effects: { 'agility' => 2, 'flee_bonus' => 0.1 } }
        },
        decline: { label: 'Keep walking', text: 'Keep your boots on', lust: 1,
                   scene: 'The attendants sigh as you walk on.' }
      },
      'orgy_room' => {
        name: 'Orgy Room', tag: 'group_sex', tracker: 'group_sex_events',
        blurb: 'moans echo from a room of tangled bodies.',
        intro: 'A sprawling room of cushions and tangled bodies. Many hands reach out to pull you in.',
        accept: {
          label: 'Join in', text: 'Dive into the pile',
          scenes: ['You are passed from partner to partner, filled and touched from every side at once, lost in a sea of pleasure.',
                   'You stumble out hours later, sore and glowing.'],
          lp: 8, lust: 16,
          condition: { key: 'afterglow', name: 'Afterglow', floors: 2,
                       effects: { 'healing_mult' => 1.2, 'lust_mult' => 1.1, 'hit_lp' => 1 } }
        },
        decline: { label: 'Back out', text: 'Politely back out', lust: 4,
                   scene: 'You tear yourself away from the heat.' },
        fight: { label: 'Fend them off', type: :demon, text: 'One of the revellers — a demon — does not take no for an answer!' }
      },
      'public_chamber' => {
        name: 'Public Chamber', tag: 'exhibitionism', tracker: 'public_play_events',
        blurb: 'a glass-walled room on a busy corridor.',
        intro: 'A glass room beside a busy corridor full of passing monsters. A bed sits in the middle.',
        accept: {
          label: 'Put on a show', text: 'Pleasure yourself in plain view',
          scenes: ['You touch yourself on the bed while monsters press against the glass to watch, egging you on.'],
          lp: 6, lust: 12,
          condition: { key: 'emboldened', name: 'Emboldened', floors: 3,
                       effects: { 'strength' => 1, 'victory_lp_bonus' => 2, 'encounter_rate' => 1.15 } }
        },
        decline: { label: 'Keep moving', text: 'Stay out of sight', lust: 1,
                   scene: 'You hurry past the glass.' }
      },
      'viewing_chamber' => {
        name: 'Viewing Chamber', tag: 'voyeurism', tracker: 'voyeurism_events',
        blurb: 'a peephole glows in the wall.',
        intro: 'A small peephole glows in the wall. Through it, you hear someone having a *very* good time.',
        accept: {
          label: 'Peek', text: 'Watch through the hole',
          scenes: ['You press your eye to the hole and watch a pair of monsters go at it. You can\'t look away — or keep your hands still.'],
          lp: 5, lust: 12,
          condition: { key: 'voyeurs_thrill', name: 'Voyeur\'s Thrill', floors: 2,
                       effects: { 'treasure_lp' => 3, 'explore_lp' => 1 } }
        },
        decline: { label: 'Move on', text: 'Give them privacy', lust: 2,
                   scene: 'You leave them to it.' }
      },
      'feasting_chamber' => {
        name: 'Feasting Chamber', tag: 'weight_gain', tracker: 'weight_gain_events',
        blurb: 'a banquet table groans with food.',
        intro: 'A banquet of rich, enchanted food. Every bite, a menu promises, *stays with you*.',
        accept: {
          label: 'Feast', text: 'Eat your fill',
          scenes: ['You eat and eat, and the food settles softly onto your hips, belly, and rear.',
                   'Heavier and pleasantly plush, you waddle on.'],
          lp: 5, lust: 8, special: :weight_gain,
          condition: { key: 'well_fed', name: 'Well-Fed', floors: 3,
                       effects: { 'max_hp_bonus' => 15, 'agility' => -2 } }
        },
        decline: { label: 'Skip it', text: 'Resist the feast', lust: 1,
                   scene: 'Your stomach rumbles in protest.' }
      },
      'bestial_pool' => {
        name: 'Bestial Pool', tag: 'furry', tracker: 'furry_events',
        blurb: 'a pool shimmering with animal spirits.',
        intro: 'A moonlit pool where animal spirits play. Bathers, it is said, come out a little *wilder*.',
        accept: {
          label: 'Bathe', text: 'Let the spirits change you',
          scenes: ['Soft fur ripples across your skin; ears perk up on your head and a tail sways behind you.',
                   'You feel wild, quick, and in heat.'],
          lp: 6, lust: 12,
          condition: { key: 'furred', name: 'Furred', floors: 4,
                       effects: { 'agility' => 1, 'strength' => 1, 'beast_lust_mult' => 1.1, 'beast_dodge_bonus' => 0.05 } }
        },
        decline: { label: 'Stay dry', text: 'Walk around the pool', lust: 1,
                   scene: 'The spirits splash after you.' },
        fight: { label: 'Fight the guardian', type: :beast, text: 'A great wolf-spirit rises from the water!' }
      }
    }.freeze

    KEYS = EVENTS.keys.freeze
    TAGS = EVENTS.transform_values { |e| e[:tag] }.freeze

    SWAPS = {
      'Male' => { name: 'Female', add: %w[vagina breasts], remove: %w[penis] },
      'Male (FtM)' => { name: 'Female', add: %w[vagina breasts], remove: %w[penis] },
      'Female' => { name: 'Male', add: %w[penis], remove: %w[vagina breasts] },
      'Female (MtF)' => { name: 'Male', add: %w[penis], remove: %w[vagina breasts] }
    }.freeze

    FUTA_CONDITION = { key: 'futa_blessing', name: 'Futa Blessing', floors: 4, effects: { 'strength' => 1 } }.freeze

    EFFECT_LABELS = {
      'strength' => 'STR', 'agility' => 'AGI', 'resistance' => 'RES', 'submission' => 'Submission',
      'max_hp_bonus' => 'max defiance'
    }.freeze

    module_function

    def event(key)
      EVENTS[key.to_s]
    end

    def event?(key)
      EVENTS.key?(key.to_s)
    end

    def available?(player, key)
      spec = event(key) or return false
      case spec[:requires]
      when nil then true
      when :swappable then SWAPS.key?(player.gender.to_s)
      else player.body_parts_list.map(&:to_s).include?(spec[:requires].to_s)
      end
    end

    def choices(player, key)
      spec = event(key) or return []
      list = []
      list << choice_button('accept', spec[:accept], :primary)
      list << choice_button('alt', spec[:alt], :primary) if spec[:alt] && option_allowed?(player, spec[:alt])
      list << choice_button('fight', spec[:fight], :danger) if spec[:fight]
      list << choice_button('decline', spec[:decline], :secondary)
      list
    end

    def choice_button(key, opt, style)
      { key: key, label: opt[:label], text: opt[:text], style: style }
    end

    def option_allowed?(player, opt)
      return false if opt[:needs_tag] && !Engine::ContentOptions.enabled?(player, opt[:needs_tag])
      return false if opt[:needs_part] && !player.body_parts_list.map(&:to_s).include?(opt[:needs_part])

      true
    end

    def start!(player, key, level)
      spec = event(key)
      player.store_event!(type: key, level: level, mode: 'choice', name: spec[:name])
      {
        ok: true,
        mode: :choice,
        name: spec[:name],
        colour: COLOUR,
        log: ["**Floor #{level}** — #{spec[:blurb]}", { scene: spec[:intro] }, 'What do you do?'],
        choices: choices(player, key)
      }
    end

    def resolve!(player, key, choice, level, log)
      spec = event(key)
      case choice
      when 'fight'
        return { ok: false, retry: true } unless spec[:fight]

        log << { scene: spec[:fight][:text] }
        { ok: true, fight: spec[:fight][:type] }
      when 'decline'
        decline!(player, key, spec, level, log)
      when 'accept', 'alt'
        opt = spec[choice.to_sym]
        return { ok: false, retry: true } unless opt && (choice == 'accept' || option_allowed?(player, opt))

        accept!(player, key, spec, opt, level, log)
        { ok: true }
      else
        { ok: false, retry: true }
      end
    end

    def decline!(player, key, spec, level, log)
      opt = spec[:decline]
      if opt[:escape]
        chance = player.trap_avoid_chance
        if rand >= chance
          log << "You're not quick enough! _(AGI #{player.effective_agility} · #{(chance * 100).round}% to escape)_"
          accept!(player, key, spec, spec[:accept], level, log)
          return { ok: true }
        end
        player.bump_tracker!('traps_avoided')
      end
      log << { scene: opt[:scene] } if opt[:scene]
      lust = opt[:lust].to_i
      if lust.positive?
        player.gain_lust!(lust)
        log << "Just the temptation leaves you warm — lust **+#{lust}** (now #{player.lust})."
      end
      { ok: true }
    end

    def accept!(player, _key, spec, opt, level, log)
      parts = player.body_parts_list.map(&:to_s)
      Array(opt[:scenes]).each { |s| log << { scene: s } }
      Hash(opt[:parts]).each { |part, s| log << { scene: s } if parts.include?(part) }

      apply_special!(player, opt[:special], log) if opt[:special]

      lp = opt[:lp].to_i + (level / 3)
      lust = opt[:lust].to_i + (level / 2)
      player.gain_lp!(lp) if lp.positive?
      player.gain_lust!(lust) if lust.positive?
      bits = []
      bits << "**+#{lp} LP**" if lp.positive?
      bits << "lust **+#{lust}** (now #{player.lust})"
      if opt[:defiance].to_i.negative?
        player.adjust_defiance!(opt[:defiance].to_i)
        bits << "defiance **#{opt[:defiance]}** (now #{player.defiance}/#{player.max_defiance})"
      end
      log << bits.join(' · ')

      apply_condition!(player, opt[:condition], log) if opt[:condition]
      Array(spec[:tracker]).each { |t| player.bump_tracker!(t) }
      player.bump_tracker!('fetish_events_accepted')
    end

    def apply_condition!(player, cond, log, parts: [], remove_parts: [])
      summary = describe_effects(cond[:effects])
      player.add_condition!(cond[:key], name: cond[:name], floors: cond[:floors], effects: cond[:effects],
                                        summary: summary, parts: parts, remove_parts: remove_parts)
      log << "**Condition — #{cond[:name]}** _(#{cond[:floors]} floors)_: #{summary}"
    end

    def apply_special!(player, special, log)
      case special
      when :bimbo then grow!(player, player.body_parts_list.map(&:to_s).include?('breasts') ? 'breasts' : 'butt', log)
      when :weight_gain then grow!(player, 'butt', log)
      when :living_clothing then grant_living_clothing!(player, log)
      when :chastity then grant_chastity!(player, log)
      when :futa then futa!(player, log)
      when :gender_swap then gender_swap!(player, log)
      end
    end

    def grow!(player, part, log)
      return if Engine::ContentOptions.max_size?(player, part)

      old, new = Engine::ContentOptions.step_size(player, part, 1)
      sizes = player.body_sizes.is_a?(Hash) ? player.body_sizes.dup : {}
      player.update(body_sizes: sizes.merge(part => new))
      label = Engine::ContentOptions::BODY_SIZES[part][:label].downcase
      log << "_Your #{label} grew: **#{old} → #{new}** (change it any time in `/options`)._"
    end

    def grant_living_clothing!(player, log)
      Engine::Treasure.sync_to_db!
      owned = player.equipment_dataset.select_map(Sequel[:equipment][:name])
      tpl = Engine::Treasure::LIVING_CLOTHING.reject { |t| owned.include?(t[:name]) }.sample
      unless tpl
        log << '_You already wear every living outfit the tower offers — this one slinks away, sulking._'
        return
      end
      item = ::Equipment.first(name: tpl[:name])
      result = player.grant_equipment!(item, auto_equip: true)
      player.bump_tracker!('living_clothing_acquired') if result[:ok]
      log << "**#{item.name}** binds itself to you! _(cursed · removal #{item.removal_cost} LP)_ #{result[:message]}"
    end

    def grant_chastity!(player, log)
      Engine::Treasure.sync_to_db!
      item = ::Equipment.first(name: 'Chastity Belt')
      if item.nil? || player.owns_equipment?(item.id)
        apply_condition!(player, { key: 'locked_tight', name: 'Locked Tight', floors: 3,
                                   effects: { 'deny_climax' => true, 'submission' => 1 } }, log)
        return
      end
      result = player.grant_equipment!(item, auto_equip: true)
      log << "**Chastity Belt** locks on! Climaxes are **denied** while you wear it " \
             "_(removal #{item.removal_cost} LP)_. #{result[:message]}"
    end

    def futa!(player, log)
      parts = player.body_parts_list.map(&:to_s)
      cond = FUTA_CONDITION
      if parts.include?('penis')
        log << '_You already have what the goddess offers — so she makes it bigger._'
        grow!(player, 'penis', log)
        apply_condition!(player, cond, log)
      else
        log << '_You have grown a cock for the next few floors._'
        apply_condition!(player, cond, log, parts: %w[penis])
      end
    end

    def gender_swap!(player, log)
      swap = SWAPS[player.gender.to_s] or return
      apply_condition!(player, { key: 'mirror_changed', name: "Mirror-Changed (#{swap[:name]})", floors: 4,
                                 effects: { 'agility' => 1 } }, log,
                       parts: swap[:add], remove_parts: swap[:remove])
      log << "_Your body is **#{swap[:name].downcase}** for the next few floors._"
    end

    def describe_effects(effects)
      Hash(effects).map { |k, v| describe_effect(k.to_s, v) }.join(', ')
    end

    def describe_effect(key, value)
      pct = ->(v) { "#{v.positive? ? '+' : ''}#{(v * 100).round}%" }
      signed = ->(v) { "#{v.positive? ? '+' : ''}#{v}" }
      type = key[/\A(beast|demon|slime|undead|plant|mimic)_/, 1]
      label = type ? "vs #{type}s" : nil
      case key
      when *EFFECT_LABELS.keys then "#{EFFECT_LABELS[key]} #{signed.(value)}"
      when 'lust_mult' then "lust taken ×#{value}"
      when /_lust_mult\z/ then "lust taken #{label} ×#{value}"
      when 'satisfy_bonus' then "satisfy #{pct.(value)}"
      when 'submit_lp_bonus' then "+#{value} LP on submit"
      when /_submit_lp\z/ then "+#{value} LP submitting #{label}"
      when 'no_flee' then "can't flee"
      when 'flee_bonus' then "flee #{pct.(value)}"
      when 'dodge_bonus' then "dodge #{pct.(value)}"
      when /_dodge_bonus\z/ then "dodge #{label} #{pct.(value)}"
      when 'victory_lp_bonus' then "+#{value} LP per fight ended"
      when 'hit_lp' then "+#{value} LP per hit taken"
      when 'explore_lp' then "+#{value} LP per floor"
      when 'treasure_lp' then "+#{value} LP from treasure"
      when 'healing_mult' then "healing ×#{value}"
      when 'encounter_rate' then "monster rooms ×#{value}"
      when 'deny_climax' then 'climaxes denied'
      else "#{key} #{value}"
      end
    end
  end
end
