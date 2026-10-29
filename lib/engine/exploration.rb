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
      :event_result, :boss_intro, keyword_init: true
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

    # tag: the content toggle a trap hides behind (nil = always possible).
    TRAP_POOL = [
      { name: 'Lust Rune', effect: :lust, value: 15 },
      { name: 'Binding Vines', effect: :agility, value: -2 },
      { name: 'Aphrodisiac Gas', effect: :lust, value: 20 },
      { name: 'Pleasure Seal', effect: :lust, value: 35 },
      { name: 'Kiss Ward', effect: :kiss, value: 8 },
      { name: 'Honey Floor', effect: :honey, value: 2 },
      { name: 'Shrinking Doorway', effect: :shrink, value: 3, tag: 'shrinking' },
      { name: 'Compliment Ward', effect: :compliment, value: 5, tag: 'body_writing' },
      { name: 'Feather Array', effect: :feather, value: 3, tag: 'tickling' },
      { name: 'Alarm Bells', effect: :alarm, value: 12, tag: 'exhibitionism' },
      { name: 'Waxworks', effect: :wax, value: 3, tag: 'temperature' }
    ].freeze

    def self.generate_trap(player = nil)
      pool = TRAP_POOL
      if player
        pool = pool.select { |t| t[:tag].nil? || Engine::ContentOptions.enabled?(player, t[:tag]) }
      end
      pool.sample.dup.tap { |t| t.delete(:tag) }
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
      when 'Kiss Ward'
        'A rune shaped like a pair of lips hovers at mouth height, puckered and patient. It does not ' \
          'look like it wants blood. It looks like it wants a kiss, blown politely across the room.'
      when 'Honey Floor'
        'The flagstones ahead gleam amber and slow-looking, and the air smells like a bakery in a ' \
          'beehive. Every step across that shine would be a decision.'
      when 'Shrinking Doorway'
        'The doorway ahead was built for someone much, much smaller — and the lintel glows faintly, ' \
          'the way the tower glows when it intends to make things fit.'
      when 'Compliment Ward'
        'A ward drawn in silver ink sleeps across the floor, its script looping in a hand too elegant ' \
          'for whatever it is clearly about to write on somebody.'
      when 'Feather Array'
        'Feathers. Hundreds of them, mounted in the walls and floor at every height, all trembling ' \
          'slightly in a breeze that is not blowing.'
      when 'Alarm Bells'
        'A tripwire at ankle height, strung with small, bright, extremely well-polished bells. ' \
          'Nothing about it looks dangerous. Everything about it looks loud.'
      when 'Waxworks'
        'The floor ahead is a shallow lake of warm wax, smooth as a ballroom, still steaming gently. ' \
          'Figures stand in it at intervals — statues, presumably. Presumably.'
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
        when 'Kiss Ward'
          s = ['The lips unfold from the wall and claim their toll directly — a phantom mouth seals over ' \
               'yours, warm and unhurried, kissing you deep and thorough while heat pools low in your belly. ' \
               'When it finally releases your lips, it keeps the kiss. You can feel it leave with it, blown ' \
               'ahead of you down the corridor like a promise.']
          s << 'Whatever it finds first is going to get that kiss exactly as you just received it.'
          s
        when 'Shrinking Doorway'
          s = ['The lintel flares and the world politely enlarges around you — walls rearing, floor dropping ' \
               'away, your own clothes suddenly a great deal more clothing than you remember buying. The ' \
               'doorway accepts you at its preferred size, and keeps the difference.']
          s << 'Everything interesting is now at a height that requires commitment to reach.'
          s
        when 'Compliment Ward'
          s = ['The silver script unspools from the floor and writes itself across your skin in elegant, ' \
               'glowing letters, unhurried as a lover\'s finger tracing the words first.']
          s << "Where anyone can read it, you now say: **#{Engine::FetishEvents::BODY_WRITING.sample.upcase}** — " \
               'in a hand far too pretty for the sentiment.'
          s
        when 'Honey Floor'
          s = ['The shine is honey, ankle-deep and in no hurry at all. It takes your boots, then your ' \
               'balance, then your dignity, in that order — every step a slow, sticky negotiation while the ' \
               'sweet smell of you rolls ahead down the corridor, announcing dinner to anything with a nose.']
          s
        when 'Alarm Bells'
          s = ['Your ankle finds the wire and the corridor erupts in bright, musical announcement. The ' \
               'bells are rigged through your clothes with a tailor\'s spite — every step, every shift, ' \
               'every indecent little movement rings out down the tower in polished little notes. Somewhere ' \
               'below, things are already turning to listen.']
          s << 'It is, objectively, a wonderful sound. That is the worst part. You can feel yourself starting to move like someone being listened to.'
          s
        when 'Waxworks'
          s = ['The wax takes your legs to the knee and sets its terms: warm, slow, and thorough. It climbs ' \
               'as you wade, sheeting over you in smooth, heavy layers, hands of it shaping as it goes — ' \
               'smoothing here, accentuating there, an invisible sculptor with strong opinions and warmer ' \
               'hands. By the far shore you move like a statue being carried.']
          s << 'Where it sets, it sets beautifully. That will be its own problem, shortly.'
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

    # Shared ending for traps that raise lust: orgasm check, and the
    # full broken-by-a-trap resolution when it overwhelms the delver.
    def self.trap_finish_lust!(player, lines)
      climax = player.try_climax!
      return [lines.join("\n"), false] unless climax

      lines.concat(climax[:lines])
      return [lines.join("\n"), false] unless climax[:broken]

      player.reset_run!
      curse = player.apply_defeat_curse!
      if curse[:curse]
        lines << "You've been cursed with **#{curse[:curse].name}**: #{curse[:entry][:description]}"
      end
      lines << "You've been completely broken by the trap!"
      lines << 'Floor, defiance, and lust reset — LP, curses, and living gear persist; normal gear and trophies are lost.'
      [lines.join("\n"), true]
    end

    # Resolves a spotted trap the player chose not to dodge automatically.
    # Returns [detail_line, broken].
    def self.apply_trap_effect(player, trap)
      case trap[:effect].to_s
      when 'lust'
        lines = trap_scenes(player, trap)
        player.gain_lust!(trap[:value].to_i)
        lines << "Lust surges — **+#{trap[:value].to_i} Lust** (now #{player.lust})."
        trap_finish_lust!(player, lines)
      when 'kiss'
        player.set_tracker!('kiss_ward', 1)
        lines = trap_scenes(player, trap)
        player.gain_lust!(trap[:value].to_i)
        lines << 'Your blown kiss drifts ahead of you — **the next monster you meet starts charmed** ' \
                 '(admirer progress for its kind, or a refreshed admirer).'
        lines << "Lust **+#{trap[:value].to_i}** (now #{player.lust})."
        trap_finish_lust!(player, lines)
      when 'shrink'
        lines = trap_scenes(player, trap)
        if player.condition?('towering')
          lines << 'You are far too large to be shrunk politely — the doorway wedges you fast until you ' \
                   'wriggle through by main force, dignity in tatters. _(Too large to shrink.)_'
          return [lines.join("\n"), false]
        end

        player.bump_tracker!('body_reduction_events')
        player.add_condition!(
          'pocket_sized', name: 'Shrunken', floors: trap[:value].to_i,
          effects: { 'strength' => -2, 'agility' => 1 },
          summary: Engine::FetishEvents.describe_effects('strength' => -2, 'agility' => 1)
        )
        lines << "**Shrunken** for **#{trap[:value].to_i} floors** — smaller, weaker, and quicker on tiny feet."
        [lines.join("\n"), false]
      when 'compliment'
        lines = trap_scenes(player, trap)
        player.bump_tracker!('body_writing_events')
        player.add_condition!(
          'inked_compliment', name: 'Inked Compliment', floors: trap[:value].to_i,
          effects: { 'satisfy_bonus' => 0.05 },
          summary: Engine::FetishEvents.describe_effects('satisfy_bonus' => 0.05)
        )
        player.gain_lust!(10)
        lines << "The ink stays for **#{trap[:value].to_i} floors** — monsters read it, and lean in closer. " \
                 'Lust **+10** (now ' + player.lust.to_s + ').'
        trap_finish_lust!(player, lines)
      when 'honey'
        lines = trap_scenes(player, trap)
        player.add_condition!(
          'honey_slowed', name: 'Honey-Slowed', floors: 1,
          effects: { 'agility' => -2, 'beast_encounter_rate' => 1.5 },
          summary: Engine::FetishEvents.describe_effects('agility' => -2, 'beast_encounter_rate' => 1.5)
        )
        player.gain_lust!(5)
        lines << '**Honey-Slowed** until you leave this floor — and the smell of you draws beasts closer.'
        trap_finish_lust!(player, lines)
      when 'alarm'
        player.set_tracker!('alarm_bells', 1)
        lines = trap_scenes(player, trap)
        player.gain_lust!(trap[:value].to_i)
        lines << 'The bells stay rigged through your clothes — **your next encounter starts watched**: ' \
                 'an audience, a little extra lust, and a monster showing off for the crowd.'
        lines << "Lust **+#{trap[:value].to_i}** (now #{player.lust})."
        trap_finish_lust!(player, lines)
      when 'wax'
        lines = trap_scenes(player, trap)
        player.add_condition!(
          'wax_slowed', name: 'Wax-Slowed', floors: 1,
          effects: { 'agility' => -2 },
          summary: Engine::FetishEvents.describe_effects('agility' => -2)
        )
        player.add_condition!(
          'sculpted', name: 'Sculpted', floors: trap[:value].to_i,
          effects: { 'satisfy_bonus' => 0.08 },
          summary: Engine::FetishEvents.describe_effects('satisfy_bonus' => 0.08)
        )
        player.gain_lust!(10)
        lines << '**Wax-Slowed** for this floor — then the wax finishes setting into **Sculpted** ' \
                 "(#{trap[:value].to_i} floors): monsters keep complimenting the workmanship, and lean in. " \
                 'Lust **+10** (now ' + player.lust.to_s + ').'
        trap_finish_lust!(player, lines)
      when 'feather'
        Engine::RandomEvents.note_seen!(player, 'feather_array')
        result = Engine::RandomEvents.start_timed!(player, 'feather_array', player.current_floor, trap[:value].to_i)
        lines = result[:log].map { |e| e.is_a?(Hash) ? (e[:scene] || e['scene']).to_s : e.to_s }
        [lines.join("\n"), result[:broken] ? true : false]
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

    # The weighted room pool for this player right now. `rooms_offset`
    # projects stairs eligibility a few rooms ahead, which is how the
    # Pale Cartographer's sketches are rolled before they are served.
    def pool_weights(threat, rooms_offset: 0)
      monster_weight = [[28 + threat.encounter_bonus, 55].min, 15].max
      rate = @player.encounter_rate_multiplier * Engine::TransformationSystem.monster_rate(@player)
      monster_weight = [[(monster_weight * rate).round, 5].max, 70].min
      # The dreaming court (floors 31-34) is sparse: Eros's own presence
      # crowds out lesser hungers. What finds you there is her.
      monster_weight = [(monster_weight * 0.6).round, 5].max if dreaming_court?

      # Weighted pool, normalized: high monster weight dilutes the stairs, never erases them.
      # Deep floors carry a little more loose wealth (chest achievements
      # are long ladders, and the tower is richer the further it falls).
      {
        monster: monster_weight,
        trap: 17,
        treasure: @player.current_floor.to_i > 20 ? 19 : 15,
        stairs: (rooms_on_floor + rooms_offset) >= stairs_minimum(threat) ? STAIRS_WEIGHTS.fetch(threat.category, 9) : 0,
        empty: 15
      }.each_with_object({}) do |(kind, w), out|
        if w.to_i <= 0
          out[kind] = 0
        else
          scaled = (w * Engine::Seasons.room_weight_mult(kind)).round
          out[kind] = [[scaled, 1].max, 90].min
        end
      end
    end

    def projected_pool_kinds(count)
      threat = ThreatCalculator.calculate(@player)
      count.times.map do |i|
        # The room counter ticks before each room is served, so the
        # first sketched room is projected one room ahead of the count.
        weights = pool_weights(threat, rooms_offset: i + 1)
        pick = rand(weights.values.sum)
        weights.find { |_, w| (pick -= w) < 0 }.first.to_s
      end
    end

    def roll
      result = roll_room
      if result && (strip = Engine::Residents.sketch_strip(@player))
        result.message = [result.message, strip].compact.join("\n")
      end
      if result && @departed_admirers&.any?
        goodbyes = @departed_admirers.flat_map do |entry|
          lines = ["_#{Engine::Admirers.farewell_line(entry)}_"]
          gift = Engine::Admirers.parting_gift!(@player, entry)
          lines << gift if gift
          lines
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
            with_actions: !boss[:pre_fight],
            boss_intro: boss[:pre_fight] ? true : false,
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

      # A Cartographer's sketch is served exactly as drawn, before the
      # soft gates (manifestations, altars, NPCs, random events) roll:
      # what he sketched is the room you get. Only the hard gates above
      # (a boss floor, a bottled sanctuary, the guaranteed stairs)
      # override it, and overriding never consumes the queue. A sketched
      # descent is forced — he only draws stairs the land already leaned
      # toward, so a threat shift since the purchase cannot swallow them.
      if (sketched = Engine::Residents.consume_sketch!(@player))
        return case sketched.to_sym
               when :monster then monster_room
               when :trap then trap_room
               when :treasure then treasure_room
               when :stairs then stairs_room(force: true)
               else empty_room
               end
      end

      court = dreaming_court?
      return manifestation_room if court && rand < 0.12

      return event_room(Engine::Altars.present!(@player)) if rand < (court ? 0.16 : 0.07)

      if (npc = Engine::NPCSystem.maybe_start!(@player))
        return event_room(npc)
      end

      if Engine::RandomEvents.should_trigger?(@player)
        return event_room(Engine::RandomEvents.start!(@player))
      end

      weights = pool_weights(threat)
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
                 'vast and warm brushes the length of you and is gone, leaving your skin singing._'
        lines << '_Lust +8._'
      else
        @player.gain_lust!(5)
        lines << '_The candlelight bends toward you, all at once, like a head turning. You feel ' \
                 '**considered** — briefly, distantly, the way weather considers a field. Then it passes._'
        lines << '_Lust +5._'
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

    # After a Door Mimic, the rest of the floor's doors stay suspect.
    def door_paranoia_line
      return '' unless @player.tracker_hash['door_mimic_stamp'].to_s == floor_stamp

      '_You check the door twice before trusting it. Professionally._'
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
      Engine::RandomEvents.tick_longing!(@player)
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

      # A Basilisk is met eyes-first: the fight waits on your nerve.
      if monster[:name].to_s.include?('Basilisk')
        @player.store_event!(
          type: 'basilisk', mode: 'choice', name: 'Basilisk',
          level: @player.current_floor, monster: monster
        )
        return event_room(
          ok: true,
          mode: :choice,
          name: 'Basilisk',
          colour: monster[:color] || COLOURS[:monster],
          log: [
            "**Floor #{@player.current_floor}** — scales, sliding over stone, in no hurry at all.",
            { scene: 'She is beautiful the way deep water is beautiful, and her eyes catch the light ' \
                     'before the rest of her does — amber, slit, and already fixed on yours. The Basilisk ' \
                     'does not charge. She waits to see what your eyes decide.' },
            'Avert your eyes and fight her half-blind (your hits land softer), or meet the gaze and ' \
            'gamble your composure on your Resistance.'
          ],
          choices: Engine::RandomEvents.choices_for(@player, { type: 'basilisk' })
        )
      end

      # The Gorgon Matron, the Basilisk's older sister, does not do
      # checks. She does negotiations.
      if monster[:name].to_s.include?('Gorgon Matron')
        @player.store_event!(
          type: 'gorgon', mode: 'choice', name: 'Gorgon Matron',
          level: @player.current_floor, monster: monster
        )
        return event_room(
          ok: true,
          mode: :choice,
          name: 'Gorgon Matron',
          colour: monster[:color] || COLOURS[:monster],
          log: [
            "**Floor #{@player.current_floor}** — a salon of statues, every one of them mid-plea.",
            { scene: 'She is coiled at the centre of her collection like a hostess among old guests — ' \
                     'serpent-crowned, magnificent, and entirely aware of the effect. "My little sister ' \
                     'turns them to stone out there," the Gorgon Matron remarks, "for looking. I am ' \
                     'civilised. I negotiate first."' },
            'Offer tribute and fight under truce (she starts charmed), talk her around with your best ' \
            'manners, or avert your eyes and fight her half-blind.'
          ],
          choices: Engine::RandomEvents.choices_for(@player, { type: 'gorgon' })
        )
      end

      @player.set_tracker!('door_mimic_stamp', floor_stamp) if monster[:name].to_s.include?('Door Mimic')
      colour = monster[:color] || COLOURS[:monster]
      RoomResult.new(
        kind: :monster,
        monster: monster,
        colour: colour,
        with_actions: true,
        message: <<~MSG.strip
          **Floor #{@player.current_floor}** — something stirs.
          #{Engine::Biomes.line(@player)}#{domain_suffix}
          #{monster[:name].to_s.include?('Door Mimic') ? 'The door ahead of you opens its eyes. The exit was the monster, and it has been waiting with its handle politely still for someone to try to leave.' : ''}
          You encounter a **#{monster[:name]}** _(#{monster[:type_name]})_!
          _#{monster[:type_description]}_
          #{Engine::ThreatCalculator.monster_opener(@player)}
          It looks hungry...
          HP #{monster[:hp]}/#{monster[:max_hp]} · STR #{monster[:strength]} · AGI #{monster[:agility]} · Lust hit #{monster[:lust_damage]}
          _Threat #{Engine::ThreatCalculator.calculate(@player).category.to_s.upcase} warps this foe._
        MSG
      )
    end

    def trap_room
      trap = self.class.generate_trap(@player)
      pip_spotted = @player.tracker('pip_spotting').positive?
      if pip_spotted || rand < @player.trap_avoid_chance
        @player.set_tracker!('pip_spotting', 0) if pip_spotted
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
            *(pip_spotted ? ["_Pip's Queen-watching pays off — she marked this one for you._"] : []),
            { scene: self.class.trap_tease(trap[:name]) },
            "You spot the **#{trap[:name]}** just in time. You could leap clear... or stay exactly where you are " \
            'and let it happen. ' \
            "_(AGI #{@player.effective_agility} · #{(@player.trap_avoid_chance * 100).round}% dodge chance — the choice is yours.)_"
          ],
          choices: self.class.trap_choices
        )
      end

      @player.bump_tracker!('traps_triggered')
      @player.set_tracker!('last_trap_name', trap[:name])
      if @player.tracker('pip_wedges').positive?
        @player.set_tracker!('pip_wedges', @player.tracker('pip_wedges') - 1)
        return RoomResult.new(
          kind: :trap,
          trap: trap,
          broken: false,
          colour: COLOURS[:trap],
          with_actions: true,
          message: <<~MSG.strip
            **Floor #{@player.current_floor}** — the floor gives way.

            You've triggered a **#{trap[:name]}** — and Pip's scavenged wedge slams home a breath before the mechanism does. Springs shriek, plates lock, and the trap dies jammed and harmless around the little wedge. _The land will grow around it shortly. So that happened._

            Lust `#{@player.lust}` · Defiance `#{@player.defiance}/#{@player.max_defiance}` · LP `#{@player.lp}` · Wedges left `#{@player.tracker('pip_wedges')}`
          MSG
        )
      end
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
          #{door_paranoia_line}
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
          #{door_paranoia_line}
          Defiance `#{@player.defiance}/#{@player.max_defiance}` · Lust `#{@player.lust}` · LP `#{@player.lp}`
        MSG
      )
    end

    def apply_trap!(trap)
      self.class.apply_trap_effect(@player, trap)
    end
  end
end
