# frozen_string_literal: true

module Engine
  module EventPacks
    FETISH = {
      'golem_of_hands' => {
        name: 'Golem of Hands', tag: 'overstimulation', tracker: 'overstim_events',
        blurb: 'a stone giant sits with dozens of open palms.',
        intro: 'A seated golem fills the alcove, its body sprouting dozens of warm, smooth stone hands that flex slowly in ' \
               'the lamplight. Runes on its chest glow a soft pink: *MORE*.',
        accept: {
          label: 'Sit with it', text: 'Two orgasms back to back (big defiance cost)',
          scenes: ['Dozens of warm hands close over you at once, stroking your thighs, kneading your hips, tracing every curve ' \
                   'with heavy, patient weight. There is nowhere on your body they do not find.',
                   'Your first orgasm crashes through you, and the hands simply keep going, coaxing the second out of your ' \
                   'shaking body while you moan for more.'],
          parts: {
            'vagina' => 'Two stone fingers curl deep inside your pussy while a thumb circles your clit without ever slowing down.',
            'penis' => 'A warm stone fist pumps your cock in long, steady strokes, milking you dry and then starting again.',
            'breasts' => 'Hands cup and squeeze your breasts, rolling your nipples between smooth stone fingertips.',
            'anus' => 'One slick stone finger presses into your ass and rocks in time with everything else.'
          },
          lp: 10, lust: 0, special: :overstimulate,
          condition: { key: 'hand_dazed', name: 'Hand-Dazed', floors: 2, effects: { 'agility' => -1, 'satisfy_bonus' => 0.1 } }
        },
        alt: {
          label: 'Just a massage', text: 'Let the hands knead you, nothing more',
          scenes: ['You ask for gentleness, and the golem obliges, warm palms working the knots from your shoulders and back ' \
                   'until you are limp, flushed, and thinking about asking for more after all.'],
          lp: 4, lust: 10,
          condition: { key: 'stone_soothed', name: 'Stone-Soothed', floors: 2, effects: { 'healing_mult' => 1.2 } }
        },
        decline: { label: 'Keep walking', text: 'Leave the hands empty', lust: 3,
                   scene: 'You step past. The golem\'s hands curl closed, one by one, waiting for someone else.' }
      },
      'succubus_encore' => {
        name: 'Succubus Encore', tag: 'overstimulation', tracker: 'overstim_events',
        blurb: 'a succubus lounges on a heart-shaped bed.',
        intro: 'A succubus sprawls across a velvet bed, tail curling lazily. "Everyone stops after one," she purrs. "So boring. ' \
               'Stay with me and I\'ll show you what *again* means."',
        accept: {
          label: 'Join her', text: 'Two orgasms back to back (big defiance cost)',
          scenes: ['She pulls you down onto the velvet and works you with expert hands and wicked kisses until you come apart ' \
                   'beneath her.',
                   'Then she laughs, low and delighted, and does not stop. "Again," she whispers, and your oversensitive body ' \
                   'obeys, shaking through a second orgasm that leaves you gasping her name.'],
          parts: {
            'vagina' => 'She rides your thigh and fingers your pussy at the same time, her tail flicking against your swollen clit.',
            'penis' => 'She sinks down onto your cock and keeps riding long after you spill inside her, grinding you into the next.',
            'breasts' => 'She sucks your nipples one after the other until they are tender, glistening and stiff.'
          },
          lp: 10, lust: 0, special: :overstimulate,
          condition: { key: 'encore_shivers', name: 'Encore Shivers', floors: 2,
                       effects: { 'lust_mult' => 1.15, 'demon_submit_lp' => 3 } }
        },
        decline: { label: 'Decline', text: 'One is plenty, thanks', lust: 4,
                   scene: 'You shake your head. She pouts, then blows you a kiss that tingles all the way down your spine.' },
        fight: { label: 'Fight her', type: :demon, text: 'The succubus rises from the bed, eyes glowing. "Fine. We\'ll play rough."' }
      },
      'feather_vines' => {
        name: 'Feather Vines', tag: 'tickling', tracker: 'tickling_events',
        blurb: 'fern-like fronds sway without any wind.',
        intro: 'The corridor is overgrown with soft, feathery fronds that turn toward you as you pass, rustling eagerly. ' \
               'They shiver like they are holding back giggles of their own.',
        accept: {
          label: 'Walk into them', text: 'Let the fronds tickle you',
          scenes: ['The vines coil around your wrists and ankles and lift you gently off the ground, and then every frond goes ' \
                   'to work at once: soles, ribs, the backs of your knees. You laugh until you cannot breathe straight.',
                   'Slowly the fronds drift inward, brushing your inner thighs in feather-light strokes, and your laughter ' \
                   'turns breathy and needy.'],
          parts: {
            'vagina' => 'A frond flutters back and forth over your clit, and you giggle and drip helplessly onto the moss.',
            'penis' => 'Feathery tips tease the head of your cock until it throbs and leaks with every helpless laugh.',
            'breasts' => 'Fronds swirl around your nipples in tiny circles until they ache and you are squealing.'
          },
          lp: 5, lust: 12,
          condition: { key: 'giggle_fits', name: 'Giggle Fits', floors: 2,
                       effects: { 'agility' => -1, 'plant_lust_mult' => 1.1, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Sprint through', text: 'Dash past the fronds', lust: 2, escape: true,
                   scene: 'You sprint through the fronds, swatting them aside, and burst out the far end only slightly giggly.' }
      },
      'bristle_slime_spa' => {
        name: 'Bristle Slime Spa', tag: 'tickling', tracker: 'tickling_events',
        blurb: 'a warm pink slime burbles in a tiled tub.',
        intro: 'A sign over a tiled tub reads *FULL BODY TREATMENT*. The pink slime inside is covered in tiny, soft bristles ' \
               'that wiggle in anticipation.',
        accept: {
          label: 'Full treatment', text: 'Sink into the bristles',
          scenes: ['You slide in and the slime engulfs you to the neck, a thousand soft bristles wriggling against every inch ' \
                   'of you at once. You thrash and shriek with laughter, utterly helpless in its warm grip.',
                   'It learns quickly where you are most ticklish and lingers there, until you are giggling and moaning in the ' \
                   'same breath.'],
          parts: {
            'vagina' => 'Bristles squirm between your folds and over your clit, teasing until you clench on nothing.',
            'penis' => 'The slime wraps your cock in wriggling bristles that tickle and stroke at once, and you leak into the tub.',
            'anus' => 'A bristly tendril of slime wiggles against your ass, and you squeal and buck in the tub.'
          },
          lp: 6, lust: 12,
          condition: { key: 'ticklish_glow', name: 'Ticklish Glow', floors: 2,
                       effects: { 'submission' => 1, 'slime_submit_lp' => 3 } }
        },
        alt: {
          label: 'Feet only', text: 'Just a foot treatment',
          scenes: ['You sit on the edge and dip your feet in. The bristles scrub and tickle your soles until you are kicking, ' \
                   'giggling and pink in the face, and somehow your toes have never felt better.'],
          lp: 4, lust: 8,
          condition: { key: 'giddy_soles', name: 'Giddy Soles', floors: 2, effects: { 'agility' => 1, 'satisfy_bonus' => 0.05 } }
        },
        decline: { label: 'Skip it', text: 'Stay dry and composed', lust: 2,
                   scene: 'You keep walking. The slime burbles something that sounds a lot like a giggle.' }
      },
      'pageant_hall' => {
        name: 'Pageant Hall', tag: 'sissification', tracker: 'sissy_events',
        blurb: 'a runway lined with velvet seats.',
        intro: 'A glittering runway stretches between rows of velvet seats. At the end, a horned judge taps a jewelled crown ' \
               'against her palm. "Every contestant gets a dress," she says. "Only the prettiest gets the crown."',
        accept: {
          label: 'Compete', text: 'Gown, heels, and a sash',
          scenes: ['Ribbons zip you into a pink satin gown with a skirt that flares when you turn, and your feet are buckled ' \
                   'into tall glittering heels. A sash settles across your chest: *PRETTIEST PET*.',
                   'You strut the runway, blow kisses, and curtsy low for the judge. She crowns you, then lifts your skirt to ' \
                   'see how much you enjoyed winning.'],
          parts: {
            'penis' => 'Under the gown your cock strains against frilly satin panties, and the judge strokes it through the lace.',
            'vagina' => 'Your panties are soaked through, and the judge slips two fingers past the lace to stroke your pussy.',
            'breasts' => 'The bodice pushes your breasts up into a plump, gleaming display that bounces with every step.'
          },
          lp: 6, lust: 10,
          condition: { key: 'pageant_princess', name: 'Pageant Princess', floors: 3,
                       effects: { 'submission' => 1, 'satisfy_bonus' => 0.1, 'strength' => -1 } }
        },
        alt: {
          label: 'Heels only', text: 'Just learn to walk in heels',
          scenes: ['The judge fits you with a pair of tall heels and makes you walk the runway until your hips sway on their own. ' \
                   'By the end you are strutting, and you rather like the click of them.'],
          lp: 4, lust: 6,
          condition: { key: 'heel_trained', name: 'Heel-Trained', floors: 3, effects: { 'agility' => 1, 'dodge_bonus' => 0.05 } }
        },
        decline: { label: 'Withdraw', text: 'No crown for you', lust: 2,
                   scene: 'You withdraw from the pageant. The judge sighs and sets the crown back on its cushion.' }
      },
      'wardrobe_mimic' => {
        name: 'Wardrobe Mimic', tag: 'sissification', tracker: 'sissy_events',
        blurb: 'a wardrobe stands open, overflowing with lace.',
        intro: 'An ornate wardrobe stands in the corner, doors ajar, spilling ribbons, stockings and lace. A sweet voice ' \
               'echoes from inside: "Step in, darling. I have *just* the thing for you."',
        accept: {
          label: 'Step inside', text: 'Let it dress you',
          scenes: ['The doors close and soft hands strip you in the dark, then dress you again piece by piece: garter belt, ' \
                   'sheer stockings, a frilled babydoll, a velvet collar with a tiny bell.',
                   'It holds you there a while, teasing you through the lace and whispering how pretty and soft you are, until ' \
                   'you believe every word.'],
          parts: {
            'penis' => 'It tucks your cock into a pair of pink lace panties and rubs it through the fabric until you whimper.',
            'vagina' => 'Silky fingers rub your pussy through the lace until the panties cling to you, soaked.',
            'breasts' => 'A frilled bra cups your breasts, and something inside the wardrobe tugs gently at your nipples through it.'
          },
          lp: 7, lust: 12,
          condition: { key: 'frilled', name: 'Frilled', floors: 3,
                       effects: { 'submission' => 1, 'mimic_submit_lp' => 3, 'resistance' => -1 } }
        },
        decline: { label: 'Shut the doors', text: 'Keep your own clothes', lust: 2,
                   scene: 'You push the doors shut. Something inside sighs and rattles the hangers sulkily.' },
        fight: { label: 'Kick it', type: :mimic, text: 'The wardrobe snaps its doors at you like jaws and lunges!' }
      },
      'sin_altar' => {
        name: 'Altar of Sin', tag: 'corruption', tracker: 'corruption_events',
        blurb: 'a velvet altar glows under red candles.',
        intro: 'A demon priestess waits behind a velvet altar, a vial of glistening dark oil in her hand. "Kneel," she says ' \
               'softly. "Let me anoint you, and you\'ll never want to be clean again."',
        accept: {
          label: 'Kneel', text: 'Be anointed (+3 Corruption)',
          scenes: ['She traces the dark oil across your forehead, down your neck and over your heart, and everywhere it ' \
                   'touches sinks into you as delicious, wicked heat.',
                   'Filthy wants unfurl inside you, and when she asks what you desire, you tell her in words you have never ' \
                   'said aloud.'],
          parts: {
            'vagina' => 'She draws a last line of oil down to your pussy, and your clit pulses as the taint seeps in.',
            'penis' => 'She strokes the oil along your cock, and it throbs as the corruption sinks into you.'
          },
          lp: 8, lust: 15, special: :corrupt
        },
        alt: {
          label: 'Refuse the oil', text: 'Cleanse some taint (-3 Corruption, -10 defiance)',
          scenes: ['You seize the vial and pour it out onto the stone, then kneel and pray in your own words until the whispers ' \
                   'inside you quiet. It leaves you hollow, trembling, and lighter.'],
          lust: 5, defiance: -10, special: :purify
        },
        decline: { label: 'Leave', text: 'Walk away from the altar', lust: 3,
                   scene: 'You turn your back on the altar. The priestess smiles. "You\'ll be back."' }
      },
      'black_orchid' => {
        name: 'Black Orchid', tag: 'corruption', tracker: 'corruption_events',
        blurb: 'a huge black flower breathes slow clouds of pollen.',
        intro: 'A black orchid the size of a doorway blooms in a crack in the floor, its petals glossy as oil. Every slow breath ' \
               'it takes releases a shimmer of violet pollen that smells like sin.',
        accept: {
          label: 'Breathe it in', text: 'Let the pollen in (+3 Corruption)',
          scenes: ['You lean into the bloom and inhale deeply. The pollen fizzes through you like dark wine, and your thoughts ' \
                   'slide sideways into soft, sticky filth.',
                   'You find yourself stroking the velvet petals, then stroking yourself, giving in a little more with every breath.'],
          parts: {
            'vagina' => 'Your pussy swells and drips, aching to be filled by anything at all.',
            'penis' => 'Your cock goes achingly hard, leaking a steady string as the pollen works on you.'
          },
          lp: 8, lust: 16, special: :corrupt,
          condition: { key: 'tainted_bloom', name: 'Tainted Bloom', floors: 3,
                       effects: { 'plant_lust_mult' => 1.1, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Hold your breath', text: 'Hurry past', lust: 4,
                   scene: 'You hold your breath and hurry past. A few motes of pollen cling to your skin, tingling.' },
        fight: { label: 'Uproot it', type: :plant, text: 'The orchid\'s roots tear free of the floor and lash at you!' }
      },
      'glowing_quill' => {
        name: 'Glowing Quill', tag: 'body_writing', tracker: 'body_writing_events',
        blurb: 'a succubus twirls a quill that glows pink.',
        intro: 'A succubus calligrapher sits at a desk of bone-white wood, twirling a quill whose tip glows hot pink. "My ink ' \
               'shines brighter the hornier you get," she says. "Shall we find out how bright you are?"',
        accept: {
          label: 'Bare your skin', text: 'Be written on in glowing ink',
          scenes: ['She writes slowly, with long elegant strokes, and the ink tingles where it touches. As you grow flushed the ' \
                   'letters begin to glow, announcing exactly how aroused you are to anyone who looks.',
                   'She steps back to admire her work, and every word pulses a little brighter when you read it.'],
          parts: {
            'breasts' => 'She writes a filthy compliment across each of your breasts and circles your nipples with glowing hearts.',
            'vagina' => 'Above your pussy she inks an arrow and the word *WET*, which glows brighter the more you drip.',
            'penis' => 'She writes *HARD FOR YOU* down the length of your cock, and it shines whenever you twitch.',
            'anus' => 'Across your ass she signs her name in big glowing script.'
          },
          lp: 5, lust: 10, special: :body_writing
        },
        decline: { label: 'Decline', text: 'Keep your skin dark', lust: 2,
                   scene: 'You decline. She caps the quill with a sigh. "Pity. You\'d have been dazzling."' }
      },
      'tally_lich' => {
        name: 'Tally Lich', tag: 'body_writing', tracker: 'body_writing_events',
        blurb: 'a skeletal clerk hunches over an enormous ledger.',
        intro: 'A robed lich hunches over a ledger thick as a door, its quill scratching endlessly. It looks up with glowing ' \
               'eyes. "Unrecorded," it rasps. "That will not do. Strip. I keep my accounts on *skin*."',
        accept: {
          label: 'Be recorded', text: 'Let it write your account on you',
          scenes: ['Cold bony fingers turn you this way and that while the quill scratches across your skin: your name, your ' \
                   'price, a list of everything you are good for. The ink is chill and makes you shiver.',
                   'It finishes with a column of tally marks down your hip and a note: *balance owed, payable in kind*.'],
          parts: {
            'breasts' => 'Under each breast it writes a number, appraising them with clinical precision.',
            'vagina' => 'Over your pussy it writes *DEPOSITS WELCOME* in tidy, old-fashioned script.',
            'penis' => 'It notes your measurements along your cock, then underlines them twice.',
            'anus' => 'Across your ass it stamps *PROPERTY OF THE LEDGER* in inky capitals.'
          },
          lp: 6, lust: 8, special: :body_writing
        },
        alt: {
          label: 'Sign the ledger', text: 'Sign your name and get a receipt on your skin',
          scenes: ['You sign its ledger in a looping hand. The lich writes your receipt across your lower back, line by line, ' \
                   'and your name glows in the book, a debt it will happily collect.'],
          lp: 5, lust: 6, special: :body_writing
        },
        decline: { label: 'Refuse', text: 'Stay off the books', lust: 2,
                   scene: 'You refuse. The lich makes a disapproving note and goes back to its endless scratching.' }
      },
      'minotaur_locker' => {
        name: 'Minotaur\'s Locker Room', tag: 'musk', tracker: 'musk_events',
        blurb: 'steam, sweat, and a bull-heavy smell.',
        intro: 'Steam curls from a stone washroom where a minotaur has just finished training. His sweat-soaked loincloth ' \
               'hangs on a hook, and the air is so thick with his musk you can taste it.',
        accept: {
          label: 'Join him', text: 'Get close and breathe him in',
          scenes: ['He lets you press against his broad, sweat-slick chest and breathe him in, and the musk goes straight to ' \
                   'your head and between your legs at the same time. You rub your face against his fur shamelessly.',
                   'By the time he is done with you, you are soaked in his scent and humming with a deep, animal need.'],
          parts: {
            'vagina' => 'He lifts you onto his thick cock and your pussy stretches around him while you breathe in his musk.',
            'penis' => 'He grinds your cock against his sweaty abs until you spill across his fur.',
            'anus' => 'He bends you over the bench and fucks your ass slow and deep, his musk heavy all around you.'
          },
          lp: 7, lust: 14,
          condition: { key: 'bull_scented', name: 'Bull-Scented', floors: 3,
                       effects: { 'beast_lust_mult' => 1.1, 'strength' => 1, 'beast_submit_lp' => 3 } }
        },
        alt: {
          label: 'Steal the loincloth', text: 'Just bury your face in it',
          scenes: ['While he is in the steam you snatch his loincloth off the hook and bury your face in it, breathing deep ' \
                   'until your knees go weak and you are touching yourself right there by the lockers.'],
          lp: 5, lust: 12,
          condition: { key: 'scent_hound', name: 'Scent Hound', floors: 3, effects: { 'explore_lp' => 1, 'lust_mult' => 1.1 } }
        },
        decline: { label: 'Leave', text: 'Get out before the smell gets you', lust: 4,
                   scene: 'You back out of the steam, but his scent clings to your clothes for a long while.' },
        fight: { label: 'Challenge him', type: :beast, text: 'The minotaur snorts, lowers his horns, and charges!' }
      },
      'orc_hot_spring' => {
        name: 'Orc Hot Spring', tag: 'musk', tracker: 'musk_events',
        blurb: 'a steaming spring ringed by lounging orcs.',
        intro: 'A natural spring steams in a cavern, ringed by big green orcs soaking after a long day. The water is warm and ' \
               'cloudy, and the heavy smell of them hangs over everything. One pats the water beside him.',
        accept: {
          label: 'Slide in', text: 'Soak with the orcs',
          scenes: ['You sink into the warm water between two of them, and the steam carries their musk straight into you. Your ' \
                   'thoughts go thick and slow and happy as heavy arms settle over your shoulders.',
                   'They take turns with you right there in the spring, and you lose count of how many before the water cools.'],
          parts: {
            'vagina' => 'An orc pulls you onto his thighs and fills your pussy, rocking you on his cock beneath the cloudy water.',
            'penis' => 'A big rough hand strokes your cock under the water while you lean back into a broad, musky chest.',
            'anus' => 'One takes your ass from behind as you cling to the stone edge, grunting into your ear.',
            'breasts' => 'Callused thumbs rub your wet nipples while you float in the steam.'
          },
          lp: 7, lust: 14,
          condition: { key: 'steeped_in_musk', name: 'Steeped in Musk', floors: 3,
                       effects: { 'lust_mult' => 1.1, 'healing_mult' => 1.2 } }
        },
        decline: { label: 'Decline', text: 'Stay out of the water', lust: 3,
                   scene: 'You wave politely and move on. A chorus of disappointed grunts follows you.' }
      },
      'frost_queen' => {
        name: 'Frost Queen', tag: 'temperature', tracker: 'temperature_events',
        blurb: 'frost creeps across the floor toward a throne of ice.',
        intro: 'A pale queen sits on a throne of glittering ice, breath misting in the cold air. "Come here, warm thing," ' \
               'she says, crooking one frosted finger. "I want to feel you shiver."',
        accept: {
          label: 'Kneel before her', text: 'Let her chill you',
          scenes: ['She draws a fingertip of frost across your collarbone and down your stomach, and goosebumps race after it. ' \
                   'Every cool touch makes your warm skin jump and tingle.',
                   'She pulls you onto her cold thighs and teases you until you are shivering and flushed at the same time.'],
          parts: {
            'vagina' => 'She slides a smooth, carved ice dildo into your pussy, and you gasp as it melts slowly against your heat.',
            'penis' => 'Her chill fingers wrap your cock and stroke it until you throb, the cold making every pulse sharper.',
            'breasts' => 'She brushes ice across your nipples until they are tight and aching, then warms them with her breath.'
          },
          lp: 6, lust: 12,
          condition: { key: 'frost_kissed', name: 'Frost-Kissed', floors: 2, effects: { 'resistance' => 1, 'flee_bonus' => 0.1 } }
        },
        decline: { label: 'Leave', text: 'Stay warm', lust: 2,
                   scene: 'You rub your arms and back away. The queen\'s soft laugh follows you like a cold draught.' }
      },
      'salamander_sauna' => {
        name: 'Salamander Sauna', tag: 'temperature', tracker: 'temperature_events',
        blurb: 'a cedar sauna glows with warm stones.',
        intro: 'A cosy cedar sauna glows with warm stones, tended by a scaled salamander woman with a bucket of fragrant oil ' \
               'and a fat, dripping candle. "Lie down," she says. "I\'ll warm you all the way through."',
        accept: {
          label: 'Lie down', text: 'Warm oil and soft wax',
          scenes: ['She lays smooth, warm stones along your spine and rubs scented oil into your skin until you melt into the ' \
                   'bench.',
                   'Then she tips the candle, and soft drops of warm wax bloom across your back and thighs, each one a gentle ' \
                   'kiss of heat that makes you sigh and arch.'],
          parts: {
            'breasts' => 'She drips warm wax around your nipples in slow circles, then peels it away, leaving them flushed.',
            'vagina' => 'Her oiled fingers slip between your folds and stroke your clit slow and warm until you are trembling.',
            'penis' => 'She works warm oil along your cock with long, slick strokes until you are throbbing and glazed.'
          },
          lp: 6, lust: 14,
          condition: { key: 'sauna_flushed', name: 'Sauna-Flushed', floors: 2,
                       effects: { 'healing_mult' => 1.25, 'satisfy_bonus' => 0.05 } }
        },
        alt: {
          label: 'Cold plunge', text: 'Warm up, then dive into the ice bath',
          scenes: ['You sweat on the warm stones until you are glowing, then she leads you to an icy plunge pool. The shock of ' \
                   'cold steals your breath and leaves every inch of you tingling and alive.'],
          lp: 5, lust: 8,
          condition: { key: 'plunge_tingle', name: 'Plunge Tingle', floors: 2, effects: { 'agility' => 1, 'resistance' => 1 } }
        },
        decline: { label: 'Decline', text: 'Stay dressed', lust: 2,
                   scene: 'You decline. She shrugs, ladles water over the stones, and the steam hisses after you.' }
      },
      'giantess_garden' => {
        name: 'Giantess Garden', tag: 'size_difference', tracker: 'size_events',
        blurb: 'flowers as tall as trees, and footsteps that shake the ground.',
        intro: 'Daisies tower over you like trees. Then the ground trembles and a giantess kneels down, her face filling the ' \
               'sky. "Oh, what a cute one," she says, and holds out her palm.',
        accept: {
          label: 'Climb on', text: 'Let her play with you',
          scenes: ['She lifts you to eye level and strokes you with a single fingertip, a touch that covers half your body at ' \
                   'once. You are tiny, helpless, and absolutely thrilled about it.',
                   'She sets you on her warm skin and lets you explore her like a landscape, giggling as you crawl and grind ' \
                   'against her.'],
          parts: {
            'vagina' => 'She rubs her fingertip slowly between your legs, the pad of it covering your whole pussy at once.',
            'penis' => 'She rolls your cock under her fingertip like a stem, and you spill across her palm in no time.',
            'breasts' => 'You end up sprawled across one of her huge breasts, rubbing yourself against a nipple bigger than your head.'
          },
          lp: 7, lust: 14,
          condition: { key: 'handheld', name: 'Handheld', floors: 2, effects: { 'submission' => 1, 'satisfy_bonus' => 0.1 } }
        },
        decline: { label: 'Hide', text: 'Duck under a leaf', lust: 2,
                   scene: 'You duck beneath a leaf until her footsteps fade, heart pounding a little more than you\'d admit.' }
      },
      'tiny_court' => {
        name: 'Tiny Court', tag: 'size_difference', tracker: 'size_events',
        blurb: 'a hall full of hand-sized imps bowing low.',
        intro: 'You step into a hall and find yourself towering over a court of hand-sized imps, who gasp and bow. "The ' \
               'colossus has come!" they cry. "Lie down, great one, and let us worship you."',
        accept: {
          label: 'Lie down', text: 'Let them worship your huge body',
          scenes: ['You stretch out across the floor and they swarm over you like adoring ants, kissing, stroking and massaging ' \
                   'every inch of skin they can reach.',
                   'Some climb your thighs on rope ladders; others form a chorus to sing your praises. You have never felt so ' \
                   'enormous, or so adored.'],
          parts: {
            'vagina' => 'A team of imps works together to stroke your huge clit, and one crawls right into your pussy to please you.',
            'penis' => 'A dozen of them hug and rub your cock at once, sliding up and down its length until you erupt over them.',
            'breasts' => 'Imps climb your breasts like hills and plant kisses all over your nipples.',
            'anus' => 'One brave imp squeezes between your cheeks and rubs your ass with both hands.'
          },
          lp: 7, lust: 14,
          condition: { key: 'worshipped_titan', name: 'Worshipped Titan', floors: 3, effects: { 'strength' => 2, 'agility' => -1 } }
        },
        decline: { label: 'Step carefully out', text: 'Leave the court', lust: 2,
                   scene: 'You tiptoe back out, mindful of the imps underfoot. They wail in disappointment.' },
        fight: { label: 'Scatter them', type: :demon, text: 'The imps shriek, and a full-sized demon steps out to defend them!' }
      },
      'sneering_mirror' => {
        name: 'Sneering Mirror', tag: 'degradation', tracker: 'degradation_events',
        blurb: 'a tall mirror smirks back at you.',
        intro: 'A tall mirror shows your reflection, except your reflection is smirking. "Look at you," it says in your own ' \
               'voice. "Pretending to be a hero. We both know what you really are."',
        accept: {
          label: 'Say it', text: 'Admit it out loud',
          scenes: ['Your reflection makes you say it, again and again: slut, needy thing, desperate hole, ' \
                   'shameless tease. Each word makes your cheeks flame and your body throb.',
                   'It tells you to touch yourself while you say it, and you do, staring into your own hungry eyes.'],
          parts: {
            'vagina' => 'Your reflection points out how swollen and wet your pussy is, and you agree, fingers slick.',
            'penis' => 'It mocks how hard your cock gets from being called names, and you stroke it faster.'
          },
          lp: 7, lust: 12,
          condition: { key: 'shameless_slut', name: 'Shameless Slut', floors: 3,
                       effects: { 'submission' => 1, 'submit_lp_bonus' => 2, 'resistance' => -1 } }
        },
        decline: { label: 'Turn away', text: 'Do not listen', lust: 3,
                   scene: 'You turn away. Behind you, your reflection laughs. "Liar."' }
      },
      'ghostly_tavern' => {
        name: 'Ghostly Tavern', tag: 'degradation', tracker: 'degradation_events',
        blurb: 'a phantom tavern roars with spectral laughter.',
        intro: 'A tavern of translucent spirits roars with laughter as you walk in. The ghostly barkeep slaps the counter. ' \
               '"Oi, lads! The new house slut\'s arrived!" Every spectral head turns your way, leering.',
        accept: {
          label: 'Play the part', text: 'Be the house slut',
          scenes: ['You climb up onto the bar and let them name you whatever they like: slut, barrel-rag, cheap ride. Every ' \
                   'cruel jeer sends a delicious flush through you.',
                   'They pass you from table to table, calling you filthier things with every round, and you thank each one.'],
          parts: {
            'vagina' => 'A cold phantom cock fills your pussy while the table jeers about how easy you are.',
            'penis' => 'A ghostly hand strokes your cock while they laugh at how fast it leaks for them.',
            'anus' => 'They bend you over a table and take turns with your ass, calling you the tavern\'s best tap.'
          },
          lp: 8, lust: 14,
          condition: { key: 'house_slut', name: 'House Slut', floors: 3,
                       effects: { 'undead_submit_lp' => 3, 'lust_mult' => 1.1 } }
        },
        alt: {
          label: 'Be the darling', text: 'Win them over sweetly instead',
          scenes: ['You serve drinks with a wink and a curtsy until the jeers soften into toasts. "Our sweet darling!" they ' \
                   'cheer, and every bit of praise warms you down to your toes.'],
          lp: 5, lust: 8,
          condition: { key: 'tavern_darling', name: 'Tavern Darling', floors: 3, effects: { 'resistance' => 1, 'explore_lp' => 1 } }
        },
        decline: { label: 'Leave', text: 'Walk back out', lust: 2,
                   scene: 'You turn and leave. The tavern fades behind you, still roaring.' }
      },
      'duchess_parlour' => {
        name: 'Duchess\'s Parlour', tag: 'maid_service', tracker: 'maid_events',
        blurb: 'a parlour set for tea, with an empty apron on a hook.',
        intro: 'A demon duchess reclines in a parlour of rose silk, a silver tea service untouched beside her. A frilled apron ' \
               'hangs on a hook. "My last maid was dreadful," she says. "Do try to be better."',
        accept: {
          label: 'Serve tea', text: 'Apron, stockings, and perfect manners',
          scenes: ['You pour, you curtsy, you hold the saucer just so, and every time a drop spills she bends you over her knee ' \
                   'and spanks you until you squeal a proper apology.',
                   'By the final cup you are flawless, and she rewards you by pulling you onto her knee and teaching you a very ' \
                   'different sort of service.'],
          parts: {
            'vagina' => 'She slips her hand beneath your apron and fingers your pussy while you hold the teacup perfectly still.',
            'penis' => 'She strokes your cock beneath your apron and forbids you to spill a single drop, of anything.',
            'breasts' => 'She tugs your uniform down and pinches your nipples whenever your posture slips.'
          },
          lp: 7, lust: 12,
          condition: { key: 'parlour_trained', name: 'Parlour-Trained', floors: 3,
                       effects: { 'resistance' => 1, 'explore_lp' => 1, 'submission' => 1 } }
        },
        alt: {
          label: 'Serve under the table', text: 'Attend to her beneath the tablecloth', needs_tag: 'oral',
          scenes: ['She lifts the tablecloth and points. You crawl beneath and spend the whole tea party between her thighs, ' \
                   'tongue buried in her while she chats calmly above you about the weather.'],
          lp: 8, lust: 14,
          condition: { key: 'under_the_table', name: 'Under the Table', floors: 2, effects: { 'submit_lp_bonus' => 3 } }
        },
        decline: { label: 'Decline', text: 'Leave the apron on its hook', lust: 2,
                   scene: 'You leave the apron where it hangs. The duchess sniffs. "Good help is so hard to find."' }
      },
      'slime_scullery' => {
        name: 'Slime Scullery', tag: 'maid_service', tracker: 'maid_events',
        blurb: 'a filthy kitchen and a mop leaning by the door.',
        intro: 'A grand kitchen lies in total disarray, and a maid\'s uniform is folded beside a bucket and mop. In the sink, a ' \
               'cheerful green slime bubbles. "Help me tidy up?" it gurgles. "I\'ll help *you* too."',
        accept: {
          label: 'Get scrubbing', text: 'Put on the uniform and clean',
          scenes: ['You scrub floors on your knees in a skirt that rides up with every stroke, while the slime oozes up your ' \
                   'stockings and under your apron to help in its own way.',
                   'By the time the kitchen sparkles, you are flushed, sticky and moaning, and the slime is very pleased with you.'],
          parts: {
            'vagina' => 'Slime slides up between your thighs and fills your pussy, pulsing warmly while you scrub.',
            'penis' => 'The slime wraps around your cock beneath the skirt and squeezes in time with your scrubbing.',
            'anus' => 'A blob of slime oozes into your ass and wriggles there every time you bend over.'
          },
          lp: 7, lust: 12,
          condition: { key: 'spotless', name: 'Spotless', floors: 3, effects: { 'treasure_lp' => 2, 'slime_lust_mult' => 1.1 } }
        },
        decline: { label: 'Leave the mess', text: 'Not your kitchen', lust: 2,
                   scene: 'You leave the mess behind. The slime burbles sadly into the dishwater.' },
        fight: { label: 'Mop it up', type: :slime, text: 'The slime surges out of the sink, wobbling indignantly!' }
      },
      'chariot_race' => {
        name: 'Chariot Race', tag: 'pony_play', tracker: 'pony_events',
        blurb: 'a sandy track and a chariot without a horse.',
        intro: 'A sandy oval track waits under torchlight, and a demoness in riding leathers leans on a gilded chariot with ' \
               'no horse hitched to it. She smiles at you and flicks a riding crop. "There you are."',
        accept: {
          label: 'Get hitched', text: 'Pull her chariot around the track',
          scenes: ['She buckles you into the traces, fits a bit between your teeth and plumes in your hair, and then you are ' \
                   'off, legs pumping, while she steers you with the reins and playful flicks of the crop.',
                   'Circuit after circuit, until you are glistening and panting and she declares you the finest pony in the tower.'],
          parts: {
            'anus' => 'Your tail is anchored by a plug in your ass that bounces with every high-stepping stride.',
            'breasts' => 'The harness frames your breasts, and the reins tug them gently whenever she steers.',
            'penis' => 'Your cock bobs, hard and leaking, with every stride, and she laughs and tells you to run faster.',
            'vagina' => 'A strap runs snug between your legs and rubs your pussy with every step until your thighs are slick.'
          },
          lp: 7, lust: 12,
          condition: { key: 'race_broken', name: 'Race-Broken', floors: 3,
                       effects: { 'agility' => 2, 'dodge_bonus' => 0.05, 'submission' => 1 } }
        },
        alt: {
          label: 'Show pony', text: 'Prance in plumes instead of racing',
          scenes: ['She decks you in plumes and silver bells and leads you through a dressage routine, high knees and proud head, ' \
                   'until every step feels like a performance you were born for.'],
          lp: 5, lust: 8,
          condition: { key: 'show_pony', name: 'Show Pony', floors: 3, effects: { 'agility' => 1, 'satisfy_bonus' => 0.05 } }
        },
        decline: { label: 'Decline', text: 'Nobody drives you', lust: 2,
                   scene: 'You decline. She shrugs and taps the crop against her boot. "Your loss, wild thing."' }
      },
      'satyr_paddock' => {
        name: 'Satyr\'s Paddock', tag: 'pony_play', tracker: 'pony_events',
        blurb: 'a grassy paddock with a grooming kit by the fence.',
        intro: 'A grassy paddock opens under a pale false sky. A grinning satyr leans on the fence with a ' \
               'brush and a set of leather hoof-boots. "Ah, a new filly," he says. "Let\'s get you groomed."',
        accept: {
          label: 'Be groomed', text: 'Hoof-boots, a mane brushing, and a ride',
          scenes: ['He brushes your hair into a glossy mane, laces you into hoof-boots and a snug harness, and walks you around ' \
                   'the paddock on a lead, praising your gait.',
                   'Then he mounts you in the soft grass, hands on your harness, and rides you like a prize.'],
          parts: {
            'vagina' => 'His thick cock sinks into your pussy from behind, and you whinny and stamp your hoof-boots.',
            'anus' => 'He takes your ass slow and steady, tugging your mane with each thrust.',
            'penis' => 'He reaches under you and strokes your cock like he is milking a prize stallion.'
          },
          lp: 7, lust: 12,
          condition: { key: 'groomed_filly', name: 'Groomed Filly', floors: 3,
                       effects: { 'flee_bonus' => 0.15, 'beast_submit_lp' => 3 } }
        },
        decline: { label: 'Decline', text: 'Stay out of the paddock', lust: 2,
                   scene: 'You decline. The satyr shrugs and goes back to whistling at the clouds.' }
      },
      'silent_chapel' => {
        name: 'Silent Chapel', tag: 'gags_hoods', tracker: 'gag_events',
        blurb: 'a hushed chapel of hooded statues.',
        intro: 'A chapel where no sound echoes. Hooded statues line the pews, and a tall wraith glides forward holding a ' \
               'padded leather hood and a gag with a velvet ball. It raises a finger to where its lips would be.',
        accept: {
          label: 'Accept the silence', text: 'Hooded and gagged (no fleeing next floor)',
          scenes: ['The wraith fits the gag between your lips and buckles it snug, then draws the hood down over your head. The ' \
                   'world becomes darkness, warm leather and the sound of your own breathing.',
                   'Cool hands guide you to kneel and explore you slowly in the silence, and every muffled moan feels like a prayer.'],
          parts: {
            'vagina' => 'Chill fingers stroke your pussy in the dark until you are dripping and moaning into the gag.',
            'penis' => 'A cool hand strokes your cock slowly, and you can only whimper behind the ball.',
            'breasts' => 'Fingertips circle your nipples endlessly, and you drool and arch into the touch.'
          },
          lp: 7, lust: 10,
          condition: { key: 'hushed', name: 'Hushed', floors: 1,
                       effects: { 'no_flee' => true, 'resistance' => 1, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Leave', text: 'Keep your voice', lust: 2,
                   scene: 'You shake your head and slip out. Not a single footstep echoes behind you.' },
        fight: { label: 'Break the silence', type: :undead, text: 'You shout, and the wraith shrieks back, flying at you!' }
      },
      'muzzle_merchant' => {
        name: 'Muzzle Merchant', tag: 'gags_hoods', tracker: 'gag_events',
        blurb: 'a goblin peddler with a cart of straps.',
        intro: 'A goblin merchant pushes a cart piled with harness gags, bit gags and a jar of wobbling blue slime labelled ' \
               '*LIVING GAG*. "Free sample!" he grins. "Try before you buy!"',
        accept: {
          label: 'Free sample', text: 'Try the living gag (no fleeing next floor)',
          scenes: ['He uncorks the jar and the slime leaps onto your face, sealing your lips with a cool, wobbly plug and ' \
                   'buckling itself behind your head. It hums softly, a buzz that tingles all the way down your spine.',
                   'Every time you try to speak it squeezes tighter and hums harder, until you give up and just moan.'],
          parts: {
            'vagina' => 'A stray drip of the slime slides down your body and nestles against your clit, humming in time with the gag.',
            'penis' => 'A strand of slime coils down and wraps your cock, pulsing every time you whimper.'
          },
          lp: 7, lust: 12,
          condition: { key: 'slime_muzzled', name: 'Slime-Muzzled', floors: 1,
                       effects: { 'no_flee' => true, 'slime_submit_lp' => 3 } }
        },
        alt: {
          label: 'Try the hood', text: 'Just a full leather hood',
          scenes: ['He lowers a soft leather hood over your head and laces it snug at the back. Sight and sound fade to a warm ' \
                   'hush, and every brush of his hands as he adjusts the laces makes you shiver.'],
          lp: 5, lust: 8,
          condition: { key: 'hooded_blind', name: 'Hooded', floors: 2, effects: { 'resistance' => 1, 'lust_mult' => 1.1 } }
        },
        decline: { label: 'No thanks', text: 'Walk past the cart', lust: 2, escape: true,
                   scene: 'You slip past before he can press a sample on you. He shouts a discount after you.' }
      }
    }.freeze
  end
end
