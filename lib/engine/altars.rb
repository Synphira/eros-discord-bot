# frozen_string_literal: true

module Engine
  # Altars of Eros, and the goddess's Attention. Devotion — satisfying the
  # tower's creatures, kneeling at her altars, wearing Syn's marks — draws
  # Eros's eye. When her Attention fills, she visits: a gift, a favour, or
  # a mercy, delivered personally.
  module Altars
    ATTENTION_TRACKER = 'eros_attention'
    MAX_ATTENTION = 100
    VISIT_KEEP = 25
    TITHE_COST = 25

    BLESSING = { key: 'eros_favour', name: "Eros's Favour", floors: 4,
                 effects: { 'satisfy_bonus' => 0.08, 'submit_lp_bonus' => 2 },
                 summary: 'The goddess is watching you with approval' }.freeze

    module_function

    def attention(player)
      player.tracker(ATTENTION_TRACKER)
    end

    def gain_attention!(player, amount, log = nil)
      total = attention(player) + amount.to_i
      if total >= MAX_ATTENTION
        player.set_tracker!(ATTENTION_TRACKER, VISIT_KEEP)
        visit!(player, log) if log
      else
        player.set_tracker!(ATTENTION_TRACKER, total)
      end
      attention(player)
    end

    # Her arrivals rotate: a goddess who always enters the same way
    # becomes furniture. One variant is reserved for the corrupted —
    # she notices what the tower is finishing in them.
    VISIT_PROSE = {
      lp: [
        'A white tentacle curls down from the dark, crimson suckers kissing your cheek, and drops a ' \
        'pouch of lust-light into your hands before withdrawing.',
        'Every candle in the room bows toward the same empty corner at once. When the flames straighten, ' \
        'a pouch of lust-light sits at your feet, still warm, and the corner is just a corner again.'
      ],
      favour: [
        'Warmth pours over you as invisible hands — and one very visible tentacle — straighten your ' \
        'clothes, stroke your hair, and send you on glowing.',
        'Her attention runs over you like a tailor\'s hands over good cloth — smoothing, approving, ' \
        'lingering at the seams. You leave wearing the day better than you arrived in it.'
      ],
      purge: [
        '"This one doesn\'t suit you, pet." A tentacle plucks the **%<name>s** curse off you like a ' \
        'thread from a dress, and it dissolves into rose smoke.',
        'A sucker seals over the brand of the **%<name>s** and simply drinks it out of your skin, ' \
        'unhurried and obscene, until nothing is left but a kiss-shaped mark that fades by the next room.'
      ],
      heal: [
        'Her hands cup your face and her red eyes soften — just slightly. "Rest, pet. You please me."',
        'You do not see her arrive; you only notice that you are sitting, that your shoulders have come ' \
        'down, and that a white tentacle is stroking your hair with infinite, proprietorial patience.'
      ]
    }.freeze

    CORRUPT_VISIT_PROSE = 'The air smells of roses left somewhere warm. Her interest, when it lands on ' \
                          'the corrupted, is not the fondness she shows the clean — it is the attention ' \
                          'of a collector recognising her own later work. "Look at you," Eros murmurs, ' \
                          'from everywhere at once. "The tower is finishing what I start, pet."'

    def visit!(player, log)
      visits = player.tracker('eros_visits') + 1
      player.set_tracker!('eros_visits', visits)
      if visits > 1
        log << "_She comes the way weather returns to a favourite field — without announcement and " \
               "entirely on purpose. Visit **#{visits}**, pet. She is keeping count too._"
      end
      if Engine::Corruption.level(player) >= 50 && rand < 0.5
        log << "🌹 **Eros visits.** #{CORRUPT_VISIT_PROSE}"
      end
      case rand(3)
      when 0
        player.gain_lp!(40)
        log << "🌹 **Eros visits.** #{VISIT_PROSE[:lp].sample} **+40 LP** " \
               '"For being such a good pet," a voice purrs from everywhere.'
      when 1
        Engine::FetishEvents.apply_condition!(player, BLESSING, log)
        log << "🌹 **Eros visits.** #{VISIT_PROSE[:favour].sample} **Eros's Favour** settles on you."
      else
        curse = player.active_curses.sample
        if curse
          player.drop_curse!(curse.name)
          log << "🌹 **Eros visits.** #{format(VISIT_PROSE[:purge].sample, name: curse.name)} " \
                 '**Curse purged, free.**'
        else
          gained = player.heal_defiance!(30)
          log << "🌹 **Eros visits.** #{VISIT_PROSE[:heal].sample} **+#{gained} Defiance**."
        end
      end
    end

    def present!(player)
      level = [player.current_floor, 1].max
      dress = altar_dress
      name = dress[:name]
      player.store_event!(type: 'altar', level: level, mode: 'choice', name: name)
      log = ["**Floor #{level}** — #{dress[:floor_line]}.",
             { scene: dress[:scene].sub('ATTN', "#{attention(player)}/#{MAX_ATTENTION}") }]
      if attention(player) >= 60
        log << '_The candles were already lit — all of them, flames leaning toward you like faces. ' \
               'She was watching this altar before you found it. She was watching **you**._'
      elsif attention(player) >= 25
        log << '_One candle lights a breath before the others. Noticed, then. Not yet known._'
      end
      log << 'What do you offer your goddess?'
      { ok: true, mode: :choice, name: name, colour: dress[:colour], log: log,
        choices: choices(player) }
    end

    def altar_dress
      if Engine::Halloween.pumpkin_altar?
        {
          key: :pumpkin,
          name: 'Pumpkin Altar of Eros',
          colour: 0xb85c1a,
          floor_line: 'pumpkin candlelight in the dark',
          scene: 'An altar of white stone dressed for All Hallows — orange silk, a hollowed pumpkin for an offering ' \
                 'bowl, candlelight grinning through carved teeth. Stone tentacles curl around the rind like they ' \
                 'have always belonged there. Her Attention rests on you at **ATTN**.'
        }
      elsif Engine::Thanksgiving.feast_altar?
        {
          key: :feast,
          name: 'Feast Altar of Eros',
          colour: 0xb8860b,
          floor_line: 'butter-candle light and the smell of gravy',
          scene: 'An altar of white stone dressed for the feast — cream silk, a gravy boat for an offering bowl, ' \
                 'wheat and late roses tucked into the tentacles\' curls. Her Attention rests on you at **ATTN**.'
        }
      elsif Engine::Christmas.yule_altar?
        {
          key: :yule,
          name: 'Yule Altar of Eros',
          colour: 0x8b0000,
          floor_line: 'pine-candle light and the smell of peppermint',
          scene: 'An altar of white stone dressed for Yule — scarlet ribbon, a hollowed stocking for an offering ' \
                 'bowl, mistletoe tucked into the tentacles\' curls. Her Attention rests on you at **ATTN**.'
        }
      elsif Engine::NewYear.midnight_altar?
        {
          key: :midnight,
          name: 'Midnight Altar of Eros',
          colour: 0x1a1a4a,
          floor_line: 'countdown candlelight and the smell of citrus fizz',
          scene: 'An altar of white stone dressed for midnight — black lace, a champagne flute for an offering ' \
                 'bowl, glitter caught in the tentacles\' curls. Her Attention rests on you at **ATTN**.'
        }
      elsif Engine::Valentines.heart_altar?
        {
          key: :heart,
          name: 'Heartstring Altar of Eros',
          colour: 0xc2185b,
          floor_line: 'rose-candle light and the smell of chocolate',
          scene: 'An altar of white stone dressed for Heartstring — crimson silk, a chocolate-heart dish for an ' \
                 'offering bowl, roses tucked into the tentacles\' curls. Her Attention rests on you at **ATTN**.'
        }
      elsif Engine::MardiGras.carnival_altar?
        {
          key: :carnival,
          name: 'Carnival Altar of Eros',
          colour: 0x6b2d8b,
          floor_line: 'parade candlelight and the smell of sugar',
          scene: 'An altar of white stone dressed for Carnival — purple-gold-green silk, a king-cake plate for an ' \
                 'offering bowl, beads caught in the tentacles\' curls. Her Attention rests on you at **ATTN**.'
        }
      elsif Engine::Easter.hare_altar?
        {
          key: :hare,
          name: "Hare's Altar of Eros",
          colour: 0xc4a35a,
          floor_line: 'lily-candle light and the smell of chocolate',
          scene: 'An altar of white stone dressed for Hare\'s Hunt — pastel silk, an egg basket for an offering ' \
                 'bowl, lilies tucked into the tentacles\' curls. Her Attention rests on you at **ATTN**.'
        }
      elsif Engine::AprilFools.fool_altar?
        {
          key: :fool,
          name: "Fool's Altar of Eros",
          colour: 0xe67e22,
          floor_line: 'whoopee candlelight and the smell of sugar',
          scene: 'An altar of white stone dressed for Fool\'s Trap — motley silk, a whoopee cushion for an offering ' \
                 'bowl, bells caught in the tentacles\' curls. Her Attention rests on you at **ATTN**.'
        }
      elsif Engine::MayDay.may_altar?
        {
          key: :may,
          name: 'Maypole Altar of Eros',
          colour: 0x2e7d32,
          floor_line: 'petal candlelight and the smell of May wine',
          scene: 'An altar of white stone dressed for Maypole — blossom silk, a ribboned cup for an offering bowl, ' \
                 'fresh blooms tucked into the tentacles\' curls. Her Attention rests on you at **ATTN**.'
        }
      elsif Engine::Midsummer.midsummer_altar?
        {
          key: :solstice,
          name: 'Solstice Altar of Eros',
          colour: 0xf1c40f,
          floor_line: 'honey-gold candlelight and the smell of sun',
          scene: 'An altar of white stone dressed for Longest Day — gold silk, a honey cup for an offering bowl, ' \
                 'sun petals tucked into the tentacles\' curls. Her Attention rests on you at **ATTN**.'
        }
      elsif Engine::Pride.pride_altar?
        {
          key: :pride,
          name: 'Pride Altar of Eros',
          colour: 0xe91e63,
          floor_line: 'glitter candlelight and the smell of sugar and parade',
          scene: 'An altar of white stone dressed for Pride Parade — rainbow silk, a glitter dish for an offering ' \
                 'bowl, foil flags caught in the tentacles\' curls. Her Attention rests on you at **ATTN**.'
        }
      else
        {
          key: :plain,
          name: 'Altar of Eros',
          colour: 0x5c0a2e,
          floor_line: 'candlelight in the dark',
          scene: 'An altar of white stone and dark red silk, carved with a towering, horned goddess whose ' \
                 'stone tentacles curl around the offering bowl. The candles light themselves as you ' \
                 'approach. Her Attention rests on you at **ATTN**.'
        }
      end
    end
    module_function :altar_dress

    def choices(_player)
      [
        { key: 'pray', label: 'Pray', text: 'Kneel and pray (a little of her Attention, a little Defiance back)', style: :primary },
        { key: 'tithe', label: "Tithe #{TITHE_COST} LP", text: 'Offer Lust Points for her Favour blessing (and some of her Attention)', style: :success },
        { key: 'kneel', label: 'Kneel and offer yourself', text: 'Offer your body to the altar (+25 Lust, the most of her Attention)', style: :danger },
        { key: 'leave', label: 'Leave', text: 'Back away respectfully', style: :secondary }
      ]
    end

    def resolve!(player, choice, log)
      dress = altar_dress
      case choice.to_s
      when 'pray'
        log << case dress[:key]
               when :pumpkin
                 'You kneel before the pumpkin altar and pray — honestly, filthily — while the carved grin ' \
                 'flickers in time with your pulse.'
               when :feast
                 'You kneel before the feast altar and pray — honestly, filthily — while gravy steam curls ' \
                 'around the wheat like incense with better manners.'
               when :yule
                 'You kneel before the Yule altar and pray — honestly, filthily — while mistletoe shadows rock ' \
                 'against the ribbon like a dare.'
               when :midnight
                 'You kneel before the midnight altar and pray — honestly, filthily — while countdown light ' \
                 'ticks against your pulse.'
               when :heart
                 'You kneel before the Heartstring altar and pray — honestly, filthily — while rose shadows rock ' \
                 'against the silk like a drawn bow.'
               when :carnival
                 'You kneel before the Carnival altar and pray — honestly, filthily — while bead-shadows clatter ' \
                 'against the silk like a thrown string.'
               when :hare
                 'You kneel before the Hare\'s altar and pray — honestly, filthily — while lily-shadows rock ' \
                 'against the silk like a soft ear.'
               when :fool
                 'You kneel before the Fool\'s altar and pray — honestly, filthily — while the offering cushion ' \
                 'sighs under your knees like a punchline.'
               when :may
                 'You kneel before the Maypole altar and pray — honestly, filthily — while ribbon-shadows wind ' \
                 'against the silk like a dance starting.'
               when :solstice
                 'You kneel before the Solstice altar and pray — honestly, filthily — while honey-light pools ' \
                 'against the silk like a fairy ring closing.'
               when :pride
                 'You kneel before the Pride altar and pray — honestly, filthily — while glitter-shadows cheer ' \
                 'against the silk like a float rolling past.'
               else
                 'You kneel before the altar and pray — honestly, filthily, telling your goddess exactly what ' \
                 'the tower has done to you and what you want it to do next.'
               end
        gain_attention!(player, 10, log)
        gained = player.heal_defiance!(10)
        log << "Warm approval brushes your skin like a suckered fingertip. **+#{gained} Defiance** · " \
               "Attention **#{attention(player)}/#{MAX_ATTENTION}**."
        grant_seasonal_altar_treat!(player, log, dress)
      when 'tithe'
        tithe = player.lp_price(TITHE_COST)
        unless player.spend_lp!(tithe, already_priced: true)
          log << "Your pockets are too empty for a tithe (#{tithe} LP). The stone goddess's smile turns pitying."
          return
        end

        log << case dress[:key]
               when :pumpkin
                 "You pour #{tithe} LP of lust-light into the pumpkin's mouth. It burns rose-orange and smells of caramel."
               when :feast
                 "You pour #{tithe} LP of lust-light into the gravy boat. It burns gold-rose and smells of butter and permission."
               when :yule
                 "You pour #{tithe} LP of lust-light into the stocking. It burns scarlet-gold and smells of peppermint and ribbon."
               when :midnight
                 "You pour #{tithe} LP of lust-light into the champagne flute. It burns night-gold and smells of citrus and oaths."
               when :heart
                 "You pour #{tithe} LP of lust-light into the chocolate dish. It burns rose-crimson and smells of sugar and claim."
               when :carnival
                 "You pour #{tithe} LP of lust-light into the king-cake plate. It burns purple-gold and smells of sugar and parade."
               when :hare
                 "You pour #{tithe} LP of lust-light into the egg basket. It burns cream-gold and smells of chocolate and lilies."
               when :fool
                 "You pour #{tithe} LP of lust-light into the whoopee cushion. It burns orange-gold and smells of sugar and setup."
               when :may
                 "You pour #{tithe} LP of lust-light into the ribboned cup. It burns leaf-gold and smells of wine and petals."
               when :solstice
                 "You pour #{tithe} LP of lust-light into the honey cup. It burns sun-gold and smells of honey and dusk."
               when :pride
                 "You pour #{tithe} LP of lust-light into the glitter dish. It burns rainbow-rose and smells of sugar and cheer."
               else
                 "You pour #{tithe} LP of lust-light into the offering bowl. It burns rose-red and rises like incense."
               end
        blessing =
          case dress[:key]
          when :pumpkin then Engine::Halloween::PUMPKIN_BLESSING
          when :feast then Engine::Thanksgiving::FEAST_BLESSING
          when :yule then Engine::Christmas::YULE_BLESSING
          when :midnight then Engine::NewYear::MIDNIGHT_BLESSING
          when :heart then Engine::Valentines::HEART_BLESSING
          when :carnival then Engine::MardiGras::CARNIVAL_BLESSING
          when :hare then Engine::Easter::HARE_BLESSING
          when :fool then Engine::AprilFools::FOOL_BLESSING
          when :may then Engine::MayDay::MAY_BLESSING
          when :solstice then Engine::Midsummer::MIDSUMMER_BLESSING
          when :pride then Engine::Pride::PRIDE_BLESSING
          else BLESSING
          end
        Engine::FetishEvents.apply_condition!(player, blessing, log)
        gain_attention!(player, 15, log)
        label =
          case dress[:key]
          when :pumpkin then 'Pumpkin Glow'
          when :feast then 'Feast Glow'
          when :yule then 'Yule Glow'
          when :midnight then 'Midnight Glow'
          when :heart then 'Heartstring Glow'
          when :carnival then 'Carnival Glow'
          when :hare then 'Hare Glow'
          when :fool then 'Fool Glow'
          when :may then 'Maypole Glow'
          when :solstice then 'Midsummer Glow'
          when :pride then 'Pride Glow'
          else "Eros's Favour"
          end
        log << "**#{label}** settles on you · Attention **#{attention(player)}/#{MAX_ATTENTION}**."
        grant_seasonal_altar_treat!(player, log, dress)
      when 'kneel'
        log << case dress[:key]
               when :pumpkin
                 'You kneel and offer yourself on pumpkin-silk steps. Stone tentacles warm and soften, smelling ' \
                 'faintly of spice, suckers kissing along your thighs while the jack-o\'-lantern watches — she ' \
                 'takes her time looking, and the looking alone leaves you trembling and soaked.'
               when :feast
                 'You kneel and offer yourself on cream-silk steps. Stone tentacles warm and soften, smelling ' \
                 'faintly of gravy and roses, suckers kissing along your thighs while the feast watches — she ' \
                 'takes her time looking, and the looking alone leaves you trembling and soaked.'
               when :yule
                 'You kneel and offer yourself on scarlet-ribbon steps. Stone tentacles warm and soften, smelling ' \
                 'faintly of pine and peppermint, suckers kissing along your thighs while the mistletoe watches — she ' \
                 'takes her time looking, and the looking alone leaves you trembling and soaked.'
               when :midnight
                 'You kneel and offer yourself on black-lace steps. Stone tentacles warm and soften, smelling ' \
                 'faintly of citrus fizz, suckers kissing along your thighs while the countdown watches — she ' \
                 'takes her time looking, and the looking alone leaves you trembling and soaked.'
               when :heart
                 'You kneel and offer yourself on crimson-silk steps. Stone tentacles warm and soften, smelling ' \
                 'faintly of roses and chocolate, suckers kissing along your thighs while the bow watches — she ' \
                 'takes her time looking, and the looking alone leaves you trembling and soaked.'
               when :carnival
                 'You kneel and offer yourself on purple-gold steps. Stone tentacles warm and soften, smelling ' \
                 'faintly of sugar and parade sweat, suckers kissing along your thighs while the mask watches — she ' \
                 'takes her time looking, and the looking alone leaves you trembling and soaked.'
               when :hare
                 'You kneel and offer yourself on pastel-silk steps. Stone tentacles warm and soften, smelling ' \
                 'faintly of lilies and chocolate, suckers kissing along your thighs while the ears watch — she ' \
                 'takes her time looking, and the looking alone leaves you trembling and soaked.'
               when :fool
                 'You kneel and offer yourself on motley steps. Stone tentacles warm and soften, smelling ' \
                 'faintly of sugar and rubber, suckers kissing along your thighs while the bells watch — she ' \
                 'takes her time looking, and the looking alone leaves you trembling and soaked.'
               when :may
                 'You kneel and offer yourself on blossom-silk steps. Stone tentacles warm and soften, smelling ' \
                 'faintly of petals and May wine, suckers kissing along your thighs while the ribbons watch — she ' \
                 'takes her time looking, and the looking alone leaves you trembling and soaked.'
               when :solstice
                 'You kneel and offer yourself on gold-silk steps. Stone tentacles warm and soften, smelling ' \
                 'faintly of honey and sun, suckers kissing along your thighs while the ring watches — she ' \
                 'takes her time looking, and the looking alone leaves you trembling and soaked.'
               when :pride
                 'You kneel and offer yourself on rainbow-silk steps. Stone tentacles warm and soften, smelling ' \
                 'faintly of glitter and sugar, suckers kissing along your thighs while the flags watch — she ' \
                 'takes her time looking, and the looking alone leaves you trembling and soaked.'
               else
                 'You kneel and offer yourself on the altar steps. Stone tentacles warm and soften beneath you, ' \
                 'suckers kissing along your thighs while candlelight crawls over your skin — she takes her time ' \
                 'looking, and the looking alone leaves you trembling and soaked.'
               end
        parts = Engine::ChastitySystem.scene_parts(player)
        touches = []
        touches << 'One warm sucker seals over your clit and pulses there, patient as prayer.' if parts.include?('vagina')
        touches << 'One tentacle curls around your cock and squeezes in slow, reverent pulses.' if parts.include?('penis')
        touches << 'Two suckers latch onto your nipples and tug them stiff.' if parts.include?('breasts')
        if touches.empty?
          caged = Engine::ChastitySystem.line(player, :tease)
          touches << caged if caged
        end
        log << touches.join(' ') if touches.any?
        player.gain_lust!(25)
        gain_attention!(player, 25, log)
        log << "**+25 Lust** · Attention **#{attention(player)}/#{MAX_ATTENTION}**."
        grant_seasonal_altar_treat!(player, log, dress, amount: 2)
      else
        log << 'You back away from the altar. Behind you, one candle stays lit a moment longer than the rest.'
      end
    end

    def grant_seasonal_altar_treat!(player, log, dress, amount: 1)
      case dress[:key]
      when :pumpkin
        added = Engine::Halloween.grant_candy!(player, amount)
        return unless added.positive?

        log << "Foil sweets tumble from the offering bowl — **+#{added} Halloween Candy** " \
               "(**#{Engine::Halloween.candy_count(player)}/#{Engine::Halloween::CANDY_MAX}** stashed; keeps after All Hallows)."
      when :feast
        added = Engine::Thanksgiving.grant_leftovers!(player, amount)
        return unless added.positive?

        log << "Wrapped leftovers tumble from the gravy boat — **+#{added} Leftovers** " \
               "(**#{Engine::Thanksgiving.leftovers_count(player)}/#{Engine::Thanksgiving::LEFTOVERS_MAX}** in your tin; keeps after the feast)."
      when :yule
        added = Engine::Christmas.grant_candy!(player, amount)
        return unless added.positive?

        log << "Foil sweets tumble from the stocking — **+#{added} Stocking Candy** " \
               "(**#{Engine::Christmas.candy_count(player)}/#{Engine::Christmas::CANDY_MAX}** stashed; keeps after Yule)."
      when :midnight
        added = Engine::NewYear.grant_bubbles!(player, amount)
        return unless added.positive?

        log << "Foil bubbles tumble from the flute — **+#{added} Champagne Bubbles** " \
               "(**#{Engine::NewYear.bubbles_count(player)}/#{Engine::NewYear::BUBBLES_MAX}** stashed; keeps after midnight)."
      when :heart
        added = Engine::Valentines.grant_hearts!(player, amount)
        return unless added.positive?

        log << "Foil hearts tumble from the dish — **+#{added} Chocolate Hearts** " \
               "(**#{Engine::Valentines.hearts_count(player)}/#{Engine::Valentines::HEARTS_MAX}** stashed; keeps after Heartstring)."
      when :carnival
        added = Engine::MardiGras.grant_cake!(player, amount)
        return unless added.positive?

        log << "Foil cake tumbles from the plate — **+#{added} King Cake** " \
               "(**#{Engine::MardiGras.cake_count(player)}/#{Engine::MardiGras::CAKE_MAX}** stashed; keeps after Carnival)."
      when :hare
        added = Engine::Easter.grant_eggs!(player, amount)
        return unless added.positive?

        log << "Foil eggs tumble from the basket — **+#{added} Chocolate Eggs** " \
               "(**#{Engine::Easter.eggs_count(player)}/#{Engine::Easter::EGGS_MAX}** stashed; keeps after Hare's Hunt)."
      when :fool
        added = Engine::AprilFools.grant_sweets!(player, amount)
        return unless added.positive?

        log << "Foil sweets tumble from the cushion — **+#{added} Fool's Sweets** " \
               "(**#{Engine::AprilFools.sweets_count(player)}/#{Engine::AprilFools::SWEETS_MAX}** stashed; keeps after Fool's Trap)."
      when :may
        added = Engine::MayDay.grant_wine!(player, amount)
        return unless added.positive?

        log << "Foil wine tumbles from the cup — **+#{added} May Wine** " \
               "(**#{Engine::MayDay.wine_count(player)}/#{Engine::MayDay::WINE_MAX}** stashed; keeps after Maypole)."
      when :solstice
        added = Engine::Midsummer.grant_honey!(player, amount)
        return unless added.positive?

        log << "Foil honey tumbles from the cup — **+#{added} Sun Honey** " \
               "(**#{Engine::Midsummer.honey_count(player)}/#{Engine::Midsummer::HONEY_MAX}** stashed; keeps after Longest Day)."
      when :pride
        added = Engine::Pride.grant_glitter!(player, amount)
        return unless added.positive?

        log << "Foil glitter tumbles from the dish — **+#{added} Pride Glitter** " \
               "(**#{Engine::Pride.glitter_count(player)}/#{Engine::Pride::GLITTER_MAX}** stashed; keeps after Pride Parade)."
      end
    end
    module_function :grant_seasonal_altar_treat!
  end
end
