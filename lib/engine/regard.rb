# frozen_string_literal: true

module Engine
  # Clergy regard, made visible. Doctrine forbids contempt for delvers, so
  # the residents *notice* the ones who stand out: the watched, the changed,
  # the regulars, the often-surrendered. Each venue's keeper says so, in
  # their own voice, once the delver has earned it.
  module Regard
    ATTENTION_MARKED = 60
    ATTENTION_NOTICED = 25

    module_function

    # Highest qualifying regard tier for this delver, or nil.
    def tier(player)
      return :marked if Altars.attention(player) >= ATTENTION_MARKED
      return :noticed if Altars.attention(player) >= ATTENTION_NOTICED
      return :changed if TransformationSystem.active(player)
      return :regular if player.tracker('cycles_completed').positive? ||
                         Array(player.tracker_hash['bosses_satisfied_names']).size >= 2
      return :surrendered if player.tracker('climaxes_survived') >= 10
      # Appearance is its own introduction: a depraved-looking delver
      # is, at minimum, noticed by the clergy before a word is spoken.
      return :noticed if Engine::ThreatCalculator.calculate(player).category == :high

      nil
    end

    # How each venue's keeper reacts to the way a delver is dressed,
    # by appearance tier. At :high this replaces the usual recognition
    # line — the look is the loudest thing in the room.
    APPEARANCE_LINES = {
      shop: {
        medium: '_Berry looks up, takes in the outfit in one long professional sweep, and fans herself ' \
                'with the ledger. "Well. Someone dressed to be *negotiated with*. Berry approves, sugar."_',
        high: '_Berry\'s wings forget their rhythm entirely. "Sugar," she says, faint and delighted, ' \
              '"you cannot walk into my tidy shop dressed like a confession and expect me to talk about ' \
              '*prices* first." She talks about prices. Eventually._'
      },
      parlour: {
        medium: '_Syn\'s tired eyes do a slow, appreciative circuit of you. "Careful, pet. Dress like ' \
                'that in my parlour and the ink starts volunteering."_',
        high: '_Syn sets the needle down. That has never happened. "Look at you," she says, low and ' \
              'thoroughly pleased. "My temple\'s favourite sermon, and not a word wasted. Sit, pet. ' \
              'Slowly. Let me appreciate the liturgy."_'
      },
      cursed: {
        medium: '_Covar\'s grin arrives before he does. "Oh, the wardrobe\'s been *consulted*. ' \
                'Vex\'s cutting, if I know ribbon-work. It suits you, delver. It suits you down to the floor."_',
        high: '_Covar comes around the counter for a better look, tail lashing, entirely unprofessional. ' \
              '"Gods below. You are not wearing that, delver — that is wearing *you*, and doing it ' \
              'beautifully. Whatever you came for, the answer is yes."_'
      }
    }.freeze

    def appearance_line(player, context)
      category = Engine::ThreatCalculator.calculate(player).category
      return nil if category == :low

      APPEARANCE_LINES.dig(context.to_sym, category)
    end

    LINES = {
      shop: {
        marked: '_Berry\'s wings slow. "Oh," she breathes. "She\'s been *watching* you. I can always tell. ' \
                'Sit — tell Berry first. Good girl. We\'ll sort the rest."_',
        noticed: '_Berry beams over the ledger. "There\'s my noticed one. She\'s looked your way more than ' \
                 'once. Syn keeps count. I keep *feelings*. Shop first — then gossip."_',
        changed: '_Berry circles you once, delighted. "Look at you. The tower\'s been *working*. Don\'t be ' \
                 'shy — half my regulars started embarrassed. You\'re already prettier for it."_',
        regular: '_Berry waves the ledger like a fan. "My regular. I was just telling Syn — never you mind. ' \
                 'The usual, sugar? Behave and I might praise you for it."_',
        surrendered: '_Berry\'s voice goes soft and proud. "Losing is just praying with worse manners, and ' \
                     'you, sugar, are *devout*. Good girl. Now — what does Berry do for you?"_'
      },
      parlour: {
        marked: '_Syn looks up from the needle and her smirk does something rare: it gentles. "Careful, ' \
                'pet. Keep drawing her eye like that and even *I\'ll* start feeling watched. Sit. Your ' \
                'skin and I have plans."_',
        noticed: '_Syn\'s tired smirk tilts. "Her eye\'s been on you. Don\'t preen — she looks at storms ' \
                 'the same way. All the same. Sit, pet. Let\'s give her something worth the view."_',
        changed: '_Syn walks a slow circle around you, appraising her favourite medium. "The tower ' \
                 'revised you. Good bones to work with before; now?" She taps two fingers over her ' \
                 'needle. "Now you\'re a *commission*."_',
        regular: '_"Back again," Syn says, already uncapping ink. "One of these days I\'m charging you ' \
                 'rent, pet. You practically live in my chair."_',
        surrendered: '_Syn pats the bench with something almost like tenderness. "My favourite kind of ' \
                     'regular. The ones who *yield* prettily. Come here, pet — devotion this consistent ' \
                     'deserves good ink."_'
      },
      cursed: {
        marked: '_Covar\'s tail goes still, then lashes once, delighted. "Oh, she *knows* your name. ' \
                'I can smell it on you — like candle-warmth. Sit close, favourite. The gear behaves ' \
                'better for the watched."_',
        noticed: '_Covar grins over the counter. "She\'s noticed you. Take it from the tower\'s own ' \
                 'success story: noticed is the best thing a delver can be. Short of *kept*."_',
        changed: '_Covar looks you over with professional, covetous joy. "Oh, the tower has been ' \
                 '*generous* with you. Changed suits you, delver. It suited me too, in case the shirt ' \
                 'wasn\'t making the point."_',
        regular: '_"My regular," Covar purrs, leaning on the counter like it\'s a date. "One of these ' \
                 'days I\'m putting your name on a shelf. Right next to mine."_',
        surrendered: '_Covar\'s grin softens into something fond. "You surrender so *sweetly*, delver. ' \
                     'Half the gear in this shop is jealous. Come and tell me everything."_'
      }
    }.freeze

    # One recognition line for a venue (:shop, :parlour, :cursed), or nil.
    # A depraved presentation speaks first; a provocative one speaks
    # when nothing louder has already been earned.
    def line(player, context)
      if Engine::ThreatCalculator.calculate(player).category == :high &&
         (seen = appearance_line(player, context))
        return seen
      end

      t = tier(player)
      return LINES.dig(context.to_sym, t) if t

      appearance_line(player, context)
    end
  end
end
