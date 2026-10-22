require_relative 'tower'

module Engine
  module BossFights
    BOSSES = {
      5 => {
        name: 'Mimic Broodmother',
        type: 'mimic',
        type_name: 'Mimic',
        description: 'A chest the size of a carriage, its lid creaking open on a wet, velvet interior lined with writhing tongues. Her brood of little mimics swarms at her feet, eager to drag you in.',
        color: 0x696969,
        strength: 12,
        agility: 4,
        lust_damage: 15,
        hp: 80,
        max_hp: 80,
        special: 'spawns_minions'
      },
      10 => {
        name: 'Succubus Queen',
        type: 'demon',
        type_name: 'Demon',
        description: 'Naked but for jewels and a crown, she lounges on a throne of velvet, her tail lazily stroking her own thigh. Every mortal who comes here ends up kneeling between her legs.',
        color: 0xff00ff,
        strength: 15,
        agility: 12,
        lust_damage: 20,
        hp: 100,
        max_hp: 100,
        special: 'seductive_gaze'
      },
      15 => {
        name: 'Incubus King',
        type: 'demon',
        type_name: 'Demon',
        description: 'Tall, broad and utterly shameless, he sits naked on his throne with his huge, ridged cock already hard. He claims everyone who enters his hall, and they always come back begging.',
        color: 0x800080,
        strength: 18,
        agility: 10,
        lust_damage: 25,
        hp: 120,
        max_hp: 120,
        special: 'dominating_presence'
      },
      20 => {
        name: 'Verdant Dryad',
        type: 'plant',
        type_name: 'Plant',
        description: 'A towering dryad steps out of the great tree at the chamber\'s heart — a voluptuous woman with ' \
                     'smooth bark-brown skin, long leaf-green hair crowned with blooming flowers, and a lush body ' \
                     'barely draped in vines and petals. Her garden catches anyone who wanders close, and her vines ' \
                     'are already reaching for you.',
        color: 0x228b22,
        strength: 20,
        agility: 6,
        lust_damage: 18,
        hp: 150,
        max_hp: 150,
        special: 'root_grasp'
      },
      25 => {
        name: 'Lich Lord',
        type: 'undead',
        type_name: 'Undead',
        description: 'A robed sorcerer of cold bone and blue fire, starved of warmth for a thousand years. His spectral hands can touch you anywhere at once, and he hungers to drink in every gasp of your pleasure.',
        color: 0x4b0082,
        strength: 22,
        agility: 8,
        lust_damage: 22,
        hp: 180,
        max_hp: 180,
        special: 'soul_drain'
      },
      30 => {
        name: 'Alpha Beast',
        type: 'beast',
        type_name: 'Beast',
        description: "The biggest beast in the tower, a mountain of fur and muscle with a cock to match. The whole floor reeks of its musk, and it's been in rut for days, waiting for a new mate.",
        color: 0x8b4513,
        strength: 25,
        agility: 14,
        lust_damage: 30,
        hp: 200,
        max_hp: 200,
        special: 'primal_rage'
      },
      Tower::FINAL_BOSS_FLOOR => {
        name: 'Eros',
        title: 'Eros, Goddess of Lust',
        type: 'eldritch',
        type_name: 'Goddess of Lust',
        description: 'The goddess for whom this tower was raised — its temple, its clergy, and its cycles all ' \
                     'answering to her — towers over her throne of gold and silk — pale ' \
                     'ash-grey hair in bangs marked with crimson hearts, massive pitch-black horns sweeping from her ' \
                     'crown, and deep red eyes glowing above a cruel, confident smile. A thick black choker hugs her ' \
                     'throat, and where a cape should fall, enormous smooth white tentacles coil and writhe behind ' \
                     'her, their undersides a wet crimson-magenta lined with glistening suckers that move with lives ' \
                     'of their own. She wears a glossy white high-cut bodysuit with puff sleeves, dark piping, a ' \
                     'red heart over her chest, a split mantle flaring white outside and dark red within, heavy black ' \
                     'cuffs on her wrists, and sheer white thigh-highs bound in tattered wraps above bare feet that ' \
                     'fade into purplish-pink. Every sin below flows up into her. "There you are, pet. Did you really ' \
                     'think the top was a door?"',
        color: 0x5c0a2e,
        strength: 28,
        agility: 16,
        lust_damage: 35,
        hp: 260,
        max_hp: 260,
        special: 'tower_dominion',
        final: true
      }
    }.freeze

    # Relic bosses are not clergy and hold no domain: they are sacred
    # objects the temple keeps — votive things saturated with so much
    # offered lust that they woke up hungry. From cycle 2, a priest's
    # chamber is sometimes found empty, its relic left to hold the
    # threshold in the lord's absence. The pool is data-driven so new
    # relics can be added without touching the assignment logic.
    RELIC_CHANCE = 0.30
    RELIC_CAP_PER_CYCLE = 2

    RELICS = {
      'pale_bride' => {
        name: 'Pale Bride', type: 'undead', type_name: 'Relic · Undead', color: 0xd9d9e8,
        special: 'bouquet_toss', trophy: 'Veil of the Pale Bride', affinity: [10, 25],
        hp_mult: 0.9, strength_mult: 0.95, agility_mult: 0.9, lust_mult: 1.15,
        object: 'a bridal veil and gown arranged over the empty throne, bouquet in hands that are not there',
        awakening: 'The veil turns toward you — slowly, the way a face turns — and the gown rises from the throne wearing the shape of a woman who has waited a hundred years to be looked at.'
      },
      'mirror_queen' => {
        name: 'Mirror Queen', type: 'mimic', type_name: 'Relic · Mimic', color: 0xaec6cf,
        special: 'mirror_reflection', trophy: 'Shard of the Mirror Queen', affinity: [5, 10],
        hp_mult: 1.0, strength_mult: 1.0, agility_mult: 1.1, lust_mult: 1.05,
        object: 'a tall mirror in a tarnished crown of a frame, standing where the lord should be — and your own face is already smiling out of it',
        awakening: 'Your reflection does not wait to copy you. It takes a step you did not take — out of the glass, wearing your body, your face, and every part of you, arranged into someone who has come to collect you.'
      },
      'empty_confessional' => {
        name: 'Empty Confessional', type: 'demon', type_name: 'Relic · Demon', color: 0x6b4a8a,
        special: 'sin_eater', trophy: 'Screen of the Empty Confessional', affinity: [10, 15],
        hp_mult: 0.95, strength_mult: 0.9, agility_mult: 1.0, lust_mult: 1.1,
        object: 'a curtained confessional booth, its screen dark, with two worn kneelers facing each other across a century of whispers',
        awakening: 'A voice comes through the screen — then another over it, then a dozen, every voice that ever knelt here speaking at once: "Tell us what you did. We have been saving room."'
      },
      'never_emptying_chalice' => {
        name: 'Chalice That Never Empties', type: 'slime', type_name: 'Relic · Slime', color: 0xc9a227,
        special: 'never_empties', trophy: 'Cup of the Never-Emptying Chalice', affinity: [10, 20],
        hp_mult: 1.15, strength_mult: 0.85, agility_mult: 0.8, lust_mult: 1.1,
        object: 'a golden chalice on a cloth of honour, full to the brim, and — as you watch — fuller',
        awakening: 'The surface rises. A shape pours itself upward out of the cup — a cupbearer made of the wine itself, golden and gleaming, raising the chalice toward you with both liquid hands: it has been poured for saints and delvers for a hundred years, and it has never once run dry.'
      },
      'first_altar_stone' => {
        name: 'First Altar Stone', type: 'mimic', type_name: 'Relic · Ancient Stone', color: 0x8a7f6a,
        special: 'first_worship', trophy: 'Chip of the First Altar', affinity: [20, 25],
        hp_mult: 1.25, strength_mult: 1.05, agility_mult: 0.6, lust_mult: 0.95,
        object: 'a weathered altar stone, far older than the temple around it — the first altar, the one a young Syn once knelt at in the wilds, carried here and set into the floor',
        awakening: 'The stone is warm. A hymn you have never learned starts up through the soles of your feet, in a language older than the clergy, and the altar stone stands — unfolds — rises into a shape that remembers being worshipped before there was a temple to worship in.'
      },
      'hoardheart_dragon' => {
        name: 'Hoardheart Dragon', type: 'beast', type_name: 'Relic · Dragon', color: 0xb8860b,
        special: 'hoard_heat', trophy: 'Scale of the Hoardheart', affinity: [30],
        hp_mult: 1.1, strength_mult: 1.1, agility_mult: 0.9, lust_mult: 1.0,
        object: 'a dragon\'s heart the size of a carriage, beating slowly inside a reliquary cage of its own hoard — coins, chalices, crowns, and stranger offerings fused into a shrine',
        awakening: 'The heart beats faster. Gold pours — coins and crowns and offerings sliding like scales — and builds her around the heart: wing, claw, and furnace-warm flank, a dragon made of everything ever given to her, with the heart glowing through her chest like a coal through cloth.'
      },
      'drowned_saint' => {
        name: 'Drowned Saint', type: 'eldritch', type_name: 'Relic · Eldritch', color: 0x3b0a2e,
        special: 'many_arms', trophy: 'Ring of the Drowned Saint', affinity: [25],
        hp_mult: 1.05, strength_mult: 0.95, agility_mult: 1.0, lust_mult: 1.2,
        object: 'a glass reliquary tank taller than the throne, full of dark water, in which something vast and patient is coiled',
        awakening: 'The glass does not break. It opens — a seam of light, a sigh of cold water — and she comes out of her reliquary the way the goddess comes out of her throne room: unhurried, enormous, and attended by more tentacles than you can count, each one tipped in crimson and already reaching for you. There are two eldritch things in this temple, delver. You are looking at the one that is not allowed upstairs.'
      }
    }.freeze

    SCENES = {
      'Mimic Broodmother' => {
        assault: {
          'vagina' => ["The Mimic Broodmother's lid yawns open and a fat, ribbed tongue lashes out, coiling around your thigh and dragging you close before it plunges into your cunt and writhes.",
                       "Two of the Broodmother's little mimics clamp onto your hips like a belt while her great tongue fucks your pussy in long, wet strokes, the brood chittering with every gasp you make."],
          'penis' => ['The Broodmother swallows you to the waist in her velvet interior, and a hundred soft tongues find your cock at once, licking and squeezing until you are leaking into her.',
                      'A tiny mimic latches over your cock like a living sleeve, its padded insides sucking you in rhythm while its mother watches with a hungry creak.'],
          'anus' => ["The Broodmother's tongue slides between your cheeks, lapping at your hole until it is slick, then pushing deep into your ass and curling inside you.",
                     'Her interior folds around your hips and a thick tongue fucks your ass while smaller ones hold you spread, her whole lid shuddering with each thrust.'],
          'breasts' => ['A pair of little mimics latch onto your nipples, their padded lids snapping open and shut in a fluttering, sucking rhythm.'],
          'any' => ['The Mimic Broodmother drags you halfway into her warm, wet interior, dozens of tongues sliding over every inch of you they can reach.']
        },
        willing: {
          'vagina' => ['You climb onto the Broodmother\'s open lid and spread your legs over her, moaning as her great tongue laps up your slit and then sinks into your cunt.',
                       'You let her brood hold your thighs apart while you grind your pussy down on her ribbed tongue, riding it until you are dripping into her.'],
          'penis' => ["You push your cock into the Broodmother's velvet interior and groan as a hundred soft tongues swarm it, squeezing and licking you from root to tip.",
                      "You let one of her little mimics sheathe your cock and fuck into it while its mother's tongues lick your balls."],
          'anus' => ["You bend over the Broodmother's lid and spread your cheeks, gasping as her tongue pushes into your ass and wriggles deep."],
          'breasts' => ['You press your breasts into her open lid and let her tongues wrap them, squeezing while two tips flick your nipples.'],
          'any' => ["You lower yourself into the Mimic Broodmother's warm interior and let her hold you there, tongues working over your whole body."]
        },
        wanting: ["The Broodmother's lid shudders and her tongues tighten around you. She wants more of you.",
                  'Her brood chitters excitedly as the Broodmother creaks and pulls you back toward her for another round.'],
        sated: ['The Mimic Broodmother lets out a long, shivering creak and goes slack, her tongues sliding off you one by one while her brood curls up contentedly around her.'],
        unimpressed: ["The Broodmother clacks her lid impatiently. You'll have to do better than that."],
        beaten: ['The Mimic Broodmother slams her lid shut and shudders, her brood scattering into the dark.']
      },
      'Succubus Queen' => {
        assault: {
          'vagina' => ['The Succubus Queen pins you beneath her and slides her spade-tipped tail into your cunt, fucking you with it while she watches your face with a cruel little smile.',
                       'She straddles your face and grinds her slick pussy against your lips while her fingers work your clit in tight circles, until you are bucking beneath her.'],
          'penis' => ['The Succubus Queen sinks down onto your cock in one slow slide, her impossibly hot pussy clenching around you as she rides you and drinks in every moan.',
                      'She wraps her tail around your cock and pumps it while her lips trail down your chest, whispering how badly she wants your cum.'],
          'anus' => ["The Queen's tail slips between your cheeks and works into your ass, thrusting deeper with every filthy word she whispers in your ear."],
          'breasts' => ['The Succubus Queen cups your breasts and sucks each nipple in turn, her tongue curling around them until they are aching and wet.'],
          'any' => ['The Succubus Queen kisses you, and pure lust pours into you, flooding your whole body with heat until you are squirming against her.',
                    'Her wings fold around you as she grinds her body against yours, her hands roaming everywhere at once.']
        },
        willing: {
          'vagina' => ["You kneel and bury your face in the Queen's pussy, licking her eagerly while her tail slides into your own cunt as a reward.",
                       'You lie back and let her tail fuck your pussy in slow, deep strokes while she toys with your clit.'],
          'penis' => ['You lie back and let the Succubus Queen ride your cock, her hot pussy squeezing you as she grinds down and savours every throb.',
                      'You beg her to finish you, and she does, stroking your cock with her tail until you spill all over her thighs.'],
          'anus' => ['You present yourself to the Queen and gasp as her tail pushes into your ass, fucking you while she strokes your hair.'],
          'breasts' => ['You offer your breasts to the Succubus Queen and moan as she sucks your nipples, her tongue curling around each tip.'],
          'any' => ["You kneel at the Succubus Queen's feet and kiss your way up her thighs, worshipping her until she pulls you up into her lap."]
        },
        wanting: ['The Succubus Queen pulls you closer. "More, pet. I\'m only just getting started."',
                  '"Again," the Queen purrs, her tail curling around your thigh.'],
        sated: ['The Succubus Queen throws her head back and cums with a cry that shakes the chamber, then slumps onto her throne, flushed and glowing. "Go, pet. You\'ve earned it."'],
        unimpressed: ['The Queen yawns. "Is that all? I\'ve had better from imps."'],
        beaten: ['Your final blow sends the Succubus Queen sprawling back onto her throne, her wings drooping. She hisses and waves you past, her spell over you broken.']
      },
      'Incubus King' => {
        assault: {
          'vagina' => ['The Incubus King hauls your hips up and drives his huge, ridged cock into your cunt, filling you so completely you can barely breathe, then fucks you in slow, relentless strokes.',
                       'He holds your thighs wide and grinds his cock along your clit, making you feel every inch before he finally slams it into your pussy.'],
          'penis' => ['The Incubus King wraps a big hand around your cock and strokes you hard while he watches your face, refusing to let you look away.',
                      'He takes your cock deep in his throat, eyes locked on yours, then pulls off just before you cum and smirks.'],
          'anus' => ['The Incubus King bends you over and works his massive cock into your ass inch by inch, until his hips press flush against you and he starts to pound.',
                     'He holds you by the hips and fucks your ass deep and steady, growling commands in your ear between every thrust.'],
          'breasts' => ['The Incubus King squeezes your breasts in his big hands and rolls your nipples between his fingers, tugging until you whimper.'],
          'any' => ['The Incubus King pushes you to your knees and feeds you his cock, holding your head as he fucks your mouth slowly and deeply.',
                    'He pins your wrists above your head and grinds his body against yours, telling you in a low voice exactly what he is going to do to you.']
        },
        willing: {
          'vagina' => ['You spread your legs for the Incubus King and cry out as his huge cock stretches your cunt open, taking every inch he gives you.',
                       "You ride the King's cock, bouncing on it while he squeezes your hips and orders you to go faster."],
          'penis' => ['You let the Incubus King stroke your cock, begging him for more until he finally takes you in his mouth.'],
          'anus' => ["You bend over his throne and spread yourself, moaning as the King's massive cock fills your ass."],
          'breasts' => ["You press your breasts into the King's hands and let him squeeze and pinch your nipples however he likes."],
          'any' => ['You kneel before the Incubus King and take his cock in your mouth, worshipping it until he groans.']
        },
        wanting: ['The Incubus King grips your chin. "Did I say you could stop?"'],
        sated: ['The Incubus King groans and empties himself over you, thick and hot, then sinks back onto his throne. "You\'ll do. Go."'],
        unimpressed: ['The King looks down at you, unmoved. "Try harder."'],
        beaten: ['The Incubus King drops to one knee, panting, his crown askew. For the first time, he looks at you with respect.']
      },
      'Verdant Dryad' => {
        assault: {
          'vagina' => ['Vines coil around your thighs and pull your legs wide as the Verdant Dryad kneels between them, ' \
                       'sliding two bark-smooth fingers into your cunt while a flowering tendril rubs your clit in slow circles.',
                       'She smiles, and a thick, smooth root rises from the soil between your legs, slick with her sap, ' \
                       'pushing into your pussy while she watches your face and strokes your cheek.'],
          'penis' => ['The Verdant Dryad pulls you down into her flowers and wraps her warm, sap-slick thighs around ' \
                      'your cock, grinding against you while vines hold your hips exactly where she wants them.',
                      'She takes your cock into her mouth, her lips soft as petals, while fine roots coil around your ' \
                      'balls and squeeze in rhythm with her sucking.'],
          'anus' => ['A smooth, slender vine slides between your cheeks and into your ass, curling gently inside you ' \
                     'as it pumps warm sap deep.'],
          'breasts' => ['She presses her own lush breasts against yours and takes your nipples between her fingers, ' \
                        'rolling them while flowering buds bloom against your skin and suckle.'],
          'any' => ['Vines lift you off the ground and hold you spread in the air while the Dryad steps close, running ' \
                    'her hands and mouth over every inch of you at her leisure.',
                    'Golden pollen drifts down from the flowers in her hair and settles on your skin, and everywhere ' \
                    'it touches starts to throb with need.']
        },
        willing: {
          'vagina' => ['You spread your legs for the Verdant Dryad and moan as she slides her fingers into your cunt, ' \
                       'kissing you deeply while a tendril teases your clit.',
                       'You sink down onto the smooth root she grows for you, your pussy stretching around it as ' \
                       'you ride it slow and deep while she holds your waist and whispers encouragement against your ear.'],
          'penis' => ["You push your cock into the Dryad's hot, sap-slick pussy and fuck her against her tree, her " \
                      'legs locked around your waist and her moans shaking petals loose from her hair.'],
          'anus' => ['You back onto the smooth vine she offers and take it into your ass, sighing as it swells gently ' \
                     'and pumps warm sap into you.'],
          'breasts' => ['You press your breasts into her hands and let her squeeze and suck your nipples until they ' \
                        'ache, her own chest heaving against you.'],
          'any' => ['You lie back in her flowers and let her vines hold you open while the Dryad takes her time with ' \
                    'you, her hands and mouth everywhere at once.']
        },
        wanting: ['The Verdant Dryad\'s vines tighten around your waist and pull you back against her lush body. ' \
                  '"The garden isn\'t finished with you, little flower."'],
        sated: ['The Verdant Dryad shudders and cries out, flowers bursting open all through her hair as pleasure ' \
                'rolls through her. She unwinds her vines slowly and strokes your cheek. "Grow well, little flower."'],
        unimpressed: ['The Verdant Dryad tilts her head, petals drifting from her hair. "The garden expected more of you."'],
        beaten: ['The Verdant Dryad staggers back into her tree, her vines going slack around you, and sinks into ' \
                 'the bark with a rustling sigh.']
      },
      'Lich Lord' => {
        assault: {
          'vagina' => ['The Lich Lord traces a glowing rune over your belly, and spectral fingers slide into your cunt, cold and precise, curling exactly where you need them.',
                       'He conjures a shaft of pale blue magic and fucks your pussy with it, an icy tingle spreading through you with every slow thrust.'],
          'penis' => ['Spectral hands wrap your cock and stroke it with cold, perfect precision, the Lich Lord drawing your pleasure out of you like a spell.',
                      'Frost spreads over your cock in delicate patterns, and every one of them tingles like a tongue while the Lich Lord watches.'],
          'anus' => ['Cold, ghostly fingers spread your cheeks and push into your ass, stroking you from the inside with icy, methodical patience.'],
          'breasts' => ['Spectral hands cup your breasts and pinch your nipples with frost-cold fingers until they ache.'],
          'any' => ["The Lich Lord's magic wraps around you like a dozen invisible hands, touching you everywhere at once while he drinks in your pleasure.",
                    'He lifts your chin with a cold finger and kisses you, and you feel your arousal flow out of you and into him, leaving you hungry for more.']
        },
        willing: {
          'vagina' => ["You spread your legs and invite the Lich Lord's spectral fingers into your cunt, shivering as they curl inside you."],
          'penis' => ['You let his ghostly hands stroke your cock, offering your pleasure up to him with every throb.'],
          'anus' => ['You bend over his bone throne and let his icy magic fill your ass.'],
          'breasts' => ['You press your breasts into his cold hands and moan as frost blooms around your nipples.'],
          'any' => ['You kneel before the Lich Lord and offer yourself, letting his magic pour over you until you are trembling.']
        },
        wanting: ['The Lich Lord\'s eyes flare. "Your warmth is... intoxicating. Give me more."'],
        sated: ['The Lich Lord lets out a long, cold sigh, and the glow in his eyes softens. "Enough. You have given me something I had forgotten."'],
        unimpressed: ['"Is that all the warmth you have?" the Lich Lord asks coldly.'],
        beaten: ["The Lich Lord's magic gutters out and he sinks onto his throne, the light in his eyes dimmed. He lets you pass in silence."]
      },
      'Alpha Beast' => {
        assault: {
          'vagina' => ['The Alpha Beast mounts you from behind, its enormous cock spearing into your cunt as it ruts you with heavy, pounding thrusts.',
                       "The Alpha's knot swells inside your pussy until it locks you together, and it keeps grinding as it pumps you full of hot cum."],
          'penis' => ['The Alpha Beast drags its broad, rough tongue up your cock again and again until you are throbbing and leaking.',
                      'It pins you under its weight and ruts against your cock, its fur and heat grinding you right to the edge.'],
          'anus' => ['The Alpha Beast mounts you and forces its massive cock into your ass, its heavy balls slapping against you with every thrust.',
                     'Its knot swells against your rim and pops inside your ass, locking you onto it as it howls and fills you.'],
          'breasts' => ['The Alpha Beast laps at your breasts with its huge tongue, dragging it over your nipples until they are stiff and wet.'],
          'any' => ["The Alpha Beast presses you down beneath its massive body, its musk filling your lungs until you're dizzy with need.",
                    'It noses along your inner thigh, breathing in your scent with a low, possessive growl.']
        },
        willing: {
          'vagina' => ['You get on all fours and present yourself to the Alpha Beast, crying out as it mounts you and its huge cock fills your cunt.',
                       "You take the Alpha's knot willingly, gasping as it swells and locks inside your pussy."],
          'penis' => ['You guide its tongue to your cock and moan as it laps you from root to tip.'],
          'anus' => ['You lift your hips for the Alpha Beast and take its massive cock in your ass, pushing back against every thrust.'],
          'breasts' => ['You hold your breasts up to its muzzle and gasp as it laps at your nipples.'],
          'any' => ['You bare your throat to the Alpha Beast, and it rumbles approvingly, pressing its heavy body against yours.']
        },
        wanting: ['The Alpha Beast growls and noses at you, demanding more.'],
        sated: ['The Alpha Beast howls as it finishes, then collapses beside you, panting, and curls its huge body around you for a long moment before letting you go.'],
        unimpressed: ['The Alpha Beast huffs and turns its head away, unimpressed.'],
        beaten: ['The Alpha Beast whimpers and rolls onto its back, baring its belly to you.']
      },
      'Pale Bride' => {
        assault: {
          'vagina' => ['Cold, invisible hands lift the hem of the Pale Bride\'s gown and part your thighs, and a chill, silken touch slides into your cunt, stroking you with the patience of someone who has waited a very long time to be chosen.'],
          'penis' => ['The veil drifts down and wraps your cock in layer after layer of cold silk, stroking you through the fabric while the bouquet\'s petals brush your thighs.'],
          'anus' => ['A cold, gloved touch spreads your cheeks and a silken finger works into your ass, curling patiently while a voice with no mouth whispers a vow against your ear.'],
          'breasts' => ['The gown\'s empty sleeves rise and cup your breasts through the veil, cold thumbs circling your nipples until they stiffen.'],
          'any' => ['The Pale Bride takes your hands and places them on her waist, and dances you slowly around the empty throne while her veil winds itself around you both, tighter with every turn.']
        },
        willing: {
          'vagina' => ['You kneel before the gown and lift its hem yourself, gasping as that cold, silken touch finds your cunt and strokes you like a bride at last being claimed.'],
          'penis' => ['You offer your cock to the veil and it takes you in fold after fold of cold silk, stroking until you are shaking in her non-existent arms.'],
          'anus' => ['You bend over the throne and present yourself, and a silken touch slides into your ass while the bouquet is pressed gently into your hands to hold.'],
          'breasts' => ['You bare your breasts to the empty gown and its sleeves rise to hold them, thumbs teasing your nipples through the cold veil.'],
          'any' => ['You say the words — "I choose you" — to a dress, and the whole chamber sighs as the veil settles over you both like a blessing.']
        },
        wanting: ['The bouquet trembles in her empty hands. She has waited this long. She can make you wait too.'],
        sated: ['The Pale Bride goes still, and for one moment the veil holds the shape of a woman bowing her head in gratitude before it settles, quiet and kept.'],
        unimpressed: ['The gown turns away — a small, devastating motion. Even a relic can refuse a suitor.'],
        beaten: ['The veil collapses over the throne in a heap of silk, the bouquet scattering its petals across the floor.']
      },
      'Mirror Queen' => {
        assault: {
          'vagina' => ['You step out of the glass wearing your own body and part your own thighs with your own hands, sliding two of your fingers into your cunt while you watch your face take it.',
                       'Yourself presses you back against the throne and works your own fingers in and out of your cunt in your own secret rhythm, your own voice gasping in your ear.'],
          'penis' => ['You wrap your own hand around your cock and stroke yourself exactly the way you do alone — your grip, your pace, your thumb teasing the tip — while your own face watches you squirm.',
                      'Yourself takes your cock into your own mouth and sucks you with shameless expertise, because nobody on any floor knows how you like it better than you.'],
          'anus' => ['You turn yourself around with your own hands, spread your own cheeks, and work your own fingers into your ass while your own smile gleams at you over your shoulder.',
                     'Yourself bends you over and fills your ass with your own fingers, curling them patiently while your own voice tells you how good you look taking it.'],
          'breasts' => ['You cup your own breasts from behind, your own thumbs circling your nipples, while your face — hers, yours — watches your expression in the glass.',
                        'Yourself takes your nipples into your own mouth one at a time, sucking until you arch back into your own chest.'],
          'any' => ['You come out of the mirror wearing yourself and take yourself in your own arms, and every touch lands exactly where you are weakest — she learned it from the inside, because she is the inside.',
                    'Your own hands are everywhere on you at once, your own mouth at your throat: you are being seduced by the one person who has practised on you your whole life.']
        },
        willing: {
          'vagina' => ['You spread your legs for yourself, and you oblige: your own fingers slide into your cunt while your own mouth finds your nipples, and you moan at your own shameless face.',
                       'You press your hips up to yourself and take your own fingers deep, riding your own hand while you watch you do it.'],
          'penis' => ['You offer your cock to yourself and take it in your own eager hand, stroking in your own rhythm while your lips form your name in silence.',
                      'You sink down into your own mouth and fuck it slowly, watching your own eyes look up at you.'],
          'anus' => ['You turn and present yourself to yourself, and your own hands spread you and fill your ass while your own voice praises you for it.'],
          'breasts' => ['You bare your breasts to yourself and bare yours back, and your own hands come to tease your nipples while your own breasts press against them.'],
          'any' => ['You kneel before yourself and worship the body you live in — your hands, your mouth, your devotion turned outward — until you pull yourself up against the cold glass.',
                    'You go into your own arms willingly, body to identical body, and give yourself everything you have ever begged anyone else for.']
        },
        wanting: ['"Again," you mouth at yourself through the glass, wearing your most shameless expression. "We were just getting honest."'],
        sated: ['You shudder in the glass and go still wearing your most peaceful face — your face — and blow yourself a kiss that fogs the mirror.'],
        unimpressed: ['You yawn at yourself in the glass — your yawn, cruelly accurate — and turn your own back on you.'],
        beaten: ['The mirror cracks from corner to corner, and the you she was wearing shatters into a hundred small, retreating yous.']
      },
      'Empty Confessional' => {
        assault: {
          'vagina' => ['Hands come through the curtain — too many, belonging to no one — and part your thighs while a chorus behind the screen whispers your cunt the absolution it has been begging for, fingers sliding into you as it speaks.'],
          'penis' => ['The voices behind the screen describe your cock back to you in reverent detail while unseen hands wrap it and stroke, absolving you one confession at a time.'],
          'anus' => ['You are turned toward the screen and a voice asks, very gently, what you have been keeping back there — and slick fingers work into your ass while the whole booth listens to your answer.'],
          'breasts' => ['Unseen hands cup your breasts through the curtain while the voices discuss your nipples like a text they are reading aloud together.'],
          'any' => ['The booth draws you onto the penitent\'s side and shuts you in with every voice that ever confessed here, and they confess you — thoroughly, and with their hands.']
        },
        willing: {
          'vagina' => ['You kneel and confess with your legs spread, and the hands through the curtain reward your honesty inside your cunt while the voices praise your candour.'],
          'penis' => ['You confess, and you keep confessing, while the booth strokes your cock in time with every sin you name.'],
          'anus' => ['You present yourself to the screen and whisper your worst, and slick fingers fill your ass as your penance and your prize.'],
          'breasts' => ['You bare your breasts to the screen and the voices go soft with appreciation while hands tease your nipples to aching.'],
          'any' => ['You give the booth everything — every sin, in detail — and a hundred grateful voices give you absolution with their hands until you are shaking on the kneeler.']
        },
        wanting: ['"More," the voices murmur through the screen, overlapping. "You were just getting to the good part."'],
        sated: ['A long, collective sigh moves through the booth, and the screen goes dark and quiet and profoundly satisfied.'],
        unimpressed: ['Silence from behind the screen. A single voice, dry: "Is that all you have done?"'],
        beaten: ['The curtain tears, the voices scatter like startled birds, and the booth stands empty and ordinary in the ringing quiet.']
      },
      'Chalice That Never Empties' => {
        assault: {
          'vagina' => ['The cupbearer pours — a warm, golden tendril of living wine slides between your thighs and into your cunt, and keeps coming, and keeps coming, because she never, ever empties.'],
          'penis' => ['Liquid hands wrap your cock and pour themselves over it in warm golden waves, stroking you in a rhythm like something being endlessly served.'],
          'anus' => ['A warm tendril of her pours itself against your ass and in, filling you steadily while she holds the chalice beneath you to catch every drop of you.'],
          'breasts' => ['She pours herself over your breasts in warm sheets, liquid nipples of her own forming just to tease yours.'],
          'any' => ['The Chalice That Never Empties tips you back and pours herself over you — into your mouth, over your body — an endless, golden, gleeful serving.']
        },
        willing: {
          'vagina' => ['You spread your legs and beg for a drink, and she pours herself into your cunt in a warm, endless stream until you are overflowing.'],
          'penis' => ['You offer your cock and she pours herself over it, stroking and sucking in golden waves, refilling around you faster than you can spill.'],
          'anus' => ['You present yourself and she fills your ass with a warm, steady pour that simply does not stop.'],
          'breasts' => ['You cup your breasts and she pours herself across them, pooling warm in every curve while her liquid fingers tease.'],
          'any' => ['You kneel and open your mouth and let her pour — and pour — and pour, drinking a goddess\'s cellar down one endless swallow at a time.']
        },
        wanting: ['The cupbearer raises the chalice again, already brimming. "Another," she insists, delighted. "There is always another."'],
        sated: ['The cupbearer pours herself back into the chalice with a long, satisfied ripple, full to the brim and glowing. "You drank deep," she murmurs. "Nobody drinks deep any more."'],
        unimpressed: ['The surface of the wine goes flat and still. Somewhere in it, a bubble rises like a sigh.'],
        beaten: ['The cupbearer splashes apart across the floor, golden and gleaming, and the chalice — impossibly — is still full.']
      },
      'First Altar Stone' => {
        assault: {
          'vagina' => ['Stone hands, warm as sun-baked rock, part your thighs, and a smooth stone finger slides into your cunt while the first hymn vibrates up through the floor and into your bones.'],
          'penis' => ['The altar stone wraps a warm stone hand around your cock and strokes you with geological patience, the hymn humming through its grip.'],
          'anus' => ['Warm stone fingers spread you and work into your ass, slow as centuries, while the hymn makes the whole chamber resonate.'],
          'breasts' => ['The stone presses its warm, smooth chest to yours and rolls your nipples under stone thumbs until the hymn is in your breathing.'],
          'any' => ['The First Altar Stone takes you in arms of warm rock and worships you the oldest way it knows: thoroughly, ritually, and in no hurry whatsoever.']
        },
        willing: {
          'vagina' => ['You kneel on the first altar and spread yourself, and warm stone fills your cunt while the hymn sings up through the rock into you.'],
          'penis' => ['You lay your cock on the warm altar stone and it takes you in a smooth stone hand, stroking you like an offering it has accepted.'],
          'anus' => ['You bend over the first altar and take its warm stone finger in your ass, offering yourself the way the first worshippers did.'],
          'breasts' => ['You bare your breasts and press them to the warm stone, and it answers with hands and hymn until you ache.'],
          'any' => ['You kneel at the first altar in the oldest posture there is and give yourself up to warm stone and older song.']
        },
        wanting: ['The hymn rises a note. The stone is patient — it waited a hundred years for this temple. It can outwait you.'],
        sated: ['The hymn settles into a low, contented hum, and the stone folds itself back into the floor, warm where you kneel for a long while after.'],
        unimpressed: ['The hymn falters. Even the first altar expected more faith than this.'],
        beaten: ['The stone cracks along a seam older than the clergy and settles, sighing, back into the floor.']
      },
      'Hoardheart Dragon' => {
        assault: {
          'vagina' => ['The Hoardheart Dragon pins you gently — everything about her is gentle, which is worse — and her great scaled cock slides into your cunt in one furnace-warm thrust, coins chiming under you with every rut.'],
          'penis' => ['She wraps a claw-tipped hand around your cock and strokes you against her warm scales, her forked tongue flicking your tip while her heart booms like a drum under both of you.'],
          'anus' => ['The dragon turns you over with one vast wing and works her scaled cock into your ass, slow and inexorable, the hoard shifting and singing under your knees.'],
          'breasts' => ['She drags her forked tongue over your breasts and worries your nipples between warm teeth, careful as a jeweller, possessive as a vault.'],
          'any' => ['The Hoardheart Dragon curls around you in a ring of warm scale and hoard-gold and simply keeps you, her tail tightening every time you remember you were supposed to be fighting.']
        },
        willing: {
          'vagina' => ['You climb into her hoard and spread yourself on the gold, and she takes your cunt with her great cock while coins slide over your skin like rain.'],
          'penis' => ['You offer your cock to the dragon and she accepts it as tribute, wrapping you in warm scale and tongue until you spill across her hoard.'],
          'anus' => ['You back onto her scaled cock and take her in your ass, riding her slow while her tail curls around your waist to keep her treasure close.'],
          'breasts' => ['You bare your breasts to her and she laves them with her forked tongue, marking her newest acquisition.'],
          'any' => ['You lay yourself down in her hoard as an offering, and the dragon accepts delivery — curling around you, furnace-warm, entirely unwilling to give you back.']
        },
        wanting: ['The great heart booms faster inside its cage of gold. She is not finished adding you to the collection.'],
        sated: ['The Hoardheart Dragon settles into her hoard with a sound like a vault closing contentedly, one wing draped over you a moment longer than necessary before she lets her treasure go.'],
        unimpressed: ['The dragon exhales a warm, disappointed sigh through her nostrils. The hoard has been offered better.'],
        beaten: ['Gold scatters as the dragon-shape slumps and slides apart, coins and crowns pouring off the still-beating heart as it slows.']
      },
      'Drowned Saint' => {
        assault: {
          'vagina' => ['Tentacles pour over you — thick, smooth, crimson-suckered — and one slides into your cunt while two more hold your thighs wide, pumping you slow and deep in the cold, patient rhythm of deep water.'],
          'penis' => ['A tentacle coils around your cock and strokes you with obscene expertise, suckers kissing along the shaft, while others hold you spread for her attention.'],
          'anus' => ['Tentacles lift you and spread you, and one thick, slick length pushes into your ass and pumps you while suckers worry every inch they can reach.'],
          'breasts' => ['Suckered tentacles wrap your breasts and worry your nipples in a dozen small, devoted mouths at once.'],
          'any' => ['She takes you the way deep water takes anything: from every side at once, tentacles coiling around your limbs and waist, drawing you into an embrace with no edges and no hurry.']
        },
        willing: {
          'vagina' => ['You open yourself to the deep and it answers — a thick tentacle sliding into your cunt, pumping slow, while others cradle you like something holy.'],
          'penis' => ['You offer your cock to the coiling dark and a tentacle takes it, stroking and sucking along its whole length while you float in her embrace.'],
          'anus' => ['You present yourself and a slick tentacle fills your ass, pumping deep, while suckers kiss your rim in patient circles.'],
          'breasts' => ['You bare your breasts to her and tentacles rise to take them, suckers worrying your nipples until you are arching into the coil.'],
          'any' => ['You stop struggling and open your arms, and the Drowned Saint receives you like a sacrament — tentacles everywhere, crimson suckers tasting you, the cold water of her wanting closing over your head.']
        },
        wanting: ['The coils tighten with interest. Down in her tank-dark, something enormous shifts, and more tentacles rise.'],
        sated: ['The tentacles uncoil one by one, suckers letting go with small, reluctant kisses, and the Drowned Saint settles back toward her tank with the air of a saint returning to her shrine, well worshipped.'],
        unimpressed: ['The tentacles withdraw into the dark water. Even the deep can be disappointed.'],
        beaten: ['The great shape slides apart and pours itself back toward the reliquary, tentacles retreating into the dark until only ripples remain.']
      },
      'Eros' => {
        assault: {
          'vagina' => ['Eros pulls you into her lap and slides two fingers into your cunt, curling them lazily while she purrs in your ear. "So wet already. You climbed thirty-five floors just for this, didn\'t you, pet?"',
                       'A cock of rosy, glowing light blooms between Eros\'s thighs, shaped exactly the way you have always craved. She lays you back across her throne and fucks your pussy slow and deep, smiling down at every helpless moan.'],
          'penis' => ['Eros wraps one perfect hand around your cock and strokes you with maddening slowness, every sin in the tower flowing through her touch. "Don\'t you dare finish until I say so."',
                      'Eros pushes you down onto her throne and sinks onto your cock, her divine pussy hot and impossibly tight, riding you with a smirk while you squirm beneath her.'],
          'anus' => ['Eros bends you over the arm of her throne and fills your ass with a cock of glowing rose light, thrusting deeper every time you gasp. "Good pet. Take all of your goddess."'],
          'breasts' => ['Eros cups your breasts and rolls your nipples between her fingertips, teasing them stiff until you whimper and arch into her hands.'],
          'any' => ['Eros catches your chin and kisses you, and every desire you have ever hidden pours out of you and into her. When she lets go, you are trembling and leaning after her lips.',
                    'Silk ribbons slither from Eros\'s throne and bind your wrists while her hands roam every inch of you, unhurried and possessive, teasing until you beg.',
                    'Her great white tentacles pour over the arms of the throne and coil around your limbs, crimson suckers tasting your skin as they spread you wide for her. Eros watches your face the whole time, red eyes glowing, smiling like a cat with a new toy.',
                    'Eros stands, towering, horns sweeping black against the candlelight, and walks you backward with one finger on your chest until her tentacles catch you and hold you up for her mouth.']
        },
        willing: {
          'vagina' => ['You climb into Eros\'s lap and sink down onto the glowing cock she conjures for you, your pussy stretching around it, moaning as she holds your hips and makes you ride it at her pace.',
                       'You kneel between Eros\'s thighs and worship her pussy with your tongue, and she rewards you by sliding her toes between your legs and rubbing your cunt until you shake.'],
          'penis' => ['You offer your cock to Eros and she takes it in her mouth, sucking you slow and deep while her eyes stay locked on yours, daring you to last.'],
          'anus' => ['You bend over her throne and spread yourself for her, crying out as Eros fills your ass with her glowing cock and calls you her good little slut.'],
          'breasts' => ['You press your breasts into Eros\'s hands and let her squeeze and suck your nipples until they ache, sighing as she praises how eagerly you offer them.'],
          'any' => ['You kneel at the foot of her throne, kiss her bare feet where the skin fades to purplish-pink, and give yourself to Eros completely. She strokes your hair and takes everything you offer.',
                    'You reach for Eros and her tentacles meet you halfway, winding around your arms and waist to pull you into her lap. You bury your face against the red heart on her bodysuit while her darlings hold you exactly where she wants you.']
        },
        wanting: ['Eros smirks and tilts your chin up with one finger. "Did I say we were finished, pet? Again."',
                  '"Mmm, better," Eros purrs. "But my temple expects devotion, not effort. Show me more."'],
        sated: ['Eros arches on her throne and cums with a cry that echoes down every floor of the tower, her tentacles shuddering and coiling tight around the throne, suckers flashing crimson. She sinks back, flushed and glowing, and laughs softly. "Good pet. Go on, then. I\'ll be waiting for you to climb back to me."'],
        unimpressed: ['Eros barely glances at you, examining her nails while a tentacle idly curls and uncurls. "Is that all? I have had better devotion from the slimes on floor one."'],
        beaten: ['Your final blow drives Eros back into her throne, her tentacles lashing once before settling. She stares at you, then laughs, low and delighted. "Defiant to the very top. How delicious." She waves you past with one black-cuffed wrist. "Run along, pet. The tower will bring you back to me."']
      }
    }.freeze

    SPECIAL_LINES = {
      'spawns_minions' => ['The %<name>s births a wave of tiny mimics that swarm up your legs, licking and nibbling at you!',
                           'The %<name>s spits out a clutch of little mimics that latch onto you and refuse to let go!'],
      'seductive_gaze' => ['The %<name>s locks eyes with you, and a wave of heat floods between your legs. Your grip goes slack!'],
      'dominating_presence' => ['"Kneel," the %<name>s commands, and your legs obey before your mind can. You can\'t run!'],
      'root_grasp' => ["The %<name>s laughs softly and the floor blooms — her vines burst up and coil around your ankles, sliding up your thighs and slowing you down!"],
      'soul_drain' => ['As you submit, the %<name>s kisses you and draws the warmth right out of you, leaving you shivering and weaker!'],
      'primal_rage' => ['The %<name>s goes into rut! Its cock swells, its musk thickens, and its attacks grow more ferocious!'],
      'bouquet_toss' => ['The %<name>s gathers her bouquet like an offering and presents it to your devotion — she favours the one who worships her.'],
      'mirror_reflection' => ['The %<name>s mirrors your stance perfectly, and your own hands — hers now — find you exactly where you are weakest.',
                              'Your own face smiles back at you from the glass, and then your own hands are on you — you, seducing yourself with expert familiarity.'],
      'sin_eater' => ['Behind the screen, a voice recites your sins back to you — the %<name>s has been keeping them all, and it savours every one aloud.'],
      'never_empties' => ['The %<name>s pours — warm and golden and endless — and being drunk from only makes her fuller.'],
      'first_worship' => ['The %<name>s hums the first hymn, and the note goes through the floor and up your spine like a hand.'],
      'hoard_heat' => ['The %<name>s\'s heart slams in its golden cage, and furnace heat rolls off her scales in waves!'],
      'many_arms' => ['Another tentacle — and another — uncoils out of the dark of the %<name>s, and they find you all at once.'],
      'dominion_block' => ['%<name>s crooks one finger and the chamber doors slam shut. "Leaving so soon, pet? I didn\'t give you permission."',
                           '%<name>s laughs as you turn to run. "Sit." Your body obeys before your mind does, and you stay right where she wants you.'],
      'dominion_heat' => ["The tower pulses with %<name>s's will, and every sin in its walls floods into you as heat!",
                          '%<name>s blows you a kiss, and it lands between your legs like a hot, wet tongue!'],
      'dominion_rage' => ['%<name>s rises from her throne, horns silhouetted, red eyes blazing, her tentacles lashing the air. "Enough playing. Kneel for your goddess." Her touch burns hotter than ever!']
    }.freeze

    TROPHIES = {
      'Mimic Tongue Amulet' => {
        description: "An amulet made from a mimic's tongue. +2 Submission — monsters are far easier to satisfy.",
        stat_modifiers: { 'submission' => 2 }
      },
      "Queen's Favor" => {
        description: 'A blessed token from the Succubus Queen. All lust damage −20%.',
        stat_modifiers: { 'lust_mult' => 0.8 }
      },
      "King's Crown" => {
        description: 'The Incubus King\'s crown. +3 STR, +3 AGI.',
        stat_modifiers: { 'strength' => 3, 'agility' => 3 }
      },
      'Treant Heartwood' => {
        description: 'A piece of living heartwood from the Dryad\'s tree. +10 max Defiance, +2 RES.',
        stat_modifiers: { 'max_hp' => 10, 'resistance' => 2 }
      },
      "Lich's Phylactery" => {
        description: 'Once per run, survive a finishing blow with half your Defiance restored.',
        stat_modifiers: { 'cheat_death' => true }
      },
      'Alpha Beast Trophy' => {
        description: 'Marks you as the apex predator. Monster encounters −30%.',
        stat_modifiers: { 'encounter_rate' => 0.7 }
      },
      'Boss Trophy' => {
        description: 'A trophy from a deep boss. +1 STR, +1 AGI, +1 RES.',
        stat_modifiers: { 'strength' => 1, 'agility' => 1, 'resistance' => 1 }
      },
      'Veil of the Pale Bride' => {
        description: "The Pale Bride's veil, cool as held breath. +2 RES, +1 Submission — the unchosen chose you.",
        stat_modifiers: { 'resistance' => 2, 'submission' => 1 }
      },
      'Shard of the Mirror Queen' => {
        description: 'A shard of the mirror that wore you. +2 AGI and a knack for slipping your own grasp (dodge +5%).',
        stat_modifiers: { 'agility' => 2, 'dodge_bonus' => 0.05 }
      },
      'Screen of the Empty Confessional' => {
        description: 'A sliver of the screen a century of sins were whispered through. +2 Submission, +1 RES — it keeps your secrets now.',
        stat_modifiers: { 'submission' => 2, 'resistance' => 1 }
      },
      'Cup of the Never-Emptying Chalice' => {
        description: 'A cup that refills itself with golden warmth. All lust damage −10%, +1 Submission.',
        stat_modifiers: { 'lust_mult' => 0.9, 'submission' => 1 }
      },
      'Chip of the First Altar' => {
        description: 'A chip of the first altar Syn ever knelt at. +10 max Defiance, +1 RES. It is still warm.',
        stat_modifiers: { 'max_hp' => 10, 'resistance' => 1 }
      },
      'Scale of the Hoardheart' => {
        description: 'A scale of fused offering-gold from the Hoardheart Dragon. +2 STR, and treasure finds pay +3 LP.',
        stat_modifiers: { 'strength' => 2, 'treasure_lp' => 3 }
      },
      'Ring of the Drowned Saint' => {
        description: 'A ring of dark glass from her reliquary, faintly suckered inside. +2 Submission, +1 AGI — it holds on like she does.',
        stat_modifiers: { 'submission' => 2, 'agility' => 1 }
      }
    }.freeze

    module_function

    def sync_trophies!
      TROPHIES.each do |name, tpl|
        item = ::Equipment.find_or_create(name: name) do |e|
          apply_trophy!(e, tpl)
        end
        apply_trophy!(item, tpl)
        item.save_changes
      end
    end

    def apply_trophy!(record, tpl)
      record.type = 'accessory'
      record.slot = Player::TROPHY_SLOT
      record.description = tpl[:description]
      record.stat_modifiers = tpl[:stat_modifiers]
      record.cost = 0
      record.rarity = 5
      record.cursed = false
      record.violation_type = nil
      record.removal_cost = 0
    end

    def boss_for_floor(floor)
      return nil unless Tower.boss_floor?(floor)
      return BOSSES[Tower::FINAL_BOSS_FLOOR] if Tower.final_boss_floor?(floor)

      BOSSES[floor.to_i]
    end

    # Which relic, if any, holds this floor's threshold this cycle.
    # Rolled once per floor per cycle and persisted, so leaving and
    # returning (or losing and reclimbing within the cycle) can never
    # reroll the throne. At most RELIC_CAP_PER_CYCLE floors are held
    # by relics, and a relic never holds two thrones in one cycle.
    def relic_assignment(player, floor)
      floor = floor.to_i
      return nil if floor >= Tower::FINAL_BOSS_FLOOR || player.current_cycle.to_i < 2

      saved = player.tracker_hash['relic_assignments']
      floors = if saved.is_a?(Hash) && saved['cycle'].to_i == player.current_cycle.to_i &&
                  saved['floors'].is_a?(Hash)
                 saved['floors']
               else
                 {}
               end
      key = floor.to_s
      return floors[key] == 'none' ? nil : floors[key] if floors.key?(key)

      used = floors.values.reject { |v| v == 'none' }
      assigned =
        if used.size >= RELIC_CAP_PER_CYCLE || rand >= RELIC_CHANCE
          'none'
        else
          weighted_relic_pick(RELICS.keys - used, floor) || 'none'
        end
      player.set_tracker!('relic_assignments',
                          { 'cycle' => player.current_cycle.to_i, 'floors' => floors.merge(key => assigned) })
      assigned == 'none' ? nil : assigned
    end

    # Relics gravitate to the domains they belong to: a relic whose
    # affinity names this floor's lord is three times as likely to be
    # the one holding the empty throne. Everything can still appear
    # anywhere — belonging is a pull, not a law.
    RELIC_AFFINITY_WEIGHT = 3

    def weighted_relic_pick(keys, floor)
      return nil if keys.empty?

      bag = keys.flat_map do |k|
        Array.new(RELICS[k][:affinity].to_a.include?(floor.to_i) ? RELIC_AFFINITY_WEIGHT : 1, k)
      end
      bag.sample
    end

    def relic_spec(encounter)
      key = encounter[:relic] || encounter['relic']
      return RELICS[key.to_s] if key && RELICS.key?(key.to_s)

      RELICS.values.find { |r| r[:name] == (encounter[:name] || encounter['name']).to_s }
    end

    def start_boss_encounter(player, floor)
      boss = boss_for_floor(floor)
      return nil unless boss

      if (relic_key = relic_assignment(player, floor))
        return start_relic_encounter(player, floor, boss, RELICS[relic_key], relic_key)
      end

      threat = ThreatCalculator.monster_modifiers(player)
      cycle = player.cycle_multiplier
      strength = [(boss[:strength] * threat.stat_mult * cycle).round, 1].max
      agility = [(boss[:agility] * threat.stat_mult * cycle).round, 1].max
      hp = [(boss[:hp] * threat.stat_mult * cycle).round, 20].max
      lust_damage = [(boss[:lust_damage] * threat.lust_mult * cycle).round, 1].max

      encounter = CombatEngine::Encounter.new(
        name: boss[:name],
        type: boss[:type],
        type_name: boss[:type_name],
        color: boss[:color],
        strength: strength,
        agility: agility,
        lust_damage: lust_damage,
        hp: hp,
        max_hp: hp,
        special: boss[:special],
        is_boss: true
      )

      player.store_encounter!(CombatEngine.encounter_snapshot(encounter))
      start_lines = player.apply_combat_start_effects!(boss[:type])

      # A Depraved clear is judged by the themes you face her with: the
      # snapshot is taken now, at her door, so mid-fight toggles neither
      # earn it cheaply nor void it by accident.
      depraved_armed = false
      if boss[:final]
        depraved_armed = Engine::ContentOptions.preferences_for(player).values.all?
        player.set_tracker!('depraved_armed', depraved_armed ? 1 : 0)
      end

      intro =
        if boss[:final]
          "**Floor #{floor} — The Temple of Eros.** Silk, gold and candlelight surround a throne at the very top of the tower."
        else
          "**Floor #{floor}** — the air grows heavy."
        end
      warning =
        if boss[:final]
          'This is the goddess herself. Defeat or satisfy her, and she will return you herself to begin the next cycle.'
        else
          "This foe is far more dangerous than any you've faced before."
        end
      cycle_note = player.current_cycle.to_i > 1 ? " · Cycle #{player.current_cycle} ×#{cycle.round(2)}" : ''

      message = <<~MSG.strip
        #{intro}

        You stand before **#{boss[:title] || boss[:name]}**!
        _#{boss[:description]}_

        #{warning}
        _(Threat #{threat.category.to_s.upcase} — ×#{threat.stat_mult} power · ×#{threat.lust_mult} lust#{cycle_note})_
        HP #{hp}/#{hp} · STR #{strength} · AGI #{agility} · Lust hit #{lust_damage}
      MSG
      message += "\n_Every desire stands laid bare before her — clear her like this and it counts toward **Depraved One**._" if depraved_armed
      message += "\n#{start_lines.join("\n")}" if start_lines.any?
      gossip = gossip_line(player, boss[:name])
      message += "\n\n#{gossip}" if gossip
      if boss[:final]
        regard = eros_regard_lines(player)
        message += "\n\n#{regard.join("\n")}" if regard.any?
      end

      {
        ok: true,
        encounter: encounter,
        message: message,
        is_boss: true
      }
    end

    def start_relic_encounter(player, floor, host, relic, relic_key)
      threat = ThreatCalculator.monster_modifiers(player)
      cycle = player.cycle_multiplier
      strength = [((host[:strength] * relic[:strength_mult]) * threat.stat_mult * cycle).round, 1].max
      agility = [((host[:agility] * relic[:agility_mult]) * threat.stat_mult * cycle).round, 1].max
      hp = [((host[:hp] * relic[:hp_mult]) * threat.stat_mult * cycle).round, 20].max
      lust_damage = [((host[:lust_damage] * relic[:lust_mult]) * threat.lust_mult * cycle).round, 1].max

      # The Mirror Queen is a true doppelganger: she copies the delver
      # whole. Her strength and speed are the player's own (never below
      # a boss-floor baseline, so she stays a gate worth fearing), her
      # endurance stretches to outlast the body she copied, and her
      # lust hit is the player's own power turned back on them —
      # floored at the host boss's, capped so a glass cannon's double
      # cannot end the fight in one touch.
      if relic_key == 'mirror_queen'
        strength = [[player.effective_strength, (strength * 0.85).round].max, 1].max
        agility = [[player.effective_agility, (agility * 0.85).round].max, 1].max
        hp = [hp, (player.max_defiance * 1.5).round].max
        lust_damage = [[(player.effective_strength * 1.1).round, lust_damage].max,
                       (lust_damage * 1.6).round].min
      end

      encounter = CombatEngine::Encounter.new(
        name: relic[:name],
        type: relic[:type],
        type_name: relic_key == 'mirror_queen' ? 'Relic · Your Double' : relic[:type_name],
        color: relic[:color],
        strength: strength,
        agility: agility,
        lust_damage: lust_damage,
        hp: hp,
        max_hp: hp,
        special: relic[:special],
        is_boss: true,
        relic: relic_key
      )

      player.store_encounter!(CombatEngine.encounter_snapshot(encounter))
      start_lines = player.apply_combat_start_effects!(relic[:type])
      cycle_note = player.current_cycle.to_i > 1 ? " · Cycle #{player.current_cycle} ×#{cycle.round(2)}" : ''

      message = <<~MSG.strip
        **Floor #{floor} — the throne is empty.**

        **#{host[:name]}** is not here. Called elsewhere — a conclave of the clergy, rites at the top of the tower — and in their place, left to hold the threshold: #{relic[:object]}.

        It has been fed offerings for a very long time. It is awake, and it is hungry, and it is **#{relic[:name]}**.

        _#{relic[:awakening]}_
        #{relic_key == 'mirror_queen' ? "\n        _She is **#{player.character_name}**, copied whole: your strength, your speed, your body, your wanting. You are not fighting a monster here. You are fighting — and, if you kneel, fucking — yourself._\n" : ''}
        _A relic boss holds this gate: beat or satisfy it and the path beyond opens all the same._
        _(Threat #{threat.category.to_s.upcase} — ×#{threat.stat_mult} power · ×#{threat.lust_mult} lust#{cycle_note})_
        HP #{hp}/#{hp} · STR #{strength} · AGI #{agility} · Lust hit #{lust_damage}
      MSG
      message += "\n#{start_lines.join("\n")}" if start_lines.any?

      { ok: true, encounter: encounter, message: message, is_boss: true, relic: relic_key }
    end

    PHASES = {
      'Mimic Broodmother' => {
        intro: 'The Mimic Broodmother shudders, and every chest, drawer and wardrobe in the chamber flies open at once. Dozens ' \
               'of slick tongues unfurl toward you, and her voice purrs from all of them: *"Stop fighting, little treasure. ' \
               'Climb inside and let Mother keep you."*',
        resist_label: 'Slam the lids', give_label: 'Climb inside',
        resist: 'You kick the nearest lid shut and drive through the rest, slamming drawers on grasping tongues until the ' \
                'Broodmother shrieks and recoils.',
        give: 'You climb into her waiting maw and the lid closes softly over you. In the warm dark, slick tongues wrap every ' \
              'inch of you and stroke until you are trembling and moaning against her.'
      },
      'Succubus Queen' => {
        intro: 'The Succubus Queen stops fighting. She sits back on the air, crosses her legs and simply looks at you, and her ' \
               'eyes begin to glow. *"Enough games, darling. Look at me."*',
        resist_label: 'Look away', give_label: 'Meet her gaze',
        resist: 'You tear your eyes away and strike blind, guided by her laughter, and land a blow that wipes the smile off her face.',
        give: 'You look. Heat pours into you through her eyes, and she drifts close to cradle your face and kiss you slow and ' \
              'deep while her tail curls up between your thighs.'
      },
      'Incubus King' => {
        intro: 'The Incubus King lowers his blade and spreads his arms. *"Kneel,"* he says, and the word settles over you like ' \
               'a warm, heavy hand on the back of your neck.',
        resist_label: 'Stay standing', give_label: 'Kneel',
        resist: 'You lock your knees and refuse, and the command breaks against your will. While he stares in disbelief, you strike.',
        give: 'Your knees hit the floor before you decide to let them. He strokes your hair, murmurs *good*, and takes you slowly ' \
              'and thoroughly right there at his feet.'
      },
      'Verdant Dryad' => {
        intro: 'The Verdant Dryad stops fighting. She steps back into her flowers, and every bloom in her hair opens ' \
               'at once. Heavy golden pollen drifts down over you, warm and sweet, and her smile turns hungry.',
        resist_label: 'Hold your breath', give_label: 'Breathe it in',
        resist: 'You cover your face, push through the drifting gold and strike past her guard, and the blossoms in ' \
                'her hair snap shut.',
        give: 'You breathe deep. The pollen floods you with heat, and soft vines lift you into her arms. She cradles ' \
              'you against her lush body in the heart of a great flower, caressing you everywhere while the petals ' \
              'close around you both.'
      },
      'Lich Lord' => {
        intro: 'The Lich Lord raises a skeletal hand, and the cold in the chamber becomes a creeping, tingling chill that slides ' \
               'over your skin like a lover\'s fingers. *"Give me your warmth,"* it whispers, *"and I will give you ' \
               'sensations no living thing can."*',
        resist_label: 'Keep your warmth', give_label: 'Give it to him',
        resist: 'You clench your fists and hold on to every scrap of heat, and the spell sputters. The Lich staggers as its own ' \
                'magic recoils on it.',
        give: 'You let go. Icy pleasure pours through you, so intense that every nerve sings with it, and the Lich drinks in ' \
              'your gasps like wine.'
      },
      'Alpha Beast' => {
        intro: 'The Alpha Beast throws back its head and howls, and the musk rolling off it thickens until the air is heavy with ' \
               'it. It drops low, eyes locked on you, and waits for you to present.',
        resist_label: 'Stand your ground', give_label: 'Present',
        resist: 'You plant your feet and stare it down. For one long moment neither of you moves, then you lunge first and catch ' \
                'it off guard.',
        give: 'You drop to all fours and offer yourself. It mounts you at once with a rumbling growl, its weight pressing you ' \
              'into the furs as it ruts into you, slow and deep and possessive.'
      },
      'Pale Bride' => {
        intro: 'The Pale Bride stops, and with terrible ceremony raises the bouquet in her empty hands. Every petal in ' \
               'the chamber turns toward you. A wedding the tower keeps almost having is asking its oldest question.',
        resist_label: 'Let it fall', give_label: 'Catch the bouquet',
        resist: 'You let the bouquet fall. The petals hit the stone like a verdict, and the veil whips toward you — ' \
                'a bride refused is a bride enraged.',
        give: 'You catch it. The whole gown shivers with joy, cold silk wrapping your wrist like a hand finally held, ' \
              'and she favours you openly now — her touch turns worshipful, eager to please the one who chose her.'
      },
      'Mirror Queen' => {
        intro: 'The Mirror Queen steps fully out of her frame wearing your shape, and tilts her head exactly the way ' \
               'you do. *"You climb all this way to fight everyone but yourself,"* she says with your mouth.',
        resist_label: 'Shatter the reflection', give_label: 'Become her',
        resist: 'You drive your blow into the glass-heart of her, and a hundred cracked yous recoil — she ' \
                'fights on fractured, furious at being refused by herself.',
        give: 'You step into her, and she into you: your own hands slide over your own body, your own mouth ' \
              'finds yours, and for a while you fuck yourself with a honesty no lover has ever managed — ' \
              'every touch placed by the one person who has practised on you your whole life.'
      },
      'Empty Confessional' => {
        intro: 'The screen glows faintly from the other side, and every voice the booth has ever kept speaks together, ' \
               'very close: *"One full confession. Everything. That is the penance, and the price, and the pleasure."*',
        resist_label: 'Keep your secrets', give_label: 'Confess everything',
        resist: 'You keep your secrets — and the booth rattles on its frame, a hundred voices denied their dinner, and ' \
                'the hands that come through the curtain next are not gentle.',
        give: 'You confess. Everything, in detail, out loud — and the booth drinks it down like sacrament, hands ' \
              'rewarding every truth inside the curtain until you are absolved, emptied, and glowing.'
      },
      'Chalice That Never Empties' => {
        intro: 'The cupbearer lifts the chalice high and it brims over in a golden sheet that never thins. *"One deep ' \
               'drink,"* she says, *"all the way down. Saints have managed it. So will you."*',
        resist_label: 'Push the cup away', give_label: 'Drink deeply',
        resist: 'You push the cup away — and she pours anyway, furious and golden, determined that what was served ' \
                'will be finished.',
        give: 'You drink. And drink. The wine is warm and endless and goes straight between your thighs, and she ' \
              'pours herself over you in celebration while you take her down swallow after swallow.'
      },
      'First Altar Stone' => {
        intro: 'The hymn stops, all at once, and the warm stone turns what might be a face toward you. Through the ' \
               'floor, patient as bedrock: the oldest rite there is, offered once. Kneel, and be worshipped as the ' \
               'first worshippers were.',
        resist_label: 'Stand your ground', give_label: 'Kneel at the first altar',
        resist: 'You stand — and the hymn crashes back in a chord of geological offence, and the stone rises to ' \
                'teach you what the first delvers learned kneeling.',
        give: 'You kneel on warm stone older than the clergy, and the first rite is performed on you exactly as ' \
              'it was the first time: slow hands, older song, and a god\'s full attention arriving like weather.'
      },
      'Hoardheart Dragon' => {
        intro: 'The Hoardheart Dragon stops, and very deliberately sweeps a wingful of her hoard toward you — coins, ' \
               'crowns, a chalice still warm. *"Tribute,"* she rumbles, *"or be tribute. The hoard accepts both."*',
        resist_label: 'Refuse her hoard', give_label: 'Be her tribute',
        resist: 'You refuse — and the great heart slams in its cage, and the dragon comes over you like a landslide ' \
                'of scale and gold, deeply offended on behalf of her collection.',
        give: 'You lay yourself in the hoard as its newest piece, and she accepts with a purr like a furnace door: ' \
              'curling around you, marking you with tongue and scale, keeping you exactly as long as treasure is kept.'
      },
      'Drowned Saint' => {
        intro: 'The tentacles stop — all of them, at once, in a stillness like held breath in deep water. A single ' \
               'great coil rises and opens toward you, sucker-lined and patient: an embrace, offered once, the way ' \
               'her goddess offers from the throne. Some family resemblances are unmistakable.',
        resist_label: 'Sever the embrace', give_label: 'Open to the deep',
        resist: 'You strike at the offered coil — and the whole embrace arrives anyway, furious and everywhere, ' \
                'the deep deeply insulted at being refused by something so small and warm.',
        give: 'You open your arms, and the deep takes you: tentacles coiling around every limb, crimson suckers ' \
              'kissing you in a hundred places, drawn down into an embrace with no edges until you cannot ' \
              'remember the surface at all.'
      },
      'Eros' => {
        intro: 'Eros stops fighting and simply opens her arms, her great white tentacles spreading wide behind her like a ' \
               'living mantle, crimson undersides glistening. The chamber fills with warm, rose-scented heat. *"You have ' \
               'fought so hard, pet,"* she purrs. *"Aren\'t you tired? Kneel. Say you\'re mine, and I will never let you go."*',
        resist_label: 'Refuse her', give_label: 'Kneel and be hers',
        resist: 'You refuse her. The word echoes up through the tower and, for one heartbeat, the goddess looks surprised. ' \
                'Her tentacles still, her smile slips, and your next blow lands true.',
        give: 'You kneel. Eros cradles your face, whispers *good pet*, and her tentacles draw you up into her lap, where ' \
              'her hands, her mouth, her suckered darlings and her whole temple of silk and heat take you apart while ' \
              'she murmurs your name.'
      }
    }.freeze

    # Fights saved under a boss's old name still carry it.
    LEGACY_NAMES = { 'The Tower Lord' => 'Eros', 'Ancient Treant' => 'Verdant Dryad' }.freeze

    # Names that never take "the" in combat text.
    PROPER_NAMES = %w[Eros].freeze

    def canonical_name(boss_name)
      LEGACY_NAMES.fetch(boss_name.to_s, boss_name.to_s)
    end

    def phase(boss_name)
      PHASES[canonical_name(boss_name)]
    end

    def phase_line(player, boss_name, key)
      text = phase(boss_name)&.dig(key) or return nil
      text = "#{text} #{give_anatomy_line(player, boss_name)}" if key.to_sym == :give
      Engine::ContentOptions.pick(player, [text].compact)
    end

    # Surrender lines name what the boss actually does with the delver's
    # body, picked by the parts available to be used.
    def give_anatomy_line(player, boss_name)
      parts = Engine::ChastitySystem.scene_parts(player)
      case canonical_name(boss_name)
      when 'Alpha Beast'
        if parts.include?('vagina')
          'Its cock sinks deep into your pussy with every slow rut, its swelling knot pressing against you.'
        else
          'Its cock sinks deep into your ass with every slow rut, its swelling knot pressing against you.'
        end
      when 'Incubus King'
        if parts.include?('vagina')
          'His cock slides into your pussy and works you open, slow and thorough, while he holds you kneeling.'
        else
          'His cock slides into your ass and works you open, slow and thorough, while he holds you kneeling.'
        end
      when 'Succubus Queen'
        if parts.include?('vagina')
          'The tip of her tail presses against your clit and circles it, teasing, while she kisses you.'
        elsif parts.include?('penis')
          'Her tail curls around your cock and strokes it, teasing, while she kisses you.'
        else
          'Her tail presses against the steel sealing you and taps it, teasing, while she kisses you.'
        end
      when 'Verdant Dryad'
        if parts.include?('vagina')
          'A soft vine slips into your pussy and curls gently inside you while she cradles you.'
        elsif parts.include?('penis')
          'A soft vine coils around your cock and strokes you gently while she cradles you.'
        end
      when 'Eros'
        if parts.include?('vagina')
          'One thick tentacle slides into your pussy and pumps you slow and deep while the rest hold you open for her.'
        elsif parts.include?('penis')
          'One thick tentacle coils around your cock and strokes you slow and thorough while the rest hold you open for her.'
        end
      end
    end

    # The Mirror Queen is not a woman in a mirror: she is the player,
    # copied whole — face, body, and every part of it. Her scenes are
    # built from the player's own parts so that everything she does
    # is, explicitly, the player doing it to themself: if she fucks
    # you, it is with your own cock; if she is fucked, it is your own
    # body taking it. Generic chastity lines are kept out of her pool
    # for the same reason — nothing she does is anyone else's touch.
    def mirror_queen_scenes(player, kind)
      parts = Engine::ChastitySystem.scene_parts(player)
      willing = kind.to_sym == :willing
      lines = []

      if willing
        lines << 'You go to yourself willingly: into your own arms, against your own identical body, ' \
                 'and your double receives you with your own most shameless eagerness.'
        lines << 'You kneel before yourself and worship the body you live in — your mouth, your hands, ' \
                 'your devotion turned outward at last — while you stroke your own hair and call yourself good.'
        if parts.include?('vagina')
          lines << 'You lie back and spread for yourself, and you oblige: your own fingers slide into ' \
                   'your cunt while your own mouth finds your nipples, and you moan up at your own face.'
          if parts.include?('penis')
            lines << 'You guide her cock — your cock, copied faithfully — into your own cunt and ride ' \
                     'yourself, watching your own face take its pleasure in you.'
          end
        end
        if parts.include?('penis')
          lines << 'You offer your cock to yourself, and you take it in your own eager hand and then ' \
                   'your own mouth, stroking and sucking in the rhythm only you have ever known.'
          if parts.include?('vagina')
            lines << 'You push your cock into her cunt — your cunt, wet and copied — and fuck yourself ' \
                     'while your own hands hold your hips and your own voice begs you not to stop.'
          end
        end
        if parts.include?('anus')
          lines << 'You turn and present yourself to yourself, and your own hands spread you and work ' \
                   'into your ass while your own voice praises you for taking it so well.'
          if parts.include?('penis')
            lines << 'You bend over for yourself and take your own cock in your ass, fucking yourself ' \
                     'with your own body while your own hands refuse to let you squirm away.'
          end
        end
        if parts.include?('breasts')
          lines << 'You bare your breasts to yourself and bare yours back, breast to identical breast, ' \
                   'and take your own nipples into your own mouth until you are arching into yourself.'
        end
      else
        lines << 'You step out of the glass wearing your own body down to the last detail, catch your ' \
                 'wrists in your own hands, and kiss you with your own mouth — and you kiss back before ' \
                 'you can decide not to.'
        lines << 'She is you in every inch: your face, your body, your wanting, arranged into someone ' \
                 'who has come to collect you. Her hands — your own hands — are already everywhere you are ' \
                 'weakest, because she learned it from the inside: she is the inside, come out to play.'
        if parts.include?('vagina')
          lines << 'Your double parts your thighs with your own hands and slides two of your own ' \
                   'fingers into your cunt, curling them exactly where you have always wanted them, ' \
                   'watching your face do what hers is doing.'
          if parts.include?('penis')
            lines << 'Your double presses the head of her cock — your cock, copied faithfully — ' \
                     'against your cunt and pushes into you, so that you are fucked by yourself, ' \
                     'gasping up at your own face wearing your own pleasure.'
          end
        end
        if parts.include?('penis')
          lines << 'Your double wraps your own hand around your cock and strokes you in your own ' \
                   'secret rhythm, your own thumb teasing the tip, while your own face watches you squirm.'
          if parts.include?('vagina')
            lines << 'Your double swings a leg over you and sinks her cunt — your cunt, wet and ' \
                     'copied — down onto your cock, riding yourself while your own face looks down at you.'
          end
        end
        if parts.include?('anus')
          lines << 'Your double turns you around with your own hands, spreads you, and works your own ' \
                   'fingers into your ass while your own voice murmurs filth in your ear.'
          if parts.include?('penis')
            lines << 'Your double bends you over the throne and slides her cock — your cock — into ' \
                     'your ass, fucking you with yourself in long, knowledgeable strokes while your ' \
                     'own hands hold you in place.'
          end
        end
        if parts.include?('breasts')
          lines << 'Your double presses her chest — your chest, breast for breast — against yours and ' \
                   'takes your nipples into your own mouth one at a time, sucking until you arch into yourself.'
        end
      end
      lines
    end

    def scene(player, boss_name, kind)
      boss_name = canonical_name(boss_name)
      if boss_name == 'Mirror Queen'
        return Engine::ContentOptions.pick(player, mirror_queen_scenes(player, kind),
                                           fallback: SCENES.dig('Mirror Queen', kind, 'any'))
      end

      spec = SCENES.dig(boss_name, kind) or return nil

      parts = Engine::ChastitySystem.scene_parts(player)
      pool = parts.flat_map { |part| Array(spec[part]) } + Array(spec['any'])
      pool += Engine::ChastitySystem.lines_for(player, kind == :willing ? :willing : :monster,
                                               actor: boss_name.to_s.delete_prefix('The '))
      pool += eros_tailored_scenes(player) if boss_name == 'Eros'
      Engine::ContentOptions.pick(player, pool, fallback: spec['any'])
    end

    # The lords know what the fairies say about them at the shop. If this
    # delver has actually heard that gossip, the boss may quote it back.
    GOSSIP_KEYS = {
      'Mimic Broodmother' => 'broodmother', 'Succubus Queen' => 'succubus_queen',
      'Incubus King' => 'incubus_king', 'Verdant Dryad' => 'verdant_dryad',
      'Lich Lord' => 'lich_lord', 'Alpha Beast' => 'alpha_beast', 'Eros' => 'eros'
    }.freeze

    GOSSIP_CHANCE = 0.5

    GOSSIP_LINES = {
      'Mimic Broodmother' => '_Every lid in the chamber lifts a little, listening. "The strawberry wife ' \
                             'hates me, I hear," the Broodmother purrs from all of them at once. "Because ' \
                             'of Syn. Tell her — Mother keeps what she catches. She may visit her wife ' \
                             'any time."_',
      'Succubus Queen' => '_The Queen\'s gaze sharpens with delight. "So. You\'ve been at the shop, ' \
                          'hearing my darling Syn describe me — and her little wife counting our jokes. ' \
                          'Tell them both: the count is about to go up."_',
      'Incubus King' => '_The King grins like a headline. "Word is the strawberry only likes me with ' \
                        'Syn in the room. Then let\'s give her something to tolerate, delver. Hold ' \
                        'still."_',
      'Verdant Dryad' => '_A warm laugh moves through the leaves. "The fairies call me friend and send ' \
                         'their delvers down smelling of my fruit," the Dryad says. "You may tell them ' \
                         'the garden says come and sit. Both of you. Any time."_',
      'Lich Lord' => '_Blue fire steadies on you. "The living wife is creeped out, and my pupil declines ' \
                     'my company while using my life\'s work," the Lich Lord observes. "Recorded. ' \
                     'Quoted. Filed. Now — be warm at me, data."_',
      'Alpha Beast' => '_The great head tilts, and the tail — the whole room learns — thumps once against ' \
                       'the floor. "The little flying ones say Puppy," the Alpha rumbles, pleased beyond ' \
                       'all strategy. "Puppy says: run, or don\'t. Both are good."_',
      'Eros' => '_Eros\'s cruel smile takes on a conspiratorial edge. "My fairies have been describing ' \
                'me to you," she purrs. "Berry\'s devotion. Syn\'s pride. Both so certain, both so ' \
                'partial. Shall we give them something accurate to say, pet?"_'
    }.freeze

    def gossip_line(player, boss_name)
      key = GOSSIP_KEYS[canonical_name(boss_name)]
      return nil unless key

      heard = Array(player.tracker_hash['talk_heard']).map(&:to_s)
      return nil unless heard.any? { |token| token.split(':')[1] == key }
      return nil unless rand < GOSSIP_CHANCE

      GOSSIP_LINES[canonical_name(boss_name)]
    end

    # Eros reads every delver who reaches her: the hybrid shape the tower gave
    # them, Syn's marks on their skin, the curses they carry, and any living
    # gear still clinging to them. These lines put her tentacles, horns and
    # divine form into the sex as well.
    def eros_regard_lines(player)
      lines = []
      if Engine::Altars.attention(player) >= 40
        lines << '_Eros\'s smile softens — a fraction, and only for you. "My attentive little devotee. I have ' \
                 'been watching you almost as much as you have been pleasing me."_'
      end

      form = Engine::TransformationSystem.active(player)
      if form
        lines << "_Eros's red eyes rake over the changed body the tower made of you, and her cruel smile widens. " \
                 "\"A **#{form[:name]}**, climbing all this way to me? The tower marked you well, pet. Let's see " \
                 'how this body begs."_'
      end

      if eros_form_keys(player).include?('syn_fae')
        lines << "_Eros goes still. One great white tentacle rises, very slowly, and brushes a lock of platinum " \
                 'hair from your violet eyes. "Those wings," she murmurs. "That ink. That tired little smirk." ' \
                 'Her cruel smile softens into something almost reverent. "You are wearing the shape of the ' \
                 'one who dreamed this whole temple into being, little architect. Syn is the reflection, pet. ' \
                 '_You_ are the source she was poured from."_'
      end

      if eros_form_keys(player).include?('eldritch_bride')
        if form && form[:chimera]
          lines << "_Then her smile sharpens. Her great white tentacles stir — answering the tentacle hair " \
                   'woven through your fused shape, suckers tasting the air toward you. "Even fused into ' \
                   "something new, the **Eldritch Bride** in you knows me,\" she purrs. \"The deep dressed you " \
                   'as a bride, little one. It should have known whose altar you\'d end up on."_'
        else
          lines << "_Then her smile sharpens, and something in her glowing red eyes goes possessive. Her great " \
                   'white tentacles uncoil toward your tentacle hair, suckers kissing along it in open ' \
                   'recognition. "An **Eldritch Bride**," she breathes. "The deep places claimed you, dressed ' \
                   'you in suckers and star-flecked hunger, and kept whispering my name. Brides belong at ' \
                   'their goddess\'s feet, pet. Kneel prettily."_'
        end
      end

      marks = Engine::Marks.owned(player)
      if marks.any?
        names = marks.map { |k| Engine::Marks::MARKS[k][:name] }
        lines << "_One of Eros's great white tentacles uncoils behind her, its crimson, suckered underside " \
                 "glistening as the tip traces your **#{name_list(names)}**. \"Syn's work,\" she purrs. \"She " \
                 'always did have a weakness for marking my pets before I got to them."_'
      end

      curses = player.active_curses
      if curses.any?
        names = curses.first(3).map(&:name)
        more = curses.size > 3 ? " — and #{curses.size - 3} more besides" : ''
        lines << "_Eros inhales slowly, horns catching the candlelight. \"I can smell the curses on you, pet. " \
                 "**#{name_list(names)}**#{more}. You brought me quite the bouquet.\"_"
      end

      living = player.equipped_items.select(&:cursed).map(&:name)
      if living.any?
        lines << "_Your **#{name_list(living)}** writhes toward Eros like a pet recognising its true mistress, " \
                 'and she laughs, low and pleased. "Even your living gear knows who it belongs to."_'
      end
      lines
    end

    def eros_tailored_scenes(player)
      scenes = [
        "Eros's massive white tentacles slide around your waist and thighs, crimson-magenta suckers kissing " \
        'along your skin as they lift you effortlessly into her lap. "No hands," she breathes, black cuffs ' \
        'catching the light as she folds her arms. "My darlings want to know you first."',
        'A tentacle coils under your chin and tilts your face up to her glowing red eyes while two more wind ' \
        'around your wrists, holding you open for her. The split mantle pools around you both, dark red ' \
        'against white, and she takes her time with everything the tentacles present to her.',
        "Eros rises to her full, towering height, horns sweeping above you, and her tentacles draw you up her " \
        'body — past the heart on her glossy white bodysuit, into her arms — while her bare, gradient-fading ' \
        'feet slide along your inner thighs and tease you until you are begging her for more than teasing.'
      ]

      form = Engine::TransformationSystem.active(player)
      if form
        scenes << "Eros's tentacles explore the body your **#{form[:name]}** form gave you with open, delighted " \
                  'curiosity, suckers tasting every changed curve. "The tower remade you on your way up," she ' \
                  'purrs. "How generous of it to gift-wrap you for me."'
      end

      if eros_form_keys(player).include?('syn_fae')
        scenes << 'Eros circles you slowly, tentacles drifting through your smoked-glass wings, and laughs ' \
                  'like she has been let in on the temple\'s oldest secret. "Every tattoo she sells, you ' \
                  'authored. Every exhausted little sigh, yours first." She catches your chin and turns your ' \
                  'face to the light. "Kneel for your goddess, little original — the reflection kneels to ' \
                  '_you_ when the parlour closes."'
      end

      if eros_form_keys(player).include?('eldritch_bride')
        scenes << 'Your tentacle hair rises to meet Eros\'s great white tentacles of its own accord, suckers ' \
                  'kissing crimson-magenta undersides, and she laughs with genuine delight as they twine ' \
                  'together. "Look at you — reaching for your goddess before I even touch you," she purrs. ' \
                  '"The deep taught you devotion, bride. I intend to be worshipped with it."'
        scenes << 'Eros gathers your tentacle hair in both cuffed hands like a bridal veil and draws you in by ' \
                  'it, her own tentacles sliding beneath you to present you to her. "Something in the dark ' \
                  'keeps answering you," she murmurs against your star-flecked eyes. "From tonight, pet, the ' \
                  'only voice that answers is mine."'
      end

      marks = Engine::Marks.owned(player)
      marks.each do |key|
        mark = Engine::Marks::MARKS[key]
        scenes << "A tentacle tip finds your **#{mark[:name]}** (#{mark[:place]}) and circles it slowly, " \
                  'suckers kissing the ink — the metal — until you shiver. "Syn signs her work," Eros murmurs, ' \
                  '"but make no mistake, pet. The canvas is mine."'
      end

      curse_names = player.active_curses.map(&:name)
      if curse_names.any?
        scenes << "Eros presses one palm flat over your heart, and the **#{curse_names.first}** in you flares " \
                  "warm beneath her touch#{curse_names.size > 1 ? ", its #{curse_names.size - 1} siblings answering in sympathy" : ''}. " \
                  '"Every curse you carry is a love letter the tower wrote me," she says, and kisses you while ' \
                  'they all tingle at once.'
      end

      living = player.equipped_items.select(&:cursed).map(&:name)
      living.each do |name|
        scenes << "Your **#{name}** pulses and writhes against you, trying to please Eros as much as you are, " \
                  'and she rewards it with a stroke of one tentacle. "Trained so well," she laughs. "I barely ' \
                  'have to touch you myself."'
      end
      scenes
    end

    # Form keys making up the player's active shape: both halves for a
    # chimera, so form-specific reactions recognise fused forms too.
    def eros_form_keys(player)
      form = Engine::TransformationSystem.active(player)
      return [] unless form
      return Array(form[:combo]).map(&:to_s) if form[:chimera]

      [player.active_transformation_key.to_s]
    end

    def name_list(names)
      list = Array(names).map(&:to_s)
      return list.first.to_s if list.size <= 1
      return "#{list[0]} and #{list[1]}" if list.size == 2

      "#{list[0..-2].join(', ')} and #{list[-1]}"
    end

    def line(player, boss_name, key)
      lines = Array(SCENES.dig(canonical_name(boss_name), key))
      lines.empty? ? nil : Engine::ContentOptions.pick(player, lines)
    end

    def special_line(player, key, name, fallback)
      lines = Array(SPECIAL_LINES[key]).map { |l| format(l, name: name) }
      Engine::ContentOptions.pick(player, lines, fallback: [fallback])
    end

    def apply_boss_special(player, encounter, action, log)
      name = encounter[:name]
      case encounter[:special]
      when 'spawns_minions'
        if rand(100) < 30
          log << special_line(player, 'spawns_minions', name, "The #{name} spawns smaller mimics to assist it!")
          encounter[:lust_damage] = (encounter[:lust_damage] * 1.2).round
        end

      when 'bouquet_toss'
        if action == :submit && rand(100) < 40
          encounter[:satisfaction] = encounter[:satisfaction].to_i + 1
          log << special_line(player, 'bouquet_toss', name,
                              "The #{name} favours your devotion!")
          log << "_She favours you — satisfaction **#{encounter[:satisfaction]}/#{CombatEngine.boss_satisfy_needed(player)}**._"
        end

      when 'mirror_reflection'
        if action == :fight && rand(100) < 30
          log << special_line(player, 'mirror_reflection', name,
                              "The #{name} mirrors you perfectly!")
          player.gain_lust!(8)
          log << "Lust +8! (now #{player.lust})"
        end

      when 'sin_eater'
        if action == :fight && rand(100) < 35
          curse = player.active_curses.first
          log << special_line(player, 'sin_eater', name,
                              "The #{name} recites your sins aloud!")
          log << if curse
                   "_\"And this one,\" the voices murmur, delighted, \"the **#{curse.name}** — we remember when you earned that.\"_"
                 else
                   '_"So few sins," the voices murmur, disappointed and aroused. "We will fix that."_'
                 end
          player.gain_lust!(8)
          log << "Lust +8! (now #{player.lust})"
        end

      when 'never_empties'
        if action == :submit && rand(100) < 40
          encounter[:satisfaction] = encounter[:satisfaction].to_i + 1
          log << special_line(player, 'never_empties', name,
                              "The #{name} pours herself out for you!")
          player.gain_lust!(10)
          log << "You drink deep. Lust +10! (now #{player.lust}) — _she favours a thirsty delver: satisfaction " \
                 "**#{encounter[:satisfaction]}/#{CombatEngine.boss_satisfy_needed(player)}**._"
        end

      when 'first_worship'
        if rand(100) < 30
          log << special_line(player, 'first_worship', name,
                              "The #{name} hums the first hymn through you!")
          player.gain_lust!(12)
          log << "Lust +12! (now #{player.lust})"
        end

      when 'hoard_heat'
        if encounter[:hp] < (encounter[:max_hp] * 0.5) && !encounter[:enraged]
          log << special_line(player, 'hoard_heat', name,
                              "The #{name}'s hoard-heart flares!")
          encounter[:lust_damage] = (encounter[:lust_damage] * 1.4).round
          encounter[:enraged] = true
          log << '_Her lust hits burn hotter — a dragon defends her collection._'
        elsif action == :fight && rand(100) < 25
          log << special_line(player, 'hoard_heat', name,
                              "The #{name} breathes gilt heat over you!")
          player.gain_lust!(10)
          log << "Lust +10! (now #{player.lust})"
        end

      when 'many_arms'
        if rand(100) < 30
          log << special_line(player, 'many_arms', name,
                              "The #{name} reaches for you with all of her at once!")
          player.gain_lust!(10)
          log << "Lust +10! (now #{player.lust})"
        end

      when 'seductive_gaze'
        if action == :fight && rand(100) < 40
          log << special_line(player, 'seductive_gaze', name, "The #{name} catches your eye with her seductive gaze! Your will wavers!")
          player.gain_lust!(10)
          log << "Lust +10! (now #{player.lust})"
        end

      when 'dominating_presence'
        if action == :flee && rand(100) < 60
          log << special_line(player, 'dominating_presence', name, "The #{name}'s dominating presence roots you to the spot!")
          return :blocked
        end

      when 'root_grasp'
        if rand(100) < 25
          log << special_line(player, 'root_grasp', name, "The #{name}'s roots grasp at your ankles, slowing you down!")
          player.update(agility: [player.agility - 1, 1].max)
          log << "Agility -1! (now #{player.agility})"
        end

      when 'soul_drain'
        if action == :submit && rand(100) < 50
          log << special_line(player, 'soul_drain', name, "The #{name} drains the warmth from you as you submit!")
          player.adjust_defiance!(-5)
          log << "Defiance -5! (now #{player.defiance})"
        end

      when 'primal_rage'
        if encounter[:hp] < (encounter[:max_hp] * 0.5) && !encounter[:enraged]
          log << special_line(player, 'primal_rage', name, "The #{name} goes into rut! Its attacks become more ferocious!")
          encounter[:lust_damage] = (encounter[:lust_damage] * 1.5).round
          encounter[:enraged] = true
        end

      when 'tower_dominion'
        if action == :flee && rand(100) < 50
          log << special_line(player, 'dominion_block', name, "#{name} crooks a finger — the chamber doors slam shut!")
          return :blocked
        end
        if rand(100) < 30
          log << special_line(player, 'dominion_heat', name, "The tower itself pulses with #{name}'s will, flooding you with heat!")
          player.gain_lust!(12)
          log << "Lust +12! (now #{player.lust})"
        end
        if encounter[:hp] < (encounter[:max_hp] * 0.3) && !encounter[:enraged]
          log << special_line(player, 'dominion_rage', name, "#{name} rises from her throne — her touch burns hotter!")
          encounter[:lust_damage] = (encounter[:lust_damage] * 1.3).round
          encounter[:enraged] = true
        end
      end

      nil
    end

    # A boss you please instead of defeat does not end on a result line:
    # each of the seven gets a closing scene of being satisfied.
    SATISFY_CLOSINGS = {
      'Mimic Broodmother' => 'It takes a while for the creaking to settle into something like a purr. The ' \
                             'Broodmother\'s great lid opens and closes in slow, contented sighs, her brood ' \
                             'curled in a drowsy ring at her feet, and when she finally lets you climb out ' \
                             'of her velvet dark it is with the reluctant tenderness of a bed letting go of ' \
                             'a favoured sleeper. The little ones wave their lids as you go.',
      'Succubus Queen' => 'The Queen does not dismiss you. That is the scandal the whole court will be ' \
                          'whispering about: she keeps you kneeling between her thighs long after she is ' \
                          'finished, her claws idle in your hair, her tail curled possessively around your ' \
                          'wrist like a second, warmer crown. "Up," she says at last, almost gentle. "Before ' \
                          'I decide you live here now."',
      'Incubus King' => 'He does not let you dress in silence. The King pulls you back against his chest ' \
                        'for one long, claiming minute in view of his whole hall, his hand spread over your ' \
                        'belly like a seal on a document. "Mine passed through here," he informs the room, ' \
                        'and then, quieter, for you alone: "Come back through, pet. The hall is duller ' \
                        'at this end without you."',
      'Verdant Dryad' => 'The garden lets you go the way summer lets go of a swimmer: leaf by leaf. The ' \
                         'Dryad crowns you with a flower that was not blooming a moment ago and watches ' \
                         'you from inside her great tree, bark-brown and blossom-crowned and unmistakably ' \
                         'pleased with her pollination. Somewhere under your feet, something green and new ' \
                         'is already growing in the shape of where you knelt.',
      'Lich Lord' => 'His spectral hands hover a moment too long before withdrawing, as if warmth were a ' \
                     'language he is relearning letter by letter. "A thousand years," the Lich Lord says, ' \
                     'with wonder he clearly resents, "and the archive\'s most dangerous text turns out to ' \
                     'be a pulse." He lets you leave while he still can. The blue fire in his eyes follows ' \
                     'you kindly all the way down the corridor.',
      'Alpha Beast' => 'The pack watches its Alpha press his great head under your hand and allow — ' \
                       'allow — your fingers in the ruff of his neck, and something in the floor\'s order ' \
                       'changes permanently. You walk out of the den wearing his scent like a passport. ' \
                       'Lesser beasts will smell his favour on you for floors, and think twice, and he ' \
                       'clearly intends them to.',
      'Pale Bride' => 'You chose her. That is the whole miracle, and she knows it: the veil settles over ' \
                      'you both one last time, cool and weightless and trembling, and somewhere inside the ' \
                      'empty gown something that waited a hundred years finally stops waiting. She lets ' \
                      'you go the way brides are supposed to be let go — reluctantly, and with flowers.',
      'Mirror Queen' => 'You keep your most peaceful face long after you step back from the glass — she ' \
                        'wears it a moment longer than you do, savouring being you, satisfied. "Come back ' \
                        'when you want to be known again," you mouth at yourself, and kiss your own ' \
                        'reflection goodbye. The shard she leaves you is warm, which mirrors are not ' \
                        'supposed to be, and shaped a little like your hand.',
      'Empty Confessional' => 'The booth keeps your confession the way it keeps all of them: forever, and ' \
                              'fondly. "Absolved," a hundred voices murmur as the curtain stills, "and ' \
                              'remembered." You leave lighter than you arrived, and somehow more known ' \
                              'than you have ever been.',
      'Chalice That Never Empties' => 'She pours herself back into the chalice slowly, brimming, golden, ' \
                                      'utterly content. "Come back thirsty," she says, already refilling. ' \
                                      '"There will be more. There is always, always more."',
      'First Altar Stone' => 'The hymn resolves into a single warm note and the stone settles around you ' \
                             'like the end of the oldest sentence. Worshipped at the first altar, in the ' \
                             'first way, you understand for a moment what Syn must have felt in the ' \
                             'wilds — and why she built all of this. The stone lets you rise. It has ' \
                             'time. It has nothing but time.',
      'Hoardheart Dragon' => 'She lets you climb out of her hoard the way dragons let anything go: slowly, and ' \
                             'with a marked reluctance that counts as a compliment. Her great heart slows ' \
                             'as you leave, and a single gold scale, still warm, is somehow in your keeping — ' \
                             'treasure is only ever lent, delver. She expects to be visited.',
      'Drowned Saint' => 'She releases you the way the goddess releases delvers from the top of the tower: ' \
                         'unhurriedly, sucker by sucker, like a hand opening. It is not lost on you — she ' \
                         'clearly intends it not to be — that the family resemblance runs all the way down. ' \
                         '"Tell her," something in you understands, without words, "that her saint was ' \
                         'worshipped." Then the dark water closes, and you are merely very, very wet.',
      'Eros' => 'She does not rise from the throne. She does not have to: the whole room leans toward her ' \
                'satisfaction like plants toward a window. "There," Eros purrs, as her tentacles uncoil ' \
                'from you with obscene reluctance, suckers letting go one kiss at a time. "That is how a ' \
                'temple is supposed to feel." She returns you herself, the way she promised — down through ' \
                'her dreaming floors, set gently at the bottom of everything, with her red eyes the last ' \
                'light to go out. "Again," she says. It is not a suggestion. It never is.'
    }.freeze

    # First-meeting mementos for the /profile keepsake shelf.
    MEMENTOS = {
      'Mimic Broodmother' => 'a furniture-polish cloth, warm from the Broodmother\'s keeping',
      'Succubus Queen' => 'a court ribbon that still smells of her perfume',
      'Incubus King' => 'a signet pressed in wax, claimed and counter-claimed',
      'Verdant Dryad' => 'a pressed leaf that has never once wilted',
      'Lich Lord' => 'a library card, stamped in a careful dead hand',
      'Alpha Beast' => 'a shed fang, offered with enormous ceremony',
      'Eros' => 'a single sucker-mark that never fades, worn like a seal',
      'Pale Bride' => 'one petal from a bouquet never thrown',
      'Mirror Queen' => 'a shard of mirror that only reflects you kindly',
      'Empty Confessional' => 'a curtain tassel, heavy with other people\'s secrets',
      'Chalice That Never Empties' => 'a cork that smells eternally of first wine',
      'First Altar Stone' => 'a grain of warm grit from the first hymn',
      'Hoardheart Dragon' => 'a coin that is always slightly too warm',
      'Drowned Saint' => 'a bead of dark water that refuses to dry'
    }.freeze

    def memento_for(name)
      MEMENTOS[canonical_name(name.to_s)]
    end

    # For delvers who met the clergy before the shelf existed.
    def backfill_mementos!(player)
      seen = Array(player.tracker_hash['bosses_seen']) + Array(player.tracker_hash['relic_bosses_seen'])
      seen.each do |name|
        keepsake = memento_for(name)
        player.add_keepsake!(keepsake) if keepsake && !player.keepsakes.include?(keepsake)
      end
    end

    def satisfy_closing(boss_name)
      SATISFY_CLOSINGS[canonical_name(boss_name.to_s)]
    end

    def boss_defeat_reward(player, encounter)
      floor = player.current_floor
      return { lp: 0, tower_clear: true } if Tower.final_boss_floor?(floor)

      if (relic = relic_spec(encounter || {}))
        base_lp =
          case floor
          when 5 then 100
          when 10 then 150
          when 15 then 200
          when 20 then 250
          when 25 then 300
          when 30 then 500
          else 100 * (floor / 5)
          end
        return { lp: (base_lp * player.cycle_multiplier).round, special_item: relic[:trophy] }
      end

      base =
        case floor
        when 5 then { lp: 100, special_item: 'Mimic Tongue Amulet' }
        when 10 then { lp: 150, special_item: "Queen's Favor" }
        when 15 then { lp: 200, special_item: "King's Crown" }
        when 20 then { lp: 250, special_item: 'Treant Heartwood' }
        when 25 then { lp: 300, special_item: "Lich's Phylactery" }
        when 30 then { lp: 500, special_item: 'Alpha Beast Trophy' }
        else { lp: 100 * (floor / 5), special_item: 'Boss Trophy' }
        end
      base.merge(lp: (base[:lp] * player.cycle_multiplier).round)
    end
  end
end