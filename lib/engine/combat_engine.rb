# frozen_string_literal: true

require_relative 'threat_calculator'
require_relative 'monster_types'
require_relative 'monster_scenes'
require_relative 'curse_catalog'
require_relative 'boss_fights'
require_relative 'exploration'

module Engine
  class CombatEngine
    VICTORY_LP = 15
    BOSS_SATISFY_NEEDED = 3
    BOSS_SATISFY_LP_MULT = 1.75

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
        is_boss: h[:is_boss] || h['is_boss'],
        negation_used: h[:negation_used] || h['negation_used']
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
      start_lines = @player.apply_combat_start_effects!(type)
      message = build_start_message(encounter)
      message += "\n\n#{start_lines.join("\n")}" if start_lines.any?
      {
        ok: true,
        encounter: encounter,
        message: message
      }
    end

    def act!(action, encounter)
      enc = normalize(encounter)
      unless @player.in_combat || @player.encounter_data
        return { ok: false, error: :not_in_combat, log: ['You are not in combat.'] }
      end
      @player.update(in_combat: true) unless @player.in_combat
      log = []
      
      if action.to_sym == :flee
        @player.bump_tracker!('flee_attempts')
        @player.bump_tracker!('run_flee_attempts')
      end

      is_boss = enc[:is_boss] || (@player.current_floor % 5).zero?

      if is_boss
        special_result = Engine::BossFights.apply_boss_special(@player, enc, action, log)
        if special_result == :blocked
          action = :blocked
        end
      end

      case action.to_sym
      when :fight
        broken = apply_fight!(enc, log)
        return finish_broken!(enc, log) if broken == true
      when :flee
        flee_result = apply_flee!(enc, log)
        return finish_flee!(enc, log) if flee_result == :fled
      when :submit
        outcome = apply_submit!(enc, log)
        return finish_broken!(enc, log) if outcome == :broken
        if outcome == :satisfied
          return finish_victory!(enc, log, satisfied: true) if is_boss

          return finish_satisfied!(enc, log)
        end
      when :blocked
      else
        return { ok: false, error: :unknown_action, log: ['Unknown action.'] }
      end

      @player.check_mimic_violations!(log)
      broken = climax_from_mimics?(enc, log)
      return finish_broken!(enc, log) if broken

      return finish_victory!(enc, log) if enc[:hp] <= 0

      broken = apply_monster_turn!(enc, log, action.to_sym)
      return finish_broken!(enc, log) if broken

      @player.check_mimic_violations!(log)
      broken = climax_from_mimics?(enc, log)
      return finish_broken!(enc, log) if broken
    
      if @player.defiance <= 0
        if immortal_vs?(enc[:type])
          @player.update(defiance: 1)
          log << 'A curse keeps you conscious — you cannot be finished by this foe (defiance holds at **1**).'
        elsif !@player.try_cheat_death!(log)
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
        is_boss: encounter[:is_boss] || encounter['is_boss'],
        negation_used: encounter[:negation_used] || encounter['negation_used'],
        satisfaction: (encounter[:satisfaction] || encounter['satisfaction']).to_i
      }
    end

    def player_hit_damage(enc)
      base = @player.effective_strength - (enc[:agility] / 2)
      base = base.round
      base = 1 if base < 1
      base + @player.equipment_effect_sum('damage').round +
        @player.curse_effect_sum("#{enc[:type]}_thorns").round
    end

    def resistance_factor
      100.0 / (100 + (@player.effective_resistance * 5))
    end

    def monster_lust_hit(enc)
      base = (enc[:lust_damage] * resistance_factor) - @player.effective_lust_resist
      base = (base * @player.curse_effect_product("#{enc[:type]}_damage_mult", default: 1.0)).to_f
      base *= @player.lust_damage_multiplier(monster_type: enc[:type])
      base = base.round
      base = 1 if base < 1
      base
    end

    def apply_fight!(enc, log)
      damage = Engine::Dev.debug?(@player) ? enc[:hp] : player_hit_damage(enc)
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

      return false unless enc[:type] == 'undead' && @player.curse_effect_flag?('undead_drain')

      drain = @player.heal_defiance!([damage / 2, 1].max)
      log << "Life Drain: you siphon **#{drain}** defiance! (now #{@player.defiance}/#{@player.max_defiance})"
      false
    end

    def dodge_chance(enc)
      base = 0.1 + (0.02 * (@player.effective_agility - (enc[:agility].to_i / 2.0)))
      base += @player.curse_effect_sum('dodge_bonus') + @player.curse_effect_sum("#{enc[:type]}_dodge_bonus")
      base.clamp(0.05, 0.5)
    end

    def apply_flee!(enc, log)
      if @player.curse_effect_flag?("#{enc[:type]}_no_flee")
        log << "You can't escape from this monster!"
        return :blocked
      end
      if @player.curse_effect_flag?('no_flee') && !Engine::Dev.debug?(@player)
        log << "Something holds you in place — a condition you're under won't let you run!"
        return :blocked
      end

      flee_chance = @player.effective_agility * 10.0
      flee_chance *= 1.0 + @player.flee_bonus
      flee_chance *= @player.curse_effect_product("#{enc[:type]}_escape_bonus", default: 1.0)
      flee_chance *= @player.curse_effect_product("#{enc[:type]}_escape_penalty", default: 1.0)
      bind = @player.curse_effect_product("#{enc[:type]}_bind_bonus", default: 1.0)
      flee_chance /= bind if bind.positive?
      flee_chance = [[flee_chance.round, 1].max, 100].min
      flee_chance = 100 if Engine::Dev.debug?(@player)

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

    def apply_submit!(enc, log)
      lp_reward = 1 + (enc[:strength].to_i / 2)
      lp_reward += (@player.curse_effect_sum('submit_lp_bonus') +
                    @player.curse_effect_sum("#{enc[:type]}_submit_lp")).round
      lp_reward = [lp_reward, 1].max
      @player.gain_lp!(lp_reward)
      @player.bump_tracker!('submissions')
      @player.bump_tracker!('run_submissions')
      @player.bump_tracker!("#{enc[:type]}_submissions")
      demon_kind = demon_kind(enc)
      @player.bump_tracker!("#{demon_kind}_submissions") if demon_kind
      log << "You submit to the #{enc[:name]}, gaining **#{lp_reward}** Lust Points for your willingness."

      scene = MonsterScenes.generate_willing_scene(@player, enc[:name], monster_type: enc[:type])
      log << { scene: scene }
      log << { scene: MonsterScenes.generate_praise(@player, enc[:name], enc[:type]) }

      lust_increase = (monster_lust_hit(enc) * 0.5).round
      @player.gain_lust!(lust_increase)
      log << "Your lust increases by **#{lust_increase}** from the passionate encounter! (now #{@player.lust})"

      climax = @player.try_climax!(monster_type: enc[:type])
      if climax
        log.concat(climax[:lines])
        if climax[:broken]
          if immortal_vs?(enc[:type])
            @player.update(defiance: 1)
            log << 'A curse keeps you conscious — you cannot be finished by this foe (defiance holds at **1**).'
          else
            log << "You've been completely consumed by pleasure! Game over."
            return :broken
          end
        end
      end

      chance = monster_satisfy_chance(enc)
      return boss_submit_roll!(enc, log, chance) if enc[:is_boss]

      if rand < chance
        log << "The #{enc[:name]} shudders with pleasure, completely satisfied by your submission!"
        log << 'The monster, now spent, lets you slip away without further incident.'
        return :satisfied
      end

      log << "The #{enc[:name]} isn't satisfied yet _(#{(chance * 100).round}% chance)_…"
      nil
    end

    def boss_submit_roll!(enc, log, chance)
      if rand < chance
        enc[:satisfaction] = enc[:satisfaction].to_i + 1
        if enc[:satisfaction] >= BOSS_SATISFY_NEEDED
          log << "The #{enc[:name]} arches and cries out, **completely satisfied**!"
          log << 'Spent and sated, it lets you pass deeper into the tower.'
          return :satisfied
        end
        log << "The #{enc[:name]} moans, clearly enjoying you — **satisfaction #{enc[:satisfaction]}/#{BOSS_SATISFY_NEEDED}** " \
               "_(#{(chance * 100).round}% per submit)_. It wants more…"
      else
        log << "The #{enc[:name]} is unimpressed — satisfaction stays at **#{enc[:satisfaction]}/#{BOSS_SATISFY_NEEDED}** " \
               "_(#{(chance * 100).round}% per submit)_."
      end
      nil
    end

    def monster_satisfy_chance(_enc = {})
      chance = (0.2 + (@player.effective_submission * 0.1) + @player.curse_effect_sum('satisfy_bonus')).clamp(0.05, 0.8)
      chance = 1.0 if Engine::Dev.debug?(@player)
      chance
    end

    def demon_kind(enc)
      name = enc[:name].to_s.downcase
      return 'succubus' if name.include?('succubus')
      return 'incubus' if name.include?('incubus')

      nil
    end

    def award_combat_end_bonus!(log)
      bonus = @player.curse_effect_sum('victory_lp_bonus').round
      return unless bonus.positive?

      @player.gain_lp!(bonus)
      log << "_Your conditions reward the encounter's end: **+#{bonus} LP**._"
    end

    def finish_satisfied!(enc, log)
      award_combat_end_bonus!(log)
      @player.clear_encounter!
      { ok: true, satisfied: true, encounter: enc, log: log }
    end

    def climax_from_mimics?(enc, log)
      climax = @player.try_climax!(monster_type: enc[:type])
      return false unless climax

      log.concat(climax[:lines])
      return false unless climax[:broken]

      if immortal_vs?(enc[:type])
        @player.update(defiance: 1)
        log << 'A curse keeps you conscious — you cannot be finished by this foe (defiance holds at **1**).'
        return false
      end

      log << "You've been broken by your own living gear! Game over."
      true
    end

    def apply_monster_turn!(enc, log, action = nil)
      return false if enc[:hp] <= 0
      return false if Engine::Dev.debug?(@player)

      regen = @player.equipment_effect_sum('defiance_regen').round
      if regen.positive?
        gained = @player.heal_defiance!(regen)
        log << "Your gear restores **#{gained}** defiance. (now #{@player.defiance}/#{@player.max_defiance})" if gained.positive?
      end

      negation = @player.curse_effect_sum('negation_chance')
      if !enc[:negation_used] && negation.positive? && rand < negation
        enc[:negation_used] = true
        log << "Your flesh briefly merges with a nearby object — the #{enc[:name]}'s attack is **absorbed**! " \
               '_(Phantom Latch, once per combat)_'
        return false
      end

      if enc[:type] != 'undead' && rand >= @player.curse_effect_product('accuracy', default: 1.0)
        log << "The #{enc[:name]} flinches from your necrotic aura and **misses** you!"
        return false
      end

      if action != :submit && rand < dodge_chance(enc)
        log << "You twist aside — the #{enc[:name]} grabs only air! _(dodged · #{(dodge_chance(enc) * 100).round}%)_"
        return false
      end

      lust_hit = monster_lust_hit(enc)
      @player.gain_lust!(lust_hit)

      log << "The #{enc[:name]} closes in and gets its hands on you!"
      assault_scene = MonsterScenes.generate_assault(@player, enc[:name], monster_type: enc[:type])
      log << { scene: assault_scene }
      log << "Your lust rises by **#{lust_hit}**. (now #{@player.lust})"
      hit_lp = @player.curse_effect_sum('hit_lp').round
      if hit_lp.positive?
        @player.gain_lp!(hit_lp)
        log << "_Being handled like this earns you **+#{hit_lp} LP**._"
      end

      climax = @player.try_climax!(monster_type: enc[:type])
      return false unless climax

      log.concat(climax[:lines])
      if climax[:broken]
        if immortal_vs?(enc[:type])
          @player.update(defiance: 1)
          log << 'A curse keeps you conscious — you cannot be finished by this foe (defiance holds at **1**).'
          return false
        end
        log << "The relentless pleasure overwhelms you completely! Game over."
        return true
      end

      false
    end

    def finish_victory!(enc, log, satisfied: false)
      award_combat_end_bonus!(log)
      @player.clear_encounter!

      is_boss = enc[:is_boss] || (@player.current_floor % 5).zero?
      kind = demon_kind(enc)
      @player.bump_tracker!("#{kind}_defeats") if kind && !satisfied

      if is_boss
        @player.bump_tracker!('bosses_defeated')
        @player.bump_tracker!('bosses_satisfied') if satisfied
        @player.remember!('bosses_seen', enc[:name].to_s)
        note_broodmother_feat!(enc, log) unless satisfied
        reward = Engine::BossFights.boss_defeat_reward(@player, enc)
        return finish_tower_clear!(enc, log) if reward[:tower_clear]

        lp = reward[:lp].to_i
        lp = (lp * BOSS_SATISFY_LP_MULT).round if satisfied
        @player.gain_lp!(lp)
        if satisfied
          log << "You satisfied the #{enc[:name]}! You gain **#{lp}** Lust Points " \
                 "_(×#{BOSS_SATISFY_LP_MULT} for winning through submission)_!"
        else
          log << "You defeated the #{enc[:name]}! You gain **#{lp}** Lust Points!"
        end

        if reward[:special_item]
          Engine::BossFights.sync_trophies!
          item = ::Equipment.first(name: reward[:special_item])
          slot_free = @player.equipment_for_slot(Player::TROPHY_SLOT).nil?
          grant = @player.grant_equipment!(item, auto_equip: slot_free)
          if grant[:ok]
            log << "You also received **#{reward[:special_item]}** as a trophy! _(#{item.description})_"
            log << "_Only one trophy can be worn at a time — swap with `/equip #{item.name}`._" unless slot_free
          elsif grant[:error] == :duplicate
            log << "You already carry **#{reward[:special_item]}** — no duplicate trophy."
          else
            log << grant[:message]
          end
        end

        cleared = @player.current_floor
        @player.update(
          highest_boss_defeated: [cleared, @player.highest_boss_defeated.to_i].max
        )
        expired = @player.advance_floor!
        log << "The path beyond opens — you advance to **Floor #{@player.current_floor}**."
        worn = Player.worn_off_line(expired)
        log << worn if worn
      else
        lp_gain = VICTORY_LP
        lp_gain = (lp_gain * @player.curse_effect_product("#{enc[:type]}_lp_mult", default: 1.0)).to_i
        lp_gain += @player.curse_effect_sum("#{enc[:type]}_lp_bonus").round

        @player.bump_tracker!('monsters_killed')
        if @player.curse_effect_flag?("#{enc[:type]}_no_lp")
          log << "You defeated the #{enc[:name]}! You gain no Lust Points due to your curse."
          return { ok: true, victory: true, encounter: enc, log: log, lp_gained: 0 }
        end

        lp_gain = (lp_gain * @player.cycle_multiplier).round
        lp_gain = 1 if lp_gain < 1
        @player.gain_lp!(lp_gain)
        log << "You defeated the #{enc[:name]}! You gain **#{lp_gain}** Lust Points!"
      end
      
      { ok: true, victory: true, encounter: enc, log: log }
    end

    BROODMOTHER_CURSED_ITEMS = 5

    def note_broodmother_feat!(enc, log)
      return unless enc[:name] == Engine::BossFights::BOSSES[5][:name]
      return if @player.tracker('mimic_broodmother_cursed').positive?
      return if @player.equipped_mimics.size < BROODMOTHER_CURSED_ITEMS

      @player.set_tracker!('mimic_broodmother_cursed', 1)
      log << 'Despite being draped in living gear, you have defeated the Mimic Broodmother!'
      log << 'The remaining mimics bow to you, recognizing you as one of their own.'
    end

    def finish_tower_clear!(enc, log)
      clear = @player.complete_cycle!
      log << "**#{enc[:name]} falls!** The Endless Ruins shudder — you have conquered the tower!"
      log << "Tower clear reward: **+#{clear[:lp]} LP**."
      log << "The ruins twist and reset around you. You awaken on **Floor 1** of **Cycle #{clear[:new_cycle]}** — " \
             'your level, stats, LP, and every piece of gear come with you.'
      log << "_Monsters now have ×#{@player.cycle_multiplier.round(2)} base stats, and LP rewards grow to match. " \
             'Fall, and you return to Cycle 1._'
      worn = Player.worn_off_line(clear[:conditions_expired])
      log << worn if worn
      { ok: true, victory: true, tower_cleared: true, encounter: enc, log: log }
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

      if loss[:gear_lost]&.any?
        log << "Your non-cursed gear and trophies are lost: #{loss[:gear_lost].map { |n| "**#{n}**" }.join(', ')}."
      end
      if loss[:curses_reactivated]&.any?
        log << "Your suppressed curses **reawaken**: #{loss[:curses_reactivated].map { |n| "**#{n}**" }.join(', ')}."
      end
      log << "You are cast out of **Cycle #{loss[:cycle_lost]}** — the tower begins again from **Cycle 1**." if loss[:cycle_lost]
      log << 'Floor, defiance, and lust reset — LP, curses, and living (cursed) gear persist.'
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
      if loss[:gear_lost]&.any?
        log << "Your non-cursed gear and trophies are lost: #{loss[:gear_lost].map { |n| "**#{n}**" }.join(', ')}."
      end
      if loss[:curses_reactivated]&.any?
        log << "Your suppressed curses **reawaken**: #{loss[:curses_reactivated].map { |n| "**#{n}**" }.join(', ')}."
      end
      log << "You are cast out of **Cycle #{loss[:cycle_lost]}** — the tower begins again from **Cycle 1**." if loss[:cycle_lost]
      log << 'Floor, defiance, and lust reset — LP, curses, and living (cursed) gear persist.'
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
        Your Defiance `#{@player.defiance}/#{@player.max_defiance}` · Lust `#{@player.lust}` · STR #{@player.effective_strength} · AGI #{@player.effective_agility} · RES #{@player.effective_resistance}

        This monster wants you whatever you choose. Choose **Fight**, **Flee**, or **Submit** — or type `!fight` / `!flee` / `!submit`.
      MSG
    end
  end
end
