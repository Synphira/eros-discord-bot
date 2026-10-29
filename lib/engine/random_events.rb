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
      confessional
      tea_ceremony
      mirror_duet
      hot_spring
      masseuse_table
      false_exit
      choir_loft
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
      'foot_idol' => 'feet',
      'tea_ceremony' => 'aphrodisiacs',
      'mirror_duet' => 'gender_bending',
      'masseuse_table' => 'overstimulation',
      'choir_loft' => 'voyeurism'
    }.merge(Engine::FetishEvents::TAGS).freeze

    LEGACY_TRACKERS = {
      'bonding_vines' => 'bondage_events',
      'public_humiliation' => 'exhibitionism_events'
    }.freeze

    # Longing: the rare, ladder-bearing timed events quietly grow more
    # likely the longer a delver goes without seeing them, so their
    # achievement ladders are a matter of persistence, not pure luck.
    LONGING_KEYS = %w[glory_hole tentacle_pit dildo_trap masseuse_table tea_ceremony].freeze
    LONGING_THRESHOLD = 150
    LONGING_STEP_ROOMS = 50
    LONGING_MAX_BONUS = 4.0

    EVENT_REQUIRES_ANY = {
      'milking_shrine' => %w[breasts penis]
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
        next false if key == 'hot_spring' &&
                      !%w[growth shrinking].any? { |t| Engine::ContentOptions.enabled?(player, t) }

        needs = EVENT_REQUIRES_ANY[key]
        needs.nil? || (needs & parts).any?
      end
    end

    def longing_rooms(player, key)
      saved = player.tracker_hash['longing']
      saved.is_a?(Hash) ? saved[key.to_s].to_i : 0
    end

    def longing_multiplier(player, key)
      return 1.0 unless LONGING_KEYS.include?(key.to_s)

      rooms = longing_rooms(player, key)
      return 1.0 if rooms < LONGING_THRESHOLD

      1.0 + [((rooms - LONGING_THRESHOLD) / LONGING_STEP_ROOMS).floor, LONGING_MAX_BONUS].min
    end

    # Called once per room explored. Events whose content toggle is off
    # do not build longing — the tower cannot miss what it may not show.
    def tick_longing!(player)
      saved = player.tracker_hash['longing']
      saved = saved.is_a?(Hash) ? saved.dup : {}
      LONGING_KEYS.each do |key|
        tag = EVENT_TAGS[key]
        next if tag && !Engine::ContentOptions.enabled?(player, tag)

        saved[key] = saved[key].to_i + 1
      end
      player.set_tracker!('longing', saved)
    end

    def reset_longing!(player, key)
      return unless LONGING_KEYS.include?(key.to_s)

      saved = player.tracker_hash['longing']
      return unless saved.is_a?(Hash) && saved.key?(key.to_s)

      player.set_tracker!('longing', saved.merge(key.to_s => 0))
    end

    def sample_key(player = nil)
      keys = player ? available_keys(player) : EVENT_KEYS
      return 'glory_hole' if keys.empty?
      return keys.sample unless player

      weights = keys.map do |k|
        tag = EVENT_TAGS[k]
        [k, Engine::TransformationSystem.event_weight(player, tag) * Engine::Biomes.event_weight(player, tag) *
            longing_multiplier(player, k)]
      end
      roll = rand * weights.sum { |(_, w)| w }
      weights.each do |k, w|
        roll -= w
        return k if roll <= 0
      end
      keys.last
    end

    # The codex event index counts sightings from here — every random,
    # fetish, and timed event in the tower starts through this door.
    def note_seen!(player, key)
      saved = player.tracker_hash['events_seen']
      saved = saved.is_a?(Hash) ? saved.dup : {}
      saved[key.to_s] = saved[key.to_s].to_i + 1
      player.set_tracker!('events_seen', saved)
    end

    def start!(player, key: nil)
      key = (key || sample_key(player)).to_s
      reset_longing!(player, key)
      note_seen!(player, key)
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
      when 'confessional', 'tea_ceremony', 'mirror_duet', 'hot_spring', 'false_exit', 'choir_loft'
        start_choice!(player, key, level)
      when 'masseuse_table' then start_timed!(player, 'masseuse_table', level, 4)
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

    CHOICE_EVENTS = %w[confessional tea_ceremony mirror_duet hot_spring false_exit choir_loft].freeze

    def start_choice!(player, type, level)
      meta = event_meta(type)
      player.store_event!(
        type: type,
        level: level,
        mode: 'choice',
        name: meta[:name]
      )
      {
        ok: true,
        mode: :choice,
        name: meta[:name],
        colour: COLOUR,
        broken: false,
        log: [
          "**Floor #{level}** — #{meta[:blurb]}",
          { scene: meta[:description] }
        ],
        choices: choices_for(player, { type: type })
      }
    end

    def choices_for(player, data)
      type = data && data[:type].to_s
      return Engine::FetishEvents.choices(player, type) if Engine::FetishEvents.event?(type)
      return Engine::NPCSystem.choices(player, data[:npc], data[:stage]) if type == 'npc'
      return Engine::Treasure.chest_choices(player) if type == 'chest'
      return Engine::Altars.choices(player) if type == 'altar'
      return Engine::Exploration.trap_choices if type == 'trap'
      return Engine::Exploration.trap_choices if type == 'dildo_trap'

      case type
      when 'confessional'
        list = [
          { key: 'confess_small', label: 'Confess a small sin', text: 'Keep it brief and wholesome, as these things go' },
          { key: 'confess_detail', label: 'Confess in detail', text: 'Leave nothing out. Nothing' },
          { key: 'leave', label: 'Slip away', text: 'Some things stay unconfessed' }
        ]
        if player.tracker('brother_confess').positive?
          list.insert(2, { key: 'ask_indulgence', label: 'Ask Brother Confess for an indulgence',
                           text: 'Absolution, tower-style: sweet now, settling under the skin later' })
        end
        list
      when 'tea_ceremony'
        [
          { key: 'drink', label: 'Drink', text: 'Accept the poured cup, whatever the blend is' },
          { key: 'refuse', label: 'Refuse politely', text: 'Bow your head and keep your wits' },
          { key: 'bottle', label: 'Bottle it', text: 'Decant the second cup — your next monster drinks instead of you' },
          { key: 'pocket', label: 'Pocket the leaves', text: 'Berry pays well for exotic tea' }
        ]
      when 'mirror_duet'
        [
          { key: 'embrace', label: 'Embrace her', text: 'Meet yourself halfway' },
          { key: 'send_back', label: 'Send her back', text: 'The mirror is quite full enough' },
          { key: 'fight', label: 'Fight her', text: 'Only one of you is leaving this room' }
        ]
      when 'false_exit'
        [
          { key: 'open', label: 'Open the door', text: 'Exits are exits. Probably' },
          { key: 'knock', label: 'Knock first', text: 'Manners, even here — especially here' },
          { key: 'leave', label: 'Leave it shut', text: 'The tower has other doors' }
        ]
      when 'hot_spring'
        [
          { key: 'soak', label: 'Soak', text: 'Sink in and let the water rearrange you' },
          { key: 'dip', label: 'Dip a toe', text: 'Test the water and learn its intentions' },
          { key: 'leave', label: 'Leave it steaming', text: 'Some springs are best un-sat-in' }
        ]
      when 'choir_loft'
        list = [{ key: 'listen', label: 'Listen from the dark', text: 'Stay unseen. Let the harmony work on you — she will notice the listening' }]
        if Engine::ContentOptions.enabled?(player, 'group_sex')
          list << { key: 'join', label: 'Join the harmony', text: 'Step out of the dark and be sung into the arrangement' }
        end
        list << { key: 'leave', label: 'Slip away', text: 'Some performances are not for you' }
        list
      when 'basilisk'
        [
          { key: 'avert', label: 'Avert your eyes', text: 'Fight her half-blind — your hits land softer, your composure holds' },
          { key: 'meet', label: 'Meet her gaze', text: 'Resistance against the amber — fail, and she takes a free turn in your head' }
        ]
      when 'gorgon'
        [
          { key: 'bargain', label: "Offer tribute (#{10 + (2 * player.current_floor)} LP)",
            text: 'Buy a civilised contest — she starts charmed and far easier to satisfy' },
          { key: 'compliment', label: 'Negotiate with compliments', text: 'Manners against the serpents — flatter her, or fight her insulted' },
          { key: 'avert', label: 'Avert your eyes', text: 'Fight her half-blind — your hits land softer, your composure holds' }
        ]
      else
        glory_hole_choices(player)
      end
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
        player.store_event!(
          type: 'dildo_trap',
          mode: 'choice',
          name: meta[:name],
          level: level
        )
        log = [
          "**Floor #{level}** — #{meta[:blurb]}",
          { scene: meta[:description] },
          'The mechanism whirs — you spot it a heartbeat before it can catch you. You could roll aside... ' \
          'or stay exactly where you are and let it happen. ' \
          "_(AGI #{player.effective_agility} · #{(player.trap_avoid_chance * 100).round}% dodge chance — the choice is yours.)_"
        ]
        return { ok: true, mode: :choice, name: meta[:name], colour: COLOUR, log: log,
                 choices: Engine::Exploration.trap_choices, broken: false }
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
      return choose_altar!(player, data, choice_key.to_s, level, log) if data[:type].to_s == 'altar'
      return choose_trap!(player, data, choice_key.to_s) if data[:type].to_s == 'trap'
      return choose_dildo_trap!(player, data, choice_key.to_s, level, log) if data[:type].to_s == 'dildo_trap'
      return choose_basilisk!(player, data, choice_key.to_s, level, log) if data[:type].to_s == 'basilisk'
      return choose_gorgon!(player, data, choice_key.to_s, level, log) if data[:type].to_s == 'gorgon'
      if CHOICE_EVENTS.include?(data[:type].to_s)
        return send(:"choose_#{data[:type]}!", player, data, choice_key.to_s, level, log)
      end

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

    # The Basilisk's pre-combat gamble: eyes down and fight softer, or
    # meet the gaze and risk her free turn inside your head.
    def choose_basilisk!(player, data, choice, level, log)
      monster = (data[:monster] || {}).transform_keys(&:to_sym)
      monster[:name] ||= 'Basilisk'
      monster[:type] ||= 'beast'

      case choice
      when 'avert'
        monster[:gaze_averted] = true
        log << { scene: 'You fix your eyes on the midline of her scales and keep them there, fighting ' \
                        'the old animal urge to look up. Everything above her shoulders stays a ' \
                        'beautiful, lethal rumour. Your strikes will land softer — but your head stays yours.' }
      when 'meet'
        chance = [0.35 + (player.effective_resistance * 0.02), 0.8].min
        if rand < chance
          log << { scene: 'You meet the Basilisk\'s gaze and hold it. Amber floods your vision — and ' \
                          'breaks, like a wave on a seawall. She blinks first, and something respectful ' \
                          'enters her posture. The fight will be honest now.' }
        else
          hit = monster[:lust_damage].to_i
          player.gain_lust!(hit)
          log << { scene: 'The gaze goes through you like a hand through warm water. Whatever she wants ' \
                          'you to imagine, you imagine it, in detail, all at once, while your body ' \
                          'answers without asking you.' }
          log << "Her free turn lands inside your head — **+#{hit} Lust** (now #{player.lust})."
          finish = finalize_lust!(player, log)
          if finish[:broken]
            player.clear_event!
            return finish.merge(ok: true, mode: :done, name: 'Basilisk', colour: 0x444444, choices: [])
          end
        end
      else
        return { ok: true, mode: :choice, name: 'Basilisk', colour: COLOUR,
                 log: log + ['Her eyes are still waiting. Decide.'], choices: choices_for(player, data) }
      end

      player.clear_event!
      { ok: true, mode: :combat, name: 'Basilisk', colour: COLOUR, log: log, monster: monster, choices: [] }
    end

    # The Gorgon Matron's pre-combat negotiation: tribute buys a
    # civilised contest, compliments gamble on her vanity, and the
    # eyes-down route is always there for the uncouth.
    def choose_gorgon!(player, data, choice, level, log)
      monster = (data[:monster] || {}).transform_keys(&:to_sym)
      monster[:name] ||= 'Gorgon Matron'
      monster[:type] ||= 'beast'

      case choice
      when 'bargain'
        cost = 10 + (2 * level)
        if player.lp < cost
          return { ok: true, mode: :choice, name: 'Gorgon Matron', colour: COLOUR,
                   log: log + ["The Matron looks at your empty purse the way her statues once looked " \
                               "at her. \"Tribute is **#{cost} LP**, darling. Sentiment is not legal " \
                               'tender. Choose again."'],
                   choices: choices_for(player, data) }
        end

        player.spend_lp!(cost)
        player.bump_tracker!('gorgon_bargains')
        monster[:pliant] = monster[:pliant].to_f + 0.30
        log << { scene: "You lay out **#{cost} LP** on the salon floor, and the serpents in her hair " \
                        'settle like an audience that has been fed. "A civilised delver," the Matron ' \
                        'says, coiling aside with real warmth. "Then we shall be civilised about what ' \
                        'happens next. I might even enjoy losing."' }
      when 'compliment'
        player.bump_tracker!('gorgon_negotiations')
        chance = [0.40 + (player.effective_submission * 0.03), 0.85].min
        if rand < chance
          monster[:pliant] = monster[:pliant].to_f + 0.30
          player.bump_tracker!('admirer_beast')
          log << { scene: 'You compliment the architecture of her — the crown of serpents, the courtesy, ' \
                          'the collection — and mean every word, which she can tell. The Matron laughs ' \
                          'like a hostess genuinely surprised by a guest. "Flattery, offered as tribute. ' \
                          'Accepted. My kind will remember your manners, too."' }
          log << '_(admirer progress +1 — beasts)_'
        else
          monster[:lust_damage] = (monster[:lust_damage].to_i * 1.15).round
          log << { scene: 'You compliment her, and land — fatally — on the one serpent that is having a ' \
                          'bad century. The whole crown rears. "THAT one?" the Matron says, in tones of ' \
                          'a woman whose evening has been ruined. "Darling. We fight insulted now."' }
          log << '_Insulted: her lust hits land 15% harder._'
        end
      when 'avert'
        monster[:gaze_averted] = true
        log << { scene: 'You decline the negotiation and fix your eyes on the midline of her scales, ' \
                        'fighting the urge to look up at the most magnificent thing on the floor. Her ' \
                        'serpents approve of your discipline. Your strikes will land softer.' }
      else
        return { ok: true, mode: :choice, name: 'Gorgon Matron', colour: COLOUR,
                 log: log + ['The Matron waits, serpents swaying. Negotiate.'], choices: choices_for(player, data) }
      end

      player.clear_event!
      { ok: true, mode: :combat, name: 'Gorgon Matron', colour: COLOUR, log: log, monster: monster, choices: [] }
    end

    def choose_fetish!(player, data, choice, level, log)
      type = data[:type].to_s
      outcome = Engine::FetishEvents.resolve!(player, type, choice, level, log)
      unless outcome[:ok]
        return { ok: true, mode: :choice, name: data[:name], colour: Engine::FetishEvents::COLOUR,
                 log: [outcome[:message] || 'That option is not available — pick another.'],
                 choices: Engine::FetishEvents.choices(player, type) }
      end

      player.clear_event!
      if outcome[:fight]
        monster = Engine::MonsterTypes.generate_monster(level, player: player, type: outcome[:fight])
        monster = monster.merge(name: outcome[:monster_name]) if outcome[:monster_name]
        return { ok: true, mode: :combat, name: data[:name], colour: 0x8b0000, log: log, monster: monster, choices: [] }
      end

      finish = finalize_lust!(player, log)
      colour = finish[:broken] ? 0x444444 : Engine::FetishEvents::COLOUR
      finish.merge(ok: true, mode: :done, name: data[:name], colour: colour, choices: [])
    end

    def choose_trap!(player, data, choice)
      result = Engine::Exploration.resolve_trap_choice!(player, data, choice)
      return result unless result[:ok]

      player.clear_event!
      result
    end

    def choose_dildo_trap!(player, data, choice, level, log)
      meta = event_meta('dildo_trap')
      case choice
      when 'dodge'
        player.clear_event!
        player.bump_tracker!('traps_avoided')
        log << 'You roll aside as the mechanism fires, the slick head sliding past into the wall, harmless. ' \
               "_(AGI #{player.effective_agility} · #{(player.trap_avoid_chance * 100).round}% dodge chance)_"
        { ok: true, mode: :done, name: data[:name], colour: COLOUR, log: log, choices: [], broken: false }
      when 'let_it_happen'
        player.clear_event!
        log << "**Floor #{level}** — #{meta[:blurb]}"
        log << { scene: meta[:description] }
        apply_immediate_effect!(player, 'dildo_trap', level, log)
        finish = finalize_lust!(player, log)
        colour = finish[:broken] ? 0x444444 : COLOUR
        finish.merge(ok: true, mode: :done, name: data[:name], colour: colour, choices: [])
      else
        { ok: true, mode: :choice, name: data[:name], colour: COLOUR,
          log: ['Pick another option.'], choices: Engine::Exploration.trap_choices }
      end
    end

    # Shared ending for one-shot choice events: run the lust/orgasm
    # resolution and close the event out.
    def finish_choice!(player, data, log)
      player.clear_event!
      finish = finalize_lust!(player, log)
      colour = finish[:broken] ? 0x444444 : COLOUR
      finish.merge(ok: true, mode: :done, name: data[:name], colour: colour, choices: [])
    end

    def choose_confessional!(player, data, choice, _level, log)
      case choice
      when 'confess_small', 'confess_detail'
        detailed = choice == 'confess_detail'
        player.bump_tracker!('confessions_made')
        prefs = Engine::ContentOptions.preferences_for(player)
        theme_key = Engine::ContentOptions::PREFERENCES.keys.select { |k| prefs[k] }.sample
        theme = theme_key ? Engine::ContentOptions.preference(theme_key)[:label] : 'wanting'
        if detailed && rand < 0.15
          log << { scene: "You describe the #{theme.downcase} in a voice that makes the curtain stir — and the " \
                          'answering laugh, bright and filthy, is unmistakably **Syn\'s**. "Oh, petal. That one\'s ' \
                          'not a sin here. That\'s a tithe."' }
        elsif detailed
          log << { scene: "You leave nothing out — the #{theme.downcase}, in detail, at length, until the " \
                          'silence behind the screen turns appreciative. "Again," the voice murmurs, "but slower ' \
                          'this time, so I can savour your sins."' }
        else
          log << { scene: "You confess something small about #{theme.downcase}. The voice behind the screen " \
                          'absolves you with obvious disappointment. "That\'s all? The tower expected more of you."' }
        end
        Engine::Altars.gain_attention!(player, detailed ? 5 : 2, log)
        if player.tracker('confessions_made') >= 5 && !player.tracker('brother_confess').positive?
          player.set_tracker!('brother_confess', 1)
          log << { scene: 'The silence behind the screen changes quality — closer, warmer, personal. ' \
                          '"Five visits," the voice says. "Most sinners are a one-booth confession. You ' \
                          'keep coming back to *me*." A pause, pleased with itself. "Call me Brother ' \
                          'Confess, darling. And do keep coming back — I keep the good absolution for ' \
                          'regulars."' }
          log << '_Brother Confess knows you now. A new option waits in his booth._'
        end
        if detailed
          player.gain_lust!(12)
          if Engine::ContentOptions.enabled?(player, 'corruption')
            old = Engine::Corruption.level(player)
            new_level = [old + 5, Engine::Corruption::MAX].min
            if new_level > old
              player.set_tracker!(Engine::Corruption::KEY, new_level)
              Engine::Corruption.refresh!(player)
              log << "_The confession settles under your skin and stays there — **corruption #{old} → #{new_level}**._"
            end
          end
          log << 'Lust **+12** (now ' + player.lust.to_s + ').'
        end
        finish_choice!(player, data, log)
      when 'ask_indulgence'
        unless player.tracker('brother_confess').positive?
          return { ok: true, mode: :choice, name: data[:name], colour: COLOUR,
                   log: ['The voice waits.'], choices: choices_for(player, data) }
        end

        player.bump_tracker!('indulgences_taken')
        player.gain_lp!(10)
        log << { scene: '"An indulgence," Brother Confess says, in the tone of a sommelier who has been ' \
                        'waiting all evening for someone to ask, "is absolution with the flavour left in. ' \
                        'Yours, darling. On the house — the house being, as ever, her."' }
        log << '**+10 LP** — he presses something warm and coin-shaped through the slot.'
        Engine::FetishEvents.apply_condition!(player,
                                              { key: 'indulged', name: 'Indulged', floors: 3,
                                                effects: { 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.05 } }, log)
        if Engine::ContentOptions.enabled?(player, 'corruption')
          old = Engine::Corruption.level(player)
          new_level = [old + 5, Engine::Corruption::MAX].min
          if new_level > old
            player.set_tracker!(Engine::Corruption::KEY, new_level)
            Engine::Corruption.refresh!(player)
            log << "_The absolution settles under your skin and stays there — **corruption #{old} → #{new_level}**._"
          end
        end
        finish_choice!(player, data, log)
      when 'leave'
        # Sometimes the voice takes a refusal personally. It was never
        # a priest back there.
        if rand < 0.25
          player.clear_event!
          player.bump_tracker!('confessor_fights')
          named = player.tracker('brother_confess').positive?
          monster = Engine::MonsterTypes.generate_monster(_level, player: player, type: :demon)
                                        .merge(name: named ? 'Brother Confess' : 'Confessor')
          log << { scene: if named
                            'The curtain does not sigh. It opens — and Brother Confess steps out of his ' \
                            'own booth, tall, horned, and personally offended. "You confess to me five ' \
                            'times and then try to *leave* unshriven?" he says. "Darling. We discuss ' \
                            'this properly. In person. Now."'
                          else
                            'The curtain does not sigh. It opens. What steps out of the booth is tall, ' \
                            'horned, and dressed like an answer to a prayer nobody should have made — ' \
                            'and it is done listening through a screen. "Unshriven," the Confessor says, ' \
                            '"is just a sin with ambition. Let us discuss yours properly."'
                          end }
          return { ok: true, mode: :combat, name: data[:name], colour: 0x8b0000, log: log,
                   monster: monster, choices: [] }
        end

        log << 'You slip out of the booth unshriven. Behind you, the curtain sighs like it expected exactly that.'
        finish_choice!(player, data, log)
      else
        { ok: true, mode: :choice, name: data[:name], colour: COLOUR, log: ['The voice waits.'],
          choices: choices_for(player, data) }
      end
    end

    def choose_tea_ceremony!(player, data, choice, level, log)
      case choice
      when 'drink'
        player.bump_tracker!('tea_ceremonies')
        player.clear_event!
        start_timed!(player, 'tea_heat', level, 3)
      when 'refuse'
        log << 'You bow over the cup and decline. The second cup, the one poured for nobody, steams a ' \
               'moment longer — then, somewhere below the floor, something politely disappointed turns away.'
        if rand < 0.35
          type = Engine::MonsterTypes::TYPES.reject { |_, t| t[:common_monsters].empty? }.keys.sample.to_s
          player.bump_tracker!("admirer_#{type}")
          log << '_Whatever it was, it appreciated your manners. (admirer progress +1)_'
        end
        finish_choice!(player, data, log)
      when 'bottle'
        player.bump_tracker!('tea_ceremonies')
        if player.tracker('bottled_ceremony') >= 3
          gain = 6 + level
          player.gain_lp!(gain)
          log << "Your vials are full, so Berry's standing offer applies instead: **#{gain} LP** for the " \
                 'leaves, no questions asked.'
        else
          player.bump_tracker!('bottled_ceremony')
          log << { scene: 'You decant the second cup — the one poured for nobody — into a little vial and ' \
                          'stopper it with care. Somewhere below the floor, something politely ' \
                          'disappointed will simply have to wait for the next monster to drink in its place.' }
          log << "**Bottled Ceremony carried (#{player.tracker('bottled_ceremony')}/3)** — your next monster " \
                 'starts charmed by the tea, far easier to satisfy.'
        end
        finish_choice!(player, data, log)
      when 'pocket'
        gain = 6 + level
        player.bump_tracker!('tea_ceremonies')
        player.gain_lp!(gain)
        log << "You palm the dry leaves into your pouch. Berry will pay **#{gain} LP** for tea like this " \
               'and ask no questions at all.'
        finish_choice!(player, data, log)
      else
        { ok: true, mode: :choice, name: data[:name], colour: COLOUR, log: ['The tea waits.'],
          choices: choices_for(player, data) }
      end
    end

    def choose_false_exit!(player, data, choice, level, log)
      case choice
      when 'open'
        player.clear_event!
        player.bump_tracker!('false_exits_opened')
        player.set_tracker!('door_mimic_stamp', "#{player.current_cycle}:#{player.current_floor}")
        monster = Engine::MonsterTypes.generate_monster(level, player: player, type: :mimic)
                                      .merge(name: 'Door Mimic')
        log << { scene: 'The handle turns under your hand like it was expecting you. The door swings ' \
                        'wide — on hinges that are teeth, into a room that is a mouth, wearing a ' \
                        'corridor beyond like a promise. The exit was the monster. It always was.' }
        { ok: true, mode: :combat, name: data[:name], colour: 0x8b0000, log: log, monster: monster, choices: [] }
      when 'knock'
        player.bump_tracker!('false_exits_knocked')
        log << { scene: 'You knock, politely. A pause — then, delighted, something inside the door ' \
                        'knocks back. Twice. It appreciates the manners enormously, and settles back ' \
                        'into being a wall with its hunger thoroughly charmed for one evening.' }
        finish_choice!(player, data, log)
      when 'leave'
        log << 'You leave it shut. Behind you, very faintly, the door sighs through its keyhole and ' \
               'rearranges itself into a wall that has never been anything else.'
        finish_choice!(player, data, log)
      else
        { ok: true, mode: :choice, name: data[:name], colour: COLOUR, log: ['The door waits.'],
          choices: choices_for(player, data) }
      end
    end

    def choose_mirror_duet!(player, data, choice, level, log)
      case choice
      when 'embrace'
        player.bump_tracker!('gender_bending_events')
        log << { scene: 'She steps out of the glass wearing your body arranged slightly differently, and ' \
                        'meets you halfway with your own mouth — the kiss tastes like recognition. Her hands ' \
                        'map every place yours would go, because she already knows, and yours answer in kind ' \
                        'while the mirror fogs from the inside.' }
        player.gain_lust!(12)
        log << 'Lust **+12** (now ' + player.lust.to_s + ').'
        if Engine::FetishEvents::SWAPS.key?(player.gender.to_s)
          Engine::FetishEvents.gender_swap!(player, log)
        elsif Engine::ContentOptions.enabled?(player, 'futanari')
          Engine::FetishEvents.futa!(player, log)
        else
          log << { scene: 'When the glass clears she is gone, and you are exactly yourself — which feels, ' \
                          'briefly, like the stranger of the two options.' }
        end
        finish_choice!(player, data, log)
      when 'send_back'
        log << { scene: 'You press your palm flat to hers through the glass and shake your head. She mouths ' \
                        'something — **your loss** — and steps backward into your reflection, which wears her ' \
                        'smirk a moment longer than yours.' }
        if Engine::ContentOptions.enabled?(player, 'body_writing')
          player.add_condition!(
            'inked_compliment', name: 'Inked Compliment', floors: 5,
            effects: { 'satisfy_bonus' => 0.05 },
            summary: Engine::FetishEvents.describe_effects('satisfy_bonus' => 0.05)
          )
          log << { scene: 'One word stays written across your skin in silver where her hand rested — a ' \
                          'compliment, in your own handwriting. It will fade in a few floors.' }
        end
        finish_choice!(player, data, log)
      when 'fight'
        player.clear_event!
        monster = Engine::MonsterTypes.generate_monster(level, player: player, type: :mimic)
                                  .merge(name: 'Your Reflection')
        log << 'Her smile drops. Yours does too, a half-second later — she was always quicker on the draw.'
        { ok: true, mode: :combat, name: data[:name], colour: 0x8b0000, log: log, monster: monster, choices: [] }
      else
        { ok: true, mode: :choice, name: data[:name], colour: COLOUR, log: ['She waits, patient as glass.'],
          choices: choices_for(player, data) }
      end
    end

    def spring_change(player)
      dirs = []
      dirs << 1 if Engine::ContentOptions.enabled?(player, 'growth')
      dirs << -1 if Engine::ContentOptions.enabled?(player, 'shrinking')
      Engine::ContentOptions.applicable_sizes(player).keys.shuffle.each do |part|
        dirs.shuffle.each do |delta|
          old, new_size = Engine::ContentOptions.step_size(player, part, delta)
          return [part, old, new_size, delta] if old != new_size
        end
      end
      nil
    end

    def choose_hot_spring!(player, data, choice, _level, log)
      case choice
      when 'soak'
        change = spring_change(player)
        if change.nil?
          log << 'You soak until your fingers wrinkle. The spring approves of you exactly as you are — ' \
                 'nothing about you is willing to move a single size tonight.'
          return finish_choice!(player, data, log)
        end

        part, old, new_size, delta = change
        sizes = player.body_sizes.is_a?(Hash) ? player.body_sizes.dup : {}
        player.update(body_sizes: sizes.merge(part => new_size))
        player.bump_tracker!(delta.positive? ? 'body_growth_events' : 'body_reduction_events')
        player.bump_tracker!('spring_soaks')
        label = Engine::ContentOptions::BODY_SIZES[part][:label].downcase
        log << { scene: "The water takes you like it was poured for you. It is only when you climb out that " \
                        "you understand what it did: your **#{label}** — " \
                        "**#{Engine::ContentOptions.size_label(part, old)} → " \
                        "#{Engine::ContentOptions.size_label(part, new_size)}**." }
        if rand < 0.25
          player.gain_lust!(10)
          log << { scene: 'Something with leaves for hair surfaces just long enough to admire its work and ' \
                          'to run one wet, appreciative hand over the change before sinking away. The ' \
                          'Spring Keeper approves. Lust **+10** (now ' + player.lust.to_s + ').' }
        end
        finish_choice!(player, data, log)
      when 'dip'
        change = spring_change(player)
        log << if change
                 part, _old, _new_size, delta = change
                 label = Engine::ContentOptions::BODY_SIZES[part][:label].downcase
                 "One toe is enough to learn the water's intentions: it wants your **#{label}** " \
                   "**#{delta.positive? ? 'bigger' : 'smaller'}**. The rest of you stays out of its reach — for now."
               else
                 'One toe learns nothing except that the water is lovely and you are, to it, already perfect.'
               end
        finish_choice!(player, data, log)
      when 'leave'
        log << 'You leave the spring to its steam. It keeps the shape of you a moment, then lets it dissolve.'
        finish_choice!(player, data, log)
      else
        { ok: true, mode: :choice, name: data[:name], colour: COLOUR, log: ['The spring steams, waiting.'],
          choices: choices_for(player, data) }
      end
    end

    def choose_choir_loft!(player, data, choice, _level, log)
      case choice
      when 'listen'
        player.bump_tracker!('choir_listens')
        player.gain_lust!(8)
        Engine::Altars.gain_attention!(player, 8, log)
        log << { scene: 'You stay in the dark below the screen and listen to all of it — the harmony, and ' \
                        'everything the harmony is politely notating. Voices trade verses and bodies with ' \
                        'conducted precision. Nobody knows you are there. Somebody, very far above, is ' \
                        'listening to you listen.' }
        log << 'Lust **+8** (now ' + player.lust.to_s + ') · **+8 Attention** — she rewards an audience.'
        finish_choice!(player, data, log)
      when 'join'
        unless Engine::ContentOptions.enabled?(player, 'group_sex')
          return { ok: true, mode: :choice, name: data[:name], colour: COLOUR,
                   log: ['The harmony has no part written for you. Decide.'], choices: choices_for(player, data) }
        end

        player.bump_tracker!('choir_joins')
        player.gain_lust!(16)
        Engine::Altars.gain_attention!(player, 12, log)
        log << { scene: 'You step out of the dark and the screen, graciously, was never locked. The choir ' \
                        'does not stop — conductors hate that — it simply opens around you, voices and hands ' \
                        'finding your places in the arrangement, until you are not interrupting the ' \
                        'performance. You are the verse it was missing.' }
        log << 'Lust **+16** (now ' + player.lust.to_s + ') · **+12 Attention**.'
        Engine::FetishEvents.apply_condition!(player,
                                              { key: 'harmonised', name: 'Harmonised', floors: 2,
                                                effects: { 'satisfy_bonus' => 0.05, 'submit_lp_bonus' => 1 } }, log)
        finish_choice!(player, data, log)
      when 'leave'
        log << { scene: 'You slip away under the sound, unseen, unheard, and only slightly rearranged by it. ' \
                        'The harmony follows you down the corridor longer than harmony should be able to.' }
        finish_choice!(player, data, log)
      else
        { ok: true, mode: :choice, name: data[:name], colour: COLOUR, log: ['The choir sings on, waiting.'],
          choices: choices_for(player, data) }
      end
    end

    def choose_altar!(player, data, choice, _level, log)
      player.clear_event!
      Engine::Altars.resolve!(player, choice, log)
      finish = finalize_lust!(player, log)
      colour = finish[:broken] ? 0x444444 : 0x5c0a2e
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
        apply_completion!(player, type, level, log)
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

    # Rewards for enduring a timed event to its natural end (as opposed
    # to wriggling free of it, which the escape roll handles above).
    def apply_completion!(player, type, level, log)
      case type.to_s
      when 'masseuse_table'
        gain = 5 + level
        player.bump_tracker!('overstim_events')
        player.bump_tracker!('massages_endured')
        player.gain_lp!(gain)
        player.add_condition!(
          'loose_limbs', name: 'Loose Limbs', floors: 3,
          effects: { 'agility' => 2 },
          summary: Engine::FetishEvents.describe_effects('agility' => 2)
        )
        log << "You endured the whole table. **+#{gain} LP**, and you walk away **Loose Limbs** (+2 AGI) " \
               'for 3 floors, boneless and glowing.'
      when 'tea_heat'
        gain = 4 + (level / 2)
        player.gain_lp!(gain)
        log << "You ride the tea out to its last shiver. The brewer's regards arrive as **+#{gain} LP**."
      when 'feather_array'
        player.bump_tracker!('tickling_events')
        player.add_condition!(
          'ticklish', name: 'Ticklish', floors: 3,
          effects: { 'agility' => 1 },
          summary: Engine::FetishEvents.describe_effects('agility' => 1)
        )
        log << 'You survived the array — and came away **Ticklish** for 3 floors, still twitching at breezes.'
      end
    end

    def finalize_lust!(player, log)
      climax = player.try_climax!
      return { broken: false, log: log } unless climax

      log.concat(climax[:lines])
      if climax[:broken]
        loss = player.reset_run!
        curse = player.apply_defeat_curse!
        if curse[:curse]
          log << "You've been cursed with **#{curse[:curse].name}**: #{curse[:entry][:description]}"
        end
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
      when 'confessional'
        {
          name: 'The Confessional Booth',
          blurb: 'a curtain, a screen, and a listening silence.',
          description: 'A curtained booth stands where no booth should be, its grille warm as if recently ' \
                       'breathed through. A voice behind the screen — patient, amused, entirely unshockable — ' \
                       'invites you to kneel and unburden yourself.'
        }
      when 'tea_ceremony'
        {
          name: 'Aphrodisiac Tea Ceremony',
          blurb: 'steam, porcelain, and a second cup poured for nobody.',
          description: 'A low table, a pot still warm, and two cups — both poured. The tea smells of honey, ' \
                       'ginger, and decisions. Whoever set this ceremony has excellent manners and no ' \
                       'innocence whatsoever.'
        }
      when 'tea_heat'
        {
          name: 'Tea Heat',
          blurb: 'the tea goes to work.',
          description: 'It tastes of honey and warm spice for exactly one swallow. Then the heat arrives — ' \
                       'not in your throat, but low and spreading, the way good news travels.'
        }
      when 'mirror_duet'
        {
          name: 'Mirror Duet',
          blurb: 'your reflection is early.',
          description: 'A full-length mirror leans against the wall where no wall was. Your reflection is ' \
                       'already mid-step, one foot over the frame — wearing your body slightly differently, ' \
                       'and smiling like she noticed you noticing.'
        }
      when 'hot_spring'
        {
          name: 'Hot Spring of Sizes',
          blurb: 'steam over black water.',
          description: 'A spring steams in a hollow of warm stone, its black water perfectly still. A ' \
                       'warning is carved at the waterline in letters too small to read and too late to matter.'
        }
      when 'false_exit'
        {
          name: 'The False Exit',
          blurb: 'a door out, far too convenient.',
          description: 'A door stands in the wall where no door was, with light beneath it and the faint ' \
                       'smell of outside. It has a knocker, a keyhole, and — if you look very carefully — ' \
                       'a pulse.'
        }
      when 'choir_loft'
        {
          name: 'The Choir Loft',
          blurb: 'singing, behind a screen, in the dark above.',
          description: 'Above the corridor, behind a carved screen, the tower\'s unseen choir is performing — ' \
                       'many voices, perfectly arranged, and from the sounds woven under the harmony, very ' \
                       'thoroughly enjoying one another. They cannot see you. That is rather the point of ' \
                       'the architecture. Of course, someone built the loft with an audience in mind.'
        }
      when 'masseuse_table'
        {
          name: "The Masseuse's Table",
          blurb: 'warm towels, low light, and confidence.',
          description: 'A padded table, folded towels, and oil warming over a candle. You cannot see the ' \
                       "masseuse. You can count considerably more than two hands' worth of intent in the room."
        }
      when 'feather_array'
        {
          name: 'Feather Array',
          blurb: 'the feathers wake.',
          description: 'Every feather in the walls and floor stands to attention at once, and the array ' \
                       'begins its slow, rustling patrol of your skin — hundreds of soft touches, none of ' \
                       'them in a hurry, all of them coordinated.'
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
        log << { scene: 'The glass warms inside you until it feels like part of you, gliding in and out with slick, wet sounds.' }
        player.gain_lust!(5)
      when 'ribbed silicone'
        log << { scene: 'The silicone flexes and twists as it thrusts inside you, its ridges dragging over every sensitive spot it can reach.' }
        player.gain_lust!(7)
      when 'stone phallus'
        log << { scene: 'The stone starts to hum with a deep, steady thrum that you feel all the way through your body.' }
        player.gain_lust!(6)
      when 'metallic tentacle'
        log << { scene: 'The metal tentacle crackles with a faint, tingling current that makes every nerve it touches light up with pleasure.' }
        player.gain_lust!(9)
      end

      if parts.include?('vagina') || parts.include?('penis')
        log << { scene: 'The dildos fuck you right up to the edge, then retract into the wall all at once, leaving you dripping, empty and aching for more.' }
      else
        log << { scene: 'The slim dildo in your ass fucks you right up to the edge, then retracts into the wall, leaving you empty and aching for more.' }
      end
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
      when 'aphrodisiac_mist' then mist_turn!(player, parts, turn, log)
      when 'tea_heat' then tea_turn!(player, parts, turn, log)
      when 'feather_array' then feather_turn!(player, parts, turn, log)
      when 'masseuse_table' then masseuse_turn!(player, parts, turn, log)
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
        if parts.include?('vagina')
          log << { scene: 'The tentacles swell and throb, their thrusts turning erratic as they near their own release, and the one in your cunt grinds over your G-spot while the one in your ass pumps harder, until you cry out.' }
        elsif parts.include?('penis')
          log << { scene: 'The tentacles swell and throb, their thrusts turning erratic as they near their own release, and the one buried in your ass grinds against your prostate while another strokes your cock, until you cry out.' }
        else
          log << { scene: 'The tentacles swell and throb, their thrusts turning erratic as they near their own release, and the one buried in your ass grinds deep inside you until you cry out.' }
        end
        player.gain_lust!(15)
      else
        if parts.include?('vagina')
          log << { scene: 'The tentacles bury themselves deep in your cunt and ass and pulse, pumping you full of hot slime until it gushes out around them, then slither away all at once. The pit loosens and you crawl free, dripping.' }
        else
          log << { scene: 'The tentacle buries itself deep in your ass and pulses, pumping you full of hot slime until it gushes out around it, then slithers away all at once. The pit loosens and you crawl free, dripping.' }
        end
        player.gain_lust!(10)
      end
      log << "Lust now `#{player.lust}`."
    end

    def tea_turn!(player, parts, turn, log)
      case turn
      when 1
        log << { scene: 'The warmth settles low and starts to spread through you in slow waves, each one ' \
                        'finding somewhere new to be. Sitting still becomes a participation sport.' }
        player.gain_lust!(8)
      when 2
        log << { scene: 'The second wave is worse — better. Your skin feels poured, your clothes feel ' \
                        'negotiated, and the empty second cup across the table starts to feel like a promise.' }
        if parts.include?('vagina')
          log << { scene: 'Heat throbs in your pussy with every heartbeat, clit swollen, empty, and keeping ' \
                          'a patient, dripping account of every second you go unfilled.' }
        end
        if parts.include?('penis')
          log << { scene: 'Your cock stands hard and leaking under the table, throbbing in time with the ' \
                          'teapot\'s soft tick as it cools — neither of you is cooling at all.' }
        end
        player.gain_lust!(10)
      else
        log << { scene: 'The tea peaks like a held note — one long, full-body flush that leaves you ' \
                        'bright-eyed, unsteady, and entirely certain the brewer knew your name.' }
        player.gain_lust!(12)
      end
      log << "Lust now `#{player.lust}`."
    end

    def feather_turn!(player, parts, turn, log)
      case turn
      when 1
        log << { scene: 'The feathers begin at your ankles and the backs of your knees — light, expert, and ' \
                        'mercilessly coordinated. It is funny for almost four seconds.' }
        player.gain_lust!(6)
      when 2
        log << { scene: 'They find your ribs, your waist, the insides of your arms. Squirming only reassigns ' \
                        'them. Somewhere in the rustling, the array learns your worst spots and files them.' }
        player.gain_lust!(9)
      else
        log << { scene: 'The feathers converge — feet, ribs, neck, and everywhere softer at once, in waves ' \
                        'that stop a half-breath before too much and then start again. You are not being ' \
                        'punished. You are being played.' }
        if parts.include?('vagina')
          log << { scene: 'Your thighs are shaking and slick with how hard you\'ve been laughing and ' \
                          'squirming, your pussy clenching around nothing through every rustling wave.' }
        end
        if parts.include?('penis')
          log << { scene: 'You\'re hard as stone and helpless with it, every laugh making you throb while ' \
                          'the feathers keep their terrible, tickling discipline.' }
        end
        player.gain_lust!(12)
      end
      log << "Lust now `#{player.lust}`."
    end

    def masseuse_turn!(player, parts, turn, log)
      case turn
      when 1
        log << { scene: 'Warm hands — however many there are, and you stop counting at four — work oil into ' \
                        'your shoulders and back with the confidence of long practice. This part is almost ' \
                        'respectable.' }
        player.gain_lust!(5)
      when 2
        log << { scene: 'The work moves lower and slows down, thumbs circling your hips, palms dragging heat ' \
                        'down the backs of your thighs and right back up again. Respectable has left the room.' }
        player.gain_lust!(8)
      when 3
        log << { scene: 'Hands are everywhere you are sensitive at once — teasing, kneading, slipping — and ' \
                        'every time you gasp the pressure finds something new to be talented about.' }
        if parts.include?('vagina')
          log << { scene: 'Fingers slick with warm oil circle your clit and slide over your folds without ' \
                          'once giving you the pressure you\'re arching for.' }
        end
        if parts.include?('penis')
          log << { scene: 'An oiled fist wraps your cock and strokes you at exactly the pace that keeps you ' \
                          'hardest and least finished, which is clearly the house style.' }
        end
        player.gain_lust!(11)
      else
        log << { scene: 'The table makes its final argument — a dozen hands working you over in slow, ' \
                        'synchronised waves, taking you to the edge and holding you there, trembling, ' \
                        'while the masseuse finally speaks: "Same time next floor."' }
        player.gain_lust!(14)
      end
      log << "Lust now `#{player.lust}`."
    end

    def mist_turn!(player, parts, turn, log)
      case turn
      when 1
        log << { scene: Engine::ChastitySystem.line(player, :mist) ||
                        'The sweet mist sinks into your lungs and heat floods straight between your legs, your skin flushing and every nerve lighting up until you\'re squirming where you stand.' }
        player.gain_lust!(8)
      when 2
        log << { scene: 'The mist thickens. Your clothes feel like hands dragging over your sensitive skin, and your mind fills with nothing but filthy images of being touched, filled and fucked.' }
        if parts.include?('vagina')
          log << { scene: 'Heat throbs in your pussy, your clit swollen and aching, empty and desperate to be filled.' }
        end
        if parts.include?('penis')
          log << { scene: 'Your cock stands hard and leaking in your clothes, untouched and throbbing with every heartbeat.' }
        end
        player.gain_lust!(10)
      else
        if parts.include?('vagina')
          log << { scene: "You're shaking with need, grinding against the wall and squeezing your thighs together, your clit dragging against the stone just for friction, every brush of air sending a jolt through you. The mist owns you now." }
        elsif parts.include?('penis')
          log << { scene: "You're shaking with need, grinding against the wall and squeezing your thighs together, your hard cock dragging against the stone just for friction, every brush of air sending a jolt through you. The mist owns you now." }
        else
          log << { scene: "You're shaking with need, grinding against the wall, but all the friction lands on the steel sealing you — your locked sex throbs behind it, denied even this. The mist owns you now." }
        end
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
        if parts.include?('vagina')
          log << { scene: 'A thick vine sinks into your cunt and another into your ass, while the rest hold you suspended and helpless, rocking you back and forth between them.' }
        else
          log << { scene: 'A thick vine sinks into your ass — the one hole left open to it — while the rest hold you suspended and helpless, rocking you back and forth onto it.' }
        end
        player.gain_lust!(10)
        if parts.include?('breasts')
          log << { scene: 'Little flower-mouths latch onto your nipples and suckle, tugging and fluttering until your breasts ache.' }
        end
        player.gain_lust!(6)
      else
        if parts.include?('vagina')
          log << { scene: 'The vines throb in your cunt and ass and pump you full of warm nectar until it runs down your thighs, then go limp and lower you to the ground, sticky and trembling.' }
        else
          log << { scene: 'The vine throbs in your ass and pumps you full of warm nectar until it runs down your thighs, then goes limp and lowers you to the ground, sticky and trembling.' }
        end
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
        if parts.include?('vagina')
          log << { scene: 'Your fingers plunge in and out of your cunt, working you right to the edge before the spirit finally drifts out with a satisfied sigh, leaving you flushed, sticky and aching.' }
        elsif parts.include?('penis')
          log << { scene: 'Your hand strokes your cock hard and fast, working you right to the edge before the spirit finally drifts out with a satisfied sigh, leaving you flushed, sticky and aching.' }
        else
          caged_line = Engine::ChastitySystem.scenes(player, :spirit).first
          log << (caged_line || { scene: 'Your fingers drag uselessly over the steel sealing you, working you right to the edge you can never cross before the spirit finally drifts out with a satisfied sigh, leaving you flushed and aching.' })
        end
        player.gain_lust!(6)
      end
      log << "Lust now `#{player.lust}`."
    end
  end
end
