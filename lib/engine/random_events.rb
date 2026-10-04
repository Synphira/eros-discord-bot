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

      chance = trigger_chance(player.current_floor) * Engine::TransformationSystem.event_rate(player) *
               Engine::Weekly.special('event_rate')
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
          { scene: 'You find a hole in the wall at waist height, its edges worn smooth. A thick cock slides through it, already hard and drooling precum, and from the other side you hear heavy, eager breathing...' },
          'What do you want to do?'
        ],
        choices: choices
      }
    end

    def choices_for(player, data)
      type = data && data[:type].to_s
      return Engine::FetishEvents.choices(player, type) if Engine::FetishEvents.event?(type)
      return Engine::NPCSystem.choices(player, data[:npc], data[:stage]) if type == 'npc'
      return Engine::Treasure.chest_choices(player) if type == 'chest'

      glory_hole_choices(player)
    end

    def glory_hole_choices(player)
      parts = Engine::ChastitySystem.scene_parts(player)
      choices = []
      if Engine::ContentOptions.enabled?(player, 'oral')
        choices << { key: 'use_mouth', label: 'Mouth', text: 'Use your mouth to pleasure them' }
      end
      choices << { key: 'use_hands', label: 'Hands', text: 'Use your hands to pleasure them' }
      if parts.include?('breasts') && Engine::ContentOptions.enabled?(player, 'breast_play')
        choices << { key: 'use_breasts', label: 'Breasts', text: 'Use your breasts to pleasure them' }
      end
      if Engine::ContentOptions.enabled?(player, 'vaginal')
        if parts.include?('vagina')
          choices << { key: 'use_vagina', label: 'Vagina', text: 'Take them inside you' }
        elsif Engine::ChastitySystem.caged_parts(player).include?('vagina')
          choices << { key: 'use_vagina', label: 'Vagina 🔒', text: 'Locked away by your chastity', disabled: true }
        end
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
      return choose_npc!(player, data, choice_key.to_s, level, log) if data[:type].to_s == 'npc'
      return Engine::Treasure.choose_chest!(player, data, choice_key.to_s) if data[:type].to_s == 'chest'

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

    def choose_npc!(player, data, choice, level, log)
      outcome = Engine::NPCSystem.resolve!(player, data, choice, log)
      unless outcome[:ok]
        return { ok: true, mode: :choice, name: data[:name], colour: Engine::NPCSystem::COLOUR,
                 log: [outcome[:message] || 'That option is not available — pick another.'],
                 choices: Engine::NPCSystem.choices(player, data[:npc], data[:stage]) }
      end

      player.clear_event!
      if outcome[:fight]
        monster = Engine::NPCSystem.monster_for(player, outcome[:fight], level)
        return { ok: true, mode: :combat, name: data[:name], colour: 0x8b0000, log: log, monster: monster, choices: [] }
      end

      finish = finalize_lust!(player, log)
      colour = finish[:broken] ? 0x444444 : Engine::NPCSystem::COLOUR
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
        log << "You've been completely broken by the encounter!"
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
          description: "The floor gives way and you drop into a tight pit, stuck fast up to your waist. You can't see below, but something warm and slippery wraps around your ankles and starts sliding up your legs..."
        }
      when 'dildo_trap'
        {
          name: 'Dildo Trap',
          blurb: 'a cruel mechanism clicks.',
          description: 'You step on a hidden plate and the wall clicks open. A lube-slick dildo slides out on a jointed arm, angling itself between your legs as it starts to move on its own...'
        }
      when 'aphrodisiac_mist'
        {
          name: 'Aphrodisiac Mist',
          blurb: 'the air sweetens.',
          description: 'A sweet, heavy mist rolls in around you. With every breath your skin grows hotter, and an insistent throb builds between your legs...'
        }
      when 'bonding_vines'
        {
          name: 'Bonding Vines',
          blurb: 'the stone sprouts life.',
          description: 'Living vines burst from the floor and wrap your wrists and ankles, hoisting you into the air. Thinner tendrils are already creeping toward your most sensitive places...'
        }
      when 'public_humiliation'
        {
          name: 'Public Humiliation',
          blurb: 'mirrors that lie.',
          description: "You stumble into a room of mirrors that don't show your reflection. Instead they show you being fucked by every creature in the tower, and the images feel so real that your body responds as if it were all happening..."
        }
      when 'spirit_possession'
        {
          name: 'Spirit Possession',
          blurb: 'something slips under your skin.',
          description: "A lustful spirit slips under your skin and takes the reins. It hasn't felt flesh in centuries, and it wants to feel everything your body can..."
        }
      else
        { name: 'Strange Event', blurb: 'something stirs.', description: 'The dungeon toys with you.' }
      end
    end

    def apply_glory_choice!(player, key, level, log)
      parts = Engine::ChastitySystem.scene_parts(player)
      case key
      when 'use_mouth'
        lp_gain = 3 + (level / 2)
        lust_gain = 8 + level
        player.gain_lp!(lp_gain)
        player.gain_lust!(lust_gain)
        log << { scene: 'You kneel and wrap your lips around the cock, swirling your tongue over its leaking tip before taking it deep, bobbing on it until it\'s slick and throbbing in your mouth.' }
        log << { scene: 'They grip the edge of the hole and fuck your mouth in short, desperate thrusts until their cock pulses and fills your mouth with thick, salty cum, and you swallow every drop.' }
        log << "You gain **#{lp_gain}** Lust Points for your service."
        log << "Your lust increases by **#{lust_gain}**. (now #{player.lust})"
        if parts.include?('vagina')
          log << { scene: 'Your cunt clenches around nothing while you suck, and by the time you\'re done your thighs are slick with your own wetness.' }
          player.gain_lust!(3)
        elsif (caged = Engine::ChastitySystem.line(player, :glory))
          log << { scene: caged }
          player.gain_lust!(3)
        end
        true
      when 'use_hands'
        lp_gain = 2 + (level / 2)
        lust_gain = 5 + level
        player.gain_lp!(lp_gain)
        player.gain_lust!(lust_gain)
        log << { scene: 'You wrap both hands around the cock and stroke it slick with its own precum, twisting your palm over the swollen head until it bucks against the wall.' }
        log << { scene: 'It throbs in your grip and spurts thick ropes of cum over your fingers and wrists, twitching until you\'ve milked out every last drop.' }
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
        log << { scene: 'You press your breasts to the hole and trap the cock between them, squeezing them together as it fucks your cleavage, its slick head poking up between your tits with every thrust.' }
        log << { scene: 'It pulses between your breasts and paints your chest and nipples with hot, sticky cum.' }
        log << "You gain **#{lp_gain}** Lust Points for your service."
        log << "Your lust increases by **#{lust_gain}**. (now #{player.lust})"
        true
      when 'use_vagina'
        unless parts.include?('vagina')
          log << if Engine::ChastitySystem.in_chastity?(player)
                   'Your chastity seals you away — you can\'t take them that way while you\'re locked.'
                 else
                   "You don't have the right equipment for that choice."
                 end
          return false
        end
        lp_gain = 4 + (level / 2)
        lust_gain = 10 + level
        player.gain_lp!(lp_gain)
        player.gain_lust!(lust_gain)
        log << { scene: 'You back up against the wall and guide the cock into your cunt, gasping as it stretches you open and starts pounding you, their hips slamming the wall with every thrust.' }
        log << "You gain **#{lp_gain}** Lust Points for your service."
        log << "Your lust increases by **#{lust_gain}**. (now #{player.lust})"
        log << { scene: 'Their cock throbs deep inside you and floods your cunt with hot cum, and it drips down your thighs as they slide out.' }
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
      parts = Engine::ChastitySystem.scene_parts(player)
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
      log << { scene: "A #{dildo[:name]} dildo slides out of the wall, glistening with lube, its #{dildo[:material]} head pressing against you." }

      if parts.include?('vagina')
        log << { scene: "It spreads your lips and pushes into your cunt, its #{dildo[:shape]} length fucking you in deep, steady strokes." }
        if parts.include?('penis')
          log << { scene: 'A slick sleeve slides down over your cock and pumps you in time with every thrust.' }
        end
        player.gain_lust!(12)
      elsif parts.include?('penis')
        log << { scene: 'It grinds up against your perineum while a slick sleeve slides down over your cock and starts to pump you.' }
        player.gain_lust!(10)
      elsif (caged = Engine::ChastitySystem.line(player, :dildo))
        log << { scene: caged }
        player.gain_lust!(10)
      end

      if parts.include?('anus')
        log << { scene: 'A second, slimmer dildo slides between your cheeks and pushes into your ass, stretching you full as it starts to thrust.' }
        player.gain_lust!(8)
      end

      case dildo[:name]
      when 'smooth glass'
        log << { scene: 'The glass warms against you until it feels like part of you, gliding in and out with slick, wet sounds.' }
        player.gain_lust!(5)
      when 'ribbed silicone'
        log << { scene: 'The silicone flexes and twists as it thrusts, its ridges dragging over every sensitive spot it can reach.' }
        player.gain_lust!(7)
      when 'stone phallus'
        log << { scene: 'The stone starts to hum with a deep, steady thrum that you feel all the way through your body.' }
        player.gain_lust!(6)
      when 'metallic tentacle'
        log << { scene: 'The metal tentacle crackles with a faint, tingling current that makes every nerve it touches light up with pleasure.' }
        player.gain_lust!(9)
      end

      log << { scene: 'The dildos fuck you right up to the edge, then retract into the wall all at once, leaving you dripping, empty and aching for more.' }
      player.gain_lust!(5)
      log << "Lust now `#{player.lust}`."
    end

    def apply_humiliation!(player, parts, log)
      log << { scene: 'The mirrors show you being taken by monsters in every way imaginable. You know none of it is real, but your body reacts as if it is, flushing and aching with every image.' }
      if parts.include?('vagina')
        log << { scene: 'In one mirror a beast has you on all fours, its cock pounding your cunt until cum spills down your thighs. You swear you can feel every thrust.' }
        player.gain_lust!(12)
      end
      if parts.include?('penis')
        log << { scene: 'In another, demonic mouths take turns on your cock, sucking you dry again and again while you moan for more.' }
        player.gain_lust!(10)
      end
      if (caged = Engine::ChastitySystem.line(player, :mirror))
        log << { scene: caged }
        player.gain_lust!(10)
      end
      if parts.include?('anus')
        log << { scene: 'A third shows tentacles stretching your ass wide while you push back on them, begging for more.' }
        player.gain_lust!(8)
      end
      log << { scene: "The mirrors finally go dark, but the images keep replaying behind your eyes, and your body hasn't forgotten them either." }
      player.gain_lust!(5)
      log << "Lust now `#{player.lust}`."
    end

    def apply_turn_effect!(player, type, turn, _level, log)
      parts = Engine::ChastitySystem.scene_parts(player)
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
        log << { scene: 'Slimy tentacles coil around your thighs and pull them wide, holding you spread open in the pit while dozens more slither over your skin, smearing you with warm slime.' }
        player.gain_lust!(8)
        lines = []
        lines << { scene: 'A thick, knobbly tentacle rubs up and down your slit until you\'re slick, then pushes into your cunt, every bump popping past your lips as it sinks deep and starts to pump.' } if parts.include?('vagina')
        lines << { scene: 'A tentacle coils around your cock from root to tip and squeezes, its slimy suckers kissing along your shaft as it strokes you to full, throbbing hardness.' } if parts.include?('penis')
        lines = Engine::ChastitySystem.scenes(player, :tentacles) if lines.empty?
        log.concat(lines)
        player.gain_lust!(7)
      when 2
        log << { scene: "The tentacles find their rhythm, working you in wet, slapping strokes that echo off the pit walls. You can't see below, but you feel every slick inch." }
        log << { scene: 'Another tentacle pushes past your lips and fills your mouth, pumping warm slime across your tongue as it slides in and out.' }
        player.gain_lust!(10)
        if parts.include?('anus')
          log << { scene: 'A thick tentacle squirms between your cheeks and works its way into your ass, stretching you wide around its girth as it starts to thrust.' }
          if parts.include?('vagina')
            log << { scene: 'The tentacles in your cunt and ass take turns, one sliding in as the other pulls out, rubbing against each other through the thin wall inside you.' }
          elsif parts.include?('penis')
            log << { scene: 'It curls inside you and presses on your prostate, squeezing a steady drip of precum from your cock.' }
          end
        end
        player.gain_lust!(8)
      when 3
        log << { scene: "The tentacles speed up, squeezing and thrusting faster and faster, dragging you toward the edge whether you're ready or not." }
        player.gain_lust!(12)
        if parts.include?('breasts')
          log << { scene: 'Thin tentacles wind around your breasts and squeeze, their tips curling around your nipples and tugging them stiff.' }
        end
        player.gain_lust!(6)
      when 4
        log << { scene: 'The tentacles swell and throb inside you, their thrusts turning erratic as they near their own release, and one grinds right against your sweet spot until you cry out.' }
        player.gain_lust!(15)
      else
        log << { scene: 'The tentacles bury themselves deep and pulse, pumping you full of hot slime until it gushes out around them, then slither away all at once. The pit loosens and you crawl free, dripping.' }
        player.gain_lust!(10)
      end
      log << "Lust now `#{player.lust}`."
    end

    def mist_turn!(player, turn, log)
      case turn
      when 1
        log << { scene: Engine::ChastitySystem.line(player, :mist) ||
                        'The sweet mist sinks into your lungs and heat floods straight between your legs, your skin flushing and every nerve lighting up until you\'re squirming where you stand.' }
        player.gain_lust!(8)
      when 2
        log << { scene: 'The mist thickens. Your clothes feel like hands dragging over your sensitive skin, and your mind fills with nothing but filthy images of being touched, filled and fucked.' }
        player.gain_lust!(10)
      else
        log << { scene: "You're shaking with need, grinding against the wall and squeezing your thighs together just for friction, every brush of air sending a jolt through you. The mist owns you now." }
        player.gain_lust!(12)
      end
      log << "Lust now `#{player.lust}`."
    end

    def vines_turn!(player, parts, turn, log)
      case turn
      when 1
        log << { scene: 'The vines hoist you into the air and pull your legs wide, thin tendrils slithering under your clothes and over every inch of your skin.' }
        player.gain_lust!(7)
        lines = []
        lines << { scene: 'A nectar-slick vine strokes up and down your slit, then circles your clit and rubs it in slow, wet circles until you\'re dripping.' } if parts.include?('vagina')
        lines << { scene: 'A vine coils tight around your cock and pumps you, its ridges dragging along your shaft until you\'re rock hard and leaking.' } if parts.include?('penis')
        lines = Engine::ChastitySystem.scenes(player, :vines) if lines.empty?
        log.concat(lines)
        player.gain_lust!(8)
      when 2
        log << { scene: 'Thicker vines push into you, filling every hole they can find while the rest hold you suspended and helpless, rocking you back and forth onto them.' }
        player.gain_lust!(10)
        if parts.include?('breasts')
          log << { scene: 'Little flower-mouths latch onto your nipples and suckle, tugging and fluttering until your breasts ache.' }
        end
        player.gain_lust!(6)
      else
        log << { scene: 'The vines throb inside you and pump you full of warm nectar until it runs down your thighs, then go limp and lower you to the ground, sticky and trembling.' }
        player.gain_lust!(12)
      end
      log << "Lust now `#{player.lust}`."
    end

    def spirit_turn!(player, parts, turn, log)
      case turn
      when 1
        log << { scene: "The spirit seizes your hands and runs them all over your body, greedy for every sensation. Soon you can't tell whose desire is whose." }
        lines = []
        lines << { scene: 'Your fingers slide between your wet folds and spread them wide, then push inside, the spirit fucking you with your own hand and moaning with your voice.' } if parts.include?('vagina')
        lines << { scene: 'Your hand wraps around your cock and strokes it hard and slow, the spirit savouring every throb as it smears your precum along your shaft.' } if parts.include?('penis')
        lines = Engine::ChastitySystem.scenes(player, :spirit) if lines.empty?
        log.concat(lines)
        player.gain_lust!(10)
      else
        log << { scene: 'The spirit spreads you out in an alcove like a display piece, legs wide, your body on show for anyone who wanders by. Every sound it pulls from your throat is a moan.' }
        if parts.include?('breasts')
          log << { scene: 'Your hands knead your breasts and pinch your nipples, rolling and tugging them until you\'re arching into your own touch.' }
        end
        player.gain_lust!(12)
        log << { scene: 'Your fingers work you right to the edge before the spirit finally drifts out with a satisfied sigh, leaving you flushed, sticky and aching.' }
        player.gain_lust!(6)
      end
      log << "Lust now `#{player.lust}`."
    end
  end
end
