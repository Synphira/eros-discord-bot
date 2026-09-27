# frozen_string_literal: true

require 'json'

# ---------------------------------------------------------------------------
# Player — Discord-bound dungeon delver.
#
# Game rules encoded here:
#   • Endless dungeon: climb floors toward the Seal of the Abyss.
#   • Death: floor resets to 1; LP and persistent curses carry over.
#   • LP boosts endurance and fuels 1-turn Overdrive Surges.
#   • High LP raises Threat (see Engine::ThreatCalculator).
#   • Character sheet: gender, body parts, defiance, lust, combat stats.
# ---------------------------------------------------------------------------
class Player < Sequel::Model(:players)
  MAX_LP_BASE = 100
  MAX_DEFIANCE = 100

  plugin :timestamps, update_on_create: true
  plugin :serialization, :json, :body_parts
  set_primary_key :discord_id
  unrestrict_primary_key

  many_to_many :curses,
               left_key: :player_id,
               right_key: :curse_id,
               join_table: :player_curses

  one_to_many :player_curse_rows,
              class: :PlayerCurse,
              key: :player_id

  many_to_many :equipment,
               class: :Equipment,
               left_key: :player_id,
               right_key: :equipment_id,
               join_table: :player_equipment

  one_to_many :player_equipment_rows,
              class: :PlayerEquipment,
              key: :player_id

  plugin :validation_helpers

  def validate
    super
    validates_presence %i[discord_id hp max_hp lp current_floor gender level defiance lust]
    validates_operator(:>=, 0, :hp)
    validates_operator(:>=, 0, :lp)
    validates_operator(:>=, 0, :lust)
    validates_operator(:>=, 0, :defiance)
    validates_operator(:>=, 1, :current_floor)
    validates_operator(:>=, 1, :level)
  end

  # --- Factory -------------------------------------------------------------

  # Build a fresh delver from a CharacterArchetypes entry.
  def self.create_from_archetype!(discord_id:, archetype:, submission: 0)
    create(
      discord_id: discord_id,
      gender: archetype[:gender],
      body_parts: archetype[:body_parts],
      level: 1,
      defiance: MAX_DEFIANCE,
      lust: 0,
      strength: 5,
      agility: 5,
      resistance: 5,
      submission: submission.to_i,
      pos_x: 0,
      pos_y: 0,
      hp: 100,
      max_hp: 100,
      lp: 0,
      current_floor: 1,
      highest_floor_reached: 1,
      in_combat: false
    )
  end

  def submission_display
    CharacterArchetypes.submission_label(submission)
  end

  def body_parts_list
    parts = body_parts
    parts.is_a?(Array) ? parts : []
  end

  def body_parts_display
    list = body_parts_list
    list.empty? ? '_none_' : list.join(', ')
  end

  # --- Curse helpers -------------------------------------------------------

  def active_curses
    curses_dataset.where(Sequel[:player_curses][:is_suppressed] => false).all
  end

  def suppressed_curses
    curses_dataset.where(Sequel[:player_curses][:is_suppressed] => true).all
  end

  def active_curse_count
    curses_dataset.where(Sequel[:player_curses][:is_suppressed] => false).count
  end

  # Flatten active curse effect maps: key => [values...]
  def curse_effect_bags
    bags = Hash.new { |h, k| h[k] = [] }
    active_curses.each do |curse|
      curse.stat_modifiers.each do |key, value|
        bags[key.to_s] << value
      end
    end
    bags
  end

  def curse_effect_sum(key)
    curse_effect_bags[key.to_s].sum { |v| v.is_a?(Numeric) ? v.to_f : 0.0 }
  end

  def curse_effect_product(key, default: 1.0)
    vals = curse_effect_bags[key.to_s].select { |v| v.is_a?(Numeric) }
    return default if vals.empty?

    product = vals.reduce(1.0) { |acc, v| acc * v.to_f }
    product <= 0 ? default : product
  end

  def curse_effect_flag?(key)
    curse_effect_bags[key.to_s].any? { |v| v == true || v.to_s == 'true' }
  end

  def effective_strength
    base = [strength + curse_effect_sum('strength').round, 1].max
    [base + equipment_effect_sum('strength').round, 1].max
  end

  def effective_agility
    base = [agility + curse_effect_sum('agility').round, 1].max
    [base + equipment_effect_sum('agility').round, 1].max
  end

  def effective_resistance
    base = [resistance + curse_effect_sum('resistance').round, 1].max
    [base + equipment_effect_sum('resistance').round, 1].max
  end

  def effective_lust_resist
    (equipment_effect_sum('lust_resist') + curse_effect_sum('lust_resist')).round
  end

  def effective_submission
    submission.to_i + equipment_effect_sum('submission').round
  end

  # Global + type-specific lust multipliers (curses and gear) for the current foe.
  def lust_damage_multiplier(monster_type: nil)
    mult = curse_effect_product('lust_mult', default: 1.0)
    mult *= equipment_effect_product('lust_mult')
    mult *= curse_effect_product('damage_reduction', default: 1.0)
    if monster_type
      mult *= curse_effect_product("#{monster_type}_lust_mult", default: 1.0)
    end
    mult <= 0 ? 1.0 : mult
  end

  # Multiplier on the chance an explore room is a monster room.
  def encounter_rate_multiplier
    curse_effect_product('encounter_rate', default: 1.0) * equipment_effect_product('encounter_rate')
  end

  def flee_bonus
    equipment_effect_sum('flee_bonus')
  end

  def max_lp_base
    MAX_LP_BASE
  end

  # --- Life / death / run reset --------------------------------------------

  # Defiance is the delver's HP: "max HP" effects raise the defiance cap.
  def max_defiance
    bonus = curse_effect_sum('max_hp_bonus') + equipment_effect_sum('max_hp')
    [MAX_DEFIANCE + bonus.round, 1].max
  end

  def starting_defiance
    mult = curse_effect_product('defiance_start', default: 1.0)
    [[(max_defiance * mult).round, 1].max, max_defiance].min
  end

  # Lust never rests below this (Infernal Lust: meter starts 30% higher).
  def base_lust
    [[curse_effect_sum('lust_start_bonus').round, 0].max, CLIMAX_THRESHOLD - 10].min
  end

  # Restorative defiance gains, scaled by healing curses (e.g. Deathly Resilience).
  def heal_defiance!(amount)
    scaled = (amount * curse_effect_product('healing_mult', default: 1.0)).round
    scaled = 1 if amount.positive? && scaled < 1
    before = defiance
    adjust_defiance!(scaled)
    defiance - before
  end

  def clamp_defiance!
    update(defiance: max_defiance) if defiance > max_defiance
  end

  # Lich's Phylactery: once per run, survive a finishing blow.
  def try_cheat_death!(lines)
    return false if phylactery_used
    return false unless equipment_effect_flag?('cheat_death')

    restored = [(max_defiance / 2.0).round, 1].max
    update(defiance: restored, lust: base_lust, phylactery_used: true)
    lines << "**Lich's Phylactery** cracks and pulls your soul back! Defiance restored to **#{restored}** " \
             '_(once per run)_.'
    true
  end

  # Full run wipe after defeat or being broken.
  # LP, curses, and cursed mimic gear persist; normal equipment is lost.
  def reset_run!
    old_level = level
    old_str = strength
    old_agi = agility
    old_res = resistance

    stripped = strip_non_cursed_equipment!

    update(
      level: 1,
      strength: 5,
      agility: 5,
      resistance: 5,
      defiance: starting_defiance,
      lust: base_lust,
      current_floor: 1,
      pos_x: 0,
      pos_y: 0,
      in_combat: false,
      active_encounter: nil,
      active_event: nil,
      highest_boss_defeated: 0,
      phylactery_used: false
    )

    {
      level_lost: [old_level - 1, 0].max,
      str_lost: [old_str - 5, 0].max,
      agi_lost: [old_agi - 5, 0].max,
      res_lost: [old_res - 5, 0].max,
      gear_lost: stripped
    }
  end

  # Bump lifetime deepest floor (never decreases; survives reset_run!).
  def note_floor_reached!(floor = current_floor)
    floor = floor.to_i
    return current_floor if floor < 1

    best = [highest_floor_reached.to_i, floor].max
    attrs = {}
    attrs[:current_floor] = floor if floor != current_floor
    attrs[:highest_floor_reached] = best if best > highest_floor_reached.to_i
    update(attrs) unless attrs.empty?
    current_floor
  end

  # Advance one floor down and record the new deepest.
  def advance_floor!
    note_floor_reached!(current_floor + 1)
  end

  def encounter_data
    raw = self[:active_encounter]
    return nil if raw.nil? || raw.to_s.strip.empty?

    data = JSON.parse(raw)
    data.is_a?(Hash) ? data.transform_keys(&:to_sym) : nil
  rescue JSON::ParserError
    nil
  end

  def store_encounter!(snapshot)
    payload = snapshot.is_a?(Hash) ? snapshot : snapshot.to_h
    update(in_combat: true, active_encounter: JSON.generate(payload))
  end

  def clear_encounter!
    update(in_combat: false, active_encounter: nil)
  end

  # --- Random events (choice / multi-turn) ----------------------------------

  def event_data
    raw = self[:active_event]
    return nil if raw.nil? || raw.to_s.strip.empty?

    data = JSON.parse(raw)
    data.is_a?(Hash) ? data.transform_keys(&:to_sym) : nil
  rescue JSON::ParserError
    nil
  end

  def active_event?
    !event_data.nil?
  end

  def store_event!(snapshot)
    payload = snapshot.is_a?(Hash) ? snapshot : snapshot.to_h
    update(active_event: JSON.generate(payload.transform_keys(&:to_s)))
  end

  def clear_event!
    update(active_event: nil)
  end

  # Drop a stale in_combat flag left after a restart with no saved monster.
  # Returns the encounter hash if combat is still valid.
  def reconcile_encounter!
    data = encounter_data
    if data
      update(in_combat: true) unless in_combat
      return data
    end

    clear_encounter! if in_combat
    nil
  end

  alias die! reset_run!

  def dead?
    defiance <= 0
  end

  def take_damage!(amount)
    adjust_defiance!(-amount)
    if dead?
      reset_run!
      :died
    else
      :survived
    end
  end

  def restore_defiance!(amount)
    heal_defiance!(amount)
  end

  # Afflict a curse from the defeating monster's type catalog.
  def apply_defeat_curse!(monster_type: nil)
    Engine::CurseCatalog.sync_to_db!
    entry = Engine::CurseCatalog.sample_for(monster_type)
    curse = Curse.first(name: entry[:name])
    curse ||= Curse.create(
      name: entry[:name],
      category: Engine::CurseCatalog::CATEGORY_FOR_TYPE.fetch(monster_type.to_s, 'Abyssal'),
      description: entry[:description],
      stat_modifier_json: JSON.generate(entry[:effects])
    )
    afflicted = afflict!(curse)
    { curse: curse, entry: entry, newly_afflicted: afflicted }
  end

  def spend_lp!(cost)
    return false if lp < cost

    update(lp: lp - cost)
    true
  end

  def gain_lp!(amount)
    update(lp: lp + amount)
  end

  # Level-up shop. Costs: STR/AGI/RES = 10 LP; Level = 50 LP (+1 all stats).
  STAT_UPGRADE_COST = 10
  LEVEL_UPGRADE_COST = 50

  def upgrade_stat!(stat)
    stat = stat.to_sym
    unless %i[strength agility resistance].include?(stat)
      return { ok: false, error: :unknown_stat, message: 'Unknown stat.' }
    end
    return { ok: false, error: :insufficient_lp, message: "You don't have enough Lust Points!" } unless spend_lp!(STAT_UPGRADE_COST)

    new_value = public_send(stat) + 1
    update(stat => new_value)
    {
      ok: true,
      stat: stat,
      value: new_value,
      message: "Your #{stat} increased to **#{new_value}**! (LP left: #{lp})"
    }
  end

  def upgrade_level!
    return { ok: false, error: :insufficient_lp, message: "You don't have enough Lust Points!" } unless spend_lp!(LEVEL_UPGRADE_COST)

    update(
      level: level + 1,
      strength: strength + 1,
      agility: agility + 1,
      resistance: resistance + 1
    )
    {
      ok: true,
      level: level,
      message: "You leveled up to **#{level}**! All stats increased by 1 " \
               "(STR #{strength} · AGI #{agility} · RES #{resistance}). LP left: #{lp}"
    }
  end

  CLIMAX_THRESHOLD = 100
  CLIMAX_DEFIANCE_LOSS = 20

  def gain_lust!(amount)
    update(lust: lust + amount)
  end

  # If lust is at/over the climax threshold: clear lust, lose defiance, optional climax LP.
  # Returns nil when no climax, otherwise { lines:, broken: }.
  def try_climax!(monster_type: nil)
    return nil if lust < CLIMAX_THRESHOLD

    lines = []
    update(lust: base_lust)

    type = monster_type&.to_s
    climax_lp = type ? curse_effect_sum("#{type}_climax_lp").round : 0
    if climax_lp.positive?
      gain_lp!(climax_lp)
      lines << "You gain **#{climax_lp}** Lust Points from climaxing!"
    end

    adjust_defiance!(-CLIMAX_DEFIANCE_LOSS)
    lines << "You climax! Your defiance drops by **#{CLIMAX_DEFIANCE_LOSS}**! (now #{defiance}/#{max_defiance})"

    broken = defiance <= 0
    # A no-death curse already saves you from this foe; keep the phylactery charge.
    immortal = type && curse_effect_flag?("#{type}_no_death")
    broken = false if broken && !immortal && try_cheat_death!(lines)

    { lines: lines, broken: broken }
  end

  def adjust_defiance!(delta)
    update(defiance: [[defiance + delta, 0].max, max_defiance].min)
  end

  # --- Shrine / curse removal ----------------------------------------------

  CURSE_REMOVE_COST = 50

  # Stable ordered list of active curses for numbered menus.
  def active_curses_ordered
    active_curses.sort_by { |c| [Engine::CurseCatalog.type_for(c.name).to_s, c.name] }
  end

  # Group active curses by monster-type key for display.
  def curses_grouped_by_type
    groups = Hash.new { |h, k| h[k] = [] }
    active_curses_ordered.each_with_index do |curse, index|
      type = Engine::CurseCatalog.type_for(curse.name)
      groups[type] << { index: index, curse: curse }
    end
    groups
  end

  def remove_curse_at!(index)
    list = active_curses_ordered
    curse = list[index]
    return { ok: false, error: :invalid_index, message: 'That curse number is invalid.' } unless curse

    unless spend_lp!(CURSE_REMOVE_COST)
      return {
        ok: false,
        error: :insufficient_lp,
        message: "You don't have enough Lust Points! You need #{CURSE_REMOVE_COST} LP."
      }
    end

    deleted = DB[:player_curses].where(player_id: discord_id, curse_id: curse.id).delete
    if deleted.zero?
      gain_lp!(CURSE_REMOVE_COST)
      return { ok: false, error: :curse_not_found, message: 'Curse not found.' }
    end

    {
      ok: true,
      curse: curse,
      message: "You've removed the curse: **#{curse.name}**! (LP left: #{lp})"
    }
  end

  def purge_curse!(curse_id, cost: CURSE_REMOVE_COST)
    return { ok: false, error: :insufficient_lp } unless spend_lp!(cost)

    deleted = DB[:player_curses].where(player_id: discord_id, curse_id: curse_id).delete
    if deleted.zero?
      gain_lp!(cost)
      return { ok: false, error: :curse_not_found }
    end

    { ok: true, action: :purged, curse_id: curse_id, lp_spent: cost }
  end

  def suppress_curse!(curse_id, cost:)
    return { ok: false, error: :insufficient_lp } unless spend_lp!(cost)

    updated = DB[:player_curses]
              .where(player_id: discord_id, curse_id: curse_id, is_suppressed: false)
              .update(is_suppressed: true)

    if updated.zero?
      gain_lp!(cost)
      return { ok: false, error: :curse_not_found_or_already_suppressed }
    end

    { ok: true, action: :suppressed, curse_id: curse_id, lp_spent: cost }
  end

  def afflict!(curse)
    return false if curses_dataset.where(curse_id: curse.id).any?

    DB[:player_curses].insert(
      player_id: discord_id,
      curse_id: curse.id,
      is_suppressed: false,
      acquired_at: Time.now
    )
    true
  end

  # --- Equipment -----------------------------------------------------------

  TROPHY_SLOT = 'trophy'

  # Effects that fire when a fight begins. Returns log lines.
  def apply_combat_start_effects!(monster_type)
    lines = []
    regen = curse_effect_sum("#{monster_type}_defiance_regen").round
    if regen.positive?
      gained = heal_defiance!(regen)
      lines << "Photosynthesis: you regain **#{gained}** defiance! (now #{defiance}/#{max_defiance})" if gained.positive?
    end
    lines
  end

  def owns_equipment?(equipment_id)
    DB[:player_equipment].where(player_id: discord_id, equipment_id: equipment_id).count.positive?
  end

  def grant_equipment!(item, auto_equip: false)
    item = ::Equipment[item] unless item.is_a?(::Equipment)
    return { ok: false, error: :not_found, message: 'Item not found.' } unless item

    if owns_equipment?(item.id)
      return { ok: false, error: :duplicate, message: "You already own **#{item.name}**." }
    end

    begin
      DB[:player_equipment].insert(
        player_id: discord_id,
        equipment_id: item.id,
        is_equipped: false,
        acquired_at: Time.now
      )
    rescue Sequel::UniqueConstraintViolation
      return { ok: false, error: :duplicate, message: "You already own **#{item.name}**." }
    end

    if auto_equip || item.cursed
      equip_result = equip_item(item.id)
      if equip_result[:ok]
        return {
          ok: true,
          message: "You bind **#{item.name}** to your body. #{Engine::Treasure.format_stat_changes(item.stat_modifiers)}"
        }
      end

      return {
        ok: true,
        message: "Added **#{item.name}** to your pack, but it couldn't auto-equip — #{equip_result[:message]}"
      }
    end

    { ok: true, message: "Added **#{item.name}** to your inventory." }
  end

  def equipped_mimics
    equipment_dataset
      .where(Sequel[:player_equipment][:is_equipped] => true)
      .where(Sequel[:equipment][:cursed] => true)
      .all
  end

  def equipment_for_slot(slot)
    equipment_dataset.where(
      Sequel[:player_equipment][:is_equipped] => true,
      Sequel[:equipment][:slot] => slot
    ).first
  end

  def equip_item(equipment_id)
    item = equipment_dataset.where(Sequel[:equipment][:id] => equipment_id).first
    return { ok: false, error: :not_found, message: 'Item not found.' } unless item

    # Boss trophies stack — every trophy can be worn at once.
    current = item.slot == TROPHY_SLOT ? nil : equipment_for_slot(item.slot)
    if current
      if current.cursed && current.id != item.id
        return {
          ok: false,
          error: :cursed_slot,
          message: "Your **#{current.name}** won't come off normally. Use `!remove #{current.name}` (costs LP)."
        }
      end
      DB[:player_equipment]
        .where(player_id: discord_id, equipment_id: current.id)
        .update(is_equipped: false)
    end

    DB[:player_equipment]
      .where(player_id: discord_id, equipment_id: equipment_id)
      .update(is_equipped: true)
    clamp_defiance!

    { ok: true, message: "Equipped **#{item.name}**!" }
  end

  def unequip_item(equipment_id)
    item = equipment_dataset.where(Sequel[:equipment][:id] => equipment_id).first
    return { ok: false, error: :not_found, message: 'Item not found.' } unless item

    if item.cursed
      return {
        ok: false,
        error: :cursed,
        message: "**#{item.name}** is living gear — spend LP with `!remove #{item.name}` to destroy it."
      }
    end

    DB[:player_equipment]
      .where(player_id: discord_id, equipment_id: equipment_id)
      .update(is_equipped: false)
    clamp_defiance!

    { ok: true, message: "Unequipped **#{item.name}**!" }
  end

  # Spend LP to destroy cursed mimic gear.
  def remove_cursed_equipment!(equipment_id)
    item = equipment_dataset.where(Sequel[:equipment][:id] => equipment_id).first
    return { ok: false, error: :not_found, message: 'Item not found.' } unless item
    return { ok: false, error: :not_cursed, message: "**#{item.name}** isn't cursed — use `!unequip`." } unless item.cursed

    cost = item.removal_cost.to_i
    unless spend_lp!(cost)
      return {
        ok: false,
        error: :insufficient_lp,
        message: "You need **#{cost}** LP to remove **#{item.name}** (you have `#{lp}`)."
      }
    end

    DB[:player_equipment].where(player_id: discord_id, equipment_id: item.id).delete
    clamp_defiance!
    {
      ok: true,
      message: "You spend **#{cost}** LP. **#{item.name}** turns to dust as it is torn free."
    }
  end

  # Drop all non-cursed gear (defeat/break). Returns names removed.
  def strip_non_cursed_equipment!
    rows = DB[:player_equipment]
           .join(:equipment, id: :equipment_id)
           .where(player_id: discord_id)
           .where(Sequel[:equipment][:cursed] => false)
           .exclude(Sequel[:equipment][:slot] => TROPHY_SLOT)
           .select(Sequel[:equipment][:name], Sequel[:player_equipment][:id])
           .all

    names = rows.map { |r| r[:name] }
    ids = rows.map { |r| r[:id] }
    DB[:player_equipment].where(id: ids).delete unless ids.empty?
    names
  end

  def check_mimic_violations!(log)
    equipped_mimics.each do |item|
      chance = 0.1 + (current_floor * 0.02)
      chance = [[chance, 0.35].min, 0.1].max
      next if rand > chance

      log << "Your **#{item.name}** suddenly comes to life!"
      scene = Engine::MimicScenes.generate(item.violation_type, self, item.name)
      log << { scene: scene }

      lust_hit = (5 + current_floor).round
      gain_lust!(lust_hit)
      log << "The violation increases your lust by **#{lust_hit}**! (now #{lust})"
    end
  end

  def equipped_items
    equipment_dataset.where(Sequel[:player_equipment][:is_equipped] => true).all
  end

  def equipment_effect_values(key)
    equipped_items.map { |item| item.stat_modifiers[key.to_s] }.compact
  end

  # Additive gear effects (float — callers round where an integer stat is needed).
  def equipment_effect_sum(key)
    equipment_effect_values(key).sum { |v| v.is_a?(Numeric) ? v.to_f : 0.0 }
  end

  # Multiplicative gear effects (e.g. lust_mult 0.8).
  def equipment_effect_product(key)
    vals = equipment_effect_values(key).select { |v| v.is_a?(Numeric) && v.positive? }
    vals.reduce(1.0) { |acc, v| acc * v.to_f }
  end

  def equipment_effect_flag?(key)
    equipment_effect_values(key).any? { |v| v == true || v.to_s == 'true' }
  end
end

class PlayerCurse < Sequel::Model(:player_curses)
  many_to_one :player, key: :player_id, primary_key: :discord_id
  many_to_one :curse
end

class PlayerEquipment < Sequel::Model(:player_equipment)
  many_to_one :player, key: :player_id, primary_key: :discord_id
  many_to_one :equipment
end
