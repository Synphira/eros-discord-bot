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
      pumpkin = Engine::Halloween.pumpkin_altar?
      name = pumpkin ? 'Pumpkin Altar of Eros' : 'Altar of Eros'
      player.store_event!(type: 'altar', level: level, mode: 'choice', name: name)
      scene =
        if pumpkin
          'An altar of white stone dressed for All Hallows — orange silk, a hollowed pumpkin for an offering ' \
          'bowl, candlelight grinning through carved teeth. Stone tentacles curl around the rind like they ' \
          "have always belonged there. Her Attention rests on you at **#{attention(player)}/#{MAX_ATTENTION}**."
        else
          'An altar of white stone and dark red silk, carved with a towering, horned goddess whose ' \
          'stone tentacles curl around the offering bowl. The candles light themselves as you ' \
          "approach. Her Attention rests on you at **#{attention(player)}/#{MAX_ATTENTION}**."
        end
      log = ["**Floor #{level}** — #{pumpkin ? 'pumpkin candlelight in the dark' : 'candlelight in the dark'}.",
             { scene: scene }]
      if attention(player) >= 60
        log << '_The candles were already lit — all of them, flames leaning toward you like faces. ' \
               'She was watching this altar before you found it. She was watching **you**._'
      elsif attention(player) >= 25
        log << '_One candle lights a breath before the others. Noticed, then. Not yet known._'
      end
      log << 'What do you offer your goddess?'
      { ok: true, mode: :choice, name: name, colour: pumpkin ? 0xb85c1a : 0x5c0a2e, log: log,
        choices: choices(player) }
    end

    def choices(_player)
      [
        { key: 'pray', label: 'Pray', text: 'Kneel and pray (a little of her Attention, a little Defiance back)', style: :primary },
        { key: 'tithe', label: "Tithe #{TITHE_COST} LP", text: 'Offer Lust Points for her Favour blessing (and some of her Attention)', style: :success },
        { key: 'kneel', label: 'Kneel and offer yourself', text: 'Offer your body to the altar (+25 Lust, the most of her Attention)', style: :danger },
        { key: 'leave', label: 'Leave', text: 'Back away respectfully', style: :secondary }
      ]
    end

    def resolve!(player, choice, log)
      pumpkin = Engine::Halloween.pumpkin_altar?
      case choice.to_s
      when 'pray'
        log << if pumpkin
                 'You kneel before the pumpkin altar and pray — honestly, filthily — while the carved grin ' \
                 'flickers in time with your pulse.'
               else
                 'You kneel before the altar and pray — honestly, filthily, telling your goddess exactly what ' \
                 'the tower has done to you and what you want it to do next.'
               end
        gain_attention!(player, 10, log)
        gained = player.heal_defiance!(10)
        log << "Warm approval brushes your skin like a suckered fingertip. **+#{gained} Defiance** · " \
               "Attention **#{attention(player)}/#{MAX_ATTENTION}**."
        grant_pumpkin_candy!(player, log) if pumpkin
      when 'tithe'
        tithe = player.lp_price(TITHE_COST)
        unless player.spend_lp!(tithe, already_priced: true)
          log << "Your pockets are too empty for a tithe (#{tithe} LP). The stone goddess's smile turns pitying."
          return
        end

        log << if pumpkin
                 "You pour #{tithe} LP of lust-light into the pumpkin's mouth. It burns rose-orange and smells of caramel."
               else
                 "You pour #{tithe} LP of lust-light into the offering bowl. It burns rose-red and rises like incense."
               end
        blessing = pumpkin ? Engine::Halloween::PUMPKIN_BLESSING : BLESSING
        Engine::FetishEvents.apply_condition!(player, blessing, log)
        gain_attention!(player, 15, log)
        label = pumpkin ? 'Pumpkin Glow' : "Eros's Favour"
        log << "**#{label}** settles on you · Attention **#{attention(player)}/#{MAX_ATTENTION}**."
        grant_pumpkin_candy!(player, log) if pumpkin
      when 'kneel'
        log << if pumpkin
                 'You kneel and offer yourself on pumpkin-silk steps. Stone tentacles warm and soften, smelling ' \
                 'faintly of spice, suckers kissing along your thighs while the jack-o\'-lantern watches — she ' \
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
        grant_pumpkin_candy!(player, log, amount: 2) if pumpkin
      else
        log << 'You back away from the altar. Behind you, one candle stays lit a moment longer than the rest.'
      end
    end

    def grant_pumpkin_candy!(player, log, amount: 1)
      added = Engine::Halloween.grant_candy!(player, amount)
      return unless added.positive?

      log << "Foil sweets tumble from the offering bowl — **+#{added} Halloween Candy** " \
             "(**#{Engine::Halloween.candy_count(player)}/#{Engine::Halloween::CANDY_MAX}** stashed; keeps after All Hallows)."
    end
    module_function :grant_pumpkin_candy!
  end
end
