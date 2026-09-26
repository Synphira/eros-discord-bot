# frozen_string_literal: true

require_relative 'threat_calculator'

module Engine
  # CombatEngine — minimal encounter loop for /explore to call.
  #
  # Starts a simple monster encounter scaled by Threat category, then
  # resolves a single exchange (player strike + monster strike). Enough
  # surface for Discord buttons without a full combat sim yet.
  #
  # Threat scaling:
  #   :low    — weak foe, light damage, modest LP reward
  #   :medium — standard foe
  #   :high   — brutal foe, high damage, richer LP / curse risk stub
  #
  class CombatEngine
    Encounter = Struct.new(
      :monster_name, :monster_hp, :monster_damage, :lp_reward, :threat, keyword_init: true
    )

    MONSTER_TABLE = {
      low: [
        { name: 'Dripping Skitter', hp: 20, damage: 8, lp_reward: 5 },
        { name: 'Whispering Mote', hp: 15, damage: 6, lp_reward: 4 }
      ],
      medium: [
        { name: 'Velvet Stalker', hp: 40, damage: 14, lp_reward: 12 },
        { name: 'Ashen Bound', hp: 35, damage: 16, lp_reward: 14 }
      ],
      high: [
        { name: 'Abyssal Bride', hp: 70, damage: 24, lp_reward: 25 },
        { name: 'Seal Warden Fragment', hp: 80, damage: 28, lp_reward: 30 }
      ]
    }.freeze

    def self.start_encounter(player)
      new(player).start_encounter
    end

    def self.resolve_round(player, surge_effects: nil)
      new(player).resolve_round(surge_effects: surge_effects)
    end

    def self.end_encounter(player, victory:)
      new(player).end_encounter(victory: victory)
    end

    def initialize(player)
      @player = player
      @threat = ThreatCalculator.calculate(player)
    end

    # Put the player into combat and roll a threat-scaled monster.
    # Stores a lightweight encounter snapshot on the instance; callers that
    # need persistence across Discord interactions should keep monster state
    # in memory / DB later — for now we re-roll lightly each resolve if needed.
    def start_encounter
      template = MONSTER_TABLE.fetch(@threat.category, MONSTER_TABLE[:medium]).sample
      encounter = Encounter.new(
        monster_name: template[:name],
        monster_hp: template[:hp],
        monster_damage: template[:damage],
        lp_reward: template[:lp_reward],
        threat: @threat
      )

      @player.update(in_combat: true)
      {
        ok: true,
        encounter: encounter,
        message: build_start_message(encounter)
      }
    end

    # One exchange: player deals fixed-ish damage, monster hits back.
    # surge_effects may include :damage_multiplier / :damage_taken_multiplier.
    def resolve_round(surge_effects: nil, monster_hp: 30, monster_damage: 12, monster_name: 'Unknown Horror')
      unless @player.in_combat
        return { ok: false, error: :not_in_combat, message: 'You are not in combat.' }
      end

      effects = surge_effects || {}
      player_damage = (12 * (effects[:damage_multiplier] || 1.0)).round
      incoming = (monster_damage * (effects[:damage_taken_multiplier] || 1.0)).round

      remaining_monster = [monster_hp - player_damage, 0].max
      log = []
      log << "You strike the #{monster_name} for **#{player_damage}** damage."

      if remaining_monster <= 0
        result = end_encounter(victory: true, lp_reward: effects[:lp_reward] || 10)
        log << result[:message]
        return { ok: true, victory: true, log: log, monster_hp: 0 }.merge(result)
      end

      outcome = @player.take_damage!(incoming)
      log << "The #{monster_name} hits you for **#{incoming}** damage."

      if outcome == :died
        log << 'You fall. The dungeon claims this run — **floor resets to 1**. LP and curses endure.'
        return {
          ok: true,
          victory: false,
          died: true,
          log: log,
          monster_hp: remaining_monster
        }
      end

      {
        ok: true,
        victory: false,
        died: false,
        log: log,
        monster_hp: remaining_monster,
        player_hp: @player.hp
      }
    end

    def end_encounter(victory:, lp_reward: 10)
      @player.update(in_combat: false)
      if victory
        @player.gain_lp!(lp_reward)
        {
          ok: true,
          message: "The foe collapses. You claim **+#{lp_reward} LP**.",
          lp_gained: lp_reward
        }
      else
        { ok: true, message: 'The encounter ends.', lp_gained: 0 }
      end
    end

    private

    def build_start_message(encounter)
      bar = threat_bar(encounter.threat.percent)
      <<~MSG.strip
        A **#{encounter.monster_name}** bars the path!
        Threat: **#{encounter.threat.category.upcase}** (#{encounter.threat.percent}%) #{bar}
        Enemy HP: #{encounter.monster_hp} · Bite: ~#{encounter.monster_damage}
      MSG
    end

    def threat_bar(percent)
      ThreatCalculator # keep constant reference for readers
      filled = [[(percent / 10).floor, 10].min, 0].max
      empty = 10 - filled
      "`[#{'█' * filled}#{'░' * empty}]`"
    end
  end
end
