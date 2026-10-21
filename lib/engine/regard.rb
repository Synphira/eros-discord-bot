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

      nil
    end

    LINES = {
      shop: {
        marked: '_Berry\'s wings slow mid-flutter. "Oh," she breathes, freckles standing out. "Oh, sugar. ' \
                'She\'s been *watching* you, hasn\'t she. I can always tell. Sit — whatever you need, you ' \
                'tell Berry first."_',
        noticed: '_Berry beams over the ledger. "There\'s my noticed one! She\'s looked your way more ' \
                 'than once, you know. I keep count. Well — Syn keeps count. I keep *feelings*."_',
        changed: '_Berry circles you once, delighted, hands clasped. "Look at you! The tower\'s been ' \
                 '*working* on you. Oh, don\'t be shy — half my regulars started out embarrassed too."_',
        regular: '_Berry waves the ledger like a fan. "My regular! I was just telling Syn — well. Never ' \
                 'you mind what I was telling Syn. The usual, sugar?"_',
        surrendered: '_Berry\'s voice goes soft and proud. "You know what I told Syn? Losing is just the ' \
                     'local way of praying, and you, sugar, are *devout*. Now. What can Berry do for you?"_'
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
    def line(player, context)
      t = tier(player)
      return nil unless t

      LINES.dig(context.to_sym, t)
    end
  end
end
