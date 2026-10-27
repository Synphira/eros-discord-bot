# frozen_string_literal: true

module Engine
  module EventPacks
    # Feast of the Willing (Nov 23–30). Rewards (leftovers, trackers → titles) persist.
    THANKSGIVING = {
      'guest_at_the_table' => {
        name: 'Guest at the Table', season: :thanksgiving, tracker: 'feast_table_events',
        blurb: 'a long table set for one more guest — you.',
        intro: 'White cloth, candle stubs, and a place card with your name spelled wrong on purpose. Something ' \
               'under the tablecloth breathes warm against your calf. A carving fork is already in someone\'s ' \
               'hand. "Sit," they say. "We saved you a seat."',
        accept: {
          label: 'Sit', text: 'Take the empty chair and be served',
          scenes: ['Plates arrive before you ask. Warm gravy, sweet glaze, fingers at your lips — hospitality ' \
                   'that expects gratitude in kind. You eat. You are eaten. The place card curls with steam.'],
          parts: {
            'vagina' => 'Under the cloth, a guest\'s mouth finds your cunt while another tips wine against your teeth.',
            'penis' => 'Someone kneels between your knees and swallows you with dessert manners — slow, thorough, proud.',
            'anus' => 'A greased finger, then more, while the toastmaster proposes a filthy toast over your head.',
            'breasts' => 'Whipped cream and mouths claim your tits; the table laughs fondly when you moan into the napkin.'
          },
          lp: 7, lust: 14,
          leftovers: 2,
          condition: { key: 'well_fed_guest', name: 'Well-Fed Guest', floors: 3,
                       effects: { 'satisfy_bonus' => 0.04, 'submit_lp_bonus' => 1, 'appearance' => 3 } }
        },
        decline: { label: 'Decline the seat', text: 'Leave the place card untouched', lust: 2,
                   scene: 'You bow out. The fork scrapes once. The chair stays empty — for now.' },
        fight: { name: 'Table Mimic', label: 'Flip the table', type: :mimic,
                 text: 'The cloth sprouts teeth. Feast furniture wants a course named you!' }
      },
      'carving_station' => {
        name: 'Carving Station', season: :thanksgiving, tracker: 'feast_table_events',
        blurb: 'a carving board, a sharp knife, and too much butter.',
        intro: 'A sideboard waits in a side hall: roast, gravy boat, and a knife that looks like Syn\'s humour. ' \
               'A note in flour-dusted ink: *Carve yourself a portion. Or be the portion. Both feed the temple.*',
        accept: {
          label: 'Carve a plate', text: 'Serve yourself — carefully',
          scenes: ['You carve. Warm juice runs. Leftovers wrap themselves for your tin without asking, and a ' \
                   'kiss of lust-light sticks to your fingers like glaze.'],
          lp: 5, lust: 6,
          leftovers: 2,
          condition: { key: 'buttered_fingers', name: 'Buttered Fingers', floors: 2,
                       effects: { 'appearance' => 2, 'explore_lp' => 1 } }
        },
        alt: {
          label: 'Be the roast', text: 'Lie on the board and let them carve attention into you',
          scenes: ['Butter and string, heat and hands — they baste praise into your skin until you tremble like ' \
                   'something ready to be plated. You leave with leftovers and less dignity.'],
          parts: {
            'vagina' => 'They baste your open cunt with gravy-warm fingers until you drip onto the board.',
            'penis' => 'Oiled hands carve slow strokes along your cock like they are portioning dessert.',
            'anus' => 'Twine and a greased thumb make a joke of your composure; the knife never touches you — the attention does.',
            'breasts' => 'Butter painted across your tits, licked clean by whoever claimed first carve.'
          },
          lp: 8, lust: 16,
          leftovers: 1,
          condition: { key: 'basted_properly', name: 'Basted Properly', floors: 2,
                       effects: { 'lust_mult' => 1.08, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Walk on', text: 'Leave the board for someone hungrier', lust: 1,
                   scene: 'You pass. The gravy boat sighs. Syn would call that rude.' },
        fight: { name: 'Butter-Basted Wolf', label: 'Fight the carver', type: :beast,
                 text: 'Something hungry claims the station — feast-week pest with carving manners!' }
      },
      'second_helping' => {
        name: 'Second Helping', season: :thanksgiving, tag: 'feast_excess', tracker: 'feast_excess_events',
        blurb: 'a kitchen that insists you are not done yet.',
        intro: 'Pots bubble. Someone in an apron too small for their appetite blocks the door with a smile. ' \
               '"You barely touched your plate," they lie. "Open wider. Seconds are mandatory."',
        accept: {
          label: 'Take seconds', text: 'Let them feed you past full',
          scenes: ['Mouthful after mouthful — sweet, rich, filthy. Your belly softens under their palm as they ' \
                   'praise every swallow. Leftovers for later. Softness for now.'],
          parts: {
            'vagina' => 'They feed your mouth while fingers stuff your cunt — two hungers taught the same lesson.',
            'penis' => 'A greased hand milks you between bites until climax and fullness arrive together.',
            'anus' => 'A plug of something warm and edible seats in your ass while they tip another spoon past your lips.',
            'breasts' => 'Cream poured over your tits and licked clean; your stomach presses soft against their apron.'
          },
          lp: 7, lust: 18,
          leftovers: 2,
          condition: { key: 'stuffed_guest', name: 'Stuffed Guest', floors: 3,
                       effects: { 'lust_mult' => 1.1, 'agility' => -1, 'submit_lp_bonus' => 2, 'appearance' => 4 } }
        },
        decline: { label: 'Refuse', text: 'Claim you are full', lust: 4,
                   scene: 'They pout. The pots hiss. You escape only slightly emptier than they wanted.' },
        fight: { name: 'Hostess Succubus', label: 'Fight the hostess', type: :demon,
                 text: 'The apron comes off. Feast etiquette ends — dessert begins!' }
      },
      'gravy_boat_trap' => {
        name: 'Gravy Boat Trap', season: :thanksgiving, tag: 'feast_excess', tracker: 'feast_excess_events',
        blurb: 'a gravy boat that tips itself toward your mouth.',
        intro: 'A silver gravy boat sits alone on a plinth, steam curling. It tips toward you without hands. ' \
               'The smell is butter, stock, and something that wants you softer.',
        accept: {
          label: 'Drink', text: 'Tip it back and take every drop',
          scenes: ['Warm gravy floods your throat. Heat pools low. You feel plush, praised, and slightly ' \
                   'ruined — exactly as the feast prefers its guests.'],
          lp: 6, lust: 15,
          leftovers: 1,
          condition: { key: 'gravy_drunk', name: 'Gravy-Drunk', floors: 2,
                       effects: { 'submission' => 1, 'satisfy_bonus' => 0.05, 'resistance' => -1 } }
        },
        decline: { label: 'Set it down', text: 'Refuse the pour', lust: 3,
                   scene: 'You right the boat. It rocks once, offended, and goes still.' },
        fight: { name: 'Gravy Amber Slime', label: 'Smash the boat', type: :slime,
                 text: 'Gravy rises into a hungry shape. Dinner fights back!' }
      }
    }.freeze
  end
end
