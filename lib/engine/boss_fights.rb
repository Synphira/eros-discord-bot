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
        type: 'demon',
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
                       'You sink down onto the smooth root she grows for you, riding it slow and deep while she holds ' \
                       'your waist and whispers encouragement against your ear.'],
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
                    'It noses between your legs, breathing in your scent with a low, possessive growl.']
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
          'vagina' => ['You climb into Eros\'s lap and sink down onto the glowing cock she conjures for you, moaning as she holds your hips and makes you ride it at her pace.',
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

    def start_boss_encounter(player, floor)
      boss = boss_for_floor(floor)
      return nil unless boss

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
      Engine::ContentOptions.pick(player, [text])
    end

    def scene(player, boss_name, kind)
      boss_name = canonical_name(boss_name)
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
        'feet slide between your legs and tease you until you are begging her for more than teasing.'
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

    def boss_defeat_reward(player, _encounter)
      floor = player.current_floor
      return { lp: 0, tower_clear: true } if Tower.final_boss_floor?(floor)

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