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
        name: 'Ancient Treant',
        type: 'plant',
        type_name: 'Plant',
        description: 'A colossal living tree dripping with amber sap, its roots carpeting the chamber. It catches anyone who wanders close, holds them in its branches, and fills them until they overflow.',
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
        name: 'The Tower Lord',
        type: 'demon',
        type_name: 'Archdemon',
        description: 'The ancient sovereign of the Endless Ruins. Every sin committed in the tower flows up into its throne, and it can become anything you have ever wanted to be fucked by.',
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
      'Ancient Treant' => {
        assault: {
          'vagina' => ['Roots burst from the floor and pull your legs wide while a thick, smooth heartwood shaft rises between them and pushes into your cunt, slick with amber sap.',
                       'The Ancient Treant fucks your pussy with a gnarled, ridged root while a soft, mossy tendril rubs your clit in slow circles.'],
          'penis' => ["A sap-slick hollow in the treant's bark closes around your cock, its warm inner wood squeezing and pulling at you in slow, creaking pulls.",
                      'Fine roots coil around your cock and balls and squeeze in rhythm while warm sap drips down your shaft.'],
          'anus' => ['A smooth root slides between your cheeks and into your ass, growing thicker inside you as it pumps warm sap deep.'],
          'breasts' => ['Mossy tendrils wrap your breasts and tug at your nipples while flowering buds latch on and suckle.'],
          'any' => ['The Ancient Treant lifts you into its branches, roots wrapped around your limbs, and runs sap-slick vines over every inch of your skin.',
                    "Golden pollen drifts down from the treant's crown and settles on your skin, and everywhere it touches starts to throb with need."]
        },
        willing: {
          'vagina' => ["You let the treant's roots spread your legs and sink down onto its heartwood shaft, moaning as it fills your cunt with sap.",
                       'You grind your clit against its mossy bark while a root fucks you slow and deep.'],
          'penis' => ["You push your cock into a sap-slick hollow in the treant's trunk and fuck it, the warm wood squeezing you with every thrust."],
          'anus' => ['You back onto a smooth root and take it into your ass, sighing as it swells and pumps warm sap into you.'],
          'breasts' => ["You press your breasts against the treant's mossy bark and let its buds suckle your nipples."],
          'any' => ["You lie back in the treant's roots and let them hold you, vines sliding over your skin as it takes its time with you."]
        },
        wanting: ["The Ancient Treant's roots tighten around you and its branches groan. It isn't finished with you."],
        sated: ['The Ancient Treant shudders from root to crown, sap pouring down its bark, then slowly unwinds from you and settles back into the earth.'],
        unimpressed: ['The treant creaks indifferently, its roots barely stirring.'],
        beaten: ['The Ancient Treant groans and sinks into the earth, its roots going slack around you.']
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
      'The Tower Lord' => {
        assault: {
          'vagina' => ['The Tower Lord reshapes itself into exactly what you crave and fills your cunt with it, every thrust timed perfectly to the pounding of your heart.',
                       'A dozen shadowy hands hold you open on the throne while the Tower Lord fucks your pussy deep and slow, its eyes never leaving yours.'],
          'penis' => ["The Tower Lord's hand closes around your cock and every sin in the tower pours through its touch, each stroke like a hundred tongues at once.",
                      'It pulls you onto the throne and sinks down on your cock, its body impossibly hot and tight as it rides you.'],
          'anus' => ['The Tower Lord bends you over its throne and fills your ass with a cock that grows thicker every time you moan.'],
          'breasts' => ["Shadowy mouths open on the Tower Lord's palms, and it cups your breasts so they can suck your nipples."],
          'any' => ['The Tower Lord pulls you into its lap, and every desire you have ever had floods your mind at once as its hands roam your body.',
                    'The throne comes alive beneath you, its carved figures reaching out to stroke and grope you while the Tower Lord watches.']
        },
        willing: {
          'vagina' => ["You climb into the Tower Lord's lap and sink down on its cock, moaning as it reshapes itself to fill your cunt perfectly."],
          'penis' => ['You let the Tower Lord take your cock in its hand, and the sins of the whole tower pour through you as it strokes.'],
          'anus' => ['You bend over the throne and offer yourself, crying out as the Tower Lord fills your ass.'],
          'breasts' => ['You offer your breasts to the shadowy mouths in its palms and moan as they suck.'],
          'any' => ['You kneel before the throne and give yourself to the Tower Lord completely, and it takes everything you offer.']
        },
        wanting: ['The Tower Lord smiles. "Every sin in this tower is mine. Show me yours."'],
        sated: ['The Tower Lord shudders, and the whole tower shudders with it. It sinks back into its throne, utterly sated.'],
        unimpressed: ['The Tower Lord barely stirs. "I have tasted every sin in this tower. Yours bore me."'],
        beaten: ['The Tower Lord reels back into its throne under your final blow, its shadows retreating into the walls. For once, the tower failed to claim you.']
      }
    }.freeze

    SPECIAL_LINES = {
      'spawns_minions' => ['The %<name>s births a wave of tiny mimics that swarm up your legs, licking and nibbling at you!',
                           'The %<name>s spits out a clutch of little mimics that latch onto you and refuse to let go!'],
      'seductive_gaze' => ['The %<name>s locks eyes with you, and a wave of heat floods between your legs. Your grip goes slack!'],
      'dominating_presence' => ['"Kneel," the %<name>s commands, and your legs obey before your mind can. You can\'t run!'],
      'root_grasp' => ["The %<name>s's roots burst up and coil around your ankles, sliding up your thighs and slowing you down!"],
      'soul_drain' => ['As you submit, the %<name>s kisses you and draws the warmth right out of you, leaving you shivering and weaker!'],
      'primal_rage' => ['The %<name>s goes into rut! Its cock swells, its musk thickens, and its attacks grow more ferocious!'],
      'dominion_block' => ['%<name>s raises a hand and the chamber doors slam shut. "Leaving so soon?"'],
      'dominion_heat' => ["The tower pulses with %<name>s's will, and every sin in its walls floods into you as heat!"],
      'dominion_rage' => ['%<name>s rises from its throne, and its touch burns hotter than ever!']
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
        description: 'A piece of living wood. +10 max Defiance, +2 RES.',
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
          "**Floor #{floor} — The Tower Lord's Chamber.** Treasure glitters in the dark around an ancient throne."
        else
          "**Floor #{floor}** — the air grows heavy."
        end
      warning =
        if boss[:final]
          'This is the final guardian. Defeat it to conquer the tower and begin the next cycle.'
        else
          "This foe is far more dangerous than any you've faced before."
        end
      cycle_note = player.current_cycle.to_i > 1 ? " · Cycle #{player.current_cycle} ×#{cycle.round(2)}" : ''

      message = <<~MSG.strip
        #{intro}

        You stand before **#{boss[:name]}**!
        _#{boss[:description]}_

        #{warning}
        _(Threat #{threat.category.to_s.upcase} — ×#{threat.stat_mult} power · ×#{threat.lust_mult} lust#{cycle_note})_
        HP #{hp}/#{hp} · STR #{strength} · AGI #{agility} · Lust hit #{lust_damage}
      MSG
      message += "\n#{start_lines.join("\n")}" if start_lines.any?

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
      'Ancient Treant' => {
        intro: 'The Ancient Treant groans, and the whole chamber blooms. Flowers burst open on every branch, and heavy golden ' \
               'pollen drifts down over you, warm and sweet.',
        resist_label: 'Hold your breath', give_label: 'Breathe it in',
        resist: 'You cover your face, push through the drifting gold and hack at the trunk until sap runs and the blossoms close.',
        give: 'You breathe deep. The pollen floods you with heat, and soft vines lift you into the heart of a great flower, ' \
              'caressing you everywhere while the petals close around you both.'
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
      'The Tower Lord' => {
        intro: 'The Tower Lord rises from the throne, and the walls themselves begin to breathe. Every carving in the chamber ' \
               'turns to watch you. *"You have fought well,"* it says. *"Now stop. Belong to me, and the tower will love ' \
               'you forever."*',
        resist_label: 'Refuse', give_label: 'Belong to it',
        resist: 'You refuse. The word rings through the chamber and the carvings flinch. The Tower Lord\'s composure cracks, and ' \
                'your next blow lands true.',
        give: 'You say yes. The tower itself embraces you: warm stone, soft hands and slick heat from every direction at once, ' \
              'and the Tower Lord\'s voice purring your name while it all takes you apart.'
      }
    }.freeze

    def phase(boss_name)
      PHASES[boss_name.to_s]
    end

    def phase_line(player, boss_name, key)
      text = phase(boss_name)&.dig(key) or return nil
      Engine::ContentOptions.pick(player, [text])
    end

    def scene(player, boss_name, kind)
      spec = SCENES.dig(boss_name.to_s, kind) or return nil

      parts = Engine::ChastitySystem.scene_parts(player)
      pool = parts.flat_map { |part| Array(spec[part]) } + Array(spec['any'])
      pool += Engine::ChastitySystem.lines_for(player, kind == :willing ? :willing : :monster,
                                               actor: boss_name.to_s.delete_prefix('The '))
      Engine::ContentOptions.pick(player, pool, fallback: spec['any'])
    end

    def line(player, boss_name, key)
      lines = Array(SCENES.dig(boss_name.to_s, key))
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
          log << special_line(player, 'dominion_block', name, "#{name} raises a hand — the chamber doors slam shut!")
          return :blocked
        end
        if rand(100) < 30
          log << special_line(player, 'dominion_heat', name, "The tower itself pulses with #{name}'s will, flooding you with heat!")
          player.gain_lust!(12)
          log << "Lust +12! (now #{player.lust})"
        end
        if encounter[:hp] < (encounter[:max_hp] * 0.3) && !encounter[:enraged]
          log << special_line(player, 'dominion_rage', name, "#{name} rises from its throne — its touch burns hotter!")
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