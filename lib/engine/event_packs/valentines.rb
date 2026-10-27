# frozen_string_literal: true

module Engine
  module EventPacks
    # Heartstring Claim (Feb 12–15). Hearts / trackers → titles persist after.
    VALENTINES = {
      'valentine_door' => {
        name: 'Valentine Door', season: :valentines, tracker: 'valentine_events',
        blurb: 'a door marked with a paper heart waits for a knock.',
        intro: 'A tower door wears a crooked paper heart and a ribbon that looks like Syn\'s humour. From the other ' \
               'side: a giggle, a growl, or both. Someone knocks back first. "Be mine… or be taken."',
        accept: {
          label: 'Be mine', text: 'Ask sweetly and hold out your hands',
          scenes: ['The door opens a crack. Warm fingers tip foil chocolate hearts and a kiss of lust-light into ' \
                   'your palms. "Good valentine," something purrs — whether you are wearing one or not.'],
          lp: 6, lust: 6,
          valentines_hearts: 2
        },
        alt: {
          label: 'Be taken', text: 'Dare them — and take what comes',
          scenes: ['The door swings wide on teeth and rose-smoke. Whatever was waiting wanted a moan more ' \
                   'than a please — and it takes its valentine from your mouth, your hips, your trembling thighs.'],
          parts: {
            'vagina' => 'It fucks you against the jamb while the paper heart watches, cream and foil underfoot.',
            'penis' => 'Painted lips wrap your cock; a claim that milks you dry into a lace bag.',
            'anus' => 'It bends you over the threshold and claims your ass until your knock turns into a moan.',
            'breasts' => 'Melted chocolate smears your tits; it licks every drip with theatrical hunger.'
          },
          lp: 8, lust: 16,
          condition: { key: 'claimed_properly', name: 'Claimed Properly', floors: 2,
                       effects: { 'submit_lp_bonus' => 2, 'appearance' => 3 } },
          valentines_hearts: 1
        },
        decline: { label: 'Walk past', text: 'Leave the door unknocked', lust: 1,
                   scene: 'You pass. Behind you, the paper heart seems briefly disappointed.' },
        fight: { name: 'Heart-Box Chest Mimic', label: 'Kick the door in', type: :mimic,
                 text: 'The jamb sprouts teeth — Valentine furniture, hungry for a claim!' }
      },
      'cupids_alcove' => {
        name: "Cupid's Alcove", season: :valentines, tracker: 'valentine_events',
        blurb: 'an alcove where a drawn bow waits above a pile of roses.',
        intro: 'Roses carpet the stone. A translucent bow hangs in the air, arrow nocked at your chest — or lower. ' \
               'A note in Syn\'s handwriting — or a forgery with excellent taste — reads: *Stand still. Or run. ' \
               'Both get you hit.*',
        accept: {
          label: 'Stand still', text: 'Let the arrow find you',
          scenes: ['The arrow becomes warmth. Heat blooms in your chest — and lower. Chocolate hearts materialise ' \
                   'in a sticky pile at your feet, and the bow winks like it heard every pulse.'],
          lp: 5, lust: 10,
          valentines_hearts: 2,
          condition: { key: 'arrow_marked', name: 'Arrow-Marked', floors: 3,
                       effects: { 'appearance' => 4, 'satisfy_bonus' => 0.04, 'submit_lp_bonus' => 1 } }
        },
        alt: {
          label: 'Run', text: 'Bolt — and get hunted properly',
          scenes: ['You run. The alcove laughs. Something catches you in roses and ribbon and fucks the chase ' \
                   'out of you until the arrow was always a courtesy.'],
          parts: {
            'vagina' => 'Pinned in petals, it fills your cunt until the chase and the climax arrive together.',
            'penis' => 'A rose-sweet mouth swallows you down while the bow watches from above.',
            'anus' => 'Ribbon and a greased claim take your ass; thorns never touch you — the attention does.',
            'breasts' => 'Petals and mouths maul your tits until your breath smells like chocolate.'
          },
          lp: 8, lust: 16,
          valentines_hearts: 1,
          condition: { key: 'hunted_fondly', name: 'Hunted Fondly', floors: 2,
                       effects: { 'lust_mult' => 1.1, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Back away', text: 'Leave the bow unfired', lust: 2,
                   scene: 'You retreat. The arrow dips once, then settles.' },
        fight: { name: 'Cupid Succubus', label: 'Fight the archer', type: :demon,
                 text: 'The bow becomes a grin. Heartstring does not do polite declines!' }
      },
      'broken_heart_nook' => {
        name: 'Broken Heart Nook', season: :valentines, tag: 'heartbreak', tracker: 'heartbreak_events',
        blurb: 'a cold nook where every valentine is already torn.',
        intro: 'Torn paper hearts litter the floor. Something exhales against the back of your neck before you turn. ' \
               'A pale shape — lace, wet eyes, too many apologies — waits in the dark. "Stay," it whispers, ' \
               'almost kindly. "I only break what I keep."',
        accept: {
          label: 'Stay', text: 'Let it keep you and ruin the vow',
          scenes: ['The ache hits like a climax — heart hammering, thighs wet, a moan you did not mean to give. ' \
                   'Cold fingers stroke the places the hurt left soft, rewarding every shiver with chocolate foil.'],
          parts: {
            'vagina' => 'A chill tongue finds your clit while the heartbreak still has you locked open.',
            'penis' => 'Icy fingers milk your cock until the ache and the orgasm arrive together.',
            'anus' => 'Something cold and curious presses into your ass while you are still gasping.',
            'breasts' => 'Frozen mouths seal over your nipples; the hurt and the suck braid into one pulse.'
          },
          lp: 7, lust: 18,
          valentines_hearts: 1,
          condition: { key: 'beautifully_broken', name: 'Beautifully Broken', floors: 2,
                       effects: { 'lust_mult' => 1.1, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Leave', text: 'Refuse the ache', lust: 4,
                   scene: 'You retreat. The nook sighs — a sound with too much lace — and goes still.' },
        fight: { name: 'Heartbroken Banshee', label: 'Swing at the dark', type: :undead,
                 text: 'The lace lunges. Heartstring does not do gentle heartbreak!' }
      },
      'obsession_gallery' => {
        name: 'Obsession Gallery', season: :valentines, tag: 'heartbreak', tracker: 'heartbreak_events',
        blurb: 'a gallery of portraits that all look a little like you.',
        intro: 'Frames line the walls — eyes that follow, mouths that smile a breath late. One portrait crooks a ' \
               'painted finger. "Look closer," it mouths. "I already love you wrong."',
        accept: {
          label: 'Look closer', text: 'Press your face to the paint',
          scenes: ['The portrait grabs you through the varnish — warm, perfect, hungry — and shows you every ' \
                   'claim you have worn this climb. Then it fucks the honesty into you until you cannot tell ' \
                   'which side of the frame you are on.'],
          parts: {
            'vagina' => 'Paint-slick fingers — then a cock that looks like devotion — fill your pussy from the wrong side of the world.',
            'penis' => 'Your own painted mouth swallows you down while your real knees buckle.',
            'anus' => 'The portrait bends you into yourself and takes your ass with relentless, smiling patience.',
            'breasts' => 'It mauls your tits against the cold varnish until your breath fogs both faces.'
          },
          lp: 8, lust: 16,
          valentines_hearts: 1,
          condition: { key: 'obsessed', name: 'Obsessed', floors: 2,
                       effects: { 'satisfy_bonus' => 0.05, 'appearance' => 5 } }
        },
        decline: { label: 'Cover them', text: 'Drape cloth and leave', lust: 2,
                   scene: 'You cover the frames. Under the cloth, something blinks once more, then settles.' },
        fight: { name: 'Your Portrait', label: 'Slash the canvas', type: :mimic,
                 text: 'The paint cracks into a dozen yous — each smiling wrong!' }
      }
    }.freeze
  end
end
