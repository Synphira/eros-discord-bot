# frozen_string_literal: true

require_relative 'threat_calculator'
require_relative 'monster_types'
require_relative 'boss_fights'
require_relative 'treasure'
require_relative 'random_events'

module Engine
  # Exploration — weighted room roll for /explore and !explore.
  #
  #   event chance first (when not in an active event)
  #   then: monster / trap / treasure / stairs / empty
  #
  class Exploration
    RoomResult = Struct.new(
      :kind, :message, :colour, :with_actions, :monster, :trap, :broken,
      :event_result, keyword_init: true
    )

    TREASURE_LP = 10

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

    def initialize(player)
      @player = player
    end

    def roll
      # Finish / resume pending events before a new room.
      if @player.active_event?
        return pending_event_nudge
      end

      # Boss gate once per floor multiple of 5 (not every explore on that floor).
      floor = @player.current_floor
      if (floor % 5).zero? && floor > @player.highest_boss_defeated.to_i
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

      # Random lewd events (not during combat).
      if Engine::RandomEvents.should_trigger?(@player)
        return event_room(Engine::RandomEvents.start!(@player))
      end

      # Regular room type roll — high Threat biases toward monster encounters.
      threat = ThreatCalculator.monster_modifiers(@player)
      monster_chance = [[28 + threat.encounter_bonus, 55].min, 15].max
      monster_chance = [[(monster_chance * @player.encounter_rate_multiplier).round, 5].max, 70].min
      trap_end = monster_chance + 17
      treasure_end = trap_end + 15
      stairs_end = treasure_end + 15

      room_type = rand(100)

      if room_type < monster_chance
        monster_room
      elsif room_type < trap_end
        trap_room
      elsif room_type < treasure_end
        treasure_room
      elsif room_type < stairs_end
        stairs_room
      else
        empty_room
      end
    end

    private

    # Bottled Sanctuary: one guaranteed-safe room (treasure, stairs, or empty).
    def sanctuary_room
      @player.update(sanctuary: false)
      room = case rand(100)
             when 0...35 then treasure_room
             when 35...65 then stairs_room
             else empty_room
             end
      room.message = "_The bottled sanctuary shields you — this room is safe._\n\n#{room.message}"
      room
    end

    def pending_event_nudge
      data = @player.event_data
      if data[:mode].to_s == 'choice'
        choices = Engine::RandomEvents.glory_hole_choices(@player)
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
      detail, broken = apply_trap!(trap)

      RoomResult.new(
        kind: :trap,
        trap: trap,
        broken: broken,
        colour: COLOURS[:trap],
        with_actions: !broken,
        message: <<~MSG.strip
          **Floor #{@player.current_floor}** — the floor gives way.

          You've triggered a **#{trap[:name]}**!
          #{detail}

          Lust `#{@player.lust}` · Defiance `#{@player.defiance}/#{@player.max_defiance}` · LP `#{@player.lp}` · AGI `#{@player.agility}`
        MSG
      )
    end

    def treasure_room
      result = Engine::Treasure.open_chest(@player)
      broken = result[:broken]

      RoomResult.new(
        kind: :treasure,
        broken: broken,
        colour: COLOURS[:treasure],
        with_actions: !broken,
        message: result[:lines].join("\n")
      )
    end

    def stairs_room
      @player.advance_floor!

      RoomResult.new(
        kind: :stairs,
        colour: COLOURS[:stairs],
        with_actions: true,
        message: <<~MSG.strip
          **Stairs downward** — stone steps spiral into colder dark.

          You descend to **Floor #{@player.current_floor}**.
          Deepest reached: **#{@player.highest_floor_reached}**.
          The threats below will be stronger.
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

          You find an empty room. Nothing of interest here.

          Defiance `#{@player.defiance}/#{@player.max_defiance}` · Lust `#{@player.lust}` · LP `#{@player.lp}`
        MSG
      )
    end

    # Returns [detail_string, broken?]
    def apply_trap!(trap)
      case trap[:effect]
      when :lust
        @player.gain_lust!(trap[:value])
        lines = ["Lust surges — **+#{trap[:value]} Lust** (now #{@player.lust})."]
        climax = @player.try_climax!
        if climax
          lines.concat(climax[:lines])
          if climax[:broken]
            @player.reset_run!
            lines << "You've been completely broken by the trap! Your run ends here."
            lines << 'Floor, defiance, and lust reset — LP, curses, and living gear persist; normal gear is lost.'
            return [lines.join("\n"), true]
          end
        end
        [lines.join("\n"), false]
      when :agility
        new_agi = [@player.agility + trap[:value], 1].max
        @player.update(agility: new_agi)
        ["Vines cinch tight — **AGI #{trap[:value]}** (now #{@player.agility}).", false]
      else
        ['The trap fizzles harmlessly.', false]
      end
    end
  end
end
