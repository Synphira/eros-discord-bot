# frozen_string_literal: true

module Engine
  module EventPacks
    # Maypole Raising (May 1–2). Wine / trackers → titles persist after.
    MAY_DAY = {
      'maypole_dance' => {
        name: 'Maypole Dance', season: :may_day, tracker: 'maypole_events',
        blurb: 'a ribboned pole rises in a hall that should not fit a meadow.',
        intro: 'Ribbons stream from a wooden pole planted in stone. Music without musicians. Dancers — some human, ' \
               'some not — already circling. A note in Syn\'s hand: *Pick a ribbon. Or be the pole. Both wind tight.*',
        accept: {
          label: 'Take a ribbon', text: 'Join the circle and dance',
          scenes: ['Ribbon in hand. The circle pulls. Warmth, petals, and May wine foil tip into your palms as the ' \
                   'dance fucks the hallway into a cheer.'],
          parts: {
            'vagina' => 'The spin presses a thigh between your legs; fingers find your cunt mid-step.',
            'penis' => 'A dancer drops to swallow you without missing the count.',
            'anus' => 'Ribbon and a greased claim take your ass while the pole watches.',
            'breasts' => 'Petals and mouths maul your tits; ribbons slap your ribs in time.'
          },
          lp: 7, lust: 14,
          may_day_wine: 2,
          condition: { key: 'ribbon_wound', name: 'Ribbon-Wound', floors: 2,
                       effects: { 'appearance' => 3, 'submit_lp_bonus' => 1 } }
        },
        alt: {
          label: 'Be the pole', text: 'Stand at the center and let them wind you',
          scenes: ['Ribbons bind. Dancers circle. You are the axis — praised, used, crowned in petals — until wine ' \
                   'foil sticks to your palm like a tip.'],
          parts: {
            'vagina' => 'Mouths and ribbons take turns at your cunt while the circle never breaks.',
            'penis' => 'They stroke and suck you as the ribbons climb; climax hits on the turn.',
            'anus' => 'Wound tight, something thick claims your ass at the center of the dance.',
            'breasts' => 'Ribbons frame your tits for every dancer\'s mouth.'
          },
          lp: 8, lust: 16,
          may_day_wine: 1,
          condition: { key: 'pole_claimed', name: 'Pole-Claimed', floors: 2,
                       effects: { 'lust_mult' => 1.08, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Watch only', text: 'Refuse the ribbon', lust: 2,
                   scene: 'You watch. A ribbon brushes your wrist anyway — fond, disappointed — then retreats.' },
        fight: { name: 'Maypole Alraune', label: 'Chop the pole', type: :plant,
                 text: 'The pole sprouts arms. May does not do polite declines!' }
      },
      'may_queen_crowning' => {
        name: 'May Queen Crowning', season: :may_day, tracker: 'maypole_events',
        blurb: 'a flower crown floats, waiting for a head that will kneel.',
        intro: 'A crown of live blooms hangs in the air. Something smiles behind it. "Kneel for the title," they say. ' \
               '"Or crown someone else with your mouth. May is generous."',
        accept: {
          label: 'Kneel', text: 'Accept the crown and what comes with it',
          scenes: ['Blooms settle. Warmth floods. May wine materialises at your knees, and the crowner takes their ' \
                   'thanks from wherever you are softest.'],
          lp: 6, lust: 12,
          may_day_wine: 2,
          condition: { key: 'may_crowned', name: 'May-Crowned', floors: 3,
                       effects: { 'appearance' => 5, 'satisfy_bonus' => 0.04, 'submit_lp_bonus' => 1 } }
        },
        decline: { label: 'Pass the crown', text: 'Nudge it toward another', lust: 1,
                   scene: 'You pass. The crown dips once toward you, then finds someone hungrier.' },
        fight: { name: 'May Queen Succubus', label: 'Fight the crowner', type: :demon,
                 text: 'The smile drops into teeth. Crowns cut both ways!' }
      },
      'ribbon_binding' => {
        name: 'Ribbon Binding', season: :may_day, tag: 'maypole_bind', tracker: 'maypole_bind_events',
        blurb: 'a side hall strung with ribbons that move first.',
        intro: 'Ribbons hang from the ceiling like waiting hands. They twitch toward your wrists. A dryad-soft voice: ' \
               '"Hold still. Pretty things stay put."',
        accept: {
          label: 'Hold still', text: 'Let the ribbons bind you',
          scenes: ['Silk winds. Tight. Beautiful. The hall uses you until wine foil presses into your bound palm ' \
                   'like a medal for being decorative.'],
          parts: {
            'vagina' => 'Ribbons spread your thighs; a vine-cock fills your cunt while you stay pretty.',
            'penis' => 'Silk strokes and a mouth milk you without letting your hips buck free.',
            'anus' => 'Wound open, something thick claims your ass; the ribbons purr.',
            'breasts' => 'Ribbons frame and squeeze your tits for every passing mouth.'
          },
          lp: 7, lust: 18,
          may_day_wine: 1,
          condition: { key: 'pretty_bound', name: 'Pretty-Bound', floors: 2,
                       effects: { 'lust_mult' => 1.1, 'submit_lp_bonus' => 2, 'agility' => -1 } }
        },
        decline: { label: 'Cut free', text: 'Slap the ribbons away', lust: 4,
                   scene: 'You slap them. They recoil — offended art — and go still.' },
        fight: { name: 'Beltane Dryad', label: 'Fight the silk', type: :plant,
                 text: 'Ribbons become arms. Binding was the opening act!' }
      },
      'beltane_bonfire' => {
        name: 'Beltane Bonfire', season: :may_day, tag: 'maypole_bind', tracker: 'maypole_bind_events',
        blurb: 'a fire that should not burn indoors, leaping for jumpers.',
        intro: 'Flames without smoke. Couples leap. Someone crooks a soot-stained finger. "Jump with me," they say. ' \
               '"Or be the fire\'s soft landing."',
        accept: {
          label: 'Jump', text: 'Leap the flames and take the heat',
          scenes: ['Heat kisses your skin. On the far side: hands, mouths, May wine — the landing is not soft and ' \
                   'you do not mind.'],
          parts: {
            'vagina' => 'You land on a cock that fills you while ash and petals stick to your thighs.',
            'penis' => 'A mouth catches you mid-leap\'s afterglow and swallows you down.',
            'anus' => 'Bent over the warm stone, they claim your ass while the fire applauds.',
            'breasts' => 'Soot-warmed hands maul your tits; the leap was only the start.'
          },
          lp: 8, lust: 16,
          may_day_wine: 2,
          condition: { key: 'fire_kissed', name: 'Fire-Kissed', floors: 2,
                       effects: { 'satisfy_bonus' => 0.05, 'appearance' => 4 } }
        },
        decline: { label: 'Stay back', text: 'Refuse the leap', lust: 2,
                   scene: 'You stay. The fire pops once, fondly disappointed.' },
        fight: { name: 'Maypole Wolf', label: 'Fight the jumper', type: :beast,
                 text: 'Fur and flame. Beltane does not do polite declines!' }
      }
    }.freeze
  end
end
