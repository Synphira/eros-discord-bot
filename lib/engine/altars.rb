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

    def visit!(player, log)
      case rand(3)
      when 0
        player.gain_lp!(40)
        log << '🌹 **Eros visits.** A white tentacle curls down from the dark, crimson suckers kissing your ' \
               'cheek, and drops a pouch of lust-light into your hands before withdrawing. **+40 LP** ' \
               "\"For being such a good pet,\" a voice purrs from everywhere."
      when 1
        Engine::FetishEvents.apply_condition!(player, BLESSING, log)
        log << '🌹 **Eros visits.** Warmth pours over you as invisible hands — and one very visible tentacle — ' \
               'straighten your clothes, stroke your hair, and send you on glowing. **Eros\'s Favour** settles on you.'
      else
        curse = player.active_curses.first
        if curse
          player.drop_curse!(curse.name)
          log << "🌹 **Eros visits.** \"This one doesn't suit you, pet.\" A tentacle plucks the **#{curse.name}** " \
                 'curse off you like a thread from a dress, and it dissolves into rose smoke. **Curse purged, free.**'
        else
          gained = player.heal_defiance!(30)
          log << '🌹 **Eros visits.** Her hands cup your face and her red eyes soften — just slightly. ' \
                 "\"Rest, pet. You please me.\" **+#{gained} Defiance**."
        end
      end
    end

    def present!(player)
      level = [player.current_floor, 1].max
      player.store_event!(type: 'altar', level: level, mode: 'choice', name: 'Altar of Eros')
      log = ["**Floor #{level}** — candlelight in the dark.",
             { scene: 'An altar of white stone and dark red silk, carved with a towering, horned goddess whose ' \
                      'stone tentacles curl around the offering bowl. The candles light themselves as you ' \
                      "approach. Her Attention rests on you at **#{attention(player)}/#{MAX_ATTENTION}**." }]
      log << 'What do you offer your goddess?'
      { ok: true, mode: :choice, name: 'Altar of Eros', colour: 0x5c0a2e, log: log, choices: choices(player) }
    end

    def choices(_player)
      [
        { key: 'pray', label: 'Pray', text: 'Kneel and pray (draw her Attention, small blessing)', style: :primary },
        { key: 'tithe', label: "Tithe #{TITHE_COST} LP", text: 'Offer Lust Points for a greater blessing', style: :success },
        { key: 'kneel', label: 'Kneel and offer yourself', text: 'Offer your body to the altar (lust, more Attention)', style: :danger },
        { key: 'leave', label: 'Leave', text: 'Back away respectfully', style: :secondary }
      ]
    end

    def resolve!(player, choice, log)
      case choice.to_s
      when 'pray'
        log << 'You kneel before the altar and pray — honestly, filthily, telling your goddess exactly what ' \
               'the tower has done to you and what you want it to do next.'
        gain_attention!(player, 10, log)
        gained = player.heal_defiance!(10)
        log << "Warm approval brushes your skin like a suckered fingertip. **+#{gained} Defiance** · " \
               "Attention **#{attention(player)}/#{MAX_ATTENTION}**."
      when 'tithe'
        unless player.spend_lp!(TITHE_COST)
          log << "Your pockets are too empty for a tithe (#{TITHE_COST} LP). The stone goddess's smile turns pitying."
          return
        end

        log << "You pour #{TITHE_COST} LP of lust-light into the offering bowl. It burns rose-red and rises like incense."
        Engine::FetishEvents.apply_condition!(player, BLESSING, log)
        gain_attention!(player, 20, log)
        log << "**Eros's Favour** settles on you · Attention **#{attention(player)}/#{MAX_ATTENTION}**."
      when 'kneel'
        log << 'You kneel and offer yourself on the altar steps. Stone tentacles warm and soften beneath you, ' \
               'suckers kissing along your thighs while candlelight crawls over your skin — she takes her time ' \
               'looking, and the looking alone leaves you trembling and soaked.'
        player.gain_lust!(25)
        gain_attention!(player, 15, log)
        log << "**+25 Lust** · Attention **#{attention(player)}/#{MAX_ATTENTION}**."
      else
        log << 'You back away from the altar. Behind you, one candle stays lit a moment longer than the rest.'
      end
    end
  end
end
