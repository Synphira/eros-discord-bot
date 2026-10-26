# frozen_string_literal: true

module Engine
  module EventPacks
    # Seasonal All Hallows' events. `season: :halloween` gates them to the
    # Oct 30–Nov 5 window; rewards (trackers → titles, candy) persist after.
    HALLOWEEN = {
      'trick_or_treat' => {
        name: 'Trick or Treat', season: :halloween, tracker: 'trick_or_treat_events',
        blurb: 'a door marked with a pumpkin grin waits for a knock.',
        intro: 'A tower door has been decorated — badly — with a carved pumpkin and a scrap of lace. ' \
               'From the other side: a giggle, a growl, or both. Someone knocks back first. "Trick… or treat?"',
        accept: {
          label: 'Treat', text: 'Ask sweetly and hold out your hands',
          scenes: ['The door opens a crack. Warm fingers tip foil-wrapped candy and a kiss of lust-light into ' \
                   'your palms. "Good costume," something purrs — whether you are wearing one or not.'],
          lp: 6, lust: 4,
          candy: 2
        },
        alt: {
          label: 'Trick', text: 'Dare them — and take what comes',
          scenes: ['The door swings wide on teeth and candle-smoke. Whatever was waiting wanted a scream more ' \
                   'than a please — and it takes its treat from your mouth, your hips, your trembling thighs.'],
          parts: {
            'vagina' => 'It fucks you against the jamb while the pumpkin\'s grin watches, cream and candy wrappers underfoot.',
            'penis' => 'Painted lips wrap your cock; a "trick" that milks you dry into a paper bag.',
            'anus' => 'It bends you over the threshold and claims your ass until your knock turns into a moan.',
            'breasts' => 'Sticky caramel smears your tits; it licks every drip with theatrical hunger.'
          },
          lp: 8, lust: 16,
          condition: { key: 'tricked_properly', name: 'Tricked Properly', floors: 2,
                       effects: { 'submit_lp_bonus' => 2, 'appearance' => 3 } },
          candy: 1
        },
        decline: { label: 'Walk past', text: 'Leave the door unknocked', lust: 1,
                   scene: 'You pass. Behind you, the pumpkin\'s smile seems briefly disappointed.' },
        fight: { name: 'Door Mimic', label: 'Kick the door in', type: :mimic,
                 text: 'The jamb sprouts teeth — All Hallows furniture, hungry for costume night!' }
      },
      'jack_o_lantern_shrine' => {
        name: 'Jack-o\'-Lantern Shrine', season: :halloween, tracker: 'trick_or_treat_events',
        blurb: 'a hollowed pumpkin glows with an indecent little flame.',
        intro: 'A jack-o\'-lantern sits on a low plinth, candle flickering behind a lewd carved grin. A note ' \
               'in Syn\'s handwriting — or a forgery with excellent taste — reads: *Light me. Or smash me. ' \
               'Both are worship.*',
        accept: {
          label: 'Light it', text: 'Cup the flame and say something filthy',
          scenes: ['The grin brightens. Warmth floods your cheeks — and lower. Candy materialises in a sticky ' \
                   'pile at your feet, and the candle winks like it heard every word.'],
          lp: 5, lust: 8,
          candy: 2,
          condition: { key: 'pumpkin_glow', name: 'Pumpkin Glow', floors: 3,
                       effects: { 'appearance' => 4, 'submit_lp_bonus' => 1 } }
        },
        alt: {
          label: 'Smash it', text: 'Boot the pumpkin — and face what spills out',
          scenes: ['Orange pulp and candle-wax explode. Something wet and laughing unfolds from the mess, ' \
                   'already reaching for your costume and the skin underneath.'],
          lp: 4, lust: 10,
          candy: 1
        },
        decline: { label: 'Leave it', text: 'Let the candle burn alone', lust: 1,
                   scene: 'You leave. The grin follows you two rooms longer than it should.' },
        fight: { name: 'Pumpkin Wraith', label: 'Fight the pulp', type: :undead,
                 text: 'Wax and rind knit into a grinning wraith. Treat time is over!' }
      },
      'haunted_alcove' => {
        name: 'Haunted Alcove', season: :halloween, tag: 'halloween_scares', tracker: 'halloween_scare_events',
        blurb: 'a cold alcove where the shadows move first.',
        intro: 'The alcove is colder than the hall. Something exhales against the back of your neck before you ' \
               'turn. A pale shape — veil, grin, too many joints — waits in the dark. "Boo," it whispers, ' \
               'almost kindly.',
        accept: {
          label: 'Let it scare you', text: 'Freeze, gasp, and take the fright',
          scenes: ['The fright hits like a climax — heart hammering, thighs wet, a moan you did not mean to ' \
                   'give. Cold fingers stroke the places the scream left soft, rewarding every shiver.'],
          parts: {
            'vagina' => 'A chill tongue finds your clit while the fear still has you locked open.',
            'penis' => 'Icy fingers milk your cock until the scare and the orgasm arrive together.',
            'anus' => 'Something cold and curious presses into your ass while you are still gasping.',
            'breasts' => 'Frozen mouths seal over your nipples; the fright and the suck braid into one pulse.'
          },
          lp: 7, lust: 18,
          condition: { key: 'still_shaking', name: 'Still Shaking', floors: 2,
                       effects: { 'lust_mult' => 1.1, 'submit_lp_bonus' => 2 } }
        },
        decline: { label: 'Back away', text: 'Refuse the scare', lust: 4,
                   scene: 'You retreat. The alcove giggles — a sound with too many teeth — and goes still.' },
        fight: { name: 'Pale Bride Echo', label: 'Swing at the dark', type: :undead,
                 text: 'The veil lunges. All Hallows does not do gentle jump-scares!' }
      },
      'mirror_that_blinks' => {
        name: 'The Mirror That Blinks', season: :halloween, tag: 'halloween_scares', tracker: 'halloween_scare_events',
        blurb: 'a tall mirror whose reflection is half a breath behind.',
        intro: 'Your reflection smiles a moment after you do — then stops smiling while you still are. It crooks ' \
               'a finger. The glass ripples like water. "Come look closer," it mouths. "I dare you."',
        accept: {
          label: 'Look closer', text: 'Press your face to the glass',
          scenes: ['The reflection grabs you through the surface — cold, perfect, hungry — and shows you every ' \
                   'mask you have worn this climb. Then it fucks the honesty into you until you cannot tell ' \
                   'which side of the glass you are on.'],
          parts: {
            'vagina' => 'Glass-slick fingers — then a cock that looks like yours — fill your pussy from the wrong side of the world.',
            'penis' => 'Your own mirrored mouth swallows you down while your real knees buckle.',
            'anus' => 'The reflection bends you into yourself and takes your ass with relentless, smiling patience.',
            'breasts' => 'It mauls your tits against the cold glass until your breath fogs both faces.'
          },
          lp: 8, lust: 16,
          condition: { key: 'mirror_fright', name: 'Mirror Fright', floors: 2,
                       effects: { 'satisfy_bonus' => 0.05, 'appearance' => 5 } }
        },
        decline: { label: 'Cover it', text: 'Drape a cloth and leave', lust: 2,
                   scene: 'You cover the glass. Under the cloth, something blinks once more, then settles.' },
        fight: { name: 'Your Reflection', label: 'Shatter it', type: :mimic,
                 text: 'The glass cracks into a dozen yous — each smiling wrong!' }
      }
    }.freeze
  end
end
