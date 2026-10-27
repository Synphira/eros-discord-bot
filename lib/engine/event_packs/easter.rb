# frozen_string_literal: true

module Engine
  module EventPacks
    # Hare's Hunt (Good Friday–Easter Monday). Eggs / trackers → titles persist after.
    EASTER = {
      'egg_hunt' => {
        name: 'Egg Hunt', season: :easter, tracker: 'easter_hunt_events',
        blurb: 'painted eggs gleam in cracks that should not hold candy.',
        intro: 'Foil-wrapped eggs wink from crevices, under silk, inside a boot that is definitely watching you. A ' \
               'note in Syn\'s handwriting — or a forgery with excellent taste — reads: *Find them. Or be found. ' \
               'Both count as spring.*',
        accept: {
          label: 'Hunt', text: 'Search on hands and knees',
          scenes: ['You crawl. Warmth, foil, and a kiss of lust-light tip into your palms with every find. Something ' \
                   'purrs approval from the walls — whether you are wearing ears or not.'],
          lp: 6, lust: 8,
          easter_eggs: 2,
          condition: { key: 'hunter_marked', name: 'Hunter-Marked', floors: 2,
                       effects: { 'explore_lp' => 1, 'appearance' => 2 } }
        },
        alt: {
          label: 'Be the egg', text: 'Hide yourself and let them find you',
          scenes: ['You tuck into a hollow. Hands find you — laughing, hungry — and unwrap praise from your skin until ' \
                   'you tremble like something ready for the basket. Eggs for later. Less dignity for now.'],
          parts: {
            'vagina' => 'Found open: fingers and tongue fill your cunt while foil crinkles under your knees.',
            'penis' => 'A spring-sweet mouth swallows you as the "egg" they came to claim.',
            'anus' => 'They bend you in the hollow and claim your ass until the hunt is over.',
            'breasts' => 'Painted hands maul your tits; chocolate smears where the find was celebrated.'
          },
          lp: 8, lust: 16,
          easter_eggs: 1,
          condition: { key: 'found_egg', name: 'Found Egg', floors: 2,
                       effects: { 'lust_mult' => 1.08, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Walk past', text: 'Leave the eggs for hungrier hunters', lust: 1,
                   scene: 'You leave. One egg rolls after you two rooms, then gives up.' },
        fight: { name: 'Egg-Basket Chest Mimic', label: 'Kick the basket', type: :mimic,
                 text: 'The basket sprouts teeth. Spring furniture wants a prize named you!' }
      },
      'warren_alcove' => {
        name: 'Warren Alcove', season: :easter, tracker: 'easter_hunt_events',
        blurb: 'a soft burrow cut into the stone, smelling of fur and chocolate.',
        intro: 'The alcove is lined with stolen cushions and shed silk. Something with long ears waits in the dark, ' \
               'paw tapping. "Come nest," it says. "Or hop away. Both make me chase."',
        accept: {
          label: 'Nest', text: 'Crawl in and take what spring offers',
          scenes: ['Warmth, fur, chocolate foil against your palm. The warren fucks hospitality into you until your ' \
                   'knees forget the hallway.'],
          parts: {
            'vagina' => 'A thick beast-cock fills your cunt while soft ears brush your cheek.',
            'penis' => 'A velvet muzzle swallows you down; the warren hums around the suck.',
            'anus' => 'Knotted patience claims your ass while chocolate melts on your tongue.',
            'breasts' => 'Soft mouths latch onto your nipples; the nest smells like sugar and rut.'
          },
          lp: 7, lust: 16,
          easter_eggs: 2,
          condition: { key: 'warren_warm', name: 'Warren-Warm', floors: 3,
                       effects: { 'beast_submit_lp' => 1, 'satisfy_bonus' => 0.04, 'appearance' => 3 } }
        },
        decline: { label: 'Hop away', text: 'Refuse the burrow', lust: 3,
                   scene: 'You retreat. Soft laughter follows. Something hops after you — once — then settles.' },
        fight: { name: 'Spring Hare Wolf', label: 'Fight the warren', type: :beast,
                 text: 'Ears and teeth. Hare does not do polite declines!' }
      },
      'fertile_garden' => {
        name: 'Fertile Garden', season: :easter, tag: 'spring_rut', tracker: 'spring_rut_events',
        blurb: 'a garden bed that wants more than watering.',
        intro: 'Lilies lean in. Soil is warm underfoot. Vines curl like fingers toward your hips. A dryad-soft voice ' \
               'from the greenery: "Plant something. Or be planted. Spring is not patient."',
        accept: {
          label: 'Be planted', text: 'Lie in the bed and take the season',
          scenes: ['Roots and pollen — they fill you with spring until your belly feels praised and soft. Eggs foil ' \
                   'into your fist like a receipt for fertility the temple already claimed.'],
          parts: {
            'vagina' => 'Thick pollen-slick vines fill your cunt until climax and bloom arrive together.',
            'penis' => 'Flower-mouths milk you into the soil; the garden drinks greedily.',
            'anus' => 'A vine seats in your ass while another tips nectar past your lips.',
            'breasts' => 'Petals seal over your nipples; sap and praise drip down your ribs.'
          },
          lp: 7, lust: 18,
          easter_eggs: 1,
          condition: { key: 'spring_seeded', name: 'Spring-Seeded', floors: 3,
                       effects: { 'lust_mult' => 1.1, 'plant_submit_lp' => 2, 'submit_lp_bonus' => 1 } }
        },
        decline: { label: 'Water only', text: 'Offer a polite sprinkle and leave', lust: 4,
                   scene: 'You sprinkle and flee. The lilies look personally insulted.' },
        fight: { name: 'Lily Alraune', label: 'Fight the bed', type: :plant,
                 text: 'The garden stands up. Nesting is mandatory!' }
      },
      'empty_tomb_nook' => {
        name: 'Empty Tomb Nook', season: :easter, tag: 'spring_rut', tracker: 'spring_rut_events',
        blurb: 'a stone nook where something already rose — and wants company.',
        intro: 'Cool stone. A rolled cloth. The air smells like lilies and sex. Something warm waits where a body ' \
               'should be cold. "Come see," it whispers. "I came back hungry."',
        accept: {
          label: 'Enter', text: 'Step into the nook and be risen with',
          scenes: ['Warmth claims you — mouths, hands, a laugh that should not fit in a tomb. Chocolate foil and ' \
                   'lust-light press into your palm when it finally lets you breathe.'],
          parts: {
            'vagina' => 'A risen tongue finds your clit while stone stays cold against your back.',
            'penis' => 'A hungry mouth swallows you until climax feels like a second rising.',
            'anus' => 'Something patient claims your ass in the dark; the cloth flutters.',
            'breasts' => 'Warm mouths seal over your nipples; the nook echoes every moan.'
          },
          lp: 8, lust: 16,
          easter_eggs: 2,
          condition: { key: 'twice_risen', name: 'Twice-Risen', floors: 2,
                       effects: { 'satisfy_bonus' => 0.05, 'appearance' => 4 } }
        },
        decline: { label: 'Leave closed', text: 'Roll the cloth and go', lust: 2,
                   scene: 'You leave. Behind you, something sighs — fond, disappointed — and settles.' },
        fight: { name: 'Risen Wraith', label: 'Swing at the dark', type: :undead,
                 text: 'The nook empties into teeth. Spring does not stay buried!' }
      }
    }.freeze
  end
end
s Hunt does not do polite declines!' }
      },
      'fertile_garden' => {
        name: 'Fertile Garden', season: :easter, tag: 'spring_rut', tracker: 'spring_rut_events',
        blurb: 'a garden bed that wants more than watering.',
        intro: 'Lilies lean in. Soil is warm underfoot. Vines curl like fingers toward your hips. A dryad-soft voice ' \
               'from the greenery: "Plant something. Or be planted. Spring is not patient."',
        accept: {
          label: 'Be planted', text: 'Lie in the bed and take the season',
          scenes: ['Roots and pollen — they fill you with spring until your belly feels praised and soft. Eggs foil ' \
                   'into your fist like a receipt for fertility the temple already claimed.'],
          parts: {
            'vagina' => 'Thick pollen-slick vines fill your cunt until climax and bloom arrive together.',
            'penis' => 'Flower-mouths milk you into the soil; the garden drinks greedily.',
            'anus' => 'A vine seats in your ass while another tips nectar past your lips.',
            'breasts' => 'Petals seal over your nipples; sap and praise drip down your ribs.'
          },
          lp: 7, lust: 18,
          easter_eggs: 1,
          condition: { key: 'spring_seeded', name: 'Spring-Seeded', floors: 3,
                       effects: { 'lust_mult' => 1.1, 'plant_submit_lp' => 2, 'submit_lp_bonus' => 1 } }
        },
        decline: { label: 'Water only', text: 'Offer a polite sprinkle and leave', lust: 4,
                   scene: 'You sprinkle and flee. The lilies look personally insulted.' },
        fight: { name: 'Lily Alraune', label: 'Fight the bed', type: :plant,
                 text: 'The garden stands up. Nesting is mandatory!' }
      },
      'empty_tomb_nook' => {
        name: 'Empty Tomb Nook', season: :easter, tag: 'spring_rut', tracker: 'spring_rut_events',
        blurb: 'a stone nook where something already rose — and wants company.',
        intro: 'Cool stone. A rolled cloth. The air smells like lilies and sex. Something warm waits where a body ' \
               'should be cold. "Come see," it whispers. "I came back hungry."',
        accept: {
          label: 'Enter', text: 'Step into the nook and be risen with',
          scenes: ['Warmth claims you — mouths, hands, a laugh that should not fit in a tomb. Chocolate foil and ' \
                   'lust-light press into your palm when it finally lets you breathe.'],
          parts: {
            'vagina' => 'A risen tongue finds your clit while stone stays cold against your back.',
            'penis' => 'A hungry mouth swallows you until climax feels like a second rising.',
            'anus' => 'Something patient claims your ass in the dark; the cloth flutters.',
            'breasts' => 'Warm mouths seal over your nipples; the nook echoes every moan.'
          },
          lp: 8, lust: 16,
          easter_eggs: 2,
          condition: { key: 'twice_risen', name: 'Twice-Risen', floors: 2,
                       effects: { 'satisfy_bonus' => 0.05, 'appearance' => 4 } }
        },
        decline: { label: 'Leave closed', text: 'Roll the cloth and go', lust: 2,
                   scene: 'You leave. Behind you, something sighs — fond, disappointed — and settles.' },
        fight: { name: 'Risen Wraith', label: 'Swing at the dark', type: :undead,
                 text: 'The nook empties into teeth. Spring does not stay buried!' }
      }
    }.freeze
  end
end
