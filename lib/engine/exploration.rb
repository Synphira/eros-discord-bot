# frozen_string_literal: true

require_relative 'threat_calculator'
require_relative 'monster_types'
require_relative 'boss_fights'
require_relative 'treasure'
require_relative 'random_events'

module Engine
  class Exploration
    RoomResult = Struct.new(
      :kind, :message, :colour, :with_actions, :monster, :trap, :broken,
      :event_result, keyword_init: true
    )

    TREASURE_LP = 10

    # After this many rooms on one floor without descending, the stairs are guaranteed.
    # Stairs also take a smaller share of the room pool as threat climbs — rarer, never gone.
    STAIRS_LIMITS = { low: 20, medium: 30, high: 40 }.freeze
    STAIRS_WEIGHTS = { low: 16, medium: 9, high: 4 }.freeze
    # The stairs can never appear before this many rooms on a floor.
    # Both the minimum and the guarantee grow by +5 per cycle after the first.
    STAIRS_MINIMUMS = { low: 5, medium: 10, high: 15 }.freeze
    CYCLE_ROOM_BONUS = 5

    COLOURS = {
      monster: 0x8b1a1a,
      trap: 0xb8860b,
      treasure: 0xb8860b,
      stairs: 0x4a6fa5,
      empty: 0x4a7c59,
      event: Engine::RandomEvents::COLOUR
    }.freeze

    def self.roll(player)
      new(player).roll
    end

    def self.generate_monster(floor, player: nil)
      MonsterTypes.generate_monster(floor, player: player)
    end

    def self.generate_trap
      [
        { name: 'Lust Rune', effect: :lust, value: 15 },
        { name: 'Binding Vines', effect: :agility, value: -2 },
        { name: 'Aphrodisiac Gas', effect: :lust, value: 20 },
        { name: 'Pleasure Seal', effect: :lust, value: 35 }
      ].sample
    end

    def self.trap_choices
      [
        { key: 'dodge', label: 'Dodge', text: 'Leap clear of the trap, untouched' },
        { key: 'let_it_happen', label: 'Let it happen', text: 'Stay still and take what the trap gives you' }
      ]
    end

    # What a spotted trap looks like before you decide its fate.
    def self.trap_tease(name)
      case name.to_s
      when 'Lust Rune'
        'A rune carved into the flagstone glows faintly pink, pulsing like a heartbeat. Whatever blessing it ' \
          'gives, it plainly gives between the legs.'
      when 'Binding Vines'
        'Hairline cracks in the floor breathe green, and something leafy shifts beneath them, coiling in wait ' \
          'for the weight of a body to hold.'
      when 'Aphrodisiac Gas'
        'A vent in the wall sighs sweet-smelling vapor in slow, rhythmic puffs, each one warmer than the last.'
      when 'Pleasure Seal'
        'A circle of pale light sleeps on the floor, its pattern shaped — unmistakably — like a pair of ' \
          'open, eager hands.'
      else
        'It waits, patient and hungry.'
      end
    end

    # Explicit scene for a sprung trap, matched to the body it catches.
    def self.trap_scenes(player, trap)
      parts = Engine::ChastitySystem.scene_parts(player)
      caged = Engine::ChastitySystem.caged_parts(player)
      lines =
        case trap[:name].to_s
        when 'Lust Rune'
          s = ['The rune flares rose-red beneath you and raw heat detonates between your legs, as if an invisible ' \
               'tongue had just dragged, slow and deliberate, over your most sensitive skin.']
          s << 'Your clit swells and throbs under the phantom stroking, your cunt clenching around nothing and ' \
               'dripping down your thighs while the rune pulses in time with your heartbeat.' if parts.include?('vagina')
          s << 'Your cock hardens so fast it strains, precum beading at the tip as invisible fingers seem to wrap ' \
               'and stroke you from root to head, patient and merciless.' if parts.include?('penis')
          s << 'Your nipples stiffen and ache as if pinched and rolled between hot lips, and your hole clenches ' \
               'with every pulse of the rune, desperate to be filled.' if parts.include?('breasts') && (parts & %w[vagina penis]).empty?
          s
        when 'Aphrodisiac Gas'
          s = ['Sweet gas rolls off the floor in a warm cloud and curls up between your legs. Every breath fans ' \
               'the heat lower and hotter, until your clothes feel like hands dragging over your skin.']
          s << 'Your pussy throbs with your pulse, clit swollen and slick, aching to be touched, filled, used — ' \
               'and the gas gives you nothing but more wanting.' if parts.include?('vagina')
          s << 'Your cock stands hard and leaking inside your clothes, throbbing untouched with every heartbeat, ' \
               'and the gas gives you nothing but more wanting.' if parts.include?('penis')
          s
        when 'Pleasure Seal'
          s = ['A seal of light blooms across your groin — and then ghostly hands are on you all at once, ' \
               'groping, stroking, teasing everywhere you are most sensitive, inhumanly patient and utterly thorough.']
          s << 'Phantom fingers spread your folds and plunge into your cunt while a ghost tongue works your clit, ' \
               'fucking you with touch that is not there until you are shaking and gushing around nothing.' if parts.include?('vagina')
          s << 'A phantom hand wraps your cock and strokes you hard and slow while ghost lips seal over the head ' \
               'and suck, milking strings of precum from you with touch that is not there.' if parts.include?('penis')
          s << 'Ghost mouths latch onto your nipples and suckle in turns, tugging them stiff while invisible ' \
               'fingers trail lower, lower — and never quite arrive.' if parts.include?('breasts') && (parts & %w[vagina penis]).empty?
          s
        when 'Binding Vines'
          s = ['Living vines explode from the floor and yank your wrists and ankles wide, hoisting you spread ' \
               'while nectar-slick tendrils slither under your clothes and grope boldly over every inch of you.']
          s << 'A tendril strokes your slit and circles your clit in slow, wet spirals until you are dripping, ' \
               'then slides deep into your cunt and pumps you while its brothers hold you helpless.' if parts.include?('vagina')
          s << 'A tendril coils around your cock and pumps you in slick, ridged strokes, another teasing between ' \
               'your cheeks, while the rest hold you helpless and spread.' if parts.include?('penis')
          s << 'When the vines at last go slack and dump you to the floor, your legs are trembling too hard to ' \
               'trust — they wrung every drop of steadiness out of you.'
          s
        else
          ['The trap springs, and hot, invisible hands make a thorough example of you before it lets you go.']
        end
      if (parts & %w[vagina penis]).empty? && caged.any?
        case trap[:name].to_s
        when 'Aphrodisiac Gas'
          lines << (Engine::ChastitySystem.line(player, :mist) ||
                    'Beneath your chastity everything throbs with need the gas will not let you spend.')
        when 'Binding Vines'
          lines.concat(Engine::ChastitySystem.scenes(player, :vines).map { |h| h[:scene] })
        else
          lines << 'All of it lands on the steel sealing you — the heat builds and builds behind your chastity, ' \
                   'denied even a trap\'s touch, until you are squirming against the metal.'
        end
      end
      lines
    end

    # Resolves a spotted trap the player chose not to dodge automatically.
    # Returns [detail_line, broken].
    def self.apply_trap_effect(player, trap)
      case trap[:effect].to_s
      when 'lust'
        lines = trap_scenes(player, trap)
        player.gain_lust!(trap[:value].to_i)
        lines << "Lust surges — **+#{trap[:value].to_i} Lust** (now #{player.lust})."
        climax = player.try_climax!
        if climax
          lines.concat(climax[:lines])
          if climax[:broken]
            player.reset_run!
            curse = player.apply_defeat_curse!
            if curse[:curse]
              lines << "You've been cursed with **#{curse[:curse].name}**: #{curse[:entry][:description]}"
            end
            lines << "You've been completely broken by the trap!"
            lines << 'Floor, defiance, and lust reset — LP, curses, and living gear persist; normal gear and trophies are lost.'
            return [lines.join("\n"), true]
          end
        end
        [lines.join("\n"), false]
      when 'agility'
        new_agi = [player.agility + trap[:value].to_i, 1].max
        player.update(agility: new_agi)
        [(trap_scenes(player, trap) + ["Your legs stay shaky long after — **AGI #{trap[:value].to_i}** (now #{player.agility})."]).join("\n"), false]
      else
        ['The trap fizzles harmlessly.', false]
      end
    end

    def self.resolve_trap_choice!(player, data, choice)
      trap = {
        name: data[:trap_name].to_s,
        effect: data[:trap_effect].to_s,
        value: data[:trap_value].to_i
      }
      log = []

      case choice.to_s
      when 'dodge'
        player.bump_tracker!('traps_avoided')
        log << "You leap clear of the **#{trap[:name]}** at the last moment, untouched. " \
               "_(AGI #{player.effective_agility} · #{(player.trap_avoid_chance * 100).round}% dodge chance)_"
        { ok: true, mode: :done, name: trap[:name], colour: COLOURS[:empty], broken: false, log: log, choices: [] }
      when 'let_it_happen'
        player.bump_tracker!('traps_triggered')
        detail, broken = apply_trap_effect(player, trap)
        log << "You see the **#{trap[:name]}** coming — and stay exactly where you are."
        log << detail
        log << "Lust `#{player.lust}` · Defiance `#{player.defiance}/#{player.max_defiance}` · LP `#{player.lp}` · AGI `#{player.agility}`"
        { ok: true, mode: :done, name: trap[:name], colour: broken ? 0x444444 : COLOURS[:trap], broken: broken,
          log: log, choices: [] }
      else
        { ok: false, mode: :choice, name: trap[:name], colour: COLOURS[:trap], log: ['Pick another option.'],
          choices: trap_choices }
      end
    end

    # Live stair-search state for status screens: rooms searched on this
    # floor, the earliest room stairs may appear, and the guaranteed room.
    def self.stairs_status(player)
      exp = new(player)
      threat = ThreatCalculator.calculate(player)
      {
        searched: exp.send(:rooms_on_floor),
        minimum: exp.send(:stairs_minimum, threat),
        limit: exp.send(:stairs_limit, threat)
      }
    end

    def initialize(player)
      @player = player
    end

    def roll
      result = roll_room
      if result && @departed_admirers&.any?
        goodbyes = @departed_admirers.map do |name|
          "_Your admirer, the **#{name}**, has lost your scent in the tower's halls and wanders off for good._"
        end
        result.message = (goodbyes + [result.message]).compact.join("\n\n")
      end
      result
    end

    def roll_room
      if @player.active_event?
        return pending_event_nudge
      end

      floor = @player.current_floor
      if Engine::Tower.boss_floor?(floor) && floor > @player.highest_boss_defeated.to_i
        boss = Engine::BossFights.start_boss_encounter(@player, floor)
        if boss
          colour = boss[:encounter].is_a?(Hash) ? boss[:encounter][:color] : boss[:encounter].color
          colour ||= COLOURS[:monster]
          return RoomResult.new(
            kind: :boss,
            monster: boss[:encounter],
            colour: colour,
            with_actions: true,
            message: boss[:message]
          )
        end
      end

      return sanctuary_room if @player.sanctuary

      threat = ThreatCalculator.calculate(@player)
      if stairs_guaranteed?(threat)
        room = stairs_room(force: true)
        room.message = "_You've combed every corner of Floor #{floor} — the tower can hide its stairs no longer._\n\n#{room.message}"
        return room
      end
      note_room_explored!

      court = dreaming_court?
      return manifestation_room if court && rand < 0.12

      return event_room(Engine::Altars.present!(@player)) if rand < (court ? 0.16 : 0.07)

      if (npc = Engine::NPCSystem.maybe_start!(@player))
        return event_room(npc)
      end

      if Engine::RandomEvents.should_trigger?(@player)
        return event_room(Engine::RandomEvents.start!(@player))
      end

      monster_weight = [[28 + threat.encounter_bonus, 55].min, 15].max
      rate = @player.encounter_rate_multiplier * Engine::TransformationSystem.monster_rate(@player)
      monster_weight = [[(monster_weight * rate).round, 5].max, 70].min
      # The dreaming court (floors 31-34) is sparse: Eros's own presence
      # crowds out lesser hungers. What finds you there is her.
      monster_weight = [(monster_weight * 0.6).round, 5].max if court

      # Weighted pool, normalized: high monster weight dilutes the stairs, never erases them.
      weights = {
        monster: monster_weight,
        trap: 17,
        treasure: 15,
        stairs: stairs_available?(threat) ? STAIRS_WEIGHTS.fetch(threat.category, 9) : 0,
        empty: 15
      }
      pick = rand(weights.values.sum)
      kind = weights.find { |_, w| (pick -= w) < 0 }.first

      case kind
      when :monster then monster_room
      when :trap then trap_room
      when :treasure then treasure_room
      when :stairs then stairs_room
      else empty_room
      end
    end

    private

    # Floors 31-34: Eros's dreaming court, just below her throne.
    def dreaming_court?
      wrapped = ((@player.current_floor.to_i - 1) % 35) + 1
      (31..34).cover?(wrapped)
    end

    # One-time domain intro for the section the player has just entered.
    def domain_suffix
      line = Engine::Biomes.domain_intro(@player)
      line ? "\n#{line}\n" : ''
    end

    # A partial manifestation: never her full presence below floor 35 —
    # a tentacle, a voice, warmth. The closer her Attention, the kinder.
    def manifestation_room
      attention = Engine::Altars.attention(@player)
      lines = [
        "**Floor #{@player.current_floor}** — the dreaming court stirs.",
        domain_suffix.strip,
        Engine::Biomes.line(@player)
      ].reject(&:empty?)

      if attention >= 40
        @player.gain_lp!(15)
        lines << '_Warmth closes around you like an embrace held a breath too long, and a great white ' \
                 'tentacle uncoils from nowhere to stroke your cheek — unhurried, familiar. "Almost ' \
                 'home, my attentive one," Eros murmurs, from everywhere and nowhere. "Come up. I have ' \
                 'been watching you almost as much as you have been pleasing me."_'
        lines << '**+15 LP** — her favour, pressed into your palm.'
      elsif attention >= 15
        @player.gain_lust!(8)
        lines << '_A voice with no mouth, close as breath on your ear: "Closer," Eros purrs. Something ' \
                 'vast and warm brushes the length of you and is gone, leaving your skin singing. ' \
                 '_Lust +8._'
      else
        @player.gain_lust!(5)
        lines << '_The candlelight bends toward you, all at once, like a head turning. You feel ' \
                 '**considered** — briefly, distantly, the way weather considers a field. Then it passes. ' \
                 '_Lust +5._'
      end
      lines << '_No monster finds you here. Down here, the only hunger that matters is hers._'

      broken = false
      if (climax = @player.try_climax!)
        lines.concat(Array(climax[:lines]))
        broken = climax[:broken]
        if broken
          @player.reset_run!
          curse = @player.apply_defeat_curse!
          lines << "You've been cursed with **#{curse[:curse].name}**: #{curse[:entry][:description]}" if curse[:curse]
          lines << "Even her lightest touch was too much. Floor, defiance, and lust reset — LP, curses, and living gear persist."
        end
      end

      RoomResult.new(
        kind: :empty,
        colour: 0x8b0046,
        with_actions: !broken,
        broken: broken,
        message: lines.join("\n")
      )
    end

    def floor_stamp
      "#{@player.current_cycle}:#{@player.current_floor}"
    end

    def rooms_on_floor
      return 0 unless @player.tracker_hash['rooms_floor_stamp'].to_s == floor_stamp

      @player.tracker('rooms_on_floor')
    end

    # Every cycle after the first stretches both ends of the search by +5 rooms.
    def cycle_room_bonus
      ([@player.current_cycle.to_i, 1].max - 1) * CYCLE_ROOM_BONUS
    end

    def stairs_minimum(threat)
      STAIRS_MINIMUMS.fetch(threat.category, 10) + cycle_room_bonus
    end

    def stairs_limit(threat)
      STAIRS_LIMITS.fetch(threat.category, 30) + cycle_room_bonus
    end

    # Counts the room being explored right now (the counter ticks before the
    # room roll), so the minimumth room of a floor is the earliest possible stairs.
    def stairs_available?(threat)
      rooms_on_floor >= stairs_minimum(threat)
    end

    def stairs_guaranteed?(threat)
      rooms_on_floor >= stairs_limit(threat)
    end

    def note_room_explored!
      @player.set_tracker!('rooms_floor_stamp', floor_stamp)
      @player.set_tracker!('rooms_on_floor', rooms_on_floor + 1)
      @departed_admirers = Engine::Admirers.tick_rooms!(@player)
    end

    def sanctuary_room
      @player.update(sanctuary: false)
      room = case rand(100)
             when 0...35 then treasure_room
             when 35...65
               (rooms_on_floor + 1) >= stairs_minimum(ThreatCalculator.calculate(@player)) ? stairs_room(force: true) : empty_room
             else empty_room
             end
      note = '_The bottled sanctuary shields you — this room is safe._'
      room.message = "#{note}\n\n#{room.message}"
      room.event_result[:log] = [note] + Array(room.event_result[:log]) if room.event_result
      room
    end

    def pending_event_nudge
      data = @player.event_data
      if data[:mode].to_s == 'choice'
        choices = Engine::RandomEvents.choices_for(@player, data)
        RoomResult.new(
          kind: :event,
          colour: COLOURS[:event],
          with_actions: false,
          event_result: {
            mode: :choice,
            name: data[:name],
            colour: COLOURS[:event],
            log: [
              "You are still before the **#{data[:name]}**.",
              'Choose a button below.'
            ],
            choices: choices
          },
          message: "You are still before the **#{data[:name]}**. Choose a button."
        )
      else
        RoomResult.new(
          kind: :event,
          colour: COLOURS[:event],
          with_actions: false,
          event_result: {
            mode: :continue,
            name: data[:name],
            colour: COLOURS[:event],
            log: [
              "**#{data[:name]}** still holds you.",
              "_Turn #{data[:turn]}/#{data[:duration]} — press **Continue**._"
            ],
            choices: []
          },
          message: "**#{data[:name]}** still holds you. Press **Continue**."
        )
      end
    end

    def event_room(result)
      RoomResult.new(
        kind: :event,
        colour: result[:colour] || COLOURS[:event],
        with_actions: false,
        broken: result[:broken],
        event_result: result,
        message: Array(result[:log]).map { |e| e.is_a?(Hash) ? (e[:scene] || e['scene']).to_s : e.to_s }.join("\n")
      )
    end

    def monster_room
      monster = self.class.generate_monster(@player.current_floor, player: @player)
      colour = monster[:color] || COLOURS[:monster]
      RoomResult.new(
        kind: :monster,
        monster: monster,
        colour: colour,
        with_actions: true,
        message: <<~MSG.strip
          **Floor #{@player.current_floor}** — something stirs.
          #{Engine::Biomes.line(@player)}#{domain_suffix}

          You encounter a **#{monster[:name]}** _(#{monster[:type_name]})_!
          _#{monster[:type_description]}_
          It looks hungry...
          HP #{monster[:hp]}/#{monster[:max_hp]} · STR #{monster[:strength]} · AGI #{monster[:agility]} · Lust hit #{monster[:lust_damage]}
          _Threat #{Engine::ThreatCalculator.calculate(@player).category.to_s.upcase} warps this foe._
        MSG
      )
    end

    def trap_room
      trap = self.class.generate_trap
      if rand < @player.trap_avoid_chance
        @player.store_event!(
          type: 'trap',
          mode: 'choice',
          name: trap[:name],
          level: @player.current_floor,
          trap_name: trap[:name],
          trap_effect: trap[:effect].to_s,
          trap_value: trap[:value]
        )
        return event_room(
          ok: true,
          mode: :choice,
          name: trap[:name],
          colour: COLOURS[:trap],
          log: [
            "**Floor #{@player.current_floor}** — a pressure plate clicks underfoot.",
            { scene: self.class.trap_tease(trap[:name]) },
            "You spot the **#{trap[:name]}** just in time. You could leap clear... or stay exactly where you are " \
            'and let it happen. ' \
            "_(AGI #{@player.effective_agility} · #{(@player.trap_avoid_chance * 100).round}% dodge chance — the choice is yours.)_"
          ],
          choices: self.class.trap_choices
        )
      end

      @player.bump_tracker!('traps_triggered')
      detail, broken = apply_trap!(trap)

      RoomResult.new(
        kind: :trap,
        trap: trap,
        broken: broken,
        colour: COLOURS[:trap],
        with_actions: !broken,
        message: <<~MSG.strip
          **Floor #{@player.current_floor}** — the floor gives way.
          #{domain_suffix}
          You've triggered a **#{trap[:name]}**!
          #{detail}

          Lust `#{@player.lust}` · Defiance `#{@player.defiance}/#{@player.max_defiance}` · LP `#{@player.lp}` · AGI `#{@player.agility}`
        MSG
      )
    end

    def treasure_room
      event_room(Engine::Treasure.present_chest!(@player))
    end

    # Single choke point: no caller may produce stairs before the minimum,
    # however it got here. `force:` is only for callers that already checked
    # the minimum themselves (the guarantee, a sanctuary room).
    def stairs_room(force: false)
      unless force || stairs_available?(ThreatCalculator.calculate(@player))
        return empty_room
      end

      searched = rooms_on_floor
      expired = @player.advance_floor!
      worn = Player.worn_off_line(expired)

      RoomResult.new(
        kind: :stairs,
        colour: COLOURS[:stairs],
        with_actions: true,
        message: <<~MSG.strip
          **Stairs downward** — stone steps spiral into colder dark.

          You descend to **Floor #{@player.current_floor}**.
          _Rooms searched on the floor above: **#{searched}**._
          #{Engine::Biomes.line(@player)}#{domain_suffix}
          Deepest reached: **#{Player.depth_label(@player.deepest_depth)}**.
          The threats below will be stronger.#{worn ? "\n#{worn}" : ''}
        MSG
      )
    end

    def empty_room
      RoomResult.new(
        kind: :empty,
        colour: COLOURS[:empty],
        with_actions: true,
        message: <<~MSG.strip
          **Floor #{@player.current_floor}** — silence.
          #{Engine::Biomes.line(@player)}#{domain_suffix}

          You find an empty room. Nothing of interest here.

          Defiance `#{@player.defiance}/#{@player.max_defiance}` · Lust `#{@player.lust}` · LP `#{@player.lp}`
        MSG
      )
    end

    def apply_trap!(trap)
      self.class.apply_trap_effect(@player, trap)
    end
  end
end
