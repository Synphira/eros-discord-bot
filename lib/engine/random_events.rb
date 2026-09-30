# frozen_string_literal: true

require_relative 'fetish_events'

module Engine
  module RandomEvents
    COLOUR = 0x9b59b6

    EVENT_KEYS = %w[
      glory_hole
      tentacle_pit
      dildo_trap
      aphrodisiac_mist
      bonding_vines
      public_humiliation
      spirit_possession
      milking_shrine
      swelling_fountain
      bloating_slime
      egg_chamber
      paddle_golem
      edging_altar
      foot_idol
    ].concat(Engine::FetishEvents::KEYS).freeze

    EVENT_TAGS = {
      'glory_hole' => nil,
      'tentacle_pit' => 'tentacles',
      'dildo_trap' => 'toys',
      'aphrodisiac_mist' => 'aphrodisiacs',
      'bonding_vines' => 'bondage',
      'public_humiliation' => 'exhibitionism',
      'spirit_possession' => 'possession',
      'milking_shrine' => 'lactation',
      'swelling_fountain' => 'growth',
      'bloating_slime' => 'inflation',
      'egg_chamber' => 'oviposition',
      'paddle_golem' => 'spanking',
      'edging_altar' => 'denial',
      'foot_idol' => 'feet'
    }.merge(Engine::FetishEvents::TAGS).freeze

    LEGACY_TRACKERS = {
      'bonding_vines' => 'bondage_events',
      'public_humiliation' => 'exhibitionism_events'
    }.freeze

    EVENT_REQUIRES = {
      'milking_shrine' => 'breasts'
    }.freeze

    module_function

    def trigger_chance(level)
      [[0.15 + (level.to_i * 0.02), 0.40].min, 0.12].max
    end

    def should_trigger?(player)
      return false if player.active_event?
      return false if player.in_combat || player.encounter_data

      chance = trigger_chance(player.current_floor) * Engine::TransformationSystem.event_rate(player)
      rand <= [chance, 0.6].min
    end

    def available_keys(player)
      parts = player.body_parts_list.map(&:to_s)
      EVENT_KEYS.select do |key|
        tag = EVENT_TAGS[key]
        next false if tag && !Engine::ContentOptions.enabled?(player, tag)
        next Engine::FetishEvents.available?(player, key) if Engine::FetishEvents.event?(key)

        need = EVENT_REQUIRES[key]
        need.nil? || parts.include?(need)
      end
    end

    def sample_key(player = nil)
      keys = player ? available_keys(player) : EVENT_KEYS
      return 'glory_hole' if keys.empty?
      return keys.sample unless player && Engine::TransformationSystem.active(player)

      weights = keys.map { |k| [k, Engine::TransformationSystem.event_weight(player, EVENT_TAGS[k])] }
      roll = rand * weights.sum { |(_, w)| w }
      weights.each do |k, w|
        roll -= w
        return k if roll <= 0
      end
      keys.last
    end

    def start!(player, key: nil)
      key = (key || sample_key(player)).to_s
      level = player.current_floor
      Array(LEGACY_TRACKERS[key]).each { |t| player.bump_tracker!(t) }
      case key
      when 'glory_hole' then start_glory_hole!(player, level)
      when 'tentacle_pit' then start_timed!(player, 'tentacle_pit', level, 3 + rand(3))
      when 'dildo_trap' then resolve_immediate!(player, 'dildo_trap', level)
      when 'aphrodisiac_mist' then start_timed!(player, 'aphrodisiac_mist', level, 2 + (level / 3))
      when 'bonding_vines' then start_timed!(player, 'bonding_vines', level, 2 + rand(2))
      when 'public_humiliation' then resolve_immediate!(player, 'public_humiliation', level)
      when 'spirit_possession' then start_timed!(player, 'spirit_possession', level, 2)
      when 'edging_altar' then start_timed!(player, 'edging_altar', level, 3)
      when *Engine::ExtraEvents::KEYS then resolve_immediate!(player, key, level)
      when *Engine::FetishEvents::KEYS then Engine::FetishEvents.start!(player, key, level)
      else
        start_glory_hole!(player, level)
      end
    end

    def start_glory_hole!(player, level)
      choices = glory_hole_choices(player)
      player.store_event!(
        type: 'glory_hole',
        level: level,
        mode: 'choice',
        name: 'Glory Hole'
      )
      {
        ok: true,
        mode: :choice,
        name: 'Glory Hole',
        colour: COLOUR,
        log: [
          "**Floor #{level}** — a peculiar alcove.",
          { scene: 'You discover a strange hole in the wall at waist height. From the other side, you hear eager breathing. Someone seems to be waiting...' },
          'What do you want to do?'
        ],
        choices: choices
      }
    end

    def choices_for(player, data)
      type = data && data[:type].to_s
      return Engine::FetishEvents.choices(player, type) if Engine::FetishEvents.event?(type)

      glory_hole_choices(player)
    end

    def glory_hole_choices(player)
      parts = player.body_parts_list.map(&:to_s)
      choices = []
      if Engine::ContentOptions.enabled?(player, 'oral')
        choices << { key: 'use_mouth', label: 'Mouth', text: 'Use your mouth to pleasure them' }
      end
      choices << { key: 'use_hands', label: 'Hands', text: 'Use your hands to pleasure them' }
      if parts.include?('breasts') && Engine::ContentOptions.enabled?(player, 'breast_play')
        choices << { key: 'use_breasts', label: 'Breasts', text: 'Use your breasts to pleasure them' }
      end
      if parts.include?('vagina') && Engine::ContentOptions.enabled?(player, 'vaginal')
        choices << { key: 'use_vagina', label: 'Vagina', text: 'Take them inside you' }
      end
      choices << { key: 'ignore', label: 'Ignore', text: 'Ignore it and move on' }
      choices
    end

    def start_timed!(player, type, level, duration)
      meta = event_meta(type)
      duration = [duration.to_i, 1].max
      player.store_event!(
        type: type,
        level: level,
        mode: 'timed',
        turn: 1,
        duration: duration,
        name: meta[:name]
      )
      log = [
        "**Floor #{level}** — #{meta[:blurb]}",
        { scene: meta[:description] }
      ]
      apply_turn_effect!(player, type, 1, level, log)
      finish = finalize_lust!(player, log)

      if finish[:broken]
        player.clear_event!
        return finish.merge(ok: true, mode: :done, name: meta[:name], colour: 0x444444, choices: [])
      end

      if duration <= 1
        player.clear_event!
        log << 'The encounter ends, leaving you breathless and wanting more.'
        return { ok: true, mode: :done, name: meta[:name], colour: COLOUR, log: log, choices: [] }
      end

      {
        ok: true,
        mode: :continue,
        name: meta[:name],
        colour: COLOUR,
        log: log + ["_Turn 1/#{duration} — press **Continue** to endure._"],
        choices: [],
        turn: 1,
        duration: duration
      }
    end

    def resolve_immediate!(player, type, level)
      meta = event_meta(type)
      if type.to_s == 'dildo_trap' && rand < player.trap_avoid_chance
        player.bump_tracker!('traps_avoided')
        log = [
          "**Floor #{level}** — #{meta[:blurb]}",
          "A hidden mechanism whirs — you roll aside before it can catch you! " \
          "_(AGI #{player.effective_agility} · #{(player.trap_avoid_chance * 100).round}% to avoid)_"
        ]
        return { ok: true, mode: :done, name: meta[:name], colour: COLOUR, log: log, choices: [], broken: false }
      end

      log = [
        "**Floor #{level}** — #{meta[:blurb]}",
        { scene: meta[:description] }
      ]
      apply_immediate_effect!(player, type, level, log)
      finish = finalize_lust!(player, log)
      colour = finish[:broken] ? 0x444444 : COLOUR
      finish.merge(ok: true, mode: :done, name: meta[:name], colour: colour, choices: [])
    end

    def choose!(player, choice_key)
      data = player.event_data
      return { ok: false, error: :none, log: ['No event awaits your choice.'] } unless data
      return { ok: false, error: :wrong_mode, log: ['This event has no choices.'] } unless data[:mode] == 'choice'

      level = data[:level].to_i
      log = []
      return choose_fetish!(player, data, choice_key.to_s, level, log) if Engine::FetishEvents.event?(data[:type])

      ok = apply_glory_choice!(player, choice_key.to_s, level, log)
      unless ok
        return {
          ok: true,
          mode: :choice,
          name: data[:name],
          colour: COLOUR,
          log: log + ['Pick another option.'],
          choices: choices_for(player, data)
        }
      end

      player.clear_event!
      player.bump_tracker!('glory_hole_encounters') if choice_key.to_s.start_with?('use_')
      finish = finalize_lust!(player, log)
      colour = finish[:broken] ? 0x444444 : COLOUR
      finish.merge(ok: true, mode: :done, name: data[:name], colour: colour, choices: [])
    end

    def choose_fetish!(player, data, choice, level, log)
      type = data[:type].to_s
      outcome = Engine::FetishEvents.resolve!(player, type, choice, level, log)
      unless outcome[:ok]
        return { ok: true, mode: :choice, name: data[:name], colour: Engine::FetishEvents::COLOUR,
                 log: ['That option is not available — pick another.'],
                 choices: Engine::FetishEvents.choices(player, type) }
      end

      player.clear_event!
      if outcome[:fight]
        monster = Engine::MonsterTypes.generate_monster(level, player: player, type: outcome[:fight])
        return { ok: true, mode: :combat, name: data[:name], colour: 0x8b0000, log: log, monster: monster, choices: [] }
      end

      finish = finalize_lust!(player, log)
      colour = finish[:broken] ? 0x444444 : Engine::FetishEvents::COLOUR
      finish.merge(ok: true, mode: :done, name: data[:name], colour: colour, choices: [])
    end

    def continue!(player)
      data = player.event_data
      return { ok: false, error: :none, log: ['No ongoing event.'] } unless data
      return { ok: false, error: :wrong_mode, log: ['This event is waiting on a choice.'] } unless data[:mode] == 'timed'

      type = data[:type].to_s
      level = data[:level].to_i
      turn = data[:turn].to_i + 1
      duration = data[:duration].to_i
      log = ["**#{data[:name]}** continues…"]

      chance = player.event_escape_chance
      if rand < chance
        player.clear_event!
        player.bump_tracker!('events_escaped')
        log << "You twist and wriggle at just the right moment and slip free of the **#{data[:name]}**! " \
               "_(AGI #{player.effective_agility} · #{(chance * 100).round}% per turn)_"
        return { ok: true, mode: :done, name: data[:name], colour: COLOUR, log: log, choices: [] }
      end

      apply_turn_effect!(player, type, turn, level, log)
      finish = finalize_lust!(player, log)

      if finish[:broken]
        player.clear_event!
        return finish.merge(ok: true, mode: :done, name: data[:name], colour: 0x444444, choices: [])
      end

      if turn >= duration
        player.clear_event!
        player.bump_tracker!('tentacle_pit_survived') if type == 'tentacle_pit'
        log << 'The encounter ends, leaving you breathless and wanting more.'
        return { ok: true, mode: :done, name: data[:name], colour: COLOUR, log: log, choices: [] }
      end

      player.store_event!(data.merge(turn: turn))
      {
        ok: true,
        mode: :continue,
        name: data[:name],
        colour: COLOUR,
        log: log + ["_Turn #{turn}/#{duration} — press **Continue** to endure._"],
        choices: [],
        turn: turn,
        duration: duration
      }
    end

    def finalize_lust!(player, log)
      climax = player.try_climax!
      return { broken: false, log: log } unless climax

      log.concat(climax[:lines])
      if climax[:broken]
        loss = player.reset_run!
        log << "You've been completely broken by the encounter! Your run ends here."
        if loss[:gear_lost]&.any?
          log << "Your non-cursed gear and trophies are lost: #{loss[:gear_lost].map { |n| "**#{n}**" }.join(', ')}."
        end
        if loss[:curses_reactivated]&.any?
          log << "Your suppressed curses **reawaken**: #{loss[:curses_reactivated].map { |n| "**#{n}**" }.join(', ')}."
        end
        log << 'Floor, defiance, and lust reset — LP, curses, living gear, and deepest floor persist.'
        return { broken: true, log: log }
      end
      { broken: false, log: log }
    end

    def event_meta(type)
      extra = Engine::ExtraEvents.meta(type)
      return extra if extra

      case type.to_s
      when 'glory_hole'
        { name: 'Glory Hole', blurb: 'a peculiar alcove.', description: 'A waist-height hole waits in the wall.' }
      when 'tentacle_pit'
        {
          name: 'Tentacle Pit',
          blurb: 'the floor betrays you.',
          description: "The floor suddenly gives way beneath you! You find yourself trapped up to your waist in a tight pit. You can't see below, but you feel something warm and slippery wrapping around your legs..."
        }
      when 'dildo_trap'
        {
          name: 'Dildo Trap',
          blurb: 'a cruel mechanism clicks.',
          description: 'You trigger a strange mechanism and a dildo suddenly emerges from the wall, positioned perfectly to penetrate you. It begins to move with a will of its own...'
        }
      when 'aphrodisiac_mist'
        {
          name: 'Aphrodisiac Mist',
          blurb: 'the air sweetens.',
          description: 'A strange sweet-smelling mist suddenly fills the area. Your body begins to tingle with growing heat...'
        }
      when 'bonding_vines'
        {
          name: 'Bonding Vines',
          blurb: 'the stone sprouts life.',
          description: 'Suddenly, living vines erupt from the ground, wrapping around your limbs and lifting you into the air. They seem particularly interested in your most sensitive areas...'
        }
      when 'public_humiliation'
        {
          name: 'Public Humiliation',
          blurb: 'mirrors that lie.',
          description: "You stumble into a room filled with magical mirrors that don't reflect your image, but instead show you in compromising positions with various creatures. The images feel so real that your body responds as if they were actually happening..."
        }
      when 'spirit_possession'
        {
          name: 'Spirit Possession',
          blurb: 'something slips under your skin.',
          description: 'As you move through the dungeon, a lustful spirit suddenly invades your body! It wants to use your form to experience physical pleasure...'
        }
      else
        { name: 'Strange Event', blurb: 'something stirs.', description: 'The dungeon toys with you.' }
      end
    end

    def apply_glory_choice!(player, key, level, log)
      parts = player.body_parts_list.map(&:to_s)
      case key
      when 'use_mouth'
        lp_gain = 3 + (level / 2)
        lust_gain = 8 + level
        player.gain_lp!(lp_gain)
        player.gain_lust!(lust_gain)
        log << { scene: 'You kneel and take the waiting member into your mouth, pleasuring them with practiced skill. They moan from the other side, clearly enjoying your attentions.' }
        log << "You gain **#{lp_gain}** Lust Points for your service."
        log << "Your lust increases by **#{lust_gain}**. (now #{player.lust})"
        if parts.include?('vagina')
          log << { scene: 'As you pleasure them, your own body responds with growing heat between your legs.' }
          player.gain_lust!(3)
        end
        true
      when 'use_hands'
        lp_gain = 2 + (level / 2)
        lust_gain = 5 + level
        player.gain_lp!(lp_gain)
        player.gain_lust!(lust_gain)
        log << { scene: 'You reach through the hole and take them in your hands, stroking with practiced movements. They buck against the wall, clearly enjoying your touch.' }
        log << "You gain **#{lp_gain}** Lust Points for your service."
        log << "Your lust increases by **#{lust_gain}**. (now #{player.lust})"
        true
      when 'use_breasts'
        unless parts.include?('breasts')
          log << "You don't have the right equipment for that choice."
          return false
        end
        lp_gain = 2 + (level / 2)
        lust_gain = 6 + level
        player.gain_lp!(lp_gain)
        player.gain_lust!(lust_gain)
        log << { scene: 'You press your breasts against the hole, trapping the member between them. They thrust against you, enjoying the soft pressure of your flesh.' }
        log << "You gain **#{lp_gain}** Lust Points for your service."
        log << "Your lust increases by **#{lust_gain}**. (now #{player.lust})"
        true
      when 'use_vagina'
        unless parts.include?('vagina')
          log << "You don't have the right equipment for that choice."
          return false
        end
        lp_gain = 4 + (level / 2)
        lust_gain = 10 + level
        player.gain_lp!(lp_gain)
        player.gain_lust!(lust_gain)
        log << { scene: 'You position yourself and press back against the hole, taking them deep inside you. They thrust with abandon, movements growing frantic.' }
        log << "You gain **#{lp_gain}** Lust Points for your service."
        log << "Your lust increases by **#{lust_gain}**. (now #{player.lust})"
        log << { scene: 'Their seed spills inside you, leaving you filled and aching for more.' }
        player.gain_lust!(5)
        true
      when 'ignore'
        log << 'You decide to ignore the strange hole and continue on your way.'
        log << 'As you walk away, you hear a disappointed sigh from the other side.'
        true
      else
        log << 'Invalid choice. The opportunity passes...'
        true
      end
    end

    def apply_immediate_effect!(player, type, level, log)
      parts = player.body_parts_list.map(&:to_s)
      case type.to_s
      when 'dildo_trap'
        apply_dildo_trap!(player, parts, log)
      when 'public_humiliation'
        apply_humiliation!(player, parts, log)
      when *Engine::ExtraEvents::KEYS
        Engine::ExtraEvents.apply!(player, type.to_s, level, log)
      else
        player.gain_lust!(5 + level)
        log << "Something strange happens — lust **+#{5 + level}** (now #{player.lust})."
      end
    end

    def apply_dildo_trap!(player, parts, log)
      dildos = [
        { name: 'smooth glass', material: 'cool, smooth', shape: 'perfectly rounded' },
        { name: 'ribbed silicone', material: 'warm, flexible', shape: 'heavily ridged' },
        { name: 'stone phallus', material: 'hard, unyielding', shape: 'realistically detailed' },
        { name: 'metallic tentacle', material: 'cold, metallic', shape: 'ribbed and flexible' }
      ]
      dildo = dildos.sample
      player.bump_tracker!('dildo_traps_encountered')
      player.bump_tracker!('traps_triggered')
      log << { scene: "A #{dildo[:name]} dildo suddenly appears, its #{dildo[:material]} surface pressing against you." }

      if parts.include?('vagina')
        log << { scene: "It thrusts into your wet cunt, its #{dildo[:shape]} form hitting all the right spots." }
        player.gain_lust!(12)
      elsif parts.include?('penis')
        log << { scene: 'It positions itself under you, pressing against your perineum and sending vibrations through your body.' }
        player.gain_lust!(10)
      end

      if parts.include?('anus')
        log << { scene: 'Another smaller dildo emerges and slides into your ass, making you gasp at the sudden fullness.' }
        player.gain_lust!(8)
      end

      case dildo[:name]
      when 'smooth glass'
        log << { scene: 'The glass warms to your body temperature, becoming more comfortable as it moves.' }
        player.gain_lust!(5)
      when 'ribbed silicone'
        log << { scene: 'The silicone seems to move with a will of its own, its ridges stimulating you perfectly.' }
        player.gain_lust!(7)
      when 'stone phallus'
        log << { scene: 'The stone begins to vibrate with low intensity, sending deep waves of pleasure through you.' }
        player.gain_lust!(6)
      when 'metallic tentacle'
        log << { scene: 'The metallic tentacle electrocutes you with low-level current, making every nerve tingle.' }
        player.gain_lust!(9)
      end

      log << { scene: 'After several minutes of intense stimulation, the dildos suddenly retreat, leaving you aching and wanting more.' }
      player.gain_lust!(5)
      log << "Lust now `#{player.lust}`."
    end

    def apply_humiliation!(player, parts, log)
      log << { scene: 'The mirrors show images of you being taken by monsters in every way imaginable. Though you know they are not real, your body responds with intense arousal.' }
      if parts.include?('vagina')
        log << { scene: 'You see yourself being bred by beasts, your cunt filled with their seed. You can almost feel it happening.' }
        player.gain_lust!(12)
      end
      if parts.include?('penis')
        log << { scene: 'You watch yourself being milked by demonic mouths, your seed willingly given.' }
        player.gain_lust!(10)
      end
      if parts.include?('anus')
        log << { scene: 'The mirrors show tentacled creatures enjoying your ass, your body eagerly welcoming every inch.' }
        player.gain_lust!(8)
      end
      log << { scene: 'After several minutes, the mirrors return to normal, but the memory lingers in your mind and body.' }
      player.gain_lust!(5)
      log << "Lust now `#{player.lust}`."
    end

    def apply_turn_effect!(player, type, turn, _level, log)
      parts = player.body_parts_list.map(&:to_s)
      case type.to_s
      when 'tentacle_pit' then tentacle_pit_turn!(player, parts, turn, log)
      when 'aphrodisiac_mist' then mist_turn!(player, turn, log)
      when 'bonding_vines' then vines_turn!(player, parts, turn, log)
      when 'spirit_possession' then spirit_turn!(player, parts, turn, log)
      when 'edging_altar' then Engine::ExtraEvents.edging_turn!(player, parts, turn, log)
      else
        player.gain_lust!(8)
        log << "The dungeon toys with you — lust **+8** (now #{player.lust})."
      end
    end

    def tentacle_pit_turn!(player, parts, turn, log)
      case turn
      when 1
        log << { scene: "Slimy tentacles wrap around your legs, easing them apart and exposing you completely. The pit holds you snugly as the tentacles begin to explore your body." }
        player.gain_lust!(8)
        if parts.include?('vagina')
          log << { scene: 'A thick tentacle presses against your entrance, slowly sliding its way inside.' }
        elsif parts.include?('penis')
          log << { scene: 'A tentacle coils around your cock, its pulsating length already bringing you to hardness.' }
        end
        player.gain_lust!(7)
      when 2
        log << { scene: "The tentacles grow bolder, working you with rhythmic thrusts. You can't see what's happening, but you feel every slimy touch." }
        player.gain_lust!(10)
        if parts.include?('anus')
          log << { scene: 'Another tentacle slips into your ass, stretching you deliciously around its girth.' }
        end
        player.gain_lust!(8)
      when 3
        log << { scene: 'The tentacles move faster, their grip tightening as they bring you closer to climax. Your body betrays you with growing pleasure.' }
        player.gain_lust!(12)
        if parts.include?('breasts')
          log << { scene: 'Smaller tentacles wrap around your breasts, teasing your nipples to sensitive hardness.' }
        end
        player.gain_lust!(6)
      when 4
        log << { scene: 'The tentacles pulse inside you, their movements becoming more erratic as they approach their own release. You cry out as they hit a particularly sensitive spot.' }
        player.gain_lust!(15)
      else
        log << { scene: 'With one final thrust, the tentacles fill you with their seed before suddenly withdrawing. As suddenly as they appeared, they retreat. The pit loosens, allowing you to escape.' }
        player.gain_lust!(10)
      end
      log << "Lust now `#{player.lust}`."
    end

    def mist_turn!(player, turn, log)
      case turn
      when 1
        log << { scene: 'The aphrodisiac mist makes your skin flush with heat, your senses heightening with every breath. You feel a growing ache between your legs.' }
        player.gain_lust!(8)
      when 2
        log << { scene: "The mist's effects intensify, making your clothes feel rough against your sensitized skin. Your mind fills with carnal thoughts." }
        player.gain_lust!(10)
      else
        log << { scene: 'Your body trembles with need, every touch sending jolts of pleasure through you. The mist has you completely in its grip.' }
        player.gain_lust!(12)
      end
      log << "Lust now `#{player.lust}`."
    end

    def vines_turn!(player, parts, turn, log)
      case turn
      when 1
        log << { scene: 'The vines lift you, spreading your legs and exposing you completely. Thinner vines begin to explore your body, their rough texture stimulating your skin.' }
        player.gain_lust!(7)
        if parts.include?('vagina')
          log << { scene: 'A vine coated in sweet nectar presses against your clit, sending jolts of pleasure through you.' }
        elsif parts.include?('penis')
          log << { scene: 'A vine wraps around your cock, its rough texture stimulating you to hardness.' }
        end
        player.gain_lust!(8)
      when 2
        log << { scene: 'The vines grow bolder, thicker ones slipping into your most intimate areas while the rest cradle you in place.' }
        player.gain_lust!(10)
        if parts.include?('breasts')
          log << { scene: 'Vines with flower-like mouths attach to your nipples, sucking and nipping with gentle pressure.' }
        end
        player.gain_lust!(6)
      else
        log << { scene: 'The vines pulse inside you, their nectar filling you with warmth and pleasure. With one final thrust, they release their seed before going limp, dropping you to the ground.' }
        player.gain_lust!(12)
      end
      log << "Lust now `#{player.lust}`."
    end

    def spirit_turn!(player, parts, turn, log)
      case turn
      when 1
        log << { scene: "The spirit takes control of your hands, guiding them over your body. Its curiosity is infectious, and soon you're not sure whose desire is whose." }
        if parts.include?('vagina')
          log << { scene: 'Your hands drift to your wet folds, spreading them open as the spirit explores your most intimate areas.' }
        elsif parts.include?('penis')
          log << { scene: 'Your hands wrap around your cock and stroke it, bringing it to full hardness as the spirit savours every sensation.' }
        end
        player.gain_lust!(10)
      else
        log << { scene: 'The spirit poses you in an alcove, putting you on display for any who pass by. Every sound it pulls from your throat comes out as a moan.' }
        if parts.include?('breasts')
          log << { scene: 'Your hands knead your breasts, pinching your nipples to hardness.' }
        end
        player.gain_lust!(12)
        log << { scene: 'After what feels like an eternity, the spirit drifts out of your body with a satisfied sigh, leaving a warm afterglow behind.' }
        player.gain_lust!(6)
      end
      log << "Lust now `#{player.lust}`."
    end
  end
end
