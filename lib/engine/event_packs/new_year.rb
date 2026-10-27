# frozen_string_literal: true

module Engine
  module EventPacks
    # Midnight Oath (Dec 31–Jan 2). Bubbles / trackers → titles persist after.
    NEW_YEAR = {
      'midnight_kiss' => {
        name: 'Midnight Kiss', season: :new_year, tracker: 'midnight_events',
        blurb: 'a clockface hangs in the air, hands almost together.',
        intro: 'The hallway holds its breath. A translucent clock ticks toward twelve without a wall to hang on. ' \
               'Someone steps close enough to share air. "Temple rule," they murmur. "When it strikes, you kiss. ' \
               'No exceptions for delvers."',
        accept: {
          label: 'Kiss at twelve', text: 'Wait for the strike and meet them',
          scenes: ['The clock strikes. Mouths meet. Bubbles of champagne-light burst against your tongue and ' \
                   'foil wraps itself into your palm like a toast you already swallowed.'],
          parts: {
            'vagina' => 'The kiss drops; fingers and tongue find your cunt as the last chime fades.',
            'penis' => 'They swallow you down through the countdown until twelve and climax arrive together.',
            'anus' => 'Turned against the clock-glow, they claim your ass while the year turns over your shoulder.',
            'breasts' => 'Champagne-cool mouths seal over your nipples; confetti sticks to wet skin.'
          },
          lp: 7, lust: 14,
          new_year_bubbles: 2,
          condition: { key: 'kissed_in', name: 'Kissed In', floors: 2,
                       effects: { 'submit_lp_bonus' => 2, 'appearance' => 3 } }
        },
        decline: { label: 'Turn away', text: 'Miss the strike on purpose', lust: 3,
                   scene: 'You turn. The clock still strikes. Somewhere Syn clicks her tongue.' },
        fight: { name: 'Countdown Wolf', label: 'Fight the greeter', type: :beast,
                 text: 'The clock cracks into teeth. Midnight does not do polite declines!' }
      },
      'resolution_desk' => {
        name: 'Resolution Desk', season: :new_year, tracker: 'midnight_events',
        blurb: 'a desk, a quill, and a ledger open to blank vows.',
        intro: 'Ink smells like citrus and iron. A ledger waits with your name already written at the top. The quill ' \
               'twitches. A note in Syn\'s hand — or a forgery with excellent taste — reads: *Swear something filthy. ' \
               'Or let us swear it for you.*',
        accept: {
          label: 'Write a vow', text: 'Ink something you will try to keep',
          scenes: ['The quill drinks. Warmth floods your chest — and lower. Bubbles materialise in a sticky pile ' \
                   'at your feet, and the ledger snaps shut like a satisfied mouth.'],
          lp: 5, lust: 8,
          new_year_bubbles: 2,
          condition: { key: 'inked_oath', name: 'Inked Oath', floors: 3,
                       effects: { 'appearance' => 3, 'satisfy_bonus' => 0.03, 'submit_lp_bonus' => 1 } }
        },
        alt: {
          label: 'Be written', text: 'Let them fill the page with you',
          scenes: ['Hands pin you to the desk. The quill writes across skin — vows you did not choose, heat you ' \
                   'cannot refuse. Bubbles for later. Less blank space for now.'],
          parts: {
            'vagina' => 'Ink-wet fingers fill your cunt while the ledger drinks every moan as a clause.',
            'penis' => 'They stroke your cock with the quill-hand until come blots the page.',
            'anus' => 'The desk edge bites your hips as they claim your ass and initial the margin.',
            'breasts' => 'Ink trails across your tits; a mouth signs each line with a suck.'
          },
          lp: 8, lust: 16,
          new_year_bubbles: 1,
          condition: { key: 'page_bound', name: 'Page-Bound', floors: 2,
                       effects: { 'lust_mult' => 1.08, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Leave blank', text: 'Walk away from the quill', lust: 1,
                   scene: 'You leave. The page flutters once, disappointed.' },
        fight: { name: 'Resolution Chest Mimic', label: 'Slam the ledger', type: :mimic,
                 text: 'The desk sprouts teeth. Oaths bite back!' }
      },
      'broken_resolution' => {
        name: 'Broken Resolution', season: :new_year, tag: 'resolutions', tracker: 'resolution_events',
        blurb: 'a mirror that already knows what you will fail at.',
        intro: 'Your reflection mouths a vow you have not said yet — then breaks it with a smirk. Glass-dust ' \
               'glitters like confetti. "Admit it," the reflection whispers. "You came here to fail beautifully."',
        accept: {
          label: 'Fail on purpose', text: 'Break the vow and take the heat',
          scenes: ['The mirror laughs with your mouth. Pleasure hits like a countdown finished early — thighs wet, ' \
                   'bubbles in your fist, every good intention ruined and rewarded.'],
          parts: {
            'vagina' => 'Glass-cool fingers fuck the honesty into your cunt until the vow is pulp.',
            'penis' => 'Your reflection milks you dry while listing every resolution you will not keep.',
            'anus' => 'It bends you into yourself and takes your ass with relentless, smiling patience.',
            'breasts' => 'It mauls your tits against the cold glass until your breath fogs both faces.'
          },
          lp: 7, lust: 18,
          new_year_bubbles: 1,
          condition: { key: 'beautifully_failed', name: 'Beautifully Failed', floors: 2,
                       effects: { 'lust_mult' => 1.1, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Cover the glass', text: 'Refuse the smirk', lust: 4,
                   scene: 'You drape cloth. Under it, something blinks once more, then settles.' },
        fight: { name: 'Your Resolution', label: 'Shatter it', type: :mimic,
                 text: 'The glass cracks into a dozen yous — each already mid-failure!' }
      },
      'champagne_fountain' => {
        name: 'Champagne Fountain', season: :new_year, tag: 'resolutions', tracker: 'resolution_events',
        blurb: 'a fountain that pours itself toward your mouth.',
        intro: 'Gold fizz arcs from a stone basin with no plumber in sight. It tips toward you without hands. ' \
               'The smell is citrus, sugar, and something that wants you softer and sworn.',
        accept: {
          label: 'Drink', text: 'Tip your head back and take every pour',
          scenes: ['Bubbles flood your throat. Heat pools low. You feel bright, praised, and slightly ruined — ' \
                   'exactly as midnight prefers its guests.'],
          lp: 6, lust: 15,
          new_year_bubbles: 2,
          condition: { key: 'champagne_drunk', name: 'Champagne-Drunk', floors: 2,
                       effects: { 'submission' => 1, 'satisfy_bonus' => 0.05, 'resistance' => -1 } }
        },
        decline: { label: 'Step back', text: 'Refuse the pour', lust: 3,
                   scene: 'You right yourself. The fountain rocks once, offended, and goes still.' },
        fight: { name: 'Champagne Slime', label: 'Smash the basin', type: :slime,
                 text: 'Fizz rises into a hungry shape. The toast fights back!' }
      }
    }.freeze
  end
end
