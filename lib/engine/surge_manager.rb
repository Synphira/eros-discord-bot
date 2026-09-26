# frozen_string_literal: true

module Engine
  # SurgeManager — 1-turn LP Overdrive Surges usable while in combat.
  #
  # Built-in surges (cost LP, last one turn / one resolve tick):
  #   Sensory Overdrive  — heighten perception; slight damage bonus flavor
  #   Hardened Aura      — reduce incoming damage this turn
  #   Willpower Flush    — clear a mental debuff stub / small heal
  #   Desperate Escape   — attempt to flee combat (ends encounter on success)
  #
  # Curse-Derived Surges: hook via register_curse_surge — unlocked when the
  # player bears a matching active curse (stub registry for future content).
  #
  class SurgeManager
    Surge = Struct.new(:key, :name, :cost, :description, :effect, keyword_init: true)

    BUILTIN = {
      sensory_overdrive: Surge.new(
        key: :sensory_overdrive,
        name: 'Sensory Overdrive',
        cost: 15,
        description: 'Heighten every nerve for one turn — strike harder.',
        effect: :damage_boost
      ),
      hardened_aura: Surge.new(
        key: :hardened_aura,
        name: 'Hardened Aura',
        cost: 20,
        description: 'LP hardens into a brief shield against the next blow.',
        effect: :damage_reduce
      ),
      willpower_flush: Surge.new(
        key: :willpower_flush,
        name: 'Willpower Flush',
        cost: 10,
        description: 'Burn LP to steady the mind and knit a little flesh.',
        effect: :heal
      ),
      desperate_escape: Surge.new(
        key: :desperate_escape,
        name: 'Desperate Escape',
        cost: 25,
        description: 'Spend LP to tear free of the encounter — if luck holds.',
        effect: :flee
      )
    }.freeze

    # Optional curse-derived surge registry: curse_name => Surge
    @curse_surges = {}

    class << self
      attr_reader :curse_surges

      def register_curse_surge(curse_name, surge)
        @curse_surges[curse_name.to_s] = surge
      end
    end

    def self.activate(player, surge_key)
      new(player).activate(surge_key)
    end

    def initialize(player)
      @player = player
    end

    # Available surges: builtins + any curse-derived unlocked by active curses.
    def available_surges
      list = BUILTIN.values.dup
      @player.active_curses.each do |curse|
        derived = self.class.curse_surges[curse.name]
        list << derived if derived
      end
      list
    end

    def find_surge(key)
      key = key.to_sym
      BUILTIN[key] || available_surges.find { |s| s.key == key }
    end

    # Attempt to fire a 1-turn surge. Fails gracefully if not in combat or LP short.
    # Returns a Hash: { ok:, error:, surge:, message:, side_effects: }
    def activate(surge_key)
      unless @player.in_combat
        return { ok: false, error: :not_in_combat, message: 'Surges only work in the heat of combat.' }
      end

      surge = find_surge(surge_key)
      unless surge
        return { ok: false, error: :unknown_surge, message: "Unknown surge: #{surge_key}" }
      end

      unless @player.spend_lp!(surge.cost)
        return {
          ok: false,
          error: :insufficient_lp,
          message: "Need #{surge.cost} LP for #{surge.name} (have #{@player.lp})."
        }
      end

      side_effects = apply_effect(surge)
      {
        ok: true,
        surge: surge,
        message: "#{surge.name} ignites for one turn! (−#{surge.cost} LP)",
        side_effects: side_effects
      }
    end

    private

    def apply_effect(surge)
      case surge.effect
      when :damage_boost
        { damage_multiplier: 1.5, turns: 1 }
      when :damage_reduce
        { damage_taken_multiplier: 0.5, turns: 1 }
      when :heal
        healed = 15
        @player.heal!(healed)
        { healed: healed, turns: 1 }
      when :flee
        # ~60% chance to break combat; caller / CombatEngine may refine.
        success = rand < 0.6
        @player.update(in_combat: false) if success
        { fled: success, turns: 1 }
      else
        { turns: 1 }
      end
    end
  end
end
