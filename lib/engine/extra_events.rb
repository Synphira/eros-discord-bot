# frozen_string_literal: true

module Engine
  module ExtraEvents
    KEYS = %w[milking_shrine swelling_fountain bloating_slime egg_chamber paddle_golem foot_idol].freeze

    TRACKERS = {
      'milking_shrine' => %w[being_milked_events lactation_events],
      'swelling_fountain' => %w[body_growth_events],
      'bloating_slime' => %w[inflation_events],
      'egg_chamber' => %w[oviposition_events],
      'paddle_golem' => %w[discipline_events],
      'foot_idol' => %w[foot_fetish_events],
      'edging_altar' => %w[chastity_events]
    }.freeze

    META = {
      'milking_shrine' => {
        name: 'Milking Shrine',
        blurb: 'brass pumps hiss rhythmically.',
        description: 'A padded stall full of brass pumps and suction cups designed to draw every drop of liquid from your body.'
      },
      'swelling_fountain' => {
        name: 'Swelling Fountain',
        blurb: 'water fizzes invitingly.',
        description: 'A fountain bubbling with potent transformation magic that makes your body parts swell dramatically.'
      },
      'bloating_slime' => {
        name: 'Bloating Slime',
        blurb: 'the floor softens and pulses beneath you.',
        description: "A gelatinous slime that forces its way into your body, expanding until you're painfully stuffed."
      },
      'egg_chamber' => {
        name: 'Egg Chamber',
        blurb: 'a pulsating ovipositor awaits.',
        description: 'A strange creature with a thick, ribbed ovipositor that desperately needs to implant its eggs in a warm body.'
      },
      'paddle_golem' => {
        name: 'Paddle Golem',
        blurb: 'a wooden golem holds a paddle.',
        description: "A rough-hewn golem that wants to spank your ass until it's red and raw."
      },
      'edging_altar' => {
        name: 'Edging Altar',
        blurb: 'an altar glows with patient light.',
        description: 'Glowing runes coil around your wrists as you touch the altar. A voice purrs that you may feel everything — except release...'
      },
      'foot_idol' => {
        name: 'Foot Idol',
        blurb: 'a stone foot glows with power.',
        description: 'A giant stone foot that radiates magical energy, demanding worship through intense foot-focused pleasure.'
      }
    }.freeze

    SIZE_WORDS = {
      'penis' => { 'small' => 'petite', 'average' => 'eager', 'large' => 'heavy, thick' },
      'breasts' => { 'small' => 'perky', 'medium' => 'firm', 'large' => 'heavy', 'huge' => 'enormous' },
      'butt' => { 'small' => 'tight', 'medium' => 'round', 'large' => 'plump', 'huge' => 'enormous' }
    }.freeze

    DENIAL_CAP = Player::CLIMAX_THRESHOLD - 5

    module_function

    def meta(type)
      META[type.to_s]
    end

    def size_word(player, part)
      SIZE_WORDS.dig(part, Engine::ContentOptions.size_of(player, part)) || ''
    end

    def reward!(player, lp, lust, log)
      player.gain_lp!(lp) if lp.positive?
      player.gain_lust!(lust)
      bits = []
      bits << "**+#{lp} LP**" if lp.positive?
      bits << "lust **+#{lust}** (now #{player.lust})"
      log << bits.join(' · ')
    end

    def apply!(player, type, level, log)
      parts = Engine::ChastitySystem.scene_parts(player)
      bump_trackers!(player, type)
      case type
      when 'milking_shrine' then milking!(player, parts, level, log)
      when 'swelling_fountain' then swelling!(player, level, log)
      when 'bloating_slime' then bloating!(player, level, log)
      when 'egg_chamber' then eggs!(player, parts, level, log)
      when 'paddle_golem' then paddle!(player, level, log)
      when 'foot_idol' then feet!(player, level, log)
      end
    end

    def bump_trackers!(player, type)
      Array(TRACKERS[type.to_s]).each { |t| player.bump_tracker!(t) }
    end

    def milking!(player, parts, level, log)
      size = Engine::ContentOptions.size_of(player, 'breasts')
      log << { scene: "The brass cups immediately clamp onto your #{size_word(player, 'breasts')} breasts, creating an airtight seal. " \
                      'The machine starts with intense suction that pulls at your nipples, making them elongate and turn dark purple as ' \
                      'blood rushes to them. Milk begins spraying from your tits in thick, steady streams, filling the collection tubes ' \
                      'with creamy white fluid.' }
      bonus = { 'small' => 0, 'medium' => 2, 'large' => 4 }.fetch(size, 0)
      if parts.include?('penis')
        log << { scene: 'A third, smaller cup descends and attaches to your cock, its suction immediately making your shaft swell as the ' \
                        'machine begins milking your prostate from inside. You can feel your balls constricting as thick ropes of semen ' \
                        'spurt from your tip, collected by the hungry machine.' }
        bonus += 2
      elsif (caged = Engine::ChastitySystem.line(player, :milking))
        log << { scene: caged }
        bonus += 2
      end
      log << { scene: "The machine's rhythm increases, the suction becoming painful as it tries to extract every last drop. Your breasts " \
                      'are now raw and dripping, your nipples swollen to twice their size. When the cups finally release with a loud pop, ' \
                      'your breasts sag, covered in your own milk, nipples glistening and sore.' }
      reward!(player, 3 + (level / 3) + (bonus / 2), 10 + (level / 2) + bonus, log)
    end

    def swelling!(player, level, log)
      growable = Engine::ContentOptions.applicable_sizes(player).keys.reject { |p| Engine::ContentOptions.max_size?(player, p) }
      if growable.empty?
        log << { scene: 'The water fizzes against your skin, but you are already as generously shaped as the tower allows. It settles for ' \
                        'making you tingle all over, your already massive assets bouncing with every step.' }
        reward!(player, 2, 6 + (level / 2), log)
        return
      end

      part = growable.sample
      old, new = Engine::ContentOptions.step_size(player, part, 1)
      sizes = player.body_sizes.is_a?(Hash) ? player.body_sizes.dup : {}
      player.update(body_sizes: sizes.merge(part => new))
      label = Engine::ContentOptions::BODY_SIZES[part][:label].downcase
      scene =
        case part
        when 'breasts'
          'Warmth pools in your chest as your breasts begin to swell dramatically. You watch in fascination as they expand through ' \
            'cup sizes, the skin stretching tight, your nipples darkening and turning rock hard as the growth continues until they ' \
            "settle at their new #{new} size."
        when 'butt'
          'Intense heat spreads through your ass and hips as your cheeks swell outward. You can feel them growing heavier and wider, ' \
            'the skin stretching, until your underwear rides deep into the crack of your expanded ass as your new curves settle.'
        when 'penis'
          'Your cock begins to lengthen and thicken dramatically. You watch as it grows, veins becoming more pronounced, the head ' \
            'swelling and flushing dark. Your balls swell too, hanging heavier between your legs.'
        else
          "Your #{label} begins to swell with alarming speed, the skin stretching tight as the magic works its changes. The sensation " \
            'is overwhelming as the growth continues.'
        end
      log << { scene: scene }
      log << "_Your #{label} grew: **#{old} → #{new}** (change it any time in `/options`)._"
      reward!(player, 3, 8 + (level / 2), log)
    end

    def bloating!(player, level, log)
      log << { scene: 'The slime suddenly surges into your mouth, forcing its way down your throat. You can feel it expanding inside your ' \
                      'stomach, filling you completely. Your belly begins to swell outward, stretching painfully as the creature pumps ' \
                      'more of itself into you.' }
      log << { scene: 'Another tendril of slime forces its way into your ass, the cold gelatinous mass filling you completely. You feel so ' \
                      'full you might burst, the pressure making you gasp as your stomach distends into a round, pregnant shape.' }
      log << { scene: 'Content at last, the slime begins to slowly withdraw, the sensation of its departure as intense as its entry. As it ' \
                      'leaves your ass with a wet sucking sound, your body collapses inward, leaving you trembling and empty.' }
      reward!(player, 4 + (level / 3), 12 + (level / 2), log)
    end

    def eggs!(player, parts, level, log)
      if parts.include?('vagina')
        log << { scene: 'The creature positions itself between your legs, its thick, ribbed ovipositor pressing against your cunt lips. It ' \
                        'thrusts in roughly, the ridges scraping your inner walls as it pushes deep into your womb. One by one, warm, ' \
                        'fist-sized eggs travel down the tube, each one stretching you as it passes through your cervix.' }
        log << { scene: 'The eggs settle in your womb, each one making your belly swell a little more. You can feel them shifting inside ' \
                        'you, their hard shells pressing against each other. The creature chirps happily, its ovipositor still buried ' \
                        'inside you as it deposits the last egg.' }
      else
        log << { scene: 'The creature forces you onto all fours as its thick ovipositor presses against your tight asshole. It thrusts in ' \
                        'without mercy, the ridged shaft burying itself deep inside you. You scream as the first egg begins to travel ' \
                        'down, stretching you painfully.' }
        log << { scene: 'The eggs fill you, making your belly distend as more and more are deposited. You feel completely stuffed, unable ' \
                        'to move without intense pressure from the eggs shifting inside you. The creature finally withdraws, leaving your ' \
                        'ass gaping and leaking.' }
      end
      log << { scene: 'A short while later the eggs begin to dissolve, their shells melting away into a warm, tingling sensation inside ' \
                      'you. The energy spreads through your body, leaving you feeling both full and empty at the same time.' }
      reward!(player, 5 + (level / 3), 14 + (level / 2), log)
    end

    def paddle!(player, level, log)
      size = Engine::ContentOptions.size_of(player, 'butt')
      log << { scene: "The golem forces you over its knee, exposing your #{size_word(player, 'butt')} rear. The wooden paddle crashes " \
                      'down, leaving an immediate red mark that quickly darkens to purple. Each impact comes harder than the last, the ' \
                      'sound echoing through the chamber as you struggle and scream.' }
      extra = { 'small' => 0, 'medium' => 1, 'large' => 2, 'huge' => 3 }.fetch(size, 0)
      log << { scene: 'After twenty brutal swats, your ass is a mass of welts and bruises. The golem runs its rough wooden fingers over ' \
                      'the damage, pressing into the deepest welts and making you cry out.' }
      player.adjust_defiance!(-3)
      log << "The brutal spanking costs you **3** defiance. (now #{player.defiance}/#{player.max_defiance})"
      reward!(player, 3 + (level / 3) + extra, 8 + (level / 2) + (extra * 2), log)
    end

    def feet!(player, level, log)
      log << { scene: 'The stone foot comes to life, its toes separating and wrapping around your ankles. It lifts your feet to a mouth ' \
                      'of living stone, where a rough tongue begins to lick your soles with relentless intensity, probing every ' \
                      'sensitive spot between your toes.' }
      log << { scene: 'Stone lips close around each of your toes in turn, sucking with firm pressure while the tongue explores your ' \
                      'arches in impossibly wet strokes. The pleasure builds to an unbearable intensity as it focuses on your most ' \
                      'sensitive spots.' }
      log << { scene: 'When your boots slide back on, your feet are still tingling and sensitive. Every step sends residual pleasure ' \
                      'through your body, making it hard to walk straight as you remember the stone tongue that worshipped you so ' \
                      'thoroughly.' }
      reward!(player, 3 + (level / 3), 8 + (level / 2), log)
    end

    def edging_turn!(player, parts, turn, log)
      penis = parts.include?('penis')
      vagina = parts.include?('vagina')
      scene =
        case turn
        when 1
          touch =
            if penis && vagina then 'They wrap around your cock and slip over your clit at once, stroking both in a steady rhythm'
            elsif penis then 'They wrap around the head of your cock and stroke in a steady rhythm'
            elsif vagina then 'They find your clit and circle it in a steady rhythm'
            else 'They find every sensitive spot you have left and work it in a steady rhythm'
            end
          'Ghostly hands force your legs apart, invisible fingers tracing circles over your most sensitive places, building heat ' \
            "with maddening patience. #{touch}, bringing you right to the edge of orgasm but never letting you fall."
        when 2
          state =
            if penis && vagina then 'your cock throbbing and your cunt dripping'
            elsif penis then 'your cock throbbing'
            elsif vagina then 'your cunt dripping'
            else 'your whole body aching'
            end
          'The runes pulse brightly, forcing you right to the brink with overwhelming pleasure. They hold you there, trembling, ' \
            "#{state} as they deny you release."
        else
          'The voice laughs softly as it pulls you back from the edge one final time, then releases the runes. Your body collapses, ' \
            'unsatisfied and desperate for more.'
        end
      log << { scene: scene }
      if turn == 2
        caged = Engine::ChastitySystem.line(player, :edging)
        if caged
          log << { scene: caged }
        elsif penis
          log << { scene: 'Your cock flushes dark and strains, leaking and desperate for a release that will not come.' }
        end
      end
      gained = [10 + (turn * 5), DENIAL_CAP - player.lust].min
      player.gain_lust!(gained) if gained.positive?
      lp = 2 + turn
      player.gain_lp!(lp)
      log << "Denied, you earn **+#{lp} LP**. Lust held at `#{player.lust}` — just short of release."
    end
  end
end
