# frozen_string_literal: true

%w[core body kink fetish].each { |pack| require_relative "event_packs/#{pack}" }

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
          scenes: ['Pink light floods your head like warm fizz. Your thoughts go giggly and soft, your lips swelling into a plump, ' \
                   'cock-sucking pout made for deepthroating. Your waist narrows dramatically while your hips flare out into wide, ' \
                   'breeding hips.',
                   'You catch yourself twirling your hair and giggling at nothing, instinctively striking poses meant to show off your ' \
                   'new body. Every thought in your head is about cock, about getting fucked, about being a perfect bimbo fucktoy.'],
          parts: { 'breasts' => 'Your tits balloon into heavy, oversized fuck-melons, the nipples swollen and permanently stiff, aching ' \
                                'to be sucked and bitten.',
                   'vagina' => 'Your cunt goes slick and stays that way, dripping down your thighs with every bouncy step.',
                   'penis' => 'Your cock stays half-hard and eager, twitching at every giggle that leaves your lips.' },
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
        intro: 'You discover a room filled with strange pumping devices. One of them stirs as you approach, ' \
               'its slick hose twisting toward you with a life of its own, dripping warm, thick fluid...',
        accept: {
          label: 'Let it connect', text: 'Get pumped full',
          scenes: ['The hose slides into you and begins to pump. You feel yourself expanding with every pulse, warm syrup filling you ' \
                   'deeper and deeper. Your stomach distends dramatically, the skin stretched tight as the liquid floods your insides.',
                   'Your skin stretches tight as you grow rounder and fuller, the pressure inside making it hard to breathe. Every ' \
                   'movement makes you slosh and blush as your swollen belly gurgles audibly, the fullness pressing on your bladder ' \
                   'until you squirm with need.'],
          lp: 5, lust: 12,
          condition: { key: 'stuffed', name: 'Stuffed Full', floors: 2,
                       effects: { 'agility' => -2, 'max_hp_bonus' => 10 } }
        },
        decline: { label: 'Dodge', text: 'Try to dodge the nozzles (AGI)', lust: 2, escape: true,
                   scene: 'You twist away from the hose and slip out of the room before it can latch on.' },
        fight: { label: 'Burst it', type: :slime, text: 'The nozzles belong to a bloated slime — and it wants you!' }
      },
      'living_clothing' => {
        name: 'Living Clothing', tag: 'living_clothing', tracker: nil,
        blurb: 'a wardrobe of clothes that sway on their own.',
        intro: 'You enter a room filled with clothing that moves on its own, rippling as if breathing. ' \
               'As you watch, a few pieces detach themselves from their hangers and drift toward you, sizing you up...',
        accept: {
          label: 'Try it on', text: 'Wear the living outfit (cursed gear)',
          scenes: ['You let the living clothes dress you. The material tightens and shifts against your skin with a will of its own, ' \
                   'sealing itself to you with a satisfied shiver. The fabric becomes a second skin, moulding to every curve and hollow.',
                   'Almost at once it starts to tease — tendrils of fabric form and begin stroking, pinching your nipples, even pressing ' \
                   'against your asshole. The clothes never stop moving, keeping you in a constant state of arousal.'],
          parts: { 'vagina' => 'A ridge of fabric settles between your folds and rubs your clit in slow, maddening circles.',
                   'penis' => 'A snug pouch forms around your cock and strokes it lazily, never quite enough.' },
          lp: 4, lust: 10, special: :living_clothing
        },
        decline: { label: 'Leave it', text: 'Leave it hanging', lust: 2,
                   scene: 'You carefully weave around the drifting clothes. They droop sadly back onto their hangers as you leave.' },
        fight: { label: 'Rip it apart', type: :mimic, text: 'The outfit lunges — it was a mimic all along!' }
      },
      'beast_taming' => {
        name: 'Beast Taming', tag: 'petplay', tracker: 'petplay_events',
        blurb: 'a leather collar hangs from a hook.',
        intro: 'You enter a chamber full of training equipment — bowls, leashes, a padded mat. A pack of watchful beasts lounges around it, ' \
               'and their alpha pads forward with a gleaming collar in its mouth, eyes full of desire to make you its pet...',
        accept: {
          label: 'Accept the collar', text: 'Become the pack\'s pet',
          scenes: ['You kneel as the alpha fastens the collar around your neck. The cool metal feels both restrictive and comforting ' \
                   'as it locks with a definitive click.',
                   'It begins to train you — teaching you to present yourself on all fours, to take its knot when it mounts you, to ' \
                   'swallow its seed when offered. Every act of obedience sends a thrill through you as the pack takes turns using ' \
                   'your mouth and ass. *Good pet.*'],
          parts: { 'vagina' => 'The alpha claims your cunt for itself, mounting you again and again until you are dripping with its seed.' },
          lp: 5, lust: 12,
          condition: { key: 'good_pet', name: 'Good Pet', floors: 3,
                       effects: { 'beast_lust_mult' => 0.8, 'beast_submit_lp' => 3, 'flee_bonus' => -0.1 } }
        },
        decline: { label: 'Refuse the collar', text: 'Leave the pack be', lust: 2,
                   scene: 'You step away from the alpha. It drops the collar with a disappointed huff and lets you go.' },
        fight: { label: 'Challenge the alpha', type: :beast, text: 'The alpha bares its teeth and charges!' }
      },
      'rubber_chamber' => {
        name: 'Rubber Chamber', tag: 'latex', tracker: 'latex_events',
        blurb: 'the walls gleam with black gloss.',
        intro: 'Glossy liquid latex pools on the floor, rising in slow tendrils that reflect your silhouette.',
        accept: {
          label: 'Be encased', text: 'Let the latex coat you',
          scenes: ['The latex flows up your body and tightens into a flawless, squeaking second skin. It seals over you completely, ' \
                   'covering your eyes and leaving only your mouth and holes exposed.',
                   'Every touch through the rubber feels muffled yet electric. The latex pulses around your nipples, milking them ' \
                   'relentlessly as it squeezes your body in a constant, gleaming embrace.'],
          parts: { 'vagina' => 'A slick nub of rubber presses against your clit and throbs in time with the rest of the suit.',
                   'penis' => 'The latex hugs your cock in a tight, glossy sheath that squeezes with every heartbeat.' },
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
          scenes: ['Her ovipositor slides in slowly, its ridged surface rubbing your insides deliciously as it pushes deep. One by one, ' \
                   'warm, fist-sized eggs travel down the tube, each one stretching you as it slips inside.',
                   'You waddle away heavy and full, your belly visibly swollen with the clutch shifting inside you. Each movement makes ' \
                   'you gasp as the eggs press against each other — a constant reminder that you are now a living incubator.'],
          parts: { 'vagina' => 'She chooses your cunt, pressing each egg past your cervix until your womb is packed full.' },
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
        intro: 'An ornate box sits open on a velvet pedestal, full of gleaming chastity devices. As you approach, a steel belt humming ' \
               'with rune-light lifts into the air and presents itself to you. A tag reads: *"Wear me. Earn your release."*',
        accept: {
          label: 'Lock it on', text: 'Wear the belt (cursed gear: orgasms denied)',
          scenes: ['You let the belt settle around your hips. With a heavy, definitive click it locks in place, sealing away your most ' \
                   'sensitive places. The metal is cold against your skin, and you know it is not coming off.',
                   'The denial sends strange waves through you — the more aroused you get, the more the lock itself becomes the pleasure, ' \
                   'the sensation of being unable to orgasm turning into its own kind of ecstasy.'],
          parts: { 'penis' => 'Your cock is caged snugly away, swelling against the steel as precum leaks from the tip.',
                   'vagina' => 'A smooth shield seals over your folds, humming faintly as it blocks any penetration while vibrating ' \
                               'maddeningly against your clit.' },
          lp: 8, lust: 12, special: :chastity
        },
        decline: { label: 'Back off', text: 'Leave it (AGI to avoid the trap)', lust: 2, escape: true,
                   scene: 'The belt lunges — and snaps shut on empty air as you twist away.' }
      },
      'hypnotic_mist' => {
        name: 'Hypnotic Mist', tag: 'mind_control', tracker: 'mind_control_events',
        blurb: 'violet mist swirls in hypnotic spirals.',
        intro: 'Violet mist spirals around you, and disembodied voices echo through it, offering relief from the burden of choice, ' \
               'counting slowly down from ten...',
        accept: {
          label: 'Open your mind', text: 'Let the voices sink in',
          scenes: ['*Nine... eight...* You relax your defences and let the voices guide your thoughts. Your own will drifts somewhere ' \
                   'distant as the hypnotic suggestions take root.',
                   'Freedom from responsibility brings a pleasure you never expected — your body answers their commands as if they were ' \
                   'your own desires. You find yourself dropping to your knees, presenting yourself to any creature that passes, your ' \
                   'mind empty except for the desire to obey and be used.'],
          lp: 5, lust: 12,
          condition: { key: 'entranced', name: 'Entranced', floors: 2,
                       effects: { 'submission' => 2, 'no_flee' => true, 'submit_lp_bonus' => 3 } }
        },
        decline: { label: 'Hold your breath', text: 'Try to push through (AGI)', lust: 2, escape: true,
                   scene: 'You fight off the intrusive whispers and dash through the mist with your breath held.' },
        fight: { label: 'Find the hypnotist', type: :demon, text: 'You spot the demon weaving the mist!' }
      },
      'glory_room' => {
        name: 'Glory Room', tag: 'bukkake', tracker: 'bukkake_events',
        blurb: 'a ring of holes lines the walls.',
        intro: 'A circular room lined with openings. As you step inside, eager cocks begin to emerge from them — far too many to count — ' \
               'all clearly intent on covering you with their cum...',
        accept: {
          label: 'Kneel in the centre', text: 'Take them all',
          scenes: ['You kneel in the centre of the room as they spill across your body, one after another, until you are dripping and ' \
                   'glazed. Hot, thick ropes of cum cover your face, chest, and stomach.',
                   'Being covered so completely marks you as *claimed*. Degradation and adoration blur together as the warm, thick ' \
                   'loads keep coming. You open your mouth to drink what you can, tasting the varied flavours of your anonymous lovers.'],
          lp: 7, lust: 14,
          condition: { key: 'glazed', name: 'Glazed', floors: 2,
                       effects: { 'hit_lp' => 1, 'lust_mult' => 1.1 } }
        },
        decline: { label: 'Leave', text: 'Leave the room', lust: 3,
                   scene: 'You decide against it and slip back out. Disappointed groans follow you down the corridor.' }
      },
      'observation_deck' => {
        name: 'Observation Deck', tag: 'exhibitionism', tracker: 'exhibitionism_events',
        blurb: 'a lit stage faces rows of hidden eyes.',
        intro: 'A spotlight snaps on over a small stage. You can\'t see the watchers, but you can *feel* their collective gaze on you, ' \
               'the air thickening with their attention as they wait for a show...',
        accept: {
          label: 'Perform', text: 'Give them a show',
          scenes: ['You strip slowly under the spotlight, revealing yourself to the unseen audience. Their attention lands on you like ' \
                   'physical touches, making your skin tingle and your body answer with growing heat.',
                   'Being seen so completely by so many awakens something in you — the exposure becomes its own kind of intimacy. You ' \
                   'spread your legs wide and touch yourself for their viewing pleasure, and coins of lust-light rain onto the stage ' \
                   'when you finish.'],
          lp: 7, lust: 10,
          condition: { key: 'on_display', name: 'On Display', floors: 3,
                       effects: { 'victory_lp_bonus' => 3, 'encounter_rate' => 1.2 } }
        },
        decline: { label: 'Stay hidden', text: 'Slip off the stage', lust: 2,
                   scene: 'The weight of all those eyes is too much. You cover yourself and duck away as the spotlight flickers off.' }
      },
      'giants_chamber' => {
        name: 'Giant\'s Chamber', tag: 'giant', tracker: 'body_growth_events',
        blurb: 'purple crystals pulse beside a colossal throne.',
        intro: 'Strange purple crystals jut from the floor around a colossal throne. As you approach, their energy pulses with invitation, ' \
               'and you already feel larger, stronger, more *powerful*...',
        accept: {
          label: 'Touch the crystals', text: 'Grow huge',
          scenes: ['Power surges through you the moment you touch them. You shoot upward, towering and thick-limbed, every inch of you ' \
                   'swollen with strength, your muscles bulging until you feel god-like.',
                   'Looking down at the suddenly tiny room fills you with dominion — this size feels more *right* than your old one. ' \
                   'You are impossibly powerful, and impossibly sensitive to every touch against your enormous body.'],
          parts: { 'breasts' => 'Your breasts swell in proportion, massive and heavy, swaying with every thunderous step.',
                   'penis' => 'Your cock grows to match, a huge, heavy length that throbs between your thighs.' },
          lp: 5, lust: 10,
          condition: { key: 'towering', name: 'Towering', floors: 3,
                       effects: { 'strength' => 3, 'agility' => -2 } }
        },
        decline: { label: 'Leave it', text: 'Stay your size', lust: 1,
                   scene: 'You give the crystals a wide berth. Their glow dims forlornly as you pass.' }
      },
      'shrinking_chamber' => {
        name: 'Shrinking Chamber', tag: 'shrinking', tracker: 'body_reduction_events',
        blurb: 'pale mushrooms puff glittering spores.',
        intro: 'Pale mushrooms carpet this room, puffing clouds of glittering spores beside a door no taller than your knee. ' \
               'The air grows thick with them, and every breath makes you feel dizzy... and a little smaller.',
        accept: {
          label: 'Breathe in', text: 'Shrink down',
          scenes: ['You breathe deep, and with every exhale you shrink — until you are only a few inches tall and the world towers ' \
                   'over you, every part of you tiny and perfectly in proportion.',
                   'A curious giantess scoops you up and plays with you like a doll, your helplessness thrillingly arousing as she rubs ' \
                   'her giant nipples against your tiny body before setting you gently down. Small, quick, and flushed, you slip ' \
                   'through the tiny door.'],
          lp: 5, lust: 10,
          condition: { key: 'pocket_sized', name: 'Pocket-Sized', floors: 3,
                       effects: { 'agility' => 3, 'strength' => -2, 'dodge_bonus' => 0.1 } }
        },
        decline: { label: 'Leave it', text: 'Stay your size', lust: 1,
                   scene: 'You hold your breath and hurry past the mushrooms before the spores can take hold.' }
      },
      'futa_fountain' => {
        name: 'Futa Fountain', tag: 'futanari', tracker: 'futanari_events',
        blurb: 'a fountain shaped like a well-endowed goddess.',
        intro: 'Warm water shimmers with strange energy as it flows from a statue of a gloriously endowed goddess. ' \
               'The air around the fountain hums with transformation magic, promising to make you *complete*...',
        accept: {
          label: 'Drink', text: 'Receive the goddess\'s gift',
          scenes: ['The water tastes sweet and fills you with warmth, and heat blooms between your legs as the magic takes hold.',
                   'You gasp at the new, heavy weight there — a thick, perfect cock with full balls beneath, already leaking precum.'],
          parts: { 'vagina' => 'Your clit throbs just beneath your new shaft, both of them aching for attention at once.' },
          lp: 6, lust: 14, special: :futa
        },
        decline: { label: 'Refuse', text: 'Don\'t drink', lust: 2,
                   scene: 'The crackle of magic makes you wary. You splash your face and move on without drinking.' }
      },
      'living_furniture' => {
        name: 'Living Furniture', tag: 'objectification', tracker: 'objectification_events',
        blurb: 'a room of eerily lifelike furniture.',
        intro: 'The chairs, tables, and lamps in this room are made from *people*. In the centre, an empty pedestal glows softly, ' \
               'beckoning you toward a new form of existence...',
        accept: {
          label: 'Become furniture', text: 'Take your place on the pedestal',
          scenes: ['You step onto the pedestal and magic envelops you, folding you into a footstool. You can still feel everything — ' \
                   'you just can\'t move, your mouth held open at the top of the stool.',
                   'Passers-by rest their feet on you, wipe their boots on your tongue, and set drinks on your back. The helplessness is ' \
                   'strangely comforting, and when the spell lifts you are stiff, flushed, and tasting leather and wine.'],
          lp: 6, lust: 10,
          condition: { key: 'furniture_mindset', name: 'Furniture Mindset', floors: 2,
                       effects: { 'resistance' => 3, 'agility' => -2, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Walk through', text: 'Ignore the pedestal', lust: 1,
                   scene: 'You reject the pedestal\'s call and pick your way carefully through the room. The furniture watches you leave.' },
        fight: { label: 'Smash it', type: :mimic, text: 'A chair lurches up on too many legs!' }
      },
      'mirror_of_change' => {
        name: 'Mirror of Change', tag: 'gender_bending', tracker: 'gender_bending_events',
        blurb: 'a mirror shows someone almost like you.',
        intro: 'A tall magic mirror shows not your reflection, but *you* as the opposite sex. The reflection winks, ' \
               'and reaches a hand out of the glass, promising a whole new perspective...',
        requires: :swappable,
        accept: {
          label: 'Take its hand', text: 'Swap bodies with your reflection (temporary)',
          scenes: ['The moment your fingers touch, transformation magic tingles through every inch of you. Your chest, your hips, and ' \
                   'everything between your legs melt and reshape themselves into their mirror image.',
                   'You step through the glass and out the other side — strange and thrilling and new. Your new parts tingle with ' \
                   'sensitivity as you explore them.'],
          lp: 6, lust: 12, special: :gender_swap
        },
        decline: { label: 'Refuse', text: 'Stay as you are', lust: 1,
                   scene: 'You keep your hands to yourself. The reflection shrugs and becomes just a reflection again.' }
      },
      'milking_chamber' => {
        name: 'Milking Chamber', tag: 'lactation', tracker: 'being_milked_events',
        blurb: 'brass pumps hiss rhythmically.',
        intro: 'A padded stall full of contraptions built to draw fluids from living bodies. A machine of brass pumps and suction cups ' \
               'hisses awake as you approach, its attachments extending toward you. A little plaque promises generous payment.',
        accept: {
          label: 'Get milked', text: 'Strap in and be milked',
          scenes: ['The pumps latch on and pull in a slow, relentless rhythm, the ache blurring into overwhelming pleasure.',
                   'Your body answers by giving more than you thought possible. The machine purrs, pleased with your output.'],
          parts: { 'breasts' => 'Your breasts swell and ache as the cups tug, milk spraying in thick white jets from your dark, swollen nipples.',
                   'penis' => 'A sleeve seals around your cock and milks you dry, again and again, drawing thick ropes of cum from your ' \
                              'balls relentlessly.' },
          caged: :milking,
          lp: 10, lust: 12,
          condition: { key: 'drained', name: 'Drained', floors: 2,
                       effects: { 'max_hp_bonus' => -10, 'treasure_lp' => 3 } }
        },
        decline: { label: 'Leave', text: 'Leave the stall', lust: 2,
                   scene: 'You twist free of the reaching cups and back out of the stall. The pumps sigh to a stop.' }
      },
      'breeding_chamber' => {
        name: 'Breeding Chamber', tag: 'breeding', tracker: 'impregnation_events',
        blurb: 'a fertility altar hums with warm light.',
        intro: 'This room was built for one purpose: breeding. A soft altar glows with fertility runes, and beside it waits a beast ' \
               'of immense size and virility, snorting eagerly as its intent becomes very clear...',
        accept: {
          label: 'Lie on the altar', text: 'Let the beast breed you',
          scenes: ['You present yourself on the altar. The beast mounts you, its massive cock stretching you as it sinks deep. Its knot ' \
                   'swells inside you, locking you together as it begins to breed you properly.',
                   'It pumps you full of thick, hot seed until you can feel it sloshing inside you. Your belly glows faintly afterward — ' \
                   'warm, full, and blissfully bred.'],
          parts: { 'vagina' => 'You can feel its seed take root in your womb, your body already eager to carry its offspring.' },
          lp: 7, lust: 14,
          condition: { key: 'bred', name: 'Bred', floors: 3,
                       effects: { 'healing_mult' => 1.25, 'agility' => -1, 'beast_submit_lp' => 2 } }
        },
        decline: { label: 'Refuse', text: 'Leave the altar', lust: 2,
                   scene: 'You back away from the altar. The beast snorts, frustrated, and lies back down.' },
        fight: { label: 'Fight the beast', type: :beast, text: 'The beast rears up, refusing to let you go!' }
      },
      'nectar_fountain' => {
        name: 'Nectar Fountain', tag: 'lactation', tracker: 'lactation_events',
        blurb: 'a fountain of sweet, milky nectar.',
        intro: 'A fountain burbles with sweet, creamy nectar, and just standing near it makes your breasts tingle. ' \
               'One sip, a sign says, and you will *overflow*.',
        requires: 'breasts',
        accept: {
          label: 'Drink deep', text: 'Drink the nectar',
          scenes: ['The nectar makes your breasts swell heavy and full, aching and sensitive. They grow rapidly, the skin stretching ' \
                   'tight as milk begins to bead at your nipples.',
                   'Soon your tits leak with every step, warm milk running down your stomach in thick rivulets — a constant, ' \
                   'pleasurable reminder of your changed body.'],
          lp: 6, lust: 12,
          condition: { key: 'nectar_swollen', name: 'Nectar-Swollen', floors: 3,
                       effects: { 'max_hp_bonus' => 10, 'lust_mult' => 1.1 } }
        },
        decline: { label: 'Walk away', text: 'Don\'t drink', lust: 1,
                   scene: 'You resist the sweet smell and walk on, your chest still tingling.' }
      },
      'golden_chamber' => {
        name: 'Golden Chamber', tag: 'watersports', tracker: 'watersports_events',
        blurb: 'a tiled room with a golden drain.',
        intro: 'A tiled room with a golden drain, where the creatures mark what they love with warm golden streams. ' \
               'A grinning demon approaches, its invitation unmistakable — it wants to *mark* you as its own.',
        accept: {
          label: 'Be marked', text: 'Accept the golden shower',
          scenes: ['Warm streams splash over you as the demon marks you thoroughly, the golden liquid running down your face, chest, ' \
                   'and stomach before collecting in the drain.',
                   'Its scent clings to you — a warning to some, an invitation to others. You open your mouth to catch some, tasting ' \
                   'it as it fills your mouth, marking you from the inside out.'],
          lp: 6, lust: 10,
          condition: { key: 'marked', name: 'Marked', floors: 2,
                       effects: { 'satisfy_bonus' => 0.1, 'demon_lust_mult' => 0.9 } }
        },
        decline: { label: 'Refuse', text: 'Leave', lust: 1,
                   scene: 'You refuse its advance. The demon seems disappointed, but shrugs and lets you go.' }
      },
      'binding_room' => {
        name: 'Binding Room', tag: 'bondage', tracker: 'bondage_events',
        blurb: 'silken ropes hang from the ceiling.',
        intro: 'Chains and silk ropes hang from hooks all over this room. As you step inside they spring to life, ' \
               'slithering toward you with purpose, eager to tie something pretty.',
        accept: {
          label: 'Be tied', text: 'Let the ropes bind you',
          scenes: ['You let the ropes wrap around you. They weave an intricate harness and hoist you into an inescapable embrace, ' \
                   'cinching snugly around your chest, waist, and thighs.',
                   'The helplessness is frustrating and thrilling all at once, the ropes pressing against your most sensitive places ' \
                   'every time you squirm. When they finally let go, pretty rope marks remain, criss-crossing your body like lace.'],
          lp: 6, lust: 12,
          condition: { key: 'rope_marks', name: 'Rope Marks', floors: 2,
                       effects: { 'resistance' => 2, 'agility' => -2, 'flee_bonus' => -0.1 } }
        },
        decline: { label: 'Slip past', text: 'Dodge the ropes (AGI)', lust: 2, escape: true,
                   scene: 'You struggle against the living ropes, dart between them, and escape before they can catch you.' }
      },
      'discipline_room' => {
        name: 'Discipline Room', tag: 'spanking', tracker: 'discipline_events',
        blurb: 'a stern figure taps a riding crop.',
        intro: 'Implements of punishment line the walls of this room. A stern demon mistress steps forward, tapping a crop against her palm, ' \
               'her eyes full of purpose. *"You have been naughty, haven\'t you?"*',
        accept: {
          label: 'Accept punishment', text: 'Bend over and take it',
          scenes: ['You bend over the discipline bench as instructed. She lays into you with crisp, stinging strokes, the crop ' \
                   'landing across your ass and inner thighs with perfect accuracy.',
                   'With every stroke your body answers with more arousal, the sting blurring into pleasure until the punishment feels ' \
                   'like a reward. You find yourself begging for more, your body trembling with need. When she finishes, you thank ' \
                   'her — and mean it.'],
          lp: 7, lust: 10, defiance: -5,
          condition: { key: 'disciplined', name: 'Well-Disciplined', floors: 3,
                       effects: { 'strength' => 1, 'resistance' => 1, 'submission' => 1 } }
        },
        decline: { label: 'Refuse', text: 'Refuse her', lust: 2,
                   scene: 'You respectfully decline. She tuts and lets you go — *this* time.' },
        fight: { label: 'Defy her', type: :demon, text: 'Her eyes flash. *"Oh, a brat. Wonderful."*' }
      },
      'public_shame' => {
        name: 'Public Shame', tag: 'humiliation', tracker: 'humiliation_events',
        blurb: 'a pillory stands in a crowded square.',
        intro: 'A pillory stands in an illusory town square full of phantoms. The moment you appear they start commenting on your body — ' \
               'your shape, your anatomy — with a cruel laughter that somehow sends a thrill through you. A sign invites volunteers.',
        accept: {
          label: 'Step into the stocks', text: 'Endure the crowd',
          scenes: ['Locked in the stocks, you listen to their cruel words, and instead of anger, you feel heat. They laugh, tease, and ' \
                   'grope, fingers pinching your nipples and probing your holes, laughing as you moan despite yourself.',
                   'Mocking as it is, their attention makes you feel *desired*. By the end your face burns — and so does the rest of ' \
                   'you, your body responding to every humiliating touch.'],
          parts: { 'breasts' => '"Look at those udders," one jeers, squeezing your breasts while the others laugh.',
                   'vagina' => '"What a needy little cunt," another sneers, spreading you open for the whole crowd to see.',
                   'penis' => '"Look how hard that pathetic cock is," someone laughs, flicking it while you whimper.' },
          lp: 7, lust: 12,
          condition: { key: 'shamed', name: 'Shamed', floors: 2,
                       effects: { 'lust_mult' => 1.1, 'victory_lp_bonus' => 2, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Walk away', text: 'Ignore the jeers', lust: 2,
                   scene: 'You refuse to let their words touch you and walk on. Boos follow you out of the square.' }
      },
      'whispering_chamber' => {
        name: 'Whispering Chamber', tag: 'mindbreak', tracker: 'mindbreak_events',
        blurb: 'a thousand soft voices whisper at once.',
        intro: 'A thousand disembodied voices whisper from the walls, picking apart your identity and your purpose. ' \
               'Their sweet, filthy words offer relief from the burden of *self* — stop thinking, and it will all feel so good.',
        accept: {
          label: 'Stop thinking', text: 'Let your thoughts melt',
          scenes: ['You listen, and the whispers begin to wear away who you were. Your old self fades until there is no room for ' \
                   'anything else. Pleasure. Obedience. Pleasure. Your body throbs as your mind empties.',
                   'In its place you find peace in emptiness, and the silence in your head is bliss. You drift out blank, with a dopey ' \
                   'smile, your body responding automatically to any touch, any command, ready to be used.'],
          lp: 7, lust: 14,
          condition: { key: 'hollow_thoughts', name: 'Hollow Thoughts', floors: 3,
                       effects: { 'submission' => 2, 'resistance' => -1, 'submit_lp_bonus' => 4, 'satisfy_bonus' => 0.1 } }
        },
        decline: { label: 'Cover your ears', text: 'Run through (AGI)', lust: 2, escape: true,
                   scene: 'You clamp your hands over your ears and sprint through, leaving the whispers behind.' },
        fight: { label: 'Silence them', type: :undead, text: 'The whispers coalesce into a lustful wraith!' }
      },
      'sensory_void' => {
        name: 'Sensory Void', tag: 'sensory_deprivation', tracker: 'sensory_deprivation_events',
        blurb: 'a padded room of total darkness and silence.',
        intro: 'A padded room of total darkness and silence. Your senses already start to fade at the threshold, ' \
               'and a blindfold and earplugs wait by the door, offering to take the rest — leaving you with nothing but touch.',
        accept: {
          label: 'Put them on', text: 'Surrender to touch alone',
          scenes: ['You let the darkness swallow your senses, leaving you vulnerable and dependent on touch alone. Your nipples ' \
                   'harden immediately, your whole body throbbing in anticipation.',
                   'Blind and deaf, you float in nothing — until unseen hands begin to touch you, every caress magnified tenfold. They ' \
                   'explore every inch of your body, probing every hole and pinching every sensitive spot. The isolation feels ' \
                   'strangely comforting as you give in completely.'],
          lp: 6, lust: 14,
          condition: { key: 'heightened_touch', name: 'Heightened Touch', floors: 2,
                       effects: { 'lust_mult' => 1.15, 'dodge_bonus' => 0.05, 'hit_lp' => 2 } }
        },
        decline: { label: 'Leave', text: 'Keep your senses', lust: 1,
                   scene: 'You feel your way back out of the darkness, to where your senses work properly.' }
      },
      'auction_block' => {
        name: 'Auction Block', tag: 'slavery', tracker: 'slavery_events',
        blurb: 'a demon auctioneer bangs a gavel.',
        intro: 'You stumble into an auction where eager bidders crowd a stage. The demon auctioneer spots you and gestures to the block. ' \
               '*"Such a fine specimen! Shall we start the bidding?"*',
        accept: {
          label: 'Step up', text: 'Be sold (for a night)',
          scenes: ['You step onto the block and present yourself. Being appraised and bid on thrills you in ways you never expected ' \
                   'as hands probe and mouths taste.',
                   'The winner leads you off by a chain and enjoys their purchase thoroughly — the feeling of being *owned* is oddly ' \
                   'comforting as they use every hole you have, then pass you around to their friends.'],
          lp: 12, lust: 12,
          condition: { key: 'owned', name: 'Owned', floors: 3,
                       effects: { 'submission' => 1, 'submit_lp_bonus' => 3, 'flee_bonus' => -0.15 } }
        },
        decline: { label: 'Refuse', text: 'Walk off the stage', lust: 2,
                   scene: 'You slip away before anyone can place a bid. The crowd groans.' },
        fight: { label: 'Fight the auctioneer', type: :demon, text: 'The auctioneer snarls and lunges!' }
      },
      'strap_on_chamber' => {
        name: 'Strap-On Chamber', tag: 'pegging', tracker: 'strap_on_events',
        blurb: 'a rack of enchanted harnesses.',
        intro: 'Enchanted strap-ons hum on a rack along the wall, twitching as if they have a will of their own. ' \
               'An eager succubus waits beside them, happy to give — or receive.',
        accept: {
          label: 'Wear one', text: 'Strap on and take charge',
          scenes: ['A harness wraps itself around your waist and settles into place as if it were made for you. The toy warms and ' \
                   '*feels*, its veins pulsing as it becomes part of you.',
                   'A strange sense of power fills you with your new length. The succubus moans as you take her hard, stretching her ' \
                   'as you pound into her until the toy floods her with its enchanted seed.'],
          lp: 6, lust: 10,
          condition: { key: 'strapped', name: 'Strapped', floors: 3,
                       effects: { 'strength' => 2, 'victory_lp_bonus' => 2 } }
        },
        alt: {
          label: 'Receive', text: 'Let her peg you', needs_tag: 'anal',
          scenes: ['She buckles on a thick toy and bends you over, taking you slow and deep until you are babbling, its ribs rubbing ' \
                   'every sensitive spot inside you.',
                   'Your body betrays you as you beg for more — harder, deeper. She laughs, flips you over, and pounds your ass into ' \
                   'blissful submission.'],
          parts: { 'penis' => 'Every thrust grinds the toy against your prostate, your cock bouncing and leaking untouched.' },
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
        intro: 'A velvet booth with a stool at face height. Several eager cocks wait beyond its openings, and a sign above ' \
               'promises a generous tip to anyone who lets them decorate their face.',
        accept: {
          label: 'Take a seat', text: 'Take it on the face',
          scenes: ['You sit, eyes closed, and present your face. One after another they finish across it in hot, thick ropes, coating ' \
                   'your cheeks, forehead, and hair.',
                   'Being marked like this excites you deeply as the cum drips down your face, some landing on your tongue when you ' \
                   'open your mouth to breathe. A tip jingles into the booth as you wipe your eyes.'],
          lp: 6, lust: 10,
          condition: { key: 'glazed_face', name: 'Glazed Face', floors: 2,
                       effects: { 'submit_lp_bonus' => 2, 'agility' => -1 } }
        },
        decline: { label: 'Leave', text: 'Leave the booth', lust: 1,
                   scene: 'You decide the booth isn\'t for you and walk on.' }
      },
      'foot_worship_chamber' => {
        name: 'Foot Worship Chamber', tag: 'feet', tracker: 'foot_fetish_events',
        blurb: 'a plush chair beside a basin of warm oil.',
        intro: 'Pillows cover the floor around a plush chair and a basin of fragrant oil. Kneeling attendants look up hopefully at your boots, ' \
               'practically trembling with the wish to serve.',
        accept: {
          label: 'Sit back', text: 'Have your feet worshipped',
          scenes: ['You sink into the chair and offer your feet. The attendants oil, knead, kiss, and suck your toes with reverent ' \
                   'devotion, their tongues slipping between each one.',
                   'They purr at every flex of your soles, and soon their mouths move higher, kissing and licking their way up your ' \
                   'calves as their hands massage your arches, sending waves of pleasure through your body.'],
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
        intro: 'A sprawling chamber of cushions where creatures tangle together in every act imaginable. They notice you, ' \
               'bodies glistening with sweat and desire, and many hands reach out to pull you in.',
        accept: {
          label: 'Join in', text: 'Dive into the pile',
          scenes: ['You let them pull you down. Hands, mouths, and more explore you from every direction as you are passed from ' \
                   'partner to partner, mouths on your chest, cocks filling your holes.',
                   'The overwhelming attention drives you from peak to peak, lost in the pleasure of serving so many. You stumble out ' \
                   'hours later sticky, sore, and glowing.'],
          lp: 8, lust: 16,
          condition: { key: 'afterglow', name: 'Afterglow', floors: 2,
                       effects: { 'healing_mult' => 1.2, 'lust_mult' => 1.1, 'hit_lp' => 1 } }
        },
        decline: { label: 'Back out', text: 'Politely back out', lust: 4,
                   scene: 'You watch from the edge for a while, then tear yourself away from the heat.' },
        fight: { label: 'Fend them off', type: :demon, text: 'One of the revellers — a demon — does not take no for an answer!' }
      },
      'public_chamber' => {
        name: 'Public Chamber', tag: 'exhibitionism', tracker: 'public_play_events',
        blurb: 'a glass-walled room on a busy corridor.',
        intro: 'A glass room beside a busy corridor full of passing monsters, with a bed in the middle. ' \
               'As you step inside you feel eyes on you from every side, their attention prickling over your skin like touch.',
        accept: {
          label: 'Put on a show', text: 'Pleasure yourself in plain view',
          scenes: ['You give them a show, touching yourself on the bed while monsters press against the glass to watch, egging you on ' \
                   'with crude comments.',
                   'The thrill of being watched by so many, without knowing who, is as nerve-racking as it is intoxicating as you ' \
                   'spread yourself wide and let them see everything.'],
          lp: 6, lust: 12,
          condition: { key: 'emboldened', name: 'Emboldened', floors: 3,
                       effects: { 'strength' => 1, 'victory_lp_bonus' => 2, 'encounter_rate' => 1.15 } }
        },
        decline: { label: 'Keep moving', text: 'Stay out of sight', lust: 1,
                   scene: 'You squirm under all those gazes and hurry past the glass.' }
      },
      'viewing_chamber' => {
        name: 'Viewing Chamber', tag: 'voyeurism', tracker: 'voyeurism_events',
        blurb: 'a one-way window glows in the wall.',
        intro: 'A one-way window looks into the next chamber, where a pair of monsters is having a *very* good time. ' \
               'You could watch without ever being seen, their private moments laid bare before you...',
        accept: {
          label: 'Watch', text: 'Watch through the glass',
          scenes: ['You settle in at the window and watch them go at it, every secret, unguarded moment on display, their bodies ' \
                   'writhing together in a frenzy of lust.',
                   'The thrill of seeing what you\'re not meant to see is intoxicating. You can\'t look away — or keep your hands from ' \
                   'straying as you touch yourself in rhythm with their coupling.'],
          lp: 5, lust: 12,
          condition: { key: 'voyeurs_thrill', name: 'Voyeur\'s Thrill', floors: 2,
                       effects: { 'treasure_lp' => 3, 'explore_lp' => 1 } }
        },
        decline: { label: 'Move on', text: 'Give them privacy', lust: 2,
                   scene: 'You tear your eyes from the glass and leave them to it.' }
      },
      'feasting_chamber' => {
        name: 'Feasting Chamber', tag: 'weight_gain', tracker: 'weight_gain_events',
        blurb: 'a banquet table groans with food.',
        intro: 'Tables groan under a banquet of rich, enchanted food, the air thick with delicious smells. ' \
               'Soft voices whisper that the feast has special properties — every bite *stays with you*.',
        accept: {
          label: 'Feast', text: 'Eat your fill',
          scenes: ['You indulge, eating far more than you thought possible, and with every bite you feel yourself grow softer and ' \
                   'larger. Your belly rounds out, your thighs thicken, your ass widens.',
                   'Heavier and pleasantly plush, you waddle on, your new body jiggling with each step and your clothes straining — ' \
                   'and the change feels natural and good.'],
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
        intro: 'A moonlit pool where animal spirits play. Your reflection in the water wears ears and a tail, ' \
               'and it beckons you in, promising a wilder, more natural form...',
        accept: {
          label: 'Step in', text: 'Let the spirits change you',
          scenes: ['You step into the pool and feel yourself changing. Soft fur ripples across your skin; ears perk up on your head ' \
                   'and a tail sways behind you.',
                   'The transformation feels natural and *right*. You feel wild, quick, and in heat, your animal instincts taking over ' \
                   'as your new body responds with intense sensitivity to every touch.'],
          lp: 6, lust: 12, special: :beastkin,
          condition: { key: 'furred', name: 'Furred', floors: 4,
                       effects: { 'agility' => 1, 'strength' => 1, 'beast_lust_mult' => 1.1, 'beast_dodge_bonus' => 0.05 } }
        },
        decline: { label: 'Stay dry', text: 'Walk around the pool', lust: 1,
                   scene: 'You decide against changing and walk around the pool. The spirits splash after you.' },
        fight: { label: 'Fight the guardian', type: :beast, text: 'A great wolf-spirit rises from the water!' }
      },
      'overstimulation_engine' => {
        name: 'Overstimulation Engine', tag: 'overstimulation', tracker: 'overstim_events',
        blurb: 'a padded chair hums with restless machinery.',
        intro: 'A padded chair sits in the middle of the room, bristling with soft arms, humming wands and slick, waiting ' \
               'sleeves. A brass plaque on the back reads: *ONE IS NEVER ENOUGH.*',
        accept: {
          label: 'Sit down', text: 'Two orgasms back to back (big defiance cost)',
          scenes: ['Straps close softly over your wrists and ankles the moment you sit. The machine wakes all at once, every arm ' \
                   'finding a sensitive spot and working it with relentless, mechanical patience.',
                   'It drags you over the edge and simply keeps going. Your first orgasm is still rolling through you when it ' \
                   'starts building the next, ignoring how you twitch and beg.'],
          parts: {
            'vagina' => 'A humming wand presses flat against your clit and never lets up, not even while you squirm and squirt ' \
                        'around the slick shaft pumping in and out of you.',
            'penis' => 'A tight, slick sleeve works your cock from root to tip, faster and faster, wringing you through one orgasm ' \
                       'and straight into the next while your oversensitive shaft throbs.',
            'breasts' => 'Little suction cups latch onto your nipples and pulse, tugging them stiff and swollen.'
          },
          lp: 10, lust: 0, special: :overstimulate,
          condition: { key: 'oversensitive', name: 'Oversensitive', floors: 2,
                       effects: { 'lust_mult' => 1.2, 'submit_lp_bonus' => 3 } }
        },
        decline: { label: 'Back away', text: 'Leave the chair alone', lust: 4,
                   scene: 'You back out of the room. Behind you the machine keeps humming, patient.' },
        fight: { label: 'Smash it', type: :mimic, text: 'The chair lurches toward you on stubby legs. It was a mimic all along!' }
      },
      'tickle_trap' => {
        name: 'Tickle Trap', tag: 'tickling', tracker: 'tickling_events',
        blurb: 'feathers drift down from the ceiling.',
        intro: 'Soft feathers rain from the ceiling, and a dozen imps peek out of holes in the walls, each holding a long quill ' \
               'and wearing a wicked grin.',
        accept: {
          label: 'Let them', text: 'Get tickled senseless',
          scenes: ['The imps pounce. Padded stocks close around your ankles and wrists, and feathers find your soles, your ribs, ' \
                   'your armpits and the backs of your knees all at once. You shriek with helpless laughter.',
                   'Just when you think you cannot take any more, the feathers drift lower, trailing over your inner thighs and ' \
                   'between your legs, and your giggles melt into moans.'],
          parts: {
            'vagina' => 'One feather flicks your clit over and over, and you squirm and giggle and drip all at once.',
            'penis' => 'A feather traces your cock from balls to tip, and it twitches and leaks while you laugh yourself breathless.',
            'breasts' => 'Two imps tease your nipples with the very tips of their quills until they stand stiff and you are gasping.'
          },
          lp: 5, lust: 12,
          condition: { key: 'tickled_pink', name: 'Tickled Pink', floors: 2,
                       effects: { 'agility' => -1, 'submission' => 1, 'satisfy_bonus' => 0.05 } }
        },
        decline: { label: 'Run for it', text: 'Dash past before they grab you', lust: 2, escape: true,
                   scene: 'You bolt past the imps before they can catch you, their giggles chasing you down the hall.' }
      },
      'sissy_boutique' => {
        name: 'Sissy Boutique', tag: 'sissification', tracker: 'sissy_events',
        blurb: 'a dressing room full of frills and lace.',
        intro: 'Racks of frilly dresses, lace panties and thigh-high stockings fill the room. A floating vanity mirror flutters ' \
               'its painted lashes at you. "Oh, sweetie," it coos. "Let me make you *pretty*."',
        accept: {
          label: 'Get dolled up', text: 'Lace, lipstick, and curtsy lessons',
          scenes: ['Ribbons lace you into a tight pink corset and a skirt so short it barely covers anything. Stockings slide up ' \
                   'your legs, and the mirror paints your lips glossy pink while invisible hands pin bows in your hair.',
                   'Then come the lessons: how to curtsy, how to bat your lashes, how to kneel prettily and say *thank you* ' \
                   'afterwards. By the end you are doing all of it without being told.'],
          parts: {
            'penis' => 'A pair of silky pink panties hugs your cock, the lace rubbing it with every swish of your skirt until a ' \
                       'damp spot spreads across the front.',
            'vagina' => 'Lace panties cling to your folds, already damp, and the mirror giggles at how wet being made pretty has made you.',
            'breasts' => 'A padded lace bra lifts and squeezes your breasts together, framing them perfectly.'
          },
          lp: 6, lust: 10,
          condition: { key: 'sissified', name: 'Sissified', floors: 3,
                       effects: { 'submission' => 1, 'agility' => 1, 'strength' => -1 } }
        },
        decline: { label: 'Decline', text: 'Leave the frills on the rack', lust: 2,
                   scene: 'You leave the frills where they hang. The mirror sighs. "Such a waste of a pretty face."' }
      },
      'corrupting_font' => {
        name: 'Corrupting Font', tag: 'corruption', tracker: 'corruption_events',
        blurb: 'black water glimmers in a carved basin.',
        intro: 'A basin of glossy black water sits on a pedestal carved with writhing, coupling figures. It smells of sex and ' \
               'sweet smoke, and soft whispers rise from it, promising that giving in would feel *so* much better than fighting.',
        accept: {
          label: 'Drink', text: 'Let the taint in (+3 Corruption)',
          scenes: ['The water slides down your throat like warm honey, and heat floods straight between your legs. Filthy thoughts ' \
                   'bloom in your head, and for a long moment you cannot remember why you were resisting at all.'],
          lp: 8, lust: 15, special: :corrupt
        },
        alt: {
          label: 'Purge', text: 'Force some taint out (-3 Corruption, -10 defiance)',
          scenes: ['You plunge your hands into the black water and force the whispers back, gritting your teeth as the taint you ' \
                   'have gathered drains out through your fingertips. It leaves you shaking and spent.'],
          lust: 5, defiance: -10, special: :purify
        },
        decline: { label: 'Leave', text: 'Walk away from the whispers', lust: 3,
                   scene: 'You turn away. The whispers follow you a long way down the corridor.' }
      },
      'scribe_imps' => {
        name: 'Scribe Imps', tag: 'body_writing', tracker: 'body_writing_events',
        blurb: 'ink pots and brushes litter the floor.',
        intro: 'A gaggle of ink-stained imps lounges around a writing desk. They look you up and down, giggling, brushes already ' \
               'dripping. "Hold still," one says. "We\'re going to label you properly."',
        accept: {
          label: 'Hold still', text: 'Let them write on you',
          scenes: ['The imps swarm over you with their brushes, the cool ink tickling as they write across your skin. You crane ' \
                   'your neck to read it and blush hot.',
                   'They finish with a row of tally marks down your thigh, one for every creature that has had you, and promise to ' \
                   'keep count.'],
          parts: {
            'breasts' => 'One imp writes something filthy in an arc over your breasts and draws a little arrow at each nipple.',
            'vagina' => 'An arrow is painted down your belly toward your pussy, labelled in neat capitals: *INSERT HERE*.',
            'penis' => 'Someone writes a crude rating along the length of your cock and giggles at their own joke.',
            'anus' => 'Across your ass, in big looping letters, they write *FREE USE* and sign it with a flourish.'
          },
          lp: 5, lust: 8, special: :body_writing
        },
        decline: { label: 'Shoo them', text: 'Keep your skin clean', lust: 2,
                   scene: 'You shoo the imps away. They blow raspberries and flick ink at the walls.' }
      },
      'musk_den' => {
        name: 'Musk Den', tag: 'musk', tracker: 'musk_events',
        blurb: 'the air turns thick and heady.',
        intro: 'The air in this den is hot and heavy with the musk of something big that sleeps here often. One breath and your ' \
               'head swims; two and your body starts to ache.',
        accept: {
          label: 'Breathe deep', text: 'Roll in the scent',
          scenes: ['You sink into the nest of furs and breathe deep. The musk goes straight to your groin, and before long you are ' \
                   'grinding against the bedding, soaking up the smell.',
                   'By the time you leave you reek of it, and you can feel every beast on the floor turning its head to follow you.'],
          parts: {
            'vagina' => 'Your pussy throbs and drips just from the scent, slick soaking into the furs beneath you.',
            'penis' => 'Your cock goes rock hard and stays that way, leaking as you rut against the musky furs.'
          },
          lp: 6, lust: 14,
          condition: { key: 'musk_drunk', name: 'Musk-Drunk', floors: 3,
                       effects: { 'beast_lust_mult' => 1.15, 'beast_submit_lp' => 4, 'lust_mult' => 1.05 } }
        },
        decline: { label: 'Hold your breath', text: 'Hurry through', lust: 4,
                   scene: 'You hold your breath and hurry through. Even so, the scent clings to you for a floor or two.' },
        fight: { label: 'Wake the owner', type: :beast, text: 'The den\'s owner wakes, sniffs the air, and comes for you!' }
      },
      'fire_and_ice' => {
        name: 'Fire and Ice', tag: 'temperature', tracker: 'temperature_events',
        blurb: 'one half of the room is frosted, the other glows warm.',
        intro: 'The chamber is split down the middle: one side glitters with frost, the other is lit by dozens of fat, dripping ' \
               'candles. A pale spirit beckons from the ice, and a glowing one from the candlelight.',
        accept: {
          label: 'Ice', text: 'Let the frost spirit play',
          scenes: ['The frost spirit traces an ice cube down your spine and over your chest, leaving a trail of shivers and ' \
                   'goosebumps. Every warm breath it blows afterwards makes you gasp.'],
          parts: {
            'breasts' => 'It circles your nipples with ice until they are stiff and aching, then warms them with its mouth.',
            'vagina' => 'It slides a smooth ice cube along your slit and over your clit, and you squirm as it melts against your heat.',
            'penis' => 'It runs the ice along the underside of your cock, then wraps it in a warm hand, and the contrast makes you throb.'
          },
          lp: 5, lust: 12,
          condition: { key: 'chilled', name: 'Chilled', floors: 2, effects: { 'resistance' => 1, 'agility' => -1 } }
        },
        alt: {
          label: 'Wax', text: 'Let the candle spirit play',
          scenes: ['The candle spirit tips a candle over you, and warm wax drips onto your skin in slow splashes, each one a soft ' \
                   'bloom of heat that makes you sigh and arch.',
                   'It paints a winding trail of wax down your body, then peels it away slowly, leaving your skin flushed and tingling.'],
          lp: 6, lust: 14,
          condition: { key: 'wax_kissed', name: 'Wax-Kissed', floors: 2, effects: { 'submission' => 1, 'satisfy_bonus' => 0.05 } }
        },
        decline: { label: 'Leave', text: 'Neither, thanks', lust: 2, scene: 'You back out of the room. Both spirits pout.' }
      },
      'colossus_lair' => {
        name: 'Colossus Lair', tag: 'size_difference', tracker: 'size_events',
        blurb: 'something huge shifts in the dark.',
        intro: 'A towering ogre lounges in the lair, three times your height, and when it stands its cock hangs as thick as your ' \
               'arm. It looks at you, then down at itself, and grins. "Think you can take it?"',
        accept: {
          label: 'Find out', text: 'Take it',
          scenes: ['It lifts you like a doll, and the sheer size of it pressing against you makes your breath catch. *There is no ' \
                   'way*, you think, and then it starts to push.',
                   'Inch by inch it stretches you wider than you thought possible, until you are stuffed so full you can feel ' \
                   'your own heartbeat around it.'],
          parts: {
            'vagina' => 'Your pussy stretches obscenely around its girth, and every slow thrust drags a helpless cry out of you.',
            'anus' => 'It works its way into your ass inch by inch until you are gaping around it, trembling and full.',
            'penis' => 'It wraps one huge hand around your cock, and the whole thing disappears inside its fist.'
          },
          lp: 8, lust: 16,
          condition: { key: 'stretched', name: 'Stretched', floors: 2, effects: { 'satisfy_bonus' => 0.1, 'agility' => -1 } }
        },
        decline: { label: 'Back away', text: 'You very much cannot take it', lust: 3,
                   scene: 'You decide you very much cannot take it and back out. The ogre\'s laughter shakes the walls.' },
        fight: { label: 'Fight it', type: :beast, text: 'The ogre roars and charges!' }
      },
      'cum_fountain' => {
        name: 'Cum Fountain', tag: 'cum_play', tracker: 'cum_play_events',
        blurb: 'a fountain gushes something thick and white.',
        intro: 'A marble fountain carved as a ring of well-endowed statues gushes warm, thick cum into a wide basin. The air ' \
               'smells of salt and sex.',
        accept: {
          label: 'Bathe', text: 'Climb into the basin',
          scenes: ['You sink into the basin and the statues turn toward you, pumping hot, sticky cum over your face, your chest and ' \
                   'your thighs until you are plastered in it.',
                   'You scoop it up and smear it over your skin, licking it from your fingers and letting it drip from your chin.'],
          parts: {
            'vagina' => 'One statue presses its marble cock into your pussy and fills you until warm cum spills out around it and ' \
                        'down your thighs.',
            'anus' => 'Another fills your ass, pumping until it leaks out of you in slow, sticky trickles.'
          },
          lp: 7, lust: 14,
          condition: { key: 'cum_drenched', name: 'Cum-Drenched', floors: 2,
                       effects: { 'submit_lp_bonus' => 2, 'lust_mult' => 1.1 } }
        },
        alt: {
          label: 'Drink', text: 'Drink straight from a statue', needs_tag: 'oral',
          scenes: ['You wrap your lips around a statue\'s cock and drink, swallowing mouthful after mouthful of warm, salty cum ' \
                   'until you are warm all the way through.'],
          lp: 6, lust: 10,
          condition: { key: 'cum_fed', name: 'Cum-Fed', floors: 2, effects: { 'max_hp_bonus' => 10, 'submission' => 1 } }
        },
        decline: { label: 'Leave', text: 'Resist the urge', lust: 3,
                   scene: 'You resist the urge to dip a finger in and walk on.' }
      },
      'jeering_gallery' => {
        name: 'Jeering Gallery', tag: 'degradation', tracker: 'degradation_events',
        blurb: 'a balcony full of sneering imps.',
        intro: 'A balcony of imps looks down at you as you walk in, jeering and catcalling. "Look at it," one sneers. "Bet it\'s ' \
               'dripping already." The rest howl with laughter.',
        accept: {
          label: 'Agree with them', text: 'Kneel and admit what you are',
          scenes: ['You kneel in the middle of the room and repeat every filthy name they shout at you: slut, toy, hole, whore. ' \
                   'Each one makes your face flush and your body ache harder.',
                   'By the end you are begging them to call you worse, and they happily oblige.'],
          parts: {
            'vagina' => 'They point out how wet you are, loudly and in great detail, and all you can do is nod.',
            'penis' => 'They laugh at how hard you are and how much you are leaking, and all you can do is nod.'
          },
          lp: 8, lust: 12,
          condition: { key: 'broken_pride', name: 'Broken Pride', floors: 3,
                       effects: { 'submission' => 2, 'resistance' => -1, 'submit_lp_bonus' => 3 } }
        },
        alt: {
          label: 'Beg for praise', text: 'Earn their approval instead',
          scenes: ['You perform for them until the jeers turn into coos: *good pet*, *such a pretty thing*, *so obedient*. Every ' \
                   'word of praise makes you flush with pride and want.'],
          lp: 6, lust: 10,
          condition: { key: 'good_pet', name: 'Good Pet', floors: 3, effects: { 'resistance' => 1, 'satisfy_bonus' => 0.05 } }
        },
        decline: { label: 'Ignore them', text: 'Head high, walk on', lust: 2,
                   scene: 'You walk through with your head held high. The jeers follow you out.' }
      },
      'pool_of_becoming' => {
        name: 'Pool of Becoming', tag: 'monster_transformation', tracker: 'monster_form_events',
        blurb: 'a pool shimmers with shifting colours.',
        intro: 'A pool in the floor shifts between colours: slime green, petal pink, hellfire red. Half-formed bodies of the ' \
               'tower\'s creatures swirl beneath the surface, inviting you to become one of them.',
        accept: {
          label: 'Wade in', text: 'Let it remake you for a few floors',
          scenes: ['The liquid climbs your body as you wade in, sinking warm into your skin, and you feel yourself begin to change.'],
          lp: 6, lust: 12, special: :monster_form
        },
        decline: { label: 'Stay out', text: 'Keep your own body', lust: 2,
                   scene: 'You step back from the edge. The shapes beneath the surface sink away, disappointed.' }
      },
      'monster_manor' => {
        name: 'Monster Manor', tag: 'maid_service', tracker: 'maid_events',
        blurb: 'a lavish hall with a maid\'s uniform laid out.',
        intro: 'A lavish hall, set for a feast that never ends. A uniform is laid out on a chair, black and white and very short, ' \
               'and a bell rings somewhere upstairs. The house expects service.',
        accept: {
          label: 'Serve', text: 'Put on the uniform and get to work',
          scenes: ['The uniform barely covers you, and every time you bend to dust a shelf or pour the wine, a hand finds its way ' \
                   'under your skirt.',
                   'By the end of the evening the master of the house has bent you over the dining table and thanked you very ' \
                   'warmly for your service.'],
          parts: {
            'vagina' => 'He takes you right there on the tablecloth, your pussy clenching around his cock while the candles flicker.',
            'anus' => 'He spreads you over the table and fucks your ass in front of the empty chairs, your little skirt flipped ' \
                      'up over your back.',
            'penis' => 'He strokes your cock under your apron until you are leaking all over the clean linen.'
          },
          lp: 8, lust: 12,
          condition: { key: 'dutiful_maid', name: 'Dutiful Maid', floors: 3, effects: { 'explore_lp' => 2, 'submission' => 1 } }
        },
        decline: { label: 'Decline', text: 'Leave the uniform', lust: 2,
                   scene: 'You leave the uniform on the chair. Upstairs, the bell rings again, irritated.' }
      },
      'the_stables' => {
        name: 'The Stables', tag: 'pony_play', tracker: 'pony_events',
        blurb: 'the smell of leather and hay.',
        intro: 'Rows of stalls, each with a gleaming harness hung on the door. A centaur stablemaster looks you over, tail ' \
               'flicking. "Fine posture," he says. "You\'d make a lovely pony."',
        accept: {
          label: 'Get harnessed', text: 'Bit, bridle, and a tail',
          scenes: ['He buckles you into a leather harness, slips a soft bit between your teeth and fits you with a long, swishing ' \
                   'tail. Then he takes the reins and trots you around the ring until you are flushed and panting.',
                   'When you have done well enough, he rewards you the way stallions do, mounting you in the clean straw.'],
          parts: {
            'anus' => 'The tail is attached to a thick plug that sits snug in your ass and shifts with every high step.',
            'vagina' => 'His huge cock spreads your pussy wide as he mounts you, and you whinny around the bit.',
            'penis' => 'He reaches beneath you and strokes your cock with a gloved hand as you trot.'
          },
          lp: 7, lust: 12,
          condition: { key: 'bridled', name: 'Bridled', floors: 3,
                       effects: { 'agility' => 2, 'flee_bonus' => 0.2, 'submission' => 1 } }
        },
        decline: { label: 'Decline', text: 'You are nobody\'s pony', lust: 2,
                   scene: 'You decline. The stablemaster shrugs and goes back to polishing his tack.' }
      },
      'gagmakers_workshop' => {
        name: 'Gagmaker\'s Workshop', tag: 'gags_hoods', tracker: 'gag_events',
        blurb: 'shelves of straps, gags and hoods.',
        intro: 'Ball gags, ring gags and padded leather hoods line the walls. A quiet craftsman measures you with his eyes. ' \
               '"Silence suits most people," he says. "Let\'s find yours."',
        accept: {
          label: 'Try them on', text: 'Gagged and hooded (no fleeing next floor)',
          scenes: ['He buckles a ball gag between your lips and pulls the strap snug, then lowers a soft leather hood over your ' \
                   'head. Sound goes muffled; the world shrinks to touch and the warmth of your own breath.',
                   'He leaves you like that for a while, drooling around the gag, every brush of his hands making you jump and ' \
                   'moan into the leather.'],
          lp: 7, lust: 10,
          condition: { key: 'gagged', name: 'Gagged', floors: 1, effects: { 'no_flee' => true, 'submit_lp_bonus' => 3 } }
        },
        alt: {
          label: 'Ring gag', text: 'Just the ring gag', needs_tag: 'oral',
          scenes: ['He fits a ring gag that holds your mouth open, and before long he is testing it, sliding his cock between ' \
                   'your stretched lips while you drool down your chin.'],
          lp: 8, lust: 14,
          condition: { key: 'ring_gagged', name: 'Ring-Gagged', floors: 2, effects: { 'submit_lp_bonus' => 4, 'resistance' => -1 } }
        },
        decline: { label: 'Leave', text: 'Keep your voice', lust: 2,
                   scene: 'You thank him politely and leave with your voice intact.' }
      }
    }.merge(EventPacks::CORE, EventPacks::BODY, EventPacks::KINK, EventPacks::FETISH).freeze

    KEYS = EVENTS.keys.freeze
    TAGS = EVENTS.transform_values { |e| e[:tag] }.freeze

    SWAPS = {
      'Male' => { name: 'Female', add: %w[vagina breasts], remove: %w[penis] },
      'Male (FtM)' => { name: 'Female', add: %w[vagina breasts], remove: %w[penis] },
      'Female' => { name: 'Male', add: %w[penis], remove: %w[vagina breasts] },
      'Female (MtF)' => { name: 'Male', add: %w[penis], remove: %w[vagina breasts] }
    }.freeze

    BEASTKIN_ANIMALS = %w[cat wolf rabbit fox bear].freeze

    BODY_WRITING = ['Slut', 'Free Use', 'Fuck Toy', 'Property of the Tower', 'Good Pet', 'Use Me', 'Monster Bait',
                    'Insert Here', 'Needy', 'Open 24/7'].freeze

    MONSTER_FORMS = [
      { scene: 'Your skin turns glossy and faintly translucent, your body soft and yielding, and every touch now sinks into you ' \
               'in the most delicious way. You have become **part slime**.',
        condition: { key: 'slime_touched', name: 'Slime-Touched', floors: 4,
                     effects: { 'slime_lust_mult' => 0.8, 'slime_submit_lp' => 3, 'agility' => 1 } } },
      { scene: 'Small horns curl up from your hair and a spade-tipped tail sways behind you, and an insatiable new hunger ' \
               'settles low in your belly. You have become **part demon**.',
        condition: { key: 'demon_touched', name: 'Demon-Kissed', floors: 4,
                     effects: { 'demon_lust_mult' => 0.8, 'demon_submit_lp' => 3, 'satisfy_bonus' => 0.1 } } },
      { scene: 'Vines curl along your arms and a flower blooms in your hair, and your skin starts to smell sweet, like nectar ' \
               'waiting to be tasted. You have become **part plant**.',
        condition: { key: 'blooming', name: 'Blooming', floors: 4,
                     effects: { 'plant_lust_mult' => 0.8, 'plant_submit_lp' => 3, 'resistance' => 1 } } }
    ].freeze

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
        log: ["**Floor #{level}** — #{spec[:blurb]}", { scene: spec[:intro] },
              *Array(Engine::ChastitySystem.reminder(player)).map { |r| "_#{r}_" }, 'What do you do?'],
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
      parts = spec[:tag] == 'chastity' ? player.body_parts_list.map(&:to_s) : Engine::ChastitySystem.scene_parts(player)
      Array(opt[:scenes]).each { |s| log << { scene: s } }
      Hash(opt[:parts]).each { |part, s| log << { scene: s } if parts.include?(part) }
      log.concat(Engine::ChastitySystem.scenes(player, opt[:caged])) if opt[:caged]

      apply_special!(player, opt[:special], log) if opt[:special]

      lp = opt[:lp].to_i + (level / 3)
      lp = (lp * player.curse_effect_product("#{spec[:tag]}_event_lp_mult", default: 1.0)).round
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
      replaced = player.add_condition!(cond[:key], name: cond[:name], floors: cond[:floors], effects: cond[:effects],
                                                   summary: summary, parts: parts, remove_parts: remove_parts)
      log << "**Condition — #{cond[:name]}** _(#{cond[:floors]} floors)_: #{summary}"
      log << "_#{replaced.map { |n| "**#{n}**" }.join(', ')} fades as your body changes size again._" if replaced.any?
    end

    def apply_special!(player, special, log)
      case special
      when :bimbo then grow!(player, player.body_parts_list.map(&:to_s).include?('breasts') ? 'breasts' : 'butt', log)
      when :weight_gain then grow!(player, 'butt', log)
      when :living_clothing then grant_living_clothing!(player, log)
      when :chastity then grant_chastity!(player, log)
      when :futa then futa!(player, log)
      when :gender_swap then gender_swap!(player, log)
      when :beastkin then log << "_Your body takes on the traits of a **#{BEASTKIN_ANIMALS.sample}**._"
      when :overstimulate then overstimulate!(player, log)
      when :corrupt then Engine::Corruption.add!(player, 3, log)
      when :purify then Engine::Corruption.add!(player, -3, log)
      when :body_writing then body_writing!(player, log)
      when :monster_form then monster_form!(player, log)
      end
    end

    def overstimulate!(player, log)
      player.update(lust: Player::CLIMAX_THRESHOLD + 15)
      first = player.try_climax!
      log.concat(Array(first&.dig(:lines)).reject { |l| l.to_s.start_with?('_') })
      player.update(lust: Player::CLIMAX_THRESHOLD + 10)
      log << '_The machine does not stop. It is already dragging you toward the next one._'
    end

    def body_writing!(player, log)
      words = BODY_WRITING.sample(2)
      words << 'Cum Dump' if Engine::ContentOptions.enabled?(player, 'cum_play') && rand < 0.4
      log << "_Scrawled across your skin: #{words.map { |w| "**#{w}**" }.join(', ')}._"
      apply_condition!(player, { key: 'marked', name: "Marked (#{words.first})", floors: 3,
                                 effects: { 'submit_lp_bonus' => 2, 'hit_lp' => 1 } }, log)
    end

    def monster_form!(player, log)
      form = MONSTER_FORMS.sample
      log << { scene: form[:scene] }
      apply_condition!(player, form[:condition], log)
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
      log << "**Chastity Belt** locks on! Orgasms are **denied** while you wear it " \
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
      log.concat(Engine::ChastitySystem.scenes(player, :futa))
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
      when 'deny_climax' then 'orgasms denied'
      else "#{key} #{value}"
      end
    end
  end
end
