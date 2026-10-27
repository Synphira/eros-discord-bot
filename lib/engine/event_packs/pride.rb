# frozen_string_literal: true

module Engine
  module EventPacks
    # Pride Parade (June 25–July 1). Glitter / trackers → titles persist after.
    PRIDE = {
      'pride_float' => {
        name: 'Pride Parade Float', season: :pride, tracker: 'pride_events',
        blurb: 'a float that should not fit the hallway rolls past anyway.',
        intro: 'Music without musicians. Confetti without a ceiling. A float packed with sweaty, glittering bodies ' \
               'creaks down stone that was never meant for wheels. A note in Syn\'s hand: *Climb up. Or be the ' \
               'decoration. Both get glitter.*',
        accept: {
          label: 'Climb aboard', text: 'Join the float and ride',
          scenes: ['Hands pull you up. Warmth, beads, and mouths find you mid-cheer — foil Pride glitter tips into ' \
                   'your palms as the float fucks the hallway into a parade.'],
          parts: {
            'vagina' => 'A rider drops between your thighs; fingers and tongue take your cunt to the beat.',
            'penis' => 'Someone swallows you without missing a wave to the empty corridor.',
            'anus' => 'Bent over the float rail, something thick claims your ass while flags slap your back.',
            'breasts' => 'Beads and mouths maul your tits; glitter sticks to every wet place.'
          },
          lp: 7, lust: 14,
          pride_glitter: 2,
          condition: { key: 'float_ridden', name: 'Float-Ridden', floors: 2,
                       effects: { 'appearance' => 3, 'submit_lp_bonus' => 1 } }
        },
        alt: {
          label: 'Be the decoration', text: 'Let them drape and display you',
          scenes: ['Flags bind. Bodies cheer. You are the centrepiece — praised, used, dusted in glitter — until foil ' \
                   'sweets stick to your palm like a tip.'],
          parts: {
            'vagina' => 'Mouths take turns at your cunt while the float never slows.',
            'penis' => 'They stroke and suck you as beads climb; climax hits on the cheer.',
            'anus' => 'Draped open, something thick claims your ass at the heart of the parade.',
            'breasts' => 'Flags frame your tits for every passing mouth.'
          },
          lp: 8, lust: 16,
          pride_glitter: 1,
          condition: { key: 'parade_display', name: 'Parade Display', floors: 2,
                       effects: { 'lust_mult' => 1.08, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Wave from the curb', text: 'Refuse the float', lust: 2,
                   scene: 'You wave. A bead strand brushes your wrist anyway — fond, disappointed — then retreats.' },
        fight: { name: 'Rainbow Gelatinous Mass', label: 'Tip the float', type: :slime,
                 text: 'The float sprouts colourful arms. Pride does not do polite declines!' }
      },
      'found_family_toast' => {
        name: 'Found-Family Toast', season: :pride, tracker: 'pride_events',
        blurb: 'a circle of strangers raises cups that were never poured.',
        intro: 'Warm light. Cups that fill themselves with something sweet and filthy. Someone grins like they already ' \
               'know your name. "Toast with us," they say. "Or be the toast. Found family is generous."',
        accept: {
          label: 'Raise a cup', text: 'Toast and take what comes with belonging',
          scenes: ['Cups clink. Warmth floods. Pride glitter materialises at your knees, and the circle takes their ' \
                   'thanks from wherever you are softest.'],
          lp: 6, lust: 12,
          pride_glitter: 2,
          condition: { key: 'family_toasted', name: 'Family-Toasted', floors: 3,
                       effects: { 'appearance' => 5, 'satisfy_bonus' => 0.04, 'submit_lp_bonus' => 1 } }
        },
        decline: { label: 'Pass the cup', text: 'Nudge it toward another', lust: 1,
                   scene: 'You pass. The circle dips once toward you, then finds someone hungrier.' },
        fight: { name: 'Pride Succubus', label: 'Fight the toastmaster', type: :demon,
                 text: 'The grin drops into teeth. Toasts cut both ways!' }
      },
      'glitter_body_paint' => {
        name: 'Glitter Body Paint', season: :pride, tag: 'pride_excess', tracker: 'pride_excess_events',
        blurb: 'a side hall where brushes move first and clothes are optional.',
        intro: 'Brushes hang in the air like waiting hands. Foil glitter drifts. A voice soft as silk: "Hold still. ' \
               'Pretty things get painted until they shine."',
        accept: {
          label: 'Hold still', text: 'Let them paint every inch',
          scenes: ['Colour winds. Tight. Beautiful. The hall uses you until Pride glitter foil presses into your ' \
                   'painted palm like a medal for being decorative.'],
          parts: {
            'vagina' => 'Brushes spread your thighs; a cock fills your cunt while glitter seals the claim.',
            'penis' => 'Paint strokes and a mouth milk you without letting your hips buck free.',
            'anus' => 'Painted open, something thick claims your ass; the brushes purr.',
            'breasts' => 'Brushes frame and squeeze your tits for every colour of mouth.'
          },
          lp: 7, lust: 18,
          pride_glitter: 1,
          condition: { key: 'glitter_painted', name: 'Glitter-Painted', floors: 2,
                       effects: { 'lust_mult' => 1.1, 'submit_lp_bonus' => 2, 'agility' => -1 } }
        },
        decline: { label: 'Slap the brush', text: 'Refuse the paint', lust: 4,
                   scene: 'You slap them. They recoil — offended art — and go still.' },
        fight: { name: 'Rainbow Demoness', label: 'Fight the painters', type: :demon,
                 text: 'Brushes become claws. Painting was the opening act!' }
      },
      'parade_afterparty' => {
        name: 'Parade Afterparty', season: :pride, tag: 'pride_excess', tracker: 'pride_excess_events',
        blurb: 'a door marked PRIVATE that never stays closed during Pride.',
        intro: 'Bass without speakers. Bodies without shame. Someone crooks a glitter-stained finger. "Come in," ' \
               'they say. "Or be the soft landing when the float empties."',
        accept: {
          label: 'Go in', text: 'Join the afterparty mess',
          scenes: ['Heat kisses your skin. Inside: hands, mouths, Pride glitter — the landing is not soft and you ' \
                   'do not mind.'],
          parts: {
            'vagina' => 'You land on a cock that fills you while beads and glitter stick to your thighs.',
            'penis' => 'A mouth catches you mid-cheer\'s afterglow and swallows you down.',
            'anus' => 'Bent over warm stone, they claim your ass while the bass applauds.',
            'breasts' => 'Glitter-warmed hands maul your tits; the float was only the start.'
          },
          lp: 8, lust: 16,
          pride_glitter: 2,
          condition: { key: 'afterparty_spent', name: 'Afterparty-Spent', floors: 2,
                       effects: { 'satisfy_bonus' => 0.05, 'appearance' => 4 } }
        },
        decline: { label: 'Stay out', text: 'Refuse the private door', lust: 2,
                   scene: 'You stay. The door pops once, fondly disappointed.' },
        fight: { name: 'Pride Wolf', label: 'Fight the greeter', type: :beast,
                 text: 'Fur and glitter. Pride does not do polite declines!' }
      }
    }.freeze
  end
end
