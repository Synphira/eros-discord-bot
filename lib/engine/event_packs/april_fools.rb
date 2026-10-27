# frozen_string_literal: true

module Engine
  module EventPacks
    # Fool's Trap (April 1). Sweets / trackers → titles persist after.
    APRIL_FOOLS = {
      'fake_chest' => {
        name: 'Fake Chest', season: :april_fools, tracker: 'april_prank_events',
        blurb: 'a treasure chest that is trying too hard to look innocent.',
        intro: 'Wood gleam. Gold trim. A lock that clicks open before you touch it. A note in Pip\'s handwriting — ' \
               'or Syn\'s forgery of Pip\'s handwriting — reads: *Definitely not a prank. Open me.*',
        accept: {
          label: 'Open it', text: 'Take the bait',
          scenes: ['Confetti. A whoopee sigh. Warm fingers tip fool\'s sweets and a kiss of lust-light into your ' \
                   'palms anyway. "Gotcha," something giggles — fond, sticky, already reaching for a second bit.'],
          lp: 5, lust: 8,
          april_fools_sweets: 2,
          condition: { key: 'gotcha_marked', name: 'Gotcha-Marked', floors: 2,
                       effects: { 'appearance' => 3, 'submit_lp_bonus' => 1 } }
        },
        alt: {
          label: 'Be the chest', text: 'Climb in and let them spring the joke on you',
          scenes: ['Lid closes. Soft dark. Hands find you laughing — the punchline is your moan — and sweets foil ' \
                   'into your fist when they finally let you out.'],
          parts: {
            'vagina' => 'Fingers fill your cunt in the dark while the lid giggles above.',
            'penis' => 'A mouth swallows you as the chest rocks; confetti sticks to your thighs.',
            'anus' => 'They claim your ass in the cramped joke until the whoopee cushion is redundant.',
            'breasts' => 'Hands maul your tits; the chest applauds with another sigh.'
          },
          lp: 8, lust: 16,
          april_fools_sweets: 1,
          condition: { key: 'punchline', name: 'Punchline', floors: 2,
                       effects: { 'lust_mult' => 1.08, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Walk past', text: 'Refuse the obvious bait', lust: 1,
                   scene: 'You pass. The lock looks personally offended. Somewhere Pip swears.' },
        fight: { name: 'Fake-Treasure Chest Mimic', label: 'Kick the chest', type: :mimic,
                 text: 'Teeth. Confetti. The joke had teeth all along!' }
      },
      'whoopee_hallway' => {
        name: 'Whoopee Hallway', season: :april_fools, tracker: 'april_prank_events',
        blurb: 'a hallway paved with cushions that should not sigh.',
        intro: 'Every step farts silk. Pip\'s handiwork — or a temple that learned from her. At the far end, a ' \
               'masked figure holds a string of fool\'s sweets like a prize. "Cross," they call. "Or crawl. Both are funny."',
        accept: {
          label: 'Cross', text: 'Walk the gauntlet and take the prize',
          scenes: ['Every cushion betrays you. By the time you reach the sweets, you are laughing, wet, and marked. ' \
                   'The prize tastes like sugar and setup.'],
          lp: 6, lust: 12,
          april_fools_sweets: 2,
          condition: { key: 'cushion_kissed', name: 'Cushion-Kissed', floors: 2,
                       effects: { 'appearance' => 2, 'agility' => -1, 'submit_lp_bonus' => 1 } }
        },
        decline: { label: 'Edge along the wall', text: 'Try to avoid every cushion', lust: 3,
                   scene: 'You edge. One cushion still finds your heel. Pip\'s laugh echoes two rooms.' },
        fight: { name: 'Whoopee Pie Clown', label: 'Fight the prize-holder', type: :clown,
                 text: 'The masked figure drops into greasepaint. April does not do polite declines!' }
      },
      'reverse_room' => {
        name: 'Reverse Room', season: :april_fools, tag: 'cruel_pranks', tracker: 'cruel_prank_events',
        blurb: 'a doorway labeled EXIT that leads deeper in.',
        intro: 'The sign says EXIT. The air says lie. Inside, gravity feels optional and every mirror shows you ' \
               'leaving while you are still entering. A voice from everywhere: "Wrong way is the right joke."',
        accept: {
          label: 'Go deeper', text: 'Trust the lie and walk in',
          scenes: ['Up is down. Hands find you from the wrong direction. The room fucks orientation out of you until ' \
                   'sweets foil into your palm like a consolation prize for being brilliantly wrong.'],
          parts: {
            'vagina' => 'Fingers fill you from an angle that should not exist; climax arrives sideways.',
            'penis' => 'A mouth swallows you while the floor is the ceiling; confetti falls up.',
            'anus' => 'Something claims your ass while your reflection leaves without you.',
            'breasts' => 'Mouths latch on; gravity argues; you moan in the wrong direction.'
          },
          lp: 7, lust: 18,
          april_fools_sweets: 1,
          condition: { key: 'turned_around', name: 'Turned Around', floors: 2,
                       effects: { 'lust_mult' => 1.1, 'flee_bonus' => -0.05, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Back out', text: 'Refuse the EXIT that isn\'t', lust: 4,
                   scene: 'You back out. The sign flips to ENTER and looks smug.' },
        fight: { name: 'Your Reflection', label: 'Fight the wrong way', type: :mimic,
                 text: 'Mirrors crack into grinning yous — each already mid-joke!' }
      },
      'pip_masterpiece' => {
        name: "Pip's Masterpiece", season: :april_fools, tag: 'cruel_pranks', tracker: 'cruel_prank_events',
        blurb: 'a trap so ornate it has a dedication plaque.',
        intro: 'Brass plates. Painted arrows. A plaque: *Property of Pip. Rate after screaming.* Syn\'s handwriting ' \
               'is scratched underneath: *I am not fixing this today.* The mechanism purrs.',
        accept: {
          label: 'Trigger it', text: 'Step on the plate like a willing sample',
          scenes: ['The trap hugs. Soft, ridiculous, thorough — Pip\'s best work and the temple\'s worst manners. ' \
                   'Sweets spill into your hands with a card: "10/10 would fool again."'],
          parts: {
            'vagina' => 'Restraints and a buzzing joke fill your cunt until the rating writes itself.',
            'penis' => 'A greased sleeve milks you while bells applaud every pulse.',
            'anus' => 'The plate tips you; something thick claims your ass with carnival patience.',
            'breasts' => 'Suction cups latch onto your tits; the plaque rattles with each moan.'
          },
          lp: 8, lust: 16,
          april_fools_sweets: 2,
          condition: { key: 'catalogue_fooled', name: 'Catalogue-Fooled', floors: 3,
                       effects: { 'trap_avoid_bonus' => -0.08, 'submit_lp_bonus' => 2, 'appearance' => 3 } }
        },
        decline: { label: 'Leave Pip\'s art alone', text: 'Walk around the plaque', lust: 2,
                   scene: 'You leave. The plaque tilts to watch you go. Somewhere a goblin pouts.' },
        fight: { name: 'April Carnival Clown', label: 'Fight the mechanism', type: :clown,
                 text: 'The trap stands up wearing greasepaint. Pip rates the fight too!' }
      }
    }.freeze
  end
end
