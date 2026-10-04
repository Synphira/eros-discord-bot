# frozen_string_literal: true

module Engine
  module EventPacks
    CORE = {
      'kneeling_shrine' => {
        name: 'Kneeling Shrine', tag: 'oral', tracker: 'oral_events',
        blurb: 'a cushioned kneeler faces a horned idol.',
        intro: 'A velvet kneeler sits before the idol of a horned demon lord, his stone cock jutting proud and glistening ' \
               'with oil. As you approach, the stone warms and an inscription glows: *Worship, and be blessed.*',
        accept: {
          label: 'Kneel', text: 'Worship the idol',
          scenes: ['You sink onto the kneeler and wrap your lips around the warm stone, and it pulses to life under your tongue. ' \
                   'The idol groans as you bob along its length, taking it deeper into your throat with every devoted stroke.',
                   'When it finally spills, you swallow every thick, salty drop and lick the stone clean, sighing as a warm ' \
                   'blessing settles over you.'],
          parts: {
            'vagina' => 'Your pussy drips onto the velvet the whole time, clenching around nothing as you worship.',
            'penis' => 'Your cock strains untouched beneath you, leaking onto the kneeler with every gulp.'
          },
          lp: 6, lust: 12,
          condition: { key: 'devoted_lips', name: 'Devoted Lips', floors: 3,
                       effects: { 'demon_submit_lp' => 3, 'satisfy_bonus' => 0.1 } }
        },
        alt: {
          label: 'Offer yourself', text: 'Let the idol taste you instead',
          scenes: ['The idol\'s stone lips part and a long, warm tongue unfurls, lapping at you with slow, reverent strokes ' \
                   'until your knees shake.'],
          parts: {
            'vagina' => 'It buries its tongue in your pussy and laps at your clit until you cum against its face.',
            'penis' => 'Its lips close around your cock and it sucks you until you spill down its stone throat.',
            'anus' => 'It parts your cheeks and rims your ass with slow, worshipful strokes.'
          },
          lp: 5, lust: 10,
          condition: { key: 'idol_blessed', name: 'Idol-Blessed', floors: 2,
                       effects: { 'resistance' => 1, 'healing_mult' => 1.2 } }
        },
        decline: { label: 'Stand up', text: 'Resist the urge', lust: 3,
                   scene: 'You tear yourself away from the kneeler. The idol\'s stone smile seems a touch smug.' },
        fight: { label: 'Smash the idol', type: :demon, text: 'The idol cracks open and a demon steps out of the stone!' }
      },
      'wall_of_lips' => {
        name: 'Wall of Lips', tag: 'oral', tracker: 'oral_events',
        blurb: 'plush lips pout from the walls.',
        intro: 'Dozens of full, glossy lips pout from the walls of this corridor, blowing kisses and murmuring compliments. ' \
               'A pair at hip height purses invitingly.',
        accept: {
          label: 'Step closer', text: 'Let the wall have a taste',
          scenes: ['You press your hips to the wall and the lips go to work, kissing and suckling while warm tongues slide out ' \
                   'to lick every inch they can reach.',
                   'More mouths join in along your thighs and stomach, until you are moaning against the stone and shaking ' \
                   'through an orgasm they happily drink down.'],
          parts: {
            'vagina' => 'The lips at your hips seal over your pussy and suck your clit while a tongue curls deep inside you.',
            'penis' => 'They swallow your cock to the root and suck with eager, slurping hunger until you spill down their throat.',
            'anus' => 'Another pair finds your ass and rims you with slow, greedy swirls of its tongue.',
            'breasts' => 'Two more pairs latch onto your nipples and suckle in rhythm.'
          },
          lp: 5, lust: 12,
          condition: { key: 'well_kissed', name: 'Well-Kissed', floors: 2,
                       effects: { 'lust_mult' => 1.1, 'mimic_submit_lp' => 2 } }
        },
        decline: { label: 'Hug the far wall', text: 'Edge past (AGI)', lust: 2, escape: true,
                   scene: 'You flatten against the opposite wall and sidle past while the lips pout and blow you kisses.' },
        fight: { label: 'Fight the wall', type: :mimic, text: 'The wall heaves — the whole corridor is one enormous mimic!' }
      },
      'rivals_bargain' => {
        name: 'Rival\'s Bargain', tag: 'oral', tracker: 'oral_events',
        blurb: 'a rival delver lounges by a campfire.',
        intro: 'A cocky rival delver lounges against her pack beside a campfire, a fat healing potion at her side. ' \
               '"Supplies cost," she drawls, spreading her knees. "And I take payment in kind."',
        accept: {
          label: 'Pay her', text: 'Go down on her',
          scenes: ['You kneel between her thighs and get to work, and she grabs your hair and grinds against your mouth, guiding ' \
                   'your tongue exactly where she wants it.',
                   'She cums with a loud, shameless moan, then makes you keep licking until she cums again, smirking down at ' \
                   'your glistening face.'],
          parts: {
            'penis' => 'Your own cock throbs untouched the whole time, and she laughs when she notices.'
          },
          lp: 6, lust: 10,
          condition: { key: 'rivals_favour', name: 'Rival\'s Favour', floors: 2,
                       effects: { 'healing_mult' => 1.25, 'explore_lp' => 1 } }
        },
        alt: {
          label: 'Make her pay', text: 'She does the kneeling',
          scenes: ['She grins and drops to her knees in front of you instead, kissing her way down your body with a hungry, ' \
                   'competitive glint in her eyes.'],
          parts: {
            'vagina' => 'She eats your pussy like she is trying to win, tongue flicking your clit until you cum on her face.',
            'penis' => 'She swallows your cock to the root and sucks you dry, then wipes her chin and calls it even.'
          },
          lp: 5, lust: 10,
          condition: { key: 'smug_victor', name: 'Smug Victor', floors: 2,
                       effects: { 'strength' => 1, 'victory_lp_bonus' => 2 } }
        },
        decline: { label: 'Decline', text: 'Keep your dignity', lust: 2,
                   scene: 'You shrug and walk on. "Your loss," she calls after you.' }
      },
      'incubus_bedchamber' => {
        name: 'Incubus Bedchamber', tag: 'vaginal', tracker: 'vaginal_events', requires: 'vagina',
        blurb: 'silk sheets and a smouldering gaze.',
        intro: 'A canopy bed of crimson silk fills this chamber, and the incubus lounging across it is beautiful enough to ' \
               'stop your heart. "I have been waiting for you," he purrs, and lets the sheet slip from his thick, heavy cock.',
        accept: {
          label: 'Join him', text: 'Let him have you',
          scenes: ['He lays you back on the silk and slides into your pussy in one slow, devastating stroke, his cock ' \
                   'stretching you perfectly.',
                   'He fucks you deep and unhurried, rolling his hips against your clit until you cum around him again and ' \
                   'again, and he only finishes when your womb is aching for it.'],
          lp: 7, lust: 14,
          condition: { key: 'incubus_kissed', name: 'Incubus-Kissed', floors: 3,
                       effects: { 'demon_lust_mult' => 1.15, 'demon_submit_lp' => 3 } }
        },
        alt: {
          label: 'Ride him', text: 'Take the reins',
          scenes: ['You push him onto his back and sink down onto his cock, riding him at your own pace while he grips your ' \
                   'hips and groans your name.',
                   'You grind your clit against him until you cum hard, your cunt fluttering around him until he follows with ' \
                   'a helpless gasp.'],
          parts: { 'breasts' => 'He reaches up to cup and knead your breasts as they bounce.' },
          lp: 6, lust: 12,
          condition: { key: 'on_top', name: 'On Top', floors: 2,
                       effects: { 'strength' => 1, 'resistance' => 1 } }
        },
        decline: { label: 'Leave', text: 'Walk away from the bed', lust: 4,
                   scene: 'You force yourself out of the room. His soft laughter follows you, promising next time.' },
        fight: { label: 'Banish him', type: :demon, text: 'The incubus rises with a sigh and comes to change your mind.' }
      },
      'moonstone_lover' => {
        name: 'Moonstone Lover', tag: 'vaginal', tracker: 'vaginal_events', requires: 'vagina',
        blurb: 'a statue of a lover kneels in a garden.',
        intro: 'In an overgrown garden kneels a moonstone statue of a lover, arms open, its sculpted cock standing upright ' \
               'and warm to the touch. The moss around its base is soaked with the slick of past visitors.',
        accept: {
          label: 'Climb on', text: 'Ride the statue',
          scenes: ['You straddle its lap and sink down onto the smooth stone cock, gasping as it warms inside your pussy and ' \
                   'the statue\'s arms close gently around your waist.',
                   'It rocks you with patient, tireless strength, the stone shaft swelling to fit you perfectly, until you are ' \
                   'cumming in its arms with your clit grinding against its cool belly.'],
          lp: 6, lust: 12,
          condition: { key: 'moonlit_glow', name: 'Moonlit Glow', floors: 2,
                       effects: { 'healing_mult' => 1.2, 'satisfy_bonus' => 0.05 } }
        },
        decline: { label: 'Admire it', text: 'Just look', lust: 2,
                   scene: 'You admire the craftsmanship, run a hand along its warm thigh, and move on.' },
        fight: { label: 'Clear the garden', type: :plant, text: 'The vines around the statue surge up toward you!' }
      },
      'centaur_grove' => {
        name: 'Centaur Grove', tag: 'vaginal', tracker: 'vaginal_events', requires: 'vagina',
        blurb: 'hoofprints circle a mossy clearing.',
        intro: 'A powerful centaur stallion stamps in the clearing, flanks gleaming with sweat, his enormous cock swinging ' \
               'heavy beneath him. He looks you over and snorts. "You look like you could use a proper mating."',
        accept: {
          label: 'Present yourself', text: 'Bend over the fallen log',
          scenes: ['You bend over a mossy log and he rears above you, the blunt head of his huge cock spreading your pussy ' \
                   'open as he lowers his weight.',
                   'He mounts you with powerful, rocking thrusts, each one bumping deep against your womb, until you are cumming ' \
                   'so hard your legs give out and he holds you up by the hips.'],
          lp: 8, lust: 16,
          condition: { key: 'mare_in_heat', name: 'Mare in Heat', floors: 3,
                       effects: { 'beast_lust_mult' => 1.15, 'beast_submit_lp' => 3, 'agility' => -1 } }
        },
        decline: { label: 'Decline', text: 'Wave him off', lust: 3,
                   scene: 'He tosses his mane in disappointment and gallops off into the trees.' },
        fight: { label: 'Wrestle him', type: :beast, text: 'The stallion tosses his head and charges!' }
      },
      'satyr_bathhouse' => {
        name: 'Satyr Bathhouse', tag: 'anal', tracker: 'anal_events',
        blurb: 'steam curls from a tiled bathhouse.',
        intro: 'Steam rolls from a tiled bathhouse where a grinning satyr lounges in the hot water, a jar of scented oil in ' \
               'hand. "Lie down," he says, patting the warm marble ledge. "Let me loosen you up."',
        accept: {
          label: 'Lie down', text: 'Let him oil you up',
          scenes: ['He works oil into your back and down over your ass, then slides one slick finger into your hole, then two, ' \
                   'until you are pushing back against his hand.',
                   'When he finally slides his cock into your ass you moan into the steam, and he fucks you slow and deep on the ' \
                   'warm marble until you cum shaking beneath him.'],
          parts: {
            'penis' => 'Your cock grinds against the slick marble with every thrust until you spill all over it.',
            'vagina' => 'Your pussy drips onto the marble, empty and jealous while he takes your ass.'
          },
          lp: 7, lust: 14,
          condition: { key: 'loosened_up', name: 'Loosened Up', floors: 2,
                       effects: { 'agility' => 1, 'satisfy_bonus' => 0.1 } }
        },
        alt: {
          label: 'Just the bath', text: 'Soak with him (keep it gentle)',
          scenes: ['You sink into the hot water beside him, and he spends a lazy hour kneading your ass and teasing your hole ' \
                   'with slick fingertips, never quite giving you more.'],
          lp: 4, lust: 10,
          condition: { key: 'steam_soaked', name: 'Steam-Soaked', floors: 2, effects: { 'healing_mult' => 1.3 } }
        },
        decline: { label: 'Pass', text: 'Skip the bath', lust: 2,
                   scene: 'You decline. He shrugs and sinks back into the steam, humming.' }
      },
      'amber_slime' => {
        name: 'Amber Slime', tag: 'anal', tracker: 'anal_events',
        blurb: 'a warm amber slime wobbles hopefully.',
        intro: 'A glossy amber slime wobbles in the corner, warm and smelling faintly of honey. It flows toward you, then ' \
               'stops politely, quivering, as if asking permission to come in the back way.',
        accept: {
          label: 'Let it in', text: 'Bend over for the slime',
          scenes: ['You bend over and the slime flows up your thighs, pooling against your ass before pushing into your hole ' \
                   'in one thick, warm surge.',
                   'It swells and churns inside you, stretching your ass wide and squeezing in slow pulses, until you are cumming ' \
                   'helplessly with your cheek pressed to the floor.'],
          parts: {
            'penis' => 'A tendril of slime coils around your cock and milks it in time with the churning in your ass.',
            'vagina' => 'A slick tendril slides into your pussy too, so you are stuffed in both holes.'
          },
          lp: 6, lust: 14,
          condition: { key: 'honey_filled', name: 'Honey-Filled', floors: 2,
                       effects: { 'slime_lust_mult' => 1.15, 'max_hp_bonus' => 8 } }
        },
        decline: { label: 'Shoo it', text: 'Step around (AGI)', lust: 2, escape: true,
                   scene: 'You dodge around the eager slime and dart through the far door.' },
        fight: { label: 'Pop it', type: :slime, text: 'The slime stops being polite and lunges for you!' }
      },
      'gargoyle_ledge' => {
        name: 'Gargoyle Ledge', tag: 'anal', tracker: 'anal_events',
        blurb: 'a gargoyle crouches on a stone ledge.',
        intro: 'A gargoyle crouches on a parapet overlooking the endless drop of the tower, wings folded, its stone cock thick ' \
               'and ridged. Its eyes open as you pass, and it pats the ledge beside it.',
        accept: {
          label: 'Bend over the ledge', text: 'Let the gargoyle take your ass',
          scenes: ['You lean over the parapet and it grips your hips with heavy stone claws, the cool ridged length pressing ' \
                   'against your ass before sliding in.',
                   'Every ridge drags inside you as it fucks your ass with slow, grinding power, the wind whipping around you ' \
                   'until you cum with your fingers clutching the stone.'],
          parts: {
            'penis' => 'Your cock bobs over the long drop, dripping precum into the void.',
            'vagina' => 'Your empty pussy clenches with every ridge that drags past.'
          },
          lp: 7, lust: 14,
          condition: { key: 'stone_steady', name: 'Stone-Steady', floors: 2,
                       effects: { 'resistance' => 2, 'agility' => -1 } }
        },
        decline: { label: 'Keep walking', text: 'Don\'t look down', lust: 2,
                   scene: 'You keep well away from the edge. The gargoyle closes its eyes, unbothered.' },
        fight: { label: 'Topple it', type: :demon, text: 'The gargoyle spreads its wings and swoops at you!' }
      },
      'wisp_hollow' => {
        name: 'Wisp Hollow', tag: 'breast_play', tracker: 'breast_play_events',
        blurb: 'warm wisps drift and hum over the moss.',
        intro: 'Warm, glowing wisps drift over a bed of moss, humming softly. As you enter they swirl toward you, gathering ' \
               'at your chest like moths to a lantern.',
        accept: {
          label: 'Bare your chest', text: 'Let the wisps play',
          scenes: ['You open your top and the wisps settle on your nipples, buzzing and swirling until they stiffen into ' \
                   'aching points.',
                   'They tease and tug and roll them in endless warm circles, until your chest is flushed and heaving and you ' \
                   'are moaning with every pulse of light.'],
          parts: {
            'breasts' => 'They crowd over your breasts, buzzing across every curve until your tits feel heavy and swollen.',
            'penis' => 'Your cock twitches and leaks with every pulse against your nipples.',
            'vagina' => 'Your pussy throbs in time with every pulse against your nipples.'
          },
          lp: 5, lust: 10,
          condition: { key: 'wisp_lit', name: 'Wisp-Lit', floors: 2,
                       effects: { 'dodge_bonus' => 0.05, 'lust_mult' => 1.1 } }
        },
        decline: { label: 'Wave them off', text: 'Keep covered', lust: 1,
                   scene: 'You wave the wisps away. They scatter, then regroup to sulk over the moss.' }
      },
      'oiling_parlour' => {
        name: 'Oiling Parlour', tag: 'breast_play', tracker: 'breast_play_events',
        blurb: 'a demoness warms oil between her palms.',
        intro: 'A curvy demoness in a silk robe runs a massage parlour in this chamber, warm oil steaming in a copper bowl. ' \
               '"Lie back," she purrs. "I specialise in the front."',
        accept: {
          label: 'Lie back', text: 'Let her work your chest',
          scenes: ['She pours warm oil over your chest and spreads it with slow, firm palms, her thumbs circling your nipples ' \
                   'until they are hard and slick.',
                   'She pinches and rolls them with expert fingers, tugging just enough to make you arch off the table, then ' \
                   'soothing them with feather-light strokes until you are begging.'],
          parts: {
            'breasts' => 'She cups and kneads your oiled breasts, squeezing them together and letting them slip through her fingers.',
            'penis' => 'She leaves your cock throbbing and untouched, smiling at how it leaks every time she pinches.',
            'vagina' => 'You squirm on the table, your pussy aching, while she lavishes all her attention higher up.'
          },
          lp: 6, lust: 12,
          condition: { key: 'glistening_chest', name: 'Glistening Chest', floors: 2,
                       effects: { 'resistance' => 1, 'demon_lust_mult' => 1.1 } }
        },
        alt: {
          label: 'Full treatment', text: 'Ask her to finish you',
          scenes: ['She grins and keeps one hand on your nipples while the other slides lower, working you with oily strokes ' \
                   'until you cum arching under her touch.'],
          lp: 7, lust: 10,
          condition: { key: 'thoroughly_oiled', name: 'Thoroughly Oiled', floors: 2,
                       effects: { 'flee_bonus' => 0.15, 'satisfy_bonus' => 0.05 } }
        },
        decline: { label: 'Not today', text: 'Decline the massage', lust: 2,
                   scene: 'She pouts and wipes her hands on a towel. "The bowl stays warm for you."' }
      },
      'minotaurs_toll' => {
        name: 'Minotaur\'s Toll', tag: 'breast_play', tracker: 'breast_play_events', requires: 'breasts',
        blurb: 'a huge minotaur eyes your chest.',
        intro: 'A towering minotaur blocks the passage, his cock hanging thick and heavy between his thighs. He stares ' \
               'unashamedly at your breasts and rumbles, "Those. Around this. Then you may pass."',
        accept: {
          label: 'Kneel', text: 'Let him fuck your tits',
          scenes: ['You kneel and press your breasts together around his huge shaft, and he groans as he starts thrusting into ' \
                   'your cleavage, his cock slick with precum.',
                   'He fucks your tits harder and faster, your nipples dragging against his thighs, until he spurts hot ropes ' \
                   'across your chest.'],
          parts: {
            'penis' => 'Your own cock throbs against his heavy balls with every thrust.',
            'vagina' => 'Your pussy aches and drips as his heavy balls swing against your stomach.'
          },
          lp: 7, lust: 14,
          condition: { key: 'pearl_necklace', name: 'Pearl Necklace', floors: 2,
                       effects: { 'beast_submit_lp' => 2, 'max_hp_bonus' => 8 } }
        },
        decline: { label: 'Squeeze past', text: 'Try to slip by (AGI)', lust: 3, escape: true,
                   scene: 'You duck under his arm and slip past while he is still staring.' },
        fight: { label: 'Fight him', type: :beast, text: 'The minotaur snorts and lowers his horns.' }
      },
      'hellhound_kennel' => {
        name: 'Hellhound Kennel', tag: 'knotting', tracker: 'knotting_events',
        blurb: 'something big pants in the dark.',
        intro: 'Ember-eyed hellhounds lounge in a warm kennel of smooth black stone, and the biggest rises as you enter, his ' \
               'red cock sliding from its sheath with a fat knot already swelling at the base.',
        accept: {
          label: 'Get on all fours', text: 'Take his knot',
          scenes: ['He mounts you from behind with his heavy paws on your back, hips pounding fast and frantic as his hot cock ' \
                   'spears into you.',
                   'With one last shove his knot pops inside, swelling until you are locked together, and you cum around it as ' \
                   'he pulses into you for what feels like forever.'],
          parts: {
            'vagina' => 'He knots your pussy, the swollen bulb grinding against every sensitive spot inside you.',
            'anus' => 'He knots your ass, stretching it wide around the swollen bulb until you can only pant and push back.',
            'penis' => 'Your cock swings beneath you, spurting onto the kennel floor with every throb of his knot.'
          },
          lp: 8, lust: 16,
          condition: { key: 'hound_marked', name: 'Hound-Marked', floors: 3,
                       effects: { 'beast_lust_mult' => 1.15, 'beast_submit_lp' => 3, 'strength' => 1 } }
        },
        decline: { label: 'Back out slowly', text: 'Leave the kennel (AGI)', lust: 3, escape: true,
                   scene: 'You back out with your eyes down, and the pack lets you go with a disappointed huff.' },
        fight: { label: 'Fight the pack leader', type: :beast, text: 'The hellhound bares glowing fangs and leaps!' }
      },
      'wolfkin_den' => {
        name: 'Wolfkin Den', tag: 'knotting', tracker: 'knotting_events',
        blurb: 'a fur-lined den smells of pine and heat.',
        intro: 'A wolfkin woman with a lean, muscled body and a thick, knotted cock grins at you from a nest of furs. ' \
               '"Pack\'s out hunting," she says. "Keep me company?"',
        accept: {
          label: 'Join her', text: 'Let her knot you',
          scenes: ['She rolls you into the furs and takes you face to face, growling softly against your neck as her thick cock ' \
                   'slides deep.',
                   'Her knot swells as she grinds in, stretching you until it locks with a slick pop, and she holds you close ' \
                   'through every throbbing pulse, nuzzling you while you cum around her.'],
          parts: {
            'vagina' => 'Her knot locks inside your pussy, swollen and snug against your clit.',
            'anus' => 'Her knot locks inside your ass, a hot, stretching fullness you feel all the way to your toes.'
          },
          lp: 7, lust: 14,
          condition: { key: 'pack_scent', name: 'Pack Scent', floors: 3,
                       effects: { 'beast_dodge_bonus' => 0.1, 'agility' => 1 } }
        },
        alt: {
          label: 'Use your mouth', text: 'Take her knot between your lips', needs_tag: 'oral',
          scenes: ['You kneel in the furs and take her cock into your mouth, and she rocks into your throat until her swelling ' \
                   'knot stretches your lips and she floods your tongue.'],
          lp: 6, lust: 12,
          condition: { key: 'wolfs_treat', name: 'Wolf\'s Treat', floors: 2,
                       effects: { 'max_hp_bonus' => 10, 'beast_submit_lp' => 2 } }
        },
        decline: { label: 'Not now', text: 'Leave her to her nap', lust: 2,
                   scene: 'She shrugs and curls back into the furs. "Door\'s always open."' }
      },
      'ritual_of_the_knot' => {
        name: 'Ritual of the Knot', tag: 'knotting', tracker: 'knotting_events',
        blurb: 'a demon waits in a glowing summoning circle.',
        intro: 'A broad, crimson-skinned demon sits cross-legged inside a glowing circle, his cock ridged and crowned with a ' \
               'heavy knot. "Step inside," he rumbles. "The circle only breaks when we are joined."',
        accept: {
          label: 'Step inside', text: 'Let him join with you',
          scenes: ['He pulls you into his lap and lowers you onto his ridged cock, each ridge sliding in until his knot presses ' \
                   'insistently at your entrance.',
                   'He rocks you down until the knot slips in and swells, locking you together, and the circle flares with ' \
                   'light as you cum with him buried to the hilt.'],
          parts: {
            'vagina' => 'His knot swells in your pussy until you feel stretched around every inch of him.',
            'anus' => 'His knot swells in your ass, locking you on his lap while you writhe.',
            'breasts' => 'He kneads your breasts while you wait for the knot to soften.'
          },
          lp: 9, lust: 16,
          condition: { key: 'circle_joined', name: 'Circle-Joined', floors: 3,
                       effects: { 'demon_submit_lp' => 3, 'max_hp_bonus' => 10, 'flee_bonus' => -0.1 } }
        },
        decline: { label: 'Stay outside', text: 'Don\'t cross the line', lust: 3,
                   scene: 'You keep your toes outside the circle. The demon chuckles and waits for the next visitor.' },
        fight: { label: 'Break the circle', type: :demon, text: 'You scuff the circle — and the demon steps free, grinning!' }
      },
      'velvet_collar' => {
        name: 'Velvet Collar', tag: 'choking', tracker: 'breath_play_events',
        blurb: 'a velvet collar rests on a cushion.',
        intro: 'A soft black velvet collar lies on a silk cushion, a tag dangling from its ring: *I tighten only when you ' \
               'want me to.*',
        accept: {
          label: 'Put it on', text: 'Fasten the collar',
          scenes: ['The collar settles around your neck and hugs snugly, and every time your arousal rises it draws a touch ' \
                   'tighter, until each breath comes shallow and sweet.',
                   'Lightheaded and floating, you touch yourself through the haze, and the moment you cum the collar loosens and ' \
                   'lets you gulp down air, giddy and glowing.'],
          parts: {
            'vagina' => 'Your pussy clenches harder with every shallow, fluttering breath.',
            'penis' => 'Your cock throbs in your hand, harder with every snug hug of the collar.'
          },
          lp: 6, lust: 12,
          condition: { key: 'breathless_glow', name: 'Breathless Glow', floors: 2,
                       effects: { 'satisfy_bonus' => 0.1, 'lust_mult' => 1.05 } }
        },
        decline: { label: 'Leave it', text: 'Keep your neck bare', lust: 2,
                   scene: 'You leave the collar on its cushion. Its tag seems to droop.' }
      },
      'succubus_throne' => {
        name: 'Succubus Throne', tag: 'choking', tracker: 'breath_play_events',
        blurb: 'a succubus lounges on a velvet throne.',
        intro: 'A smiling succubus lounges on a velvet throne and crooks a finger at you. "Come sit with me, darling. I like ' \
               'to feel a heartbeat under my hand."',
        accept: {
          label: 'Go to her', text: 'Let her hold your neck',
          scenes: ['She pulls you into her lap and rests her hand around your neck, thumb stroking your pulse while she grinds ' \
                   'against you, pressing just enough to make your head swim.',
                   'Every time you start to float she eases off and kisses you, then presses again, until you cum dizzy and ' \
                   'gasping in her arms and she lets go completely, purring praise.'],
          parts: {
            'penis' => 'She strokes your cock with her free hand in time with your pulse.',
            'vagina' => 'Her free hand works your pussy in slow circles, matching the rhythm of your pulse.'
          },
          lp: 7, lust: 14,
          condition: { key: 'held_close', name: 'Held Close', floors: 2,
                       effects: { 'demon_lust_mult' => 1.1, 'submit_lp_bonus' => 2 } }
        },
        alt: {
          label: 'Hold her', text: 'You take the throne',
          scenes: ['You sit on the throne and she settles in your lap, guiding your hand to her neck with a delighted shiver, ' \
                   'and you hold her lightly while she rides you to a gasping, shuddering finish.'],
          lp: 6, lust: 12,
          condition: { key: 'gentle_grip', name: 'Gentle Grip', floors: 2,
                       effects: { 'strength' => 1, 'victory_lp_bonus' => 2 } }
        },
        decline: { label: 'Decline', text: 'Bow and leave', lust: 2,
                   scene: 'You bow and back away. She blows you a kiss.' }
      },
      'lamias_embrace' => {
        name: 'Lamia\'s Embrace', tag: 'choking', tracker: 'breath_play_events',
        blurb: 'scales glint around a sun-warmed rock.',
        intro: 'A lamia basks on a warm rock, her long, gleaming tail coiled in lazy loops. "You look tense," she hisses ' \
               'fondly. "Let me hug it out of you."',
        accept: {
          label: 'Let her coil', text: 'Sink into her coils',
          scenes: ['Her tail winds around you in warm, smooth loops, hugging your chest until every breath comes short and ' \
                   'shallow, while the tip of her tail strokes between your legs.',
                   'She squeezes gently as you build, lets go as you gasp, and squeezes again, until you cum lightheaded and ' \
                   'boneless in her coils and she loosens to cradle you.'],
          parts: {
            'vagina' => 'The tip of her tail slips between your folds and strokes your clit in slow, coiling circles.',
            'penis' => 'The tip of her tail wraps around your cock and pumps it in time with her squeezes.'
          },
          lp: 6, lust: 12,
          condition: { key: 'coiled_calm', name: 'Coiled Calm', floors: 2,
                       effects: { 'resistance' => 1, 'healing_mult' => 1.2 } }
        },
        decline: { label: 'Pass', text: 'Thank her and move on', lust: 2,
                   scene: 'She sighs and settles back into the sun.' },
        fight: { label: 'Fight her', type: :beast, text: 'The lamia rears up, hissing, offended by the refusal!' }
      },
      'tentacle_bath' => {
        name: 'Tentacle Bath', tag: 'tentacles', tracker: 'tentacle_events',
        blurb: 'a warm pool churns with soft shapes.',
        intro: 'A steaming pool fills this grotto, its surface rippling as soft, slick tentacles curl up from below to wave ' \
               'at you.',
        accept: {
          label: 'Slip in', text: 'Bathe with the tentacles',
          scenes: ['You slide into the warm water and the tentacles gather around you, stroking your thighs, curling around ' \
                   'your waist and lifting you to float on your back.',
                   'They slip inside you one after another, thick and slick and pulsing, rocking you gently in the water until ' \
                   'you cum again and again in their embrace.'],
          parts: {
            'vagina' => 'One thick tentacle fills your pussy and ripples, while a thinner one curls around your clit.',
            'penis' => 'A tentacle hollows itself into a sleeve and milks your cock with warm, rippling pulses.',
            'anus' => 'Another works its way into your ass, swelling until you are deliciously full.',
            'breasts' => 'Fine tendrils curl around your nipples and tug them in time.'
          },
          lp: 7, lust: 14,
          condition: { key: 'pool_softened', name: 'Pool-Softened', floors: 2,
                       effects: { 'healing_mult' => 1.3, 'agility' => -1 } }
        },
        alt: {
          label: 'Dip your toes', text: 'Just sit on the edge',
          scenes: ['You sit on the edge and let a few curious tentacles curl around your ankles and up your calves, teasing ' \
                   'your inner thighs with slick, lazy strokes.'],
          lp: 4, lust: 8,
          condition: { key: 'tentacle_teased', name: 'Tentacle-Teased', floors: 1, effects: { 'lust_mult' => 1.1 } }
        },
        decline: { label: 'Stay dry', text: 'Leave the grotto', lust: 2,
                   scene: 'You back out of the grotto. The tentacles wave goodbye, a touch sadly.' }
      },
      'ceiling_creeper' => {
        name: 'Ceiling Creeper', tag: 'tentacles', tracker: 'tentacle_events',
        blurb: 'something sweet drips from the ceiling.',
        intro: 'Thick green tentacles hang from the ceiling like vines, beaded with sweet nectar that drips onto the floor. ' \
               'They sway toward you as you step beneath them.',
        accept: {
          label: 'Stand still', text: 'Let them lift you up',
          scenes: ['The tentacles coil around your arms and thighs and hoist you off the floor, spreading you wide in mid-air ' \
                   'as their slick tips explore every inch of you.',
                   'Then they push in, all at once, and thrust in a slow, wet rhythm while you hang moaning in their grip.'],
          parts: {
            'vagina' => 'One plunges into your pussy and swells, nectar slicking its way deeper with every thrust.',
            'anus' => 'One works its way into your ass and ripples until you squirm.',
            'penis' => 'A sticky tentacle coils around your cock and squeezes until you spurt onto the floor below.',
            'breasts' => 'Two thin tendrils circle your nipples and tug them taut.'
          },
          lp: 7, lust: 14,
          condition: { key: 'nectar_sticky', name: 'Nectar-Sticky', floors: 2,
                       effects: { 'plant_lust_mult' => 1.15, 'plant_submit_lp' => 3 } }
        },
        decline: { label: 'Duck under', text: 'Dash through (AGI)', lust: 3, escape: true,
                   scene: 'You duck low and sprint beneath the swaying tentacles.' },
        fight: { label: 'Hack at them', type: :plant, text: 'The tentacles thrash and lash toward you!' }
      },
      'honeyed_orchard' => {
        name: 'Honeyed Orchard', tag: 'aphrodisiacs', tracker: 'aphrodisiac_events',
        blurb: 'heavy pink fruit hangs from twisted trees.',
        intro: 'An impossible orchard grows under a glowing ceiling, its trees heavy with plump pink fruit. A carved sign ' \
               'reads: *Potent aphrodisiac. One bite.*',
        accept: {
          label: 'Take a bite', text: 'Eat the fruit',
          scenes: ['The fruit bursts sweet and sticky, and the aphrodisiac hits a heartbeat later, heat rushing between your ' \
                   'legs until every brush of fabric makes you gasp.',
                   'You end up sprawled under the trees, rubbing yourself frantically through orgasm after orgasm, juice ' \
                   'smeared all over your chin.'],
          parts: {
            'vagina' => 'Your pussy swells and drips, your clit so sensitive that the lightest touch makes you cum.',
            'penis' => 'Your cock stays rock hard and leaks constantly, twitching at the faintest breeze.'
          },
          lp: 6, lust: 16,
          condition: { key: 'fruit_flushed', name: 'Fruit-Flushed', floors: 2,
                       effects: { 'lust_mult' => 1.2, 'max_hp_bonus' => 5 } }
        },
        alt: {
          label: 'Pocket some', text: 'Save a fruit for later',
          scenes: ['You pocket a fruit and nibble just a sliver, and the aphrodisiac settles into a low, simmering warmth that ' \
                   'keeps your skin humming as you walk.'],
          lp: 4, lust: 8,
          condition: { key: 'simmering_warmth', name: 'Simmering Warmth', floors: 3,
                       effects: { 'strength' => 1, 'lust_mult' => 1.05 } }
        },
        decline: { label: 'Leave it', text: 'Ignore the fruit', lust: 2,
                   scene: 'You walk through the orchard without touching a thing. The scent follows you for a while.' }
      },
      'incense_salon' => {
        name: 'Incense Salon', tag: 'aphrodisiacs', tracker: 'aphrodisiac_events',
        blurb: 'pink smoke curls from ornate censers.',
        intro: 'Plush cushions fill a dim salon where ornate censers puff thick pink smoke. A sleepy-eyed succubus waves you ' \
               'in. "Breathe deep, sweetness. It is only a mild aphrodisiac."',
        accept: {
          label: 'Breathe deep', text: 'Lounge in the smoke',
          scenes: ['You sink into the cushions and breathe deep, and the aphrodisiac smoke turns your whole body warm, heavy ' \
                   'and achingly sensitive.',
                   'Soon you are writhing on the cushions, hands everywhere, and the succubus looks on lazily from her divan, ' \
                   'offering a helping hand whenever you start to slow down.'],
          parts: {
            'vagina' => 'You finger your pussy in a slow daze, cumming every time you press your clit.',
            'penis' => 'You stroke your cock in a slow daze, cumming again before you have even softened.'
          },
          lp: 6, lust: 14,
          condition: { key: 'smoke_dazed', name: 'Smoke-Dazed', floors: 2,
                       effects: { 'demon_lust_mult' => 1.15, 'agility' => -1, 'satisfy_bonus' => 0.05 } }
        },
        decline: { label: 'Hold your breath', text: 'Hurry through (AGI)', lust: 3, escape: true,
                   scene: 'You hold your breath and hurry through before the smoke can take hold.' },
        fight: { label: 'Douse the censers', type: :demon, text: 'The succubus rises from her divan, thoroughly annoyed.' }
      },
      'phantom_waltz' => {
        name: 'Phantom Waltz', tag: 'possession', tracker: 'possession_events',
        blurb: 'ghostly music drifts from a ballroom.',
        intro: 'In a ruined ballroom, a translucent ghost in an old-fashioned gown sways alone to music only she can hear. ' \
               'She turns to you with hungry eyes. "It has been so long since I felt anything. May I borrow you?"',
        accept: {
          label: 'Let her in', text: 'Let the ghost possess you',
          scenes: ['She steps into you like stepping into a warm bath, and suddenly your hands are not your own as she ' \
                   'possesses every inch of you, exploring your body with centuries of pent-up longing.',
                   'She dances you across the ballroom, touching you everywhere, and drives your body through one long, rolling ' \
                   'orgasm after another until she sighs out of you, sated.'],
          parts: {
            'vagina' => 'She slides your fingers into your pussy with a delighted gasp, marvelling at how wet you are.',
            'penis' => 'She wraps your hand around your cock and strokes it with wonder, savouring every throb.',
            'breasts' => 'She cups and squeezes your breasts with your own hands, sighing at the softness.'
          },
          lp: 6, lust: 12,
          condition: { key: 'ghost_warmed', name: 'Ghost-Warmed', floors: 2,
                       effects: { 'undead_lust_mult' => 0.85, 'undead_dodge_bonus' => 0.1 } }
        },
        decline: { label: 'Decline', text: 'Keep your body to yourself', lust: 2,
                   scene: 'You shake your head. She fades with a wistful sigh.' },
        fight: { label: 'Exorcise her', type: :undead, text: 'The ghost shrieks and swoops at you!' }
      },
      'ring_of_the_rider' => {
        name: 'Ring of the Rider', tag: 'possession', tracker: 'possession_events',
        blurb: 'a ruby ring glints on a stone hand.',
        intro: 'A heavy ruby ring rests on the outstretched hand of a statue. A voice purrs from the gem: "Wear me, and I ' \
               'will show you what your body can really do."',
        accept: {
          label: 'Put it on', text: 'Let the demon ride your body',
          scenes: ['The ring slides on and the demon inside takes control, a delicious warmth pouring up your arm as it ' \
                   'possesses you and moves your body like a dancer.',
                   'It strips you right there and ruts you against the statue, pleasuring you with your own hands until you ' \
                   'collapse, sated, and it hands control back with a satisfied chuckle.'],
          parts: {
            'vagina' => 'It grinds your pussy against the statue\'s thigh until you squirt down the stone.',
            'penis' => 'It ruts your cock against the cool stone until you spurt all over it.'
          },
          lp: 7, lust: 14,
          condition: { key: 'demon_ridden', name: 'Demon-Ridden', floors: 2,
                       effects: { 'strength' => 1, 'submission' => 1, 'demon_submit_lp' => 2 } }
        },
        alt: {
          label: 'Bargain', text: 'Share control instead',
          scenes: ['You set terms, and the demon agrees to share: your hands, its appetite, possessing you just enough that ' \
                   'every touch feels doubled.'],
          lp: 5, lust: 10,
          condition: { key: 'shared_reins', name: 'Shared Reins', floors: 3,
                       effects: { 'strength' => 1, 'victory_lp_bonus' => 2 } }
        },
        decline: { label: 'Leave it', text: 'Leave the ring', lust: 2,
                   scene: 'You leave the ring where it lies. The gem dims, sulking.' }
      },
      'humming_cache' => {
        name: 'Humming Cache', tag: 'toys', tracker: 'toy_events',
        blurb: 'a chest buzzes softly in the corner.',
        intro: 'An open chest overflows with enchanted toys: glass dildos, beaded wands and smooth eggs that hum against each ' \
               'other with a soft, inviting buzz.',
        accept: {
          label: 'Try them out', text: 'Play with the toys',
          scenes: ['You pick out a thick glass dildo and a humming wand, and the enchanted toys practically guide themselves, ' \
                   'sliding and vibrating exactly where you need them.',
                   'You lose track of time on the floor beside the chest, swapping one toy for another until you are wrung out ' \
                   'and trembling.'],
          parts: {
            'vagina' => 'The glass dildo slides deep into your pussy while the wand buzzes against your clit.',
            'penis' => 'A vibrating sleeve slips over your cock and hums you to a shuddering orgasm.',
            'anus' => 'A string of humming beads slips into your ass, one by one.',
            'breasts' => 'Two humming eggs settle on your nipples and buzz until they ache.'
          },
          lp: 6, lust: 12,
          condition: { key: 'buzzing_afterglow', name: 'Buzzing Afterglow', floors: 2,
                       effects: { 'lust_mult' => 1.1, 'treasure_lp' => 2 } }
        },
        alt: {
          label: 'Pocket one', text: 'Take a toy with you',
          scenes: ['You slip a humming egg into your clothes and carry it with you, its gentle vibration a constant, ' \
                   'distracting companion.'],
          lp: 4, lust: 8,
          condition: { key: 'pocket_buzz', name: 'Pocket Buzz', floors: 3,
                       effects: { 'explore_lp' => 2, 'lust_mult' => 1.05 } }
        },
        decline: { label: 'Close the lid', text: 'Leave the toys', lust: 2,
                   scene: 'You close the lid. The buzzing goes muffled and sad.' },
        fight: { label: 'Kick the chest', type: :mimic, text: 'The chest yawns wide, toys and all — it was a mimic!' }
      },
      'goblin_workshop' => {
        name: 'Goblin Workshop', tag: 'toys', tracker: 'toy_events',
        blurb: 'gears clatter in a cluttered workshop.',
        intro: 'A goblin artificer in goggles waves you into her cluttered workshop, where a padded bench sits under a ' \
               'jointed arm tipped with a gleaming dildo. "Need a tester! Pays in loot!"',
        accept: {
          label: 'Volunteer', text: 'Test the fucking machine',
          scenes: ['You climb onto the bench and the arm whirs to life, sliding its slick dildo into you with smooth, ' \
                   'mechanical strokes that speed up as she twists her dials.',
                   'She takes notes while you moan and squirm, cranking the vibration higher every few minutes until you cum ' \
                   'hard enough to rattle the bench.'],
          parts: {
            'vagina' => 'The dildo pistons into your pussy while a vibrating nub hums against your clit.',
            'anus' => 'She swaps in a tapered attachment and lets it fuck your ass on its slowest, deepest setting.',
            'penis' => 'A vibrating sleeve closes over your cock and milks you in time with the strokes.'
          },
          lp: 7, lust: 14,
          condition: { key: 'calibrated', name: 'Calibrated', floors: 2,
                       effects: { 'satisfy_bonus' => 0.1, 'treasure_lp' => 2 } }
        },
        decline: { label: 'Decline', text: 'Not a test subject', lust: 2,
                   scene: 'She shrugs and goes back to tinkering. "Your loss!"' }
      },
      'orc_victory_rite' => {
        name: 'Orc Victory Rite', tag: 'cum_play', tracker: 'cum_play_events',
        blurb: 'drums thump from an orc camp.',
        intro: 'A band of muscular orcs celebrates a victory around a roaring campfire, and their chieftain beckons you into ' \
               'the circle. "Every victory needs a prize to mark."',
        accept: {
          label: 'Be the prize', text: 'Let them mark you',
          scenes: ['You kneel in the firelight as the orcs stroke their thick cocks around you, and one by one they groan and ' \
                   'spurt across your skin until you are plastered in cum, hot and dripping from your chin.',
                   'They cheer as you rub it in, and the chieftain fills you with seed last of all, leaving it leaking down ' \
                   'your thighs while his warriors roar.'],
          parts: {
            'vagina' => 'The chieftain empties himself in your pussy, and cum oozes out of you when you stand.',
            'anus' => 'Another orc takes your ass and leaves you dripping with seed.'
          },
          lp: 8, lust: 14,
          condition: { key: 'orc_marked', name: 'Orc-Marked', floors: 2,
                       effects: { 'strength' => 1, 'victory_lp_bonus' => 2, 'submit_lp_bonus' => 1 } }
        },
        alt: {
          label: 'Swallow', text: 'Drink every load', needs_tag: 'oral',
          scenes: ['You kneel and take them in your mouth one after another, swallowing load after load until your belly is ' \
                   'warm and full and the camp roars its approval.'],
          lp: 7, lust: 12,
          condition: { key: 'orc_fed', name: 'Orc-Fed', floors: 2, effects: { 'max_hp_bonus' => 12, 'submission' => 1 } }
        },
        decline: { label: 'Slip away', text: 'Leave the celebration', lust: 3,
                   scene: 'You slip back into the dark before the chieftain notices. The drums fade behind you.' }
      },
      'cream_slime' => {
        name: 'Cream Slime', tag: 'cum_play', tracker: 'cum_play_events',
        blurb: 'a pearly slime gurgles in a basin.',
        intro: 'A thick, pearly-white slime fills a stone basin, warm and salty-smelling, and it quivers with excitement ' \
               'when it sees you.',
        accept: {
          label: 'Climb in', text: 'Wallow in it',
          scenes: ['You slide into the basin and the slime rolls over you, warm cum given shape, until you are coated in cum ' \
                   'from head to toe.',
                   'It squirts into you in thick, pulsing gushes, filling you with cum until it spills back out, and the slime ' \
                   'greedily soaks it up to do it all again.'],
          parts: {
            'vagina' => 'It floods your pussy until cum drips from you in heavy strings.',
            'anus' => 'It pumps your ass full until cum leaks out in warm trickles.',
            'penis' => 'It milks your cock and swirls your own load into itself.'
          },
          lp: 7, lust: 14,
          condition: { key: 'cream_coated', name: 'Cream-Coated', floors: 2,
                       effects: { 'slime_submit_lp' => 3, 'slime_lust_mult' => 1.1 } }
        },
        decline: { label: 'Step back', text: 'Avoid the basin', lust: 2,
                   scene: 'You keep your distance. The slime burbles sadly and settles.' },
        fight: { label: 'Fight it', type: :slime, text: 'The slime surges out of its basin toward you!' }
      },
      'silkweavers_web' => {
        name: 'Silkweaver\'s Web', tag: 'bondage', tracker: 'bondage_events',
        blurb: 'shimmering silk strands crisscross the room.',
        intro: 'Glittering webs fill this chamber, and a spider-woman with eight graceful legs and a sultry smile descends ' \
               'from above. "Such a lovely thing to wrap up," she murmurs.',
        accept: {
          label: 'Let her wrap you', text: 'Be bound in silk',
          scenes: ['She spins you slowly, wrapping your arms and legs in soft, shimmering silk until you are bound fast and ' \
                   'suspended in her web, spread open and helpless.',
                   'Then she takes her time with you, tracing every exposed inch with silk-soft fingers, teasing you until you ' \
                   'cum shuddering in your bindings, tied tight and utterly hers.'],
          parts: {
            'vagina' => 'She strokes your pussy through a gap in the silk until you are dripping onto the web.',
            'penis' => 'She leaves your cock jutting free of the silk and strokes it with maddening slowness.',
            'anus' => 'She slides a silk-wrapped finger into your ass and crooks it until you whimper.',
            'breasts' => 'She leaves your nipples bare and rolls them between her fingers.'
          },
          lp: 7, lust: 14,
          condition: { key: 'silk_wrapped', name: 'Silk-Wrapped', floors: 2,
                       effects: { 'resistance' => 2, 'agility' => -2 } }
        },
        alt: {
          label: 'Wrap her', text: 'Turn the silk on her',
          scenes: ['You catch a strand and wrap her up instead, binding her legs with her own silk while she laughs and ' \
                   'squirms, and you tease her until she begs.'],
          lp: 5, lust: 10,
          condition: { key: 'web_weaver', name: 'Web-Weaver', floors: 2,
                       effects: { 'beast_dodge_bonus' => 0.1, 'strength' => 1 } }
        },
        decline: { label: 'Back out', text: 'Slip out (AGI)', lust: 3, escape: true,
                   scene: 'You slip between the strands and out of the chamber before she can drop.' },
        fight: { label: 'Fight her', type: :beast, text: 'The silkweaver drops toward you, legs spread wide!' }
      }
    }.freeze
  end
end
