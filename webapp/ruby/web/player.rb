# frozen_string_literal: true

# Browser versions of the bot Player methods that used SQL. Everything else
# (combat maths, conditions, orgasms, titles, curses' effects...) is the bot's
# own code from bot/models/player.rb.
class Player
  WEB_DEFAULTS = {
    discord_id: 1, character_name: nil, gender: 'Unset', body_parts: [],
    level: 1, defiance: MAX_DEFIANCE, lust: 0, strength: 5, agility: 5, resistance: 5, submission: 0,
    pos_x: 0, pos_y: 0, hp: 100, max_hp: 100, lp: 0,
    current_floor: 1, highest_floor_reached: 1, highest_boss_defeated: 0, current_cycle: 1,
    in_combat: false, active_encounter: nil, active_event: nil,
    phylactery_used: false, sanctuary: false,
    selected_title: nil, trackers: {}, titles: [], achievements: [],
    preferences: {}, body_sizes: {}, conditions: [], transformations: [], active_transformation: nil,
    web_curses: [], web_equipment: []
  }.freeze

  WEB_SERIALIZED = %i[body_parts trackers titles achievements preferences body_sizes conditions
                      transformations web_curses web_equipment].freeze

  class << self
    # What survives a restart (titles, achievements, records, options).
    attr_accessor :legacy

    def character_name_error(name, except_id: nil) # rubocop:disable Lint/UnusedMethodArgument
      unless CHARACTER_NAME_LENGTH.cover?(name.length)
        return "Names must be #{CHARACTER_NAME_LENGTH.min}–#{CHARACTER_NAME_LENGTH.max} characters."
      end
      return 'Names may only use letters, numbers, spaces, apostrophes, and hyphens.' unless name.match?(CHARACTER_NAME_FORMAT)

      nil
    end

    def find_by_character_name(*) = nil
  end

  def save_legacy!
    Player.legacy = {
      'trackers' => tracker_hash.reject { |k, _| RUN_TRACKERS.include?(k) },
      'titles' => earned_titles,
      'achievements' => earned_achievements,
      'selected_title' => selected_title,
      'highest_floor_reached' => highest_floor_reached.to_i,
      'preferences' => preferences.is_a?(Hash) ? preferences : {},
      'transformations' => unlocked_transformations,
      'active_transformation' => active_transformation
    }
  end

  def restore_legacy!
    row = Player.legacy
    return false unless row.is_a?(Hash)

    update(
      trackers: row['trackers'] || {},
      titles: row['titles'] || [],
      achievements: row['achievements'] || [],
      selected_title: row['selected_title'],
      highest_floor_reached: [row['highest_floor_reached'].to_i, 1].max,
      preferences: row['preferences'] || {},
      transformations: row['transformations'] || [],
      active_transformation: row['active_transformation']
    )
    Engine::NPCSystem.reset_finished!(self)
    Player.legacy = nil
    true
  end

  # Curses: rows of { 'name', 'suppressed' } on the player.

  def curse_rows = Array(web_curses)

  def curse_records(suppressed)
    curse_rows.select { |r| r['suppressed'] == suppressed }.filter_map { |r| Curse[r['name']] }
  end

  def curses_dataset = WebDataset.new(curse_rows.filter_map { |r| Curse[r['name']] })
  def curses = curses_dataset.all
  def active_curses = curse_records(false)
  def suppressed_curses = curse_records(true)
  def active_curse_count = active_curses.size

  def drop_curse!(name)
    rows = curse_rows
    kept = rows.reject { |r| r['name'] == name.to_s }
    update(web_curses: kept)
    kept.size < rows.size
  end

  def remove_curse_at!(index)
    curse = active_curses_ordered[index]
    return { ok: false, error: :invalid_index, message: 'That curse number is invalid.' } unless curse

    unless spend_lp!(CURSE_REMOVE_COST)
      return { ok: false, error: :insufficient_lp,
               message: "You don't have enough Lust Points! You need #{CURSE_REMOVE_COST} LP." }
    end

    drop_curse!(curse.name)
    clamp_defiance!
    { ok: true, curse: curse, message: "You've removed the curse: **#{curse.name}**! (LP left: #{lp})" }
  end

  def reactivate_suppressed_curses!
    names = suppressed_curses.map(&:name)
    update(web_curses: curse_rows.map { |r| r.merge('suppressed' => false) }) if names.any?
    names
  end

  def purge_curse!(curse_id, cost: CURSE_REMOVE_COST)
    return { ok: false, error: :insufficient_lp } unless spend_lp!(cost)

    unless drop_curse!(curse_id)
      refund_lp!(cost)
      return { ok: false, error: :curse_not_found }
    end

    { ok: true, action: :purged, curse_id: curse_id, lp_spent: cost }
  end

  def suppress_curse!(curse_id, cost:)
    return { ok: false, error: :insufficient_lp } unless spend_lp!(cost)

    unless curse_rows.any? { |r| r['name'] == curse_id.to_s && !r['suppressed'] }
      refund_lp!(cost)
      return { ok: false, error: :curse_not_found_or_already_suppressed }
    end

    update(web_curses: curse_rows.map { |r| r['name'] == curse_id.to_s ? r.merge('suppressed' => true) : r })
    clamp_defiance!
    { ok: true, action: :suppressed, curse_id: curse_id, lp_spent: cost }
  end

  def afflict!(curse)
    return false if curse_rows.any? { |r| r['name'] == curse.name }

    update(web_curses: curse_rows + [{ 'name' => curse.name, 'suppressed' => false }])
    remember!('curses_seen', curse.name)
    count = active_curse_count
    set_tracker!('max_curses_simultaneous', count) if count > tracker('max_curses_simultaneous')
    true
  end

  # Equipment: rows of { 'name', 'equipped' } on the player.

  def gear_rows = Array(web_equipment)

  def gear_records(equipped: nil)
    rows = equipped.nil? ? gear_rows : gear_rows.select { |r| r['equipped'] == equipped }
    rows.filter_map { |r| ::Equipment[r['name']] }
  end

  def equipment_dataset = WebDataset.new(gear_records)
  def equipment = gear_records
  def equipped_items = gear_records(equipped: true)
  def equipped_mimics = equipped_items.select(&:cursed)
  def equipment_for_slot(slot) = equipped_items.find { |i| i.slot == slot }
  def owns_equipment?(equipment_id) = gear_rows.any? { |r| r['name'] == equipment_id.to_s }
  def equipped?(name) = gear_rows.any? { |r| r['name'] == name.to_s && r['equipped'] }

  def set_equipped!(name, flag)
    update(web_equipment: gear_rows.map { |r| r['name'] == name.to_s ? r.merge('equipped' => flag) : r })
  end

  def drop_equipment!(name)
    update(web_equipment: gear_rows.reject { |r| r['name'] == name.to_s })
  end

  def grant_equipment!(item, auto_equip: false)
    item = ::Equipment[item] unless item.is_a?(::Equipment)
    return { ok: false, error: :not_found, message: 'Item not found.' } unless item
    return { ok: false, error: :duplicate, message: "You already own **#{item.name}**." } if owns_equipment?(item.id)

    update(web_equipment: gear_rows + [{ 'name' => item.name, 'equipped' => false }])

    if auto_equip || item.cursed
      equip_result = equip_item(item.id)
      if equip_result[:ok]
        return { ok: true,
                 message: "You bind **#{item.name}** to your body. #{Engine::Treasure.format_stat_changes(item.stat_modifiers)}" }
      end

      return { ok: true,
               message: "Added **#{item.name}** to your pack, but it couldn't auto-equip — #{equip_result[:message]}" }
    end

    { ok: true, message: "Added **#{item.name}** to your inventory." }
  end

  def equip_item(equipment_id)
    item = owns_equipment?(equipment_id) && ::Equipment[equipment_id]
    return { ok: false, error: :not_found, message: 'Item not found.' } unless item

    current = equipment_for_slot(item.slot)
    if current
      if current.cursed && current.id != item.id
        return { ok: false, error: :cursed_slot,
                 message: "Your **#{current.name}** won't come off normally. Tear it free from your gear (costs LP)." }
      end
      set_equipped!(current.name, false)
    end

    set_equipped!(item.name, true)
    clamp_defiance!
    { ok: true, message: "Equipped **#{item.name}**!" }
  end

  def unequip_item(equipment_id)
    item = owns_equipment?(equipment_id) && ::Equipment[equipment_id]
    return { ok: false, error: :not_found, message: 'Item not found.' } unless item

    if item.cursed
      return { ok: false, error: :cursed,
               message: "**#{item.name}** is living gear — spend LP to tear it free." }
    end

    set_equipped!(item.name, false)
    clamp_defiance!
    { ok: true, message: "Unequipped **#{item.name}**!" }
  end

  def remove_cursed_equipment!(equipment_id)
    item = owns_equipment?(equipment_id) && ::Equipment[equipment_id]
    return { ok: false, error: :not_found, message: 'Item not found.' } unless item
    return { ok: false, error: :not_cursed, message: "**#{item.name}** isn't cursed — just unequip it." } unless item.cursed

    cost = item.removal_cost.to_i
    unless spend_lp!(cost)
      return { ok: false, error: :insufficient_lp,
               message: "You need **#{cost}** LP to remove **#{item.name}** (you have `#{lp}`)." }
    end

    drop_equipment!(item.name)
    clamp_defiance!
    first_time = !cursed_shop_unlocked?(item.name)
    remember!('mimics_removed', item.name)
    unlock = first_time ? "\n_**#{item.name}** is now available for free in the Cursed Shop._" : ''
    { ok: true, message: "You spend **#{cost}** LP. **#{item.name}** turns to dust as it is torn free.#{unlock}" }
  end

  def strip_non_cursed_equipment!
    names = gear_records.reject(&:cursed).map(&:name)
    update(web_equipment: gear_rows.reject { |r| names.include?(r['name']) }) unless names.empty?
    names
  end
end
