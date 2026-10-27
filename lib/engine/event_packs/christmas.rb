# frozen_string_literal: true

module Engine
  module EventPacks
    # Yule of Surrender (Dec 20–26). Candy / trackers → titles persist after.
    CHRISTMAS = {
      'under_the_mistletoe' => {
        name: 'Under the Mistletoe', season: :christmas, tracker: 'mistletoe_events',
        blurb: 'a sprig of mistletoe hung exactly where you have to pass.',
        intro: 'The hallway narrows under a hanging sprig — berries bright, ribbon tighter than necessary. ' \
               'Someone is already waiting on the other side, smiling like a dare. "Temple rule," they say. ' \
               '"You don\'t get past without a kiss."',
        accept: {
          label: 'Kiss', text: 'Tip your face up and take what comes',
          scenes: ['Warm mouth, cold berries, ribbon at your wrists for a heartbeat. Candy foil presses into ' \
                   'your palm when they let go — a receipt for being good.'],
          parts: {
            'vagina' => 'The kiss slides lower; mistletoe shadows rock against your clit until your knees soften.',
            'penis' => 'Painted lips wrap your cock under the sprig — a "kiss" that milks a moan out of you.',
            'anus' => 'They turn you under the berries and claim your ass while the ribbon holds your wrists.',
            'breasts' => 'Mouths and mistletoe leave berry-red marks across your tits; the hallway watches fondly.'
          },
          lp: 7, lust: 14,
          christmas_candy: 2,
          condition: { key: 'kissed_properly', name: 'Kissed Properly', floors: 2,
                       effects: { 'submit_lp_bonus' => 2, 'appearance' => 3 } }
        },
        decline: { label: 'Duck under', text: 'Refuse the sprig', lust: 3,
                   scene: 'You duck. The berries rustle, offended. Somewhere Syn laughs once.' },
        fight: { name: 'Mistletoe Dryad', label: 'Fight the greeter', type: :plant,
                 text: 'The sprig sprouts arms. Yule does not do polite declines!' }
      },
      'gift_under_the_tree' => {
        name: 'Gift Under the Tree', season: :christmas, tracker: 'mistletoe_events',
        blurb: 'a wrapped box ticks once under a crooked pine.',
        intro: 'A tower alcove hosts a pine that should not fit. Beneath it: one gift with your name spelled wrong ' \
               'on purpose. The bow breathes. A note in Syn\'s handwriting — or a forgery with excellent taste — ' \
               'reads: *Unwrap. Or be unwrapped. Both count.*',
        accept: {
          label: 'Unwrap it', text: 'Pull the ribbon and see',
          scenes: ['Ribbon yields. Warmth, foil candy, and a kiss of lust-light spill into your hands. The box ' \
                   'sighs like it enjoyed being opened.'],
          lp: 5, lust: 8,
          christmas_candy: 2,
          condition: { key: 'gift_glow', name: 'Gift Glow', floors: 3,
                       effects: { 'appearance' => 4, 'satisfy_bonus' => 0.03 } }
        },
        alt: {
          label: 'Be the gift', text: 'Lie under the tree and let them wrap you',
          scenes: ['Ribbon, paper, hands — they wrap praise into your skin until you tremble like something ' \
                   'ready for the tag. Candy for later. Less dignity for now.'],
          parts: {
            'vagina' => 'Ribbon frames your open cunt; a mouth unwraps you slow under the pine.',
            'penis' => 'They wind silk around your cock and stroke until the bow is ruined with come.',
            'anus' => 'Paper crackles as they claim your ass; the tag on your hip says *fragile* and lies.',
            'breasts' => 'Bows tied around your tits, tugged loose with teeth and laughter.'
          },
          lp: 8, lust: 16,
          christmas_candy: 1,
          condition: { key: 'ribbon_bound', name: 'Ribbon-Bound', floors: 2,
                       effects: { 'lust_mult' => 1.08, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Leave it', text: 'Let the box wait', lust: 1,
                   scene: 'You leave. The bow tightens once, then settles.' },
        fight: { name: 'Gift-Wrapped Chest Mimic', label: 'Kick the gift', type: :mimic,
                 text: 'Paper teeth grin. Yule furniture wants a present named you!' }
      },
      'naughty_list_nook' => {
        name: 'Naughty List Nook', season: :christmas, tag: 'naughty_list', tracker: 'naughty_list_events',
        blurb: 'a coal-warm alcove where the list is already open to your name.',
        intro: 'Coal glows in a brazier. A parchment unrolls by itself — your name inked wet at the bottom under ' \
               'NAUGHTY. Something chuckles in the dark. "Confess," it says. "Or we\'ll invent better sins."',
        accept: {
          label: 'Confess', text: 'Admit every filthy thing and take the mark',
          scenes: ['The list drinks your words. Heat blooms — coal-kissed skin, a moan you meant to keep, candy ' \
                   'foil pressed into your palm like a black star.'],
          parts: {
            'vagina' => 'Coal-warm fingers find your cunt while the list drinks every gasp.',
            'penis' => 'A soot-stained mouth milks your cock until confession and climax arrive together.',
            'anus' => 'Something hot and patient claims your ass while your name darkens on the parchment.',
            'breasts' => 'Coal-warmed mouths seal over your nipples; the list purrs as you shake.'
          },
          lp: 7, lust: 18,
          christmas_candy: 1,
          condition: { key: 'on_the_list', name: 'On the List', floors: 2,
                       effects: { 'lust_mult' => 1.1, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Claim nice', text: 'Argue you were good', lust: 4,
                   scene: 'The parchment snorts. Coal pops. You escape only slightly less marked.' },
        fight: { name: 'Coal Ember Fiend', label: 'Fight the list', type: :demon,
                 text: 'The brazier stands up. Naughty does not negotiate!' }
      },
      'chimney_trap' => {
        name: 'Chimney Trap', season: :christmas, tag: 'naughty_list', tracker: 'naughty_list_events',
        blurb: 'a flue that smells of soot and peppermint.',
        intro: 'A chimney mouth opens in the ceiling where no fireplace should be. Warm soot-scented air pulls at ' \
               'your clothes. A voice echoes down: "Stuck already? Perfect."',
        accept: {
          label: 'Climb up', text: 'Let the flue take you',
          scenes: ['The chimney holds you — tight, warm, ridiculous — while something above laughs and rewards ' \
                   'every squirm with candy and heat.'],
          lp: 6, lust: 15,
          christmas_candy: 2,
          condition: { key: 'soot_kissed', name: 'Soot-Kissed', floors: 2,
                       effects: { 'appearance' => 3, 'submit_lp_bonus' => 1, 'agility' => -1 } }
        },
        decline: { label: 'Stay down', text: 'Refuse the climb', lust: 2,
                   scene: 'You step back. Soot drifts like disappointed confetti.' },
        fight: { name: 'Chimney Wraith', label: 'Yank whatever\'s up there', type: :undead,
                 text: 'Soot knits into a grinning wraith. Stocking time is over!' }
      }
    }.freeze
  end
end
