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
  def self.create_from_archetype!(discord_id:, archetype:)
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
      pos_x: 0,
      pos_y: 0,
      hp: 100,
      max_hp: 100,
      lp: 0,
      current_floor: 1,
      in_combat: false
    )
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
    [base + equipment_effect_sum('strength'), 1].max
  end

  def effective_agility
    base = [agility + curse_effect_sum('agility').round, 1].max
    [base + equipment_effect_sum('agility'), 1].max
  end

  def effective_resistance
    base = [resistance + curse_effect_sum('resistance').round, 1].max
    [base + equipment_effect_sum('resistance'), 1].max
  end

  # Global + type-specific lust multipliers for the current foe.
  def lust_damage_multiplier(monster_type: nil)
    mult = curse_effect_product('lust_mult', default: 1.0)
    if monster_type
      mult *= curse_effect_product("#{monster_type}_lust_mult", default: 1.0)
    end
    mult <= 0 ? 1.0 : mult
  end

  def max_lp_base
    MAX_LP_BASE
  end

  # --- Life / death / run reset --------------------------------------------

  def starting_defiance
    mult = curse_effect_product('defiance_start', default: 1.0)
    [[(MAX_DEFIANCE * mult).round, 1].max, MAX_DEFIANCE].min
  end

  # Full run wipe after defeat or being broken. LP, curses, and gear persist.
  def reset_run!
    old_level = level
    old_str = strength
    old_agi = agility
    old_res = resistance

    update(
      level: 1,
      strength: 5,
      agility: 5,
      resistance: 5,
      defiance: starting_defiance,
      lust: 0,
      current_floor: 1,
      pos_x: 0,
      pos_y: 0,
      hp: max_hp,
      in_combat: false,
      active_encounter: nil,
      highest_boss_defeated: 0
    )

    {
      level_lost: [old_level - 1, 0].max,
      str_lost: [old_str - 5, 0].max,
      agi_lost: [old_agi - 5, 0].max,
      res_lost: [old_res - 5, 0].max
    }
  end

  # --- Active encounter (survives process restart) -------------------------

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

  def heal!(amount)
    update(hp: [hp + amount, max_hp].min)
  end

  def restore_defiance!(amount)
    adjust_defiance!(amount)
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
    update(lust: 0)

    type = monster_type&.to_s
    climax_lp = type ? curse_effect_sum("#{type}_climax_lp").round : 0
    if climax_lp.positive?
      gain_lp!(climax_lp)
      lines << "You gain **#{climax_lp}** Lust Points from climaxing!"
    end

    adjust_defiance!(-CLIMAX_DEFIANCE_LOSS)
    lines << "You climax! Your defiance drops by **#{CLIMAX_DEFIANCE_LOSS}**! (now #{defiance})"

    { lines: lines, broken: defiance <= 0 }
  end

  def adjust_defiance!(delta)
    update(defiance: [[defiance + delta, 0].max, MAX_DEFIANCE].min)
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

  def equipment_for_slot(slot)
    equipment_dataset.where(
      Sequel[:player_equipment][:is_equipped] => true,
      Sequel[:equipment][:slot] => slot
    ).first
  end

  def equip_item(equipment_id)
    item = equipment_dataset.where(Sequel[:equipment][:id] => equipment_id).first
    return { ok: false, error: :not_found, message: 'Item not found.' } unless item

    current = equipment_for_slot(item.slot)
    if current
      DB[:player_equipment]
        .where(player_id: discord_id, equipment_id: current.id)
        .update(is_equipped: false)
    end

    DB[:player_equipment]
      .where(player_id: discord_id, equipment_id: equipment_id)
      .update(is_equipped: true)

    { ok: true, message: "Equipped **#{item.name}**!" }
  end

  def unequip_item(equipment_id)
    item = equipment_dataset.where(Sequel[:equipment][:id] => equipment_id).first
    return { ok: false, error: :not_found, message: 'Item not found.' } unless item

    DB[:player_equipment]
      .where(player_id: discord_id, equipment_id: equipment_id)
      .update(is_equipped: false)

    { ok: true, message: "Unequipped **#{item.name}**!" }
  end

  def equipment_effect_sum(key)
    equipment_dataset
      .where(Sequel[:player_equipment][:is_equipped] => true)
      .all
      .sum { |item| item.stat_modifiers[key.to_s].to_i }
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
