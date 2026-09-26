# frozen_string_literal: true

require_relative 'threat_calculator'
require_relative 'monster_types'
require_relative 'monster_scenes'
require_relative 'curse_catalog'
require_relative 'boss_fights'
require_relative 'exploration'

module Engine
  # CombatEngine — fight / flee / submit loop.
  # Player hits chip monster HP; monster hits raise lust (climaxes drain defiance).
  class CombatEngine
    VICTORY_LP = 15

    Encounter = Struct.new(
      :name, :type, :type_name, :color, :strength, :agility, :lust_damage, :hp, :max_hp,
      :special, :enraged, :is_boss,
      keyword_init: true
    )

    def self.start_encounter(player, monster: nil)
      new(player).start_encounter(monster: monster)
    end

    def self.act!(player, action, encounter)
      new(player).act!(action, encounter)
    end

    def self.encounter_snapshot(encounter)
      h = encounter.is_a?(Hash) ? encounter : encounter.to_h
      {
        name: h[:name] || h['name'],
        type: h[:type] || h['type'],
        type_name: h[:type_name] || h['type_name'],
        color: h[:color] || h['color'],
        strength: (h[:strength] || h['strength']).to_i,
        agility: (h[:agility] || h['agility']).to_i,
        lust_damage: (h[:lust_damage] || h['lust_damage']).to_i,
        hp: (h[:hp] || h['hp']).to_i,
        max_hp: (h[:max_hp] || h['max_hp'] || h[:hp] || h['hp']).to_i,
        special: h[:special] || h['special'],
        enraged: h[:enraged] || h['enraged'],
        is_boss: h[:is_boss] || h['is_boss']
      }
    end

    def initialize(player)
      @player = player
    end

    def start_encounter(monster: nil)
      template = monster || Exploration.generate_monster(@player.current_floor, player: @player)
      type = (template[:type] || 'beast').to_s
      info = MonsterTypes.fetch(type) || MonsterTypes.fetch(:beast)
      hp = (template[:hp] || template[:max_hp] || (18 + @player.current_floor * 4)).to_i
      max_hp = (template[:max_hp] || hp).to_i
      encounter = Encounter.new(
        name: template[:name],
        type: type,
        type_name: template[:type_name] || info[:name],
        color: template[:color] || info[:color],
        strength: template[:strength].to_i,
        agility: template[:agility].to_i,
        lust_damage: template[:lust_damage].to_i,
        hp: hp,
        max_hp: max_hp
      )

      @player.store_encounter!(self.class.encounter_snapshot(encounter))
      {
        ok: true,
        encounter: encounter,
        message: build_start_message(encounter)
      }
    end

    def act!(action, encounter)
      enc = normalize(encounter)
      # Prefer the saved encounter over a stale in_combat flag alone.
      unless @player.in_combat || @player.encounter_data
        return { ok: false, error: :not_in_combat, log: ['You are not in combat.'] }
      end
      @player.update(in_combat: true) unless @player.in_combat
      log = []
      
      # Check if this is a boss encounter
      is_boss = enc[:is_boss] || (@player.current_floor % 5).zero?

      # Apply boss special abilities if applicable
      if is_boss
        special_result = Engine::BossFights.apply_boss_special(@player, enc, action, log)
        if special_result == :blocked
          # Special denied the action (e.g. flee) — fall through to monster turn.
          action = :blocked
        end
      end

      case action.to_sym
      when :fight
        apply_fight!(enc, log)
      when :flee
        flee_result = apply_flee!(enc, log)
        return finish_flee!(enc, log) if flee_result == :fled
      when :submit
        broken = apply_submit!(enc, log)
        return finish_broken!(enc, log) if broken
      when :blocked
        # Action prevented by boss special; monster still acts.
      else
        return { ok: false, error: :unknown_action, log: ['Unknown action.'] }
      end
    
      return finish_victory!(enc, log) if enc[:hp] <= 0
    
      broken = apply_monster_turn!(enc, log)
      return finish_broken!(enc, log) if broken
    
      if @player.defiance <= 0
        if immortal_vs?(enc[:type])
          @player.update(defiance: 1)
          log << 'A curse keeps you conscious — you cannot be finished by this foe (defiance holds at **1**).'
        else
          return finish_defeat!(enc, log)
        end
      end
    
      @player.store_encounter!(enc)
      { ok: true, ongoing: true, encounter: enc, log: log }
    end

    private

    def normalize(encounter)
      type = (encounter[:type] || encounter['type'] || 'beast').to_s
      info = MonsterTypes.fetch(type)
      strength = (encounter[:strength] || encounter['strength']).to_i
      # Legacy snapshots stored STR as the hit pool — seed HP from it if missing.
      raw_hp = encounter[:hp] || encounter['hp']
      hp = raw_hp.nil? ? [strength * 5, 18].max : raw_hp.to_i
      max_hp = (encounter[:max_hp] || encounter['max_hp'] || hp).to_i
      {
        name: encounter[:name] || encounter['name'] || 'Unknown Horror',
        type: type,
        type_name: encounter[:type_name] || encounter['type_name'] || info&.dig(:name) || type.capitalize,
        color: encounter[:color] || encounter['color'] || info&.dig(:color) || 0x8b1a1a,
        strength: strength,
        agility: (encounter[:agility] || encounter['agility']).to_i,
        lust_damage: (encounter[:lust_damage] || encounter['lust_damage']).to_i,
        hp: hp,
        max_hp: max_hp,
        special: encounter[:special] || encounter['special'],
        enraged: encounter[:enraged] || encounter['enraged'],
        is_boss: encounter[:is_boss] || encounter['is_boss']
      }
    end

    # --- Damage ------------------------------------------------------------

    def player_hit_damage(enc)
      base = @player.effective_strength - (enc[:agility] / 2)
      base = base.round
      base = 1 if base < 1
      base
    end

    # Monster hits raise lust only (resistance softens; curse mults apply).
    def monster_lust_hit(enc)
      base = enc[:lust_damage] - (@player.effective_resistance / 2)
      base = (base * @player.curse_effect_product("#{enc[:type]}_damage_mult", default: 1.0)).to_f
      base *= @player.lust_damage_multiplier(monster_type: enc[:type])
      base = base.round
      base = 1 if base < 1
      base
    end

   # In lib/engine/combat.rb, modify the apply_fight! method:

  def apply_fight!(enc, log)
    damage = player_hit_damage(enc)
    enc[:hp] = [enc[:hp] - damage, 0].max
    log << "You deal **#{damage}** damage to the #{enc[:name]}! " \
           "(HP `#{enc[:hp]}/#{enc[:max_hp]}`)"
    
    climax = @player.try_climax!(monster_type: enc[:type])
  if climax
    log.concat(climax[:lines])
    if climax[:broken]
      if immortal_vs?(enc[:type])
        @player.update(defiance: 1)
        log << 'A curse keeps you conscious — you cannot be finished by this foe (defiance holds at **1**).'
        return false
      end
      log << "You've been completely broken! Game over."
      return true
    end
  end
  
  # Life drain for undead
  return unless enc[:type] == 'undead' && @player.curse_effect_flag?('undead_drain')

  drain = [damage / 2, 1].max
  @player.adjust_defiance!(drain)
  log << "Life Drain: you siphon **#{drain}** defiance! (now #{@player.defiance})"
end

    # --- Flee --------------------------------------------------------------

    def apply_flee!(enc, log)
      if @player.curse_effect_flag?("#{enc[:type]}_no_flee")
        log << "You can't escape from this monster!"
        return :blocked
      end

      flee_chance = @player.agility * 10
      flee_chance += @player.curse_effect_sum('agility') * 10
      flee_chance *= @player.curse_effect_product("#{enc[:type]}_escape_bonus", default: 1.0)
      bind = @player.curse_effect_product("#{enc[:type]}_bind_bonus", default: 1.0)
      flee_chance /= bind if bind.positive?
      flee_chance = [[flee_chance, 1].max, 100].min

      if rand(100) < flee_chance
        log << 'You successfully flee from combat!'
        :fled
      else
        log << 'You failed to escape!'
        :failed
      end
    end

    def finish_flee!(enc, log)
      @player.clear_encounter!
      { ok: true, fled: true, encounter: enc, log: log }
    end

    # --- Submit ------------------------------------------------------------

    def apply_submit!(enc, log)
      scene = MonsterScenes.generate_assault(@player, enc[:name], monster_type: enc[:type])
      log << "You submit to the #{enc[:name]}, allowing it to sexually assault you without resistance."
      log << "_#{scene}_"

      lust_increase = monster_lust_hit(enc)
      # Submit is more intense than a normal hit
      lust_increase = [(lust_increase * 1.5).round, enc[:lust_damage]].max
      lust_increase = 1 if lust_increase < 1

      @player.gain_lust!(lust_increase)
      log << "Your lust increases by **#{lust_increase}** from the willing violation! (now #{@player.lust})"

      climax = @player.try_climax!(monster_type: enc[:type])
      return false unless climax

      log.concat(climax[:lines])
      if climax[:broken]
        if immortal_vs?(enc[:type])
          @player.update(defiance: 1)
          log << 'A curse keeps you conscious — you cannot be finished by this foe (defiance holds at **1**).'
          return false
        end
        log << "You've been completely broken by the relentless assault! Game over."
        return true
      end

      false
    end

    # --- Monster turn ------------------------------------------------------

    # Returns true if the player is broken by climax.
    def apply_monster_turn!(enc, log)
      return false if enc[:hp] <= 0

      regen = @player.curse_effect_sum("#{enc[:type]}_defiance_regen").round
      if regen.positive?
        @player.adjust_defiance!(regen)
        log << "You regain **#{regen}** defiance! (now #{@player.defiance})"
      end

      lust_hit = monster_lust_hit(enc)
      @player.gain_lust!(lust_hit)

      assault_scene = MonsterScenes.generate_assault(@player, enc[:name], monster_type: enc[:type])
      log << "The #{enc[:name]} sexually assaults you! #{assault_scene}"
      log << "Your lust surges by **#{lust_hit}** from the violation! (now #{@player.lust})."

      climax = @player.try_climax!(monster_type: enc[:type])
      return false unless climax

      log.concat(climax[:lines])
      if climax[:broken]
        if immortal_vs?(enc[:type])
          @player.update(defiance: 1)
          log << 'A curse keeps you conscious — you cannot be finished by this foe (defiance holds at **1**).'
          return false
        end
        log << "You've been completely broken by the relentless assault! Game over."
        return true
      end

      false
    end

    # --- End states --------------------------------------------------------

    def finish_victory!(enc, log)
      @player.clear_encounter!

      # Check if this was a boss fight
      is_boss = enc[:is_boss] || (@player.current_floor % 5).zero?

      if is_boss
        reward = Engine::BossFights.boss_defeat_reward(@player, enc)
        @player.gain_lp!(reward[:lp])
        log << "You defeated the #{enc[:name]}! You gain **#{reward[:lp]}** Lust Points!"

        if reward[:special_item]
          item = ::Equipment.find_or_create(name: reward[:special_item]) do |e|
            e.type = 'special'
            e.slot = 'accessory'
            e.description = reward[:description]
            e.stat_modifiers = {}
            e.cost = 0
            e.rarity = 5
          end

          owned = DB[:player_equipment]
                  .where(player_id: @player.discord_id, equipment_id: item.id)
                  .first
          unless owned
            DB[:player_equipment].insert(
              player_id: @player.discord_id,
              equipment_id: item.id,
              is_equipped: false,
              acquired_at: Time.now
            )
            log << "You also received **#{reward[:special_item]}** as a trophy!"
          end
        end

        cleared = @player.current_floor
        @player.update(
          highest_boss_defeated: [cleared, @player.highest_boss_defeated.to_i].max,
          current_floor: cleared + 1
        )
        log << "The path beyond opens — you advance to **Floor #{@player.current_floor}**."
      else
        # Regular monster victory
        lp_gain = VICTORY_LP
        lp_gain = (lp_gain * @player.curse_effect_product("#{enc[:type]}_lp_mult", default: 1.0)).to_i

        if @player.curse_effect_flag?("#{enc[:type]}_no_lp")
          log << "You defeated the #{enc[:name]}! You gain no Lust Points due to your curse."
          return { ok: true, victory: true, encounter: enc, log: log, lp_gained: 0 }
        end

        lp_gain = 1 if lp_gain < 1
        @player.gain_lp!(lp_gain)
        log << "You defeated the #{enc[:name]}! You gain **#{lp_gain}** Lust Points!"
      end
      
      { ok: true, victory: true, encounter: enc, log: log }
    end

    def finish_defeat!(enc, log)
      result = @player.apply_defeat_curse!(monster_type: enc[:type])
      loss = @player.reset_run!
      @player.clear_encounter!

      log << "You've been defeated! Your run ends here."
      log << curse_affliction_line(result[:curse], result[:entry], result[:newly_afflicted])

      if loss[:level_lost] > 0 || loss[:str_lost] > 0
        log << "The dungeon's power strips your growth: back to **Level 1** " \
               "(−#{loss[:level_lost]} Lv · −#{loss[:str_lost]} STR · " \
               "−#{loss[:agi_lost]} AGI · −#{loss[:res_lost]} RES)."
      end

      log << 'Floor, defiance, and lust reset — LP, curses, and gear persist.'
      { ok: true, defeated: true, encounter: enc, log: log, curse: result[:curse] }
    end

    def finish_broken!(enc, log)
      result = @player.apply_defeat_curse!(monster_type: enc[:type])
      loss = @player.reset_run!
      @player.clear_encounter!
      log << curse_affliction_line(result[:curse], result[:entry], result[:newly_afflicted])
      if loss[:level_lost] > 0 || loss[:str_lost] > 0
        log << "The dungeon's power strips your growth: back to **Level 1** " \
               "(−#{loss[:level_lost]} Lv · −#{loss[:str_lost]} STR · " \
               "−#{loss[:agi_lost]} AGI · −#{loss[:res_lost]} RES)."
      end
      log << 'Floor, defiance, and lust reset — LP, curses, and gear persist.'
      { ok: true, broken: true, encounter: enc, log: log, curse: result[:curse] }
    end

    def immortal_vs?(type)
      @player.curse_effect_flag?("#{type}_no_death")
    end

    def curse_affliction_line(curse, entry, newly)
      if newly
        "You've been cursed with **#{curse.name}**: #{entry[:description]}"
      else
        "The brand of **#{curse.name}** burns again — you already bear this curse."
      end
    end

    def build_start_message(encounter)
      <<~MSG.strip
        **Combat!** What do you want to do?

        **#{encounter.name}** _(#{encounter.type_name})_ — HP `#{encounter.hp}/#{encounter.max_hp}` · STR `#{encounter.strength}` · AGI `#{encounter.agility}` · Lust hit `#{encounter.lust_damage}`
        Your Defiance `#{@player.defiance}` · Lust `#{@player.lust}` · STR #{@player.effective_strength} · AGI #{@player.effective_agility} · RES #{@player.effective_resistance}

        This monster will sexually assault you regardless of your choice. Choose **Fight**, **Flee**, or **Submit** — or type `!fight` / `!flee` / `!submit`.
      MSG
    end
  end
end
