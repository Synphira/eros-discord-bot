# frozen_string_literal: true

module Engine
  module EventPacks
    # Longest Day (June 20–22). Honey / trackers → titles persist after.
    MIDSUMMER = {
      'solstice_circle' => {
        name: 'Solstice Circle', season: :midsummer, tracker: 'midsummer_events',
        blurb: 'a ring of gold light opens in a hall that should not hold a meadow.',
        intro: 'Daisies and sun-dust mark a perfect circle on stone. Music without musicians. Dancers — some human, ' \
               'some not — already circling. A note in Syn\'s hand: *Step in. Or be the sun. Both burn sweet.*',
        accept: {
          label: 'Step in', text: 'Join the circle and dance the longest day',
          scenes: ['Light on your skin. The circle pulls. Warmth, honey, and Sun Honey foil tip into your palms as the ' \
                   'dance fucks the hallway into a cheer that lasts past dusk.'],
          parts: {
            'vagina' => 'The spin presses a thigh between your legs; fingers find your cunt mid-step.',
            'penis' => 'A dancer drops to swallow you without missing the count.',
            'anus' => 'Gold dust and a greased claim take your ass while the ring watches.',
            'breasts' => 'Daisies and mouths maul your tits; sun-warmth slap your ribs in time.'
          },
          lp: 7, lust: 14,
          midsummer_honey: 2,
          condition: { key: 'sun_kissed', name: 'Sun-Kissed', floors: 2,
                       effects: { 'appearance' => 3, 'submit_lp_bonus' => 1 } }
        },
        alt: {
          label: 'Be the sun', text: 'Stand at the center and let them orbit you',
          scenes: ['Hands bind light around you. Dancers circle. You are the axis — praised, used, crowned in gold — ' \
                   'until honey foil sticks to your palm like a tip.'],
          parts: {
            'vagina' => 'Mouths and warmth take turns at your cunt while the circle never breaks.',
            'penis' => 'They stroke and suck you as the light climbs; climax hits on the turn.',
            'anus' => 'Held open, something thick claims your ass at the center of the dance.',
            'breasts' => 'Sun-dust frames your tits for every dancer\'s mouth.'
          },
          lp: 8, lust: 16,
          midsummer_honey: 1,
          condition: { key: 'solstice_claimed', name: 'Solstice-Claimed', floors: 2,
                       effects: { 'lust_mult' => 1.08, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Watch only', text: 'Refuse the circle', lust: 2,
                   scene: 'You watch. A daisy brushes your wrist anyway — fond, disappointed — then retreats.' },
        fight: { name: 'Solstice Alraune', label: 'Break the circle', type: :plant,
                 text: 'The ring sprouts arms. Midsummer does not do polite declines!' }
      },
      'golden_hour_crowning' => {
        name: 'Golden Hour Crowning', season: :midsummer, tracker: 'midsummer_events',
        blurb: 'a sun halo floats, waiting for a head that will kneel.',
        intro: 'A halo of late light hangs in the air. Something smiles behind it. "Kneel for the hour," they say. ' \
               '"Or crown someone else with your mouth. The longest day is generous."',
        accept: {
          label: 'Kneel', text: 'Accept the halo and what comes with it',
          scenes: ['Gold settles. Warmth floods. Sun Honey materialises at your knees, and the crowner takes their ' \
                   'thanks from wherever you are softest.'],
          lp: 6, lust: 12,
          midsummer_honey: 2,
          condition: { key: 'midsummer_crowned', name: 'Midsummer-Crowned', floors: 3,
                       effects: { 'appearance' => 5, 'satisfy_bonus' => 0.04, 'submit_lp_bonus' => 1 } }
        },
        decline: { label: 'Pass the halo', text: 'Nudge it toward another', lust: 1,
                   scene: 'You pass. The halo dips once toward you, then finds someone hungrier.' },
        fight: { name: 'Midsummer Queen Succubus', label: 'Fight the crowner', type: :demon,
                 text: 'The smile drops into teeth. Halos cut both ways!' }
      },
      'fairy_ring_binding' => {
        name: 'Fairy Ring Binding', season: :midsummer, tag: 'fairy_rings', tracker: 'fairy_ring_events',
        blurb: 'a side hall ringed with mushrooms that move first.',
        intro: 'Mushrooms circle the stone like waiting mouths. They twitch toward your ankles. A dryad-soft voice: ' \
               '"Hold still. Pretty things stay put until dawn fails."',
        accept: {
          label: 'Hold still', text: 'Let the fairy ring bind you',
          scenes: ['Soft stems wind. Tight. Beautiful. The hall uses you until honey foil presses into your bound palm ' \
                   'like a medal for being decorative.'],
          parts: {
            'vagina' => 'The ring spreads your thighs; a vine-cock fills your cunt while you stay pretty.',
            'penis' => 'Soft stems stroke and a mouth milk you without letting your hips buck free.',
            'anus' => 'Wound open, something thick claims your ass; the mushrooms purr.',
            'breasts' => 'Gold dust frames and squeezes your tits for every passing mouth.'
          },
          lp: 7, lust: 18,
          midsummer_honey: 1,
          condition: { key: 'ring_bound', name: 'Ring-Bound', floors: 2,
                       effects: { 'lust_mult' => 1.1, 'submit_lp_bonus' => 2, 'agility' => -1 } }
        },
        decline: { label: 'Step out', text: 'Slap the mushrooms away', lust: 4,
                   scene: 'You slap them. They recoil — offended art — and go still.' },
        fight: { name: 'Solstice Dryad', label: 'Fight the ring', type: :plant,
                 text: 'Mushrooms become arms. Binding was the opening act!' }
      },
      'shortest_night_revel' => {
        name: 'Shortest Night Revel', season: :midsummer, tag: 'fairy_rings', tracker: 'fairy_ring_events',
        blurb: 'a revel that should not fit indoors, leaping for the brief dark.',
        intro: 'Lanterns without oil. Couples leap the thin strip of night. Someone crooks a honey-stained finger. ' \
               '"Jump with me," they say. "Or be the dusk\'s soft landing."',
        accept: {
          label: 'Jump', text: 'Leap the thin night and take the warmth',
          scenes: ['Heat kisses your skin. On the far side: hands, mouths, Sun Honey — the landing is not soft and ' \
                   'you do not mind.'],
          parts: {
            'vagina' => 'You land on a cock that fills you while gold dust and daisies stick to your thighs.',
            'penis' => 'A mouth catches you mid-leap\'s afterglow and swallows you down.',
            'anus' => 'Bent over the warm stone, they claim your ass while the lanterns applaud.',
            'breasts' => 'Honey-warmed hands maul your tits; the leap was only the start.'
          },
          lp: 8, lust: 16,
          midsummer_honey: 2,
          condition: { key: 'dusk_kissed', name: 'Dusk-Kissed', floors: 2,
                       effects: { 'satisfy_bonus' => 0.05, 'appearance' => 4 } }
        },
        decline: { label: 'Stay back', text: 'Refuse the leap', lust: 2,
                   scene: 'You stay. A lantern pops once, fondly disappointed.' },
        fight: { name: 'Midsummer Wolf', label: 'Fight the jumper', type: :beast,
                 text: 'Fur and gold light. Midsummer does not do polite declines!' }
      }
    }.freeze
  end
end
