# frozen_string_literal: true

module Engine
  module EventPacks
    # Carnival of Beads (Sat–Fat Tuesday). Cake / trackers → titles persist after.
    MARDI_GRAS = {
      'bead_toss' => {
        name: 'Bead Toss', season: :mardi_gras, tracker: 'carnival_events',
        blurb: 'a balcony rains purple-gold-green beads into the hall.',
        intro: 'Beads clatter on stone. Someone on a balcony — mask, smirk, too many strings — holds a throw like a ' \
               'dare. "Show me something," they call. "Or take what falls either way."',
        accept: {
          label: 'Flash', text: 'Give them a show and catch what comes',
          scenes: ['You flash. Beads rain. Warm fingers tip king-cake foil and a kiss of lust-light into your palms. ' \
                   '"Good parade," something purrs — whether you are wearing a mask or not.'],
          parts: {
            'vagina' => 'Beads kiss your thighs while a mouth finds your cunt under the balcony\'s cheer.',
            'penis' => 'A masked mouth swallows you as beads pour; the float above applauds.',
            'anus' => 'They bend you into the cheer and claim your ass while beads pool at your feet.',
            'breasts' => 'Beads slap your tits; tongues chase every bounce with carnival hunger.'
          },
          lp: 7, lust: 14,
          mardi_gras_cake: 2,
          condition: { key: 'bead_blessed', name: 'Bead-Blessed', floors: 2,
                       effects: { 'appearance' => 4, 'submit_lp_bonus' => 1 } }
        },
        decline: { label: 'Catch only', text: 'Keep your clothes; take what drops', lust: 2,
                   scene: 'You catch a string. The balcony laughs — fond, disappointed — and throws one more anyway.' },
        fight: { name: 'Parade Incubus', label: 'Climb the balcony', type: :demon,
                 text: 'The thrower drops into the hall with teeth. Carnival does not do polite declines!' }
      },
      'king_cake_table' => {
        name: 'King Cake Table', season: :mardi_gras, tracker: 'carnival_events',
        blurb: 'a table of sugar-purple cake waits with a plastic baby somewhere inside.',
        intro: 'King cake coils on a sideboard, sugar in carnival colours. A note in Syn\'s handwriting — or a forgery ' \
               'with excellent taste — reads: *Find the baby. Or be the baby. Both throw the next party.*',
        accept: {
          label: 'Take a slice', text: 'Eat carefully and hope',
          scenes: ['Sugar melts. Warmth floods. Foil cake wraps itself into your tin, and something hard clicks ' \
                   'against your tooth — luck, or a claim. The table laughs either way.'],
          lp: 5, lust: 8,
          mardi_gras_cake: 2,
          condition: { key: 'sugar_crowned', name: 'Sugar-Crowned', floors: 3,
                       effects: { 'appearance' => 3, 'satisfy_bonus' => 0.03, 'submit_lp_bonus' => 1 } }
        },
        alt: {
          label: 'Be the baby', text: 'Lie on the table and let them find you',
          scenes: ['Sugar and hands — they frost praise into your skin until you tremble like something ready for ' \
                   'the next throw. Cake for later. Less dignity for now.'],
          parts: {
            'vagina' => 'Sugar-slick fingers fill your cunt while the table cheers the find.',
            'penis' => 'They frost and stroke your cock until come blots the purple sugar.',
            'anus' => 'A greased claim takes your ass; the plastic baby never mattered — you did.',
            'breasts' => 'Sugar poured over your tits, licked clean by whoever found the prize.'
          },
          lp: 8, lust: 16,
          mardi_gras_cake: 1,
          condition: { key: 'found_properly', name: 'Found Properly', floors: 2,
                       effects: { 'lust_mult' => 1.08, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Walk on', text: 'Leave the cake for hungrier revelers', lust: 1,
                   scene: 'You leave. The sugar sighs. Syn would call that rude.' },
        fight: { name: 'King-Cake Chest Mimic', label: 'Smash the cake', type: :mimic,
                 text: 'Sugar sprouts teeth. Carnival furniture wants a course named you!' }
      },
      'float_alcove' => {
        name: 'Float Alcove', season: :mardi_gras, tag: 'parade_filth', tracker: 'parade_filth_events',
        blurb: 'a jammed float blocks the hall, dancers still moving.',
        intro: 'Papier-mâché and sweat. A carnival float is wedged in the corridor, dancers grinding to music that ' \
               'should not fit in stone. A masked krewe captain crooks a finger. "Ride," they say. "Or get ridden. ' \
               'The parade does not stop."',
        accept: {
          label: 'Ride', text: 'Climb on and join the grind',
          scenes: ['You mount the float. Hands, beads, mouths — the parade fucks the hallway into a cheer until ' \
                   'king cake foil sticks to your palm like a tip.'],
          parts: {
            'vagina' => 'Someone fills your cunt while the float rocks; beads slap your thighs in time.',
            'penis' => 'A dancer swallows you down between cheers until climax and the brass hit together.',
            'anus' => 'Bent over the rail, they claim your ass while the krewe applauds.',
            'breasts' => 'Bead-strings and mouths maul your tits until your breath tastes like sugar.'
          },
          lp: 7, lust: 18,
          mardi_gras_cake: 1,
          condition: { key: 'float_ridden', name: 'Float-Ridden', floors: 2,
                       effects: { 'lust_mult' => 1.1, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Squeeze past', text: 'Refuse the ride', lust: 4,
                   scene: 'You squeeze by. The captain pouts behind the mask. The float somehow follows two rooms.' },
        fight: { name: 'Rex Carnival Clown', label: 'Fight the krewe', type: :clown,
                 text: 'The float lunges. Carnival does not do gentle declines!' }
      },
      'unmasking_chamber' => {
        name: 'Unmasking Chamber', season: :mardi_gras, tag: 'parade_filth', tracker: 'parade_filth_events',
        blurb: 'a velvet room where every mask wants off — yours or theirs.',
        intro: 'Velvet walls. A dozen masks hang on hooks, each smiling wrong. One lifts itself toward your face. ' \
               '"Wear me," it whispers. "Or take someone else\'s off with your teeth."',
        accept: {
          label: 'Wear it', text: 'Let the mask claim your face',
          scenes: ['The mask seals warm. Heat blooms — identity soft, thighs wet, a moan that is not only yours. ' \
                   'Cake foil presses into your palm when it finally lets you breathe.'],
          parts: {
            'vagina' => 'Blind behind the mask, fingers find your cunt until you come for a face that is not yours.',
            'penis' => 'The mask\'s smile wraps your cock; climax arrives without your name attached.',
            'anus' => 'Something claims your ass while the mask drinks every gasp as its own.',
            'breasts' => 'Hands that are not yours maul your tits; the mask purrs approval.'
          },
          lp: 8, lust: 16,
          mardi_gras_cake: 2,
          condition: { key: 'mask_bound', name: 'Mask-Bound', floors: 2,
                       effects: { 'satisfy_bonus' => 0.05, 'appearance' => 5 } }
        },
        decline: { label: 'Leave masked', text: 'Keep your own face', lust: 2,
                   scene: 'You back out. The hooks rattle once, then settle.' },
        fight: { name: 'Masked Succubus', label: 'Tear the velvet', type: :demon,
                 text: 'The masks drop into a body. Unmasking cuts both ways!' }
      }
    }.freeze
  end
end
