# frozen_string_literal: true

require 'json'

class Player < Sequel::Model(:players)
  MAX_LP_BASE = 100
  MAX_DEFIANCE = 100

  plugin :timestamps, update_on_create: true
  plugin :serialization, :json, :body_parts, :trackers, :titles, :achievements, :preferences, :body_sizes,
         :conditions, :transformations
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

  def self.create_from_archetype!(discord_id:, archetype:, submission: 0, character_name: nil)
    player = create(
      discord_id: discord_id,
      character_name: character_name,
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
    player.restore_legacy!
    player
  end

  RUN_TRACKERS = %w[run_flee_attempts run_submissions run_floors_cleared run_climaxes climax_addicted floors_since_climax].freeze

  def save_legacy!
    row = {
      trackers: JSON.generate(tracker_hash.reject { |k, _| RUN_TRACKERS.include?(k) }),
      titles: JSON.generate(earned_titles),
      achievements: JSON.generate(earned_achievements),
      selected_title: selected_title,
      highest_floor_reached: highest_floor_reached.to_i,
      preferences: JSON.generate(preferences.is_a?(Hash) ? preferences : {}),
      saved_at: Time.now
    }
    if transformations_supported?
      row[:transformations] = JSON.generate(unlocked_transformations)
      row[:active_transformation] = active_transformation
    end
    ds = DB[:legacy_progress].where(discord_id: discord_id)
    ds.update(row).zero? && DB[:legacy_progress].insert(row.merge(discord_id: discord_id))
  end

  def restore_legacy!
    row = DB[:legacy_progress].where(discord_id: discord_id).first
    return false unless row

    restored = {
      trackers: JSON.parse(row[:trackers].to_s.empty? ? '{}' : row[:trackers]),
      titles: JSON.parse(row[:titles].to_s.empty? ? '[]' : row[:titles]),
      achievements: JSON.parse(row[:achievements].to_s.empty? ? '[]' : row[:achievements]),
      selected_title: row[:selected_title],
      highest_floor_reached: [row[:highest_floor_reached].to_i, 1].max,
      preferences: JSON.parse(row[:preferences].to_s.empty? ? '{}' : row[:preferences])
    }
    if transformations_supported? && row.key?(:transformations)
      restored[:transformations] = JSON.parse(row[:transformations].to_s.empty? ? '[]' : row[:transformations])
      restored[:active_transformation] = row[:active_transformation]
    end
    update(restored)
    DB[:legacy_progress].where(discord_id: discord_id).delete
    true
  rescue JSON::ParserError
    false
  end

  def submission_display
    CharacterArchetypes.submission_label(submission)
  end

  CHARACTER_NAME_LENGTH = (2..24)
  CHARACTER_NAME_FORMAT = /\A[\p{L}\p{N}][\p{L}\p{N} '\-]*\z/

  def self.normalize_character_name(raw)
    raw.to_s.strip.gsub(/\s+/, ' ')
  end

  def self.character_name_error(name, except_id: nil)
    unless CHARACTER_NAME_LENGTH.cover?(name.length)
      return "Names must be #{CHARACTER_NAME_LENGTH.min}–#{CHARACTER_NAME_LENGTH.max} characters."
    end
    unless name.match?(CHARACTER_NAME_FORMAT)
      return 'Names may only use letters, numbers, spaces, apostrophes, and hyphens.'
    end

    taken = where(Sequel.function(:lower, :character_name) => name.downcase)
    taken = taken.exclude(discord_id: except_id) if except_id
    return "**#{name}** is already taken — pick another name." if taken.any?

    nil
  end

  def self.find_by_character_name(raw)
    name = normalize_character_name(raw)
    return nil if name.empty?

    first(Sequel.function(:lower, :character_name) => name.downcase)
  end

  def set_character_name!(raw)
    name = self.class.normalize_character_name(raw)
    error = self.class.character_name_error(name, except_id: discord_id)
    return { ok: false, message: error } if error

    update(character_name: name)
    { ok: true, message: "Your delver is now known as **#{name}**." }
  rescue Sequel::UniqueConstraintViolation
    { ok: false, message: "**#{name}** is already taken — pick another name." }
  end

  def display_name
    character_name.to_s.empty? ? 'Unnamed Delver' : character_name
  end

  def tracker_hash
    trackers.is_a?(Hash) ? trackers : {}
  end

  def tracker(key)
    tracker_hash[key.to_s].to_i
  end

  def bump_tracker!(key, by = 1)
    data = tracker_hash.dup
    data[key.to_s] = data[key.to_s].to_i + by
    update(trackers: data)
  end

  def remember!(key, value)
    list = Array(tracker_hash[key.to_s])
    return if list.include?(value)

    update(trackers: tracker_hash.merge(key.to_s => list + [value]))
  end

  def progress_value(key)
    case key.to_sym
    when :highest_floor then highest_floor_reached.to_i
    when :curses_acquired
      (Array(tracker_hash['curses_seen']) | curses_dataset.select_map(Sequel[:curses][:name])).size
    when :unique_bosses_defeated then Array(tracker_hash['bosses_seen']).size
    when :royal_demons_cleared
      (Array(tracker_hash['bosses_seen']) & ['Succubus Queen', 'Incubus King']).size
    when :mimics_removed_count then cursed_shop_unlocks.size
    when :current_floor then current_floor.to_i
    when :is_developer then Engine::Dev.owner?(discord_id) ? 1 : 0
    when :is_bug_tester then Engine::Dev.bug_tester?(discord_id) ? 1 : 0
    when :pure_title then earned_titles.include?('pure') ? 1 : 0
    when :max_curses_simultaneous then [tracker(key), active_curse_count].max
    when :submission_to_defeat_ratio
      kills = tracker('monsters_killed')
      subs = tracker('submissions')
      kills.zero? ? subs.to_f : subs.to_f / kills
    else tracker(key)
    end
  end

  def set_tracker!(key, value)
    update(trackers: tracker_hash.merge(key.to_s => value))
  end

  def earned_titles
    Array(titles).map(&:to_s)
  end

  def earned_achievements
    Array(achievements).map(&:to_s)
  end

  def active_title_key
    return selected_title if selected_title && earned_titles.include?(selected_title)

    Engine::TitleSystem.best_title_key(earned_titles)
  end

  def active_title_name
    Engine::TitleSystem.title(active_title_key)&.dig(:name)
  end

  def select_title!(key)
    if key.nil?
      update(selected_title: nil)
      return { ok: true, message: 'Title cleared — your best title shows automatically.' }
    end

    entry = Engine::TitleSystem.title(key)
    return { ok: false, message: 'Unknown title.' } unless entry
    return { ok: false, message: "You haven't earned **#{entry[:name]}** yet." } unless earned_titles.include?(key.to_s)

    update(selected_title: key.to_s)
    { ok: true, message: "You now bear the title **#{entry[:name]}**." }
  end

  def check_progress!
    lines = []
    3.times do
      new_titles = Engine::TitleSystem::TITLES.reject { |k, _| earned_titles.include?(k) }
                                              .select { |_, t| Engine::TitleSystem.met?(self, t[:requirement]) }
      new_achievements = Engine::TitleSystem::ACHIEVEMENTS.reject { |a| earned_achievements.include?(a[:id]) }
                                                          .select { |a| Engine::TitleSystem.met?(self, a[:requirement]) }
      break if new_titles.empty? && new_achievements.empty?

      update(titles: earned_titles + new_titles.keys, achievements: earned_achievements + new_achievements.map { |a| a[:id] })
      new_titles.each_value do |t|
        lines << "**New title unlocked:** #{t[:name]} — _#{t[:description]}_ (equip with `/titles`)"
      end
      new_achievements.each do |a|
        reward = a.dig(:reward, :lp).to_i
        gain_lp!(reward) if reward.positive?
        bonus = reward.positive? ? " · **+#{reward} LP**" : ''
        lines << "**Achievement unlocked:** #{a[:name]} — _#{a[:description]}_#{bonus}"
      end
    end
    lines.concat(check_transformations!)
  end

  def transformations_supported?
    self.class.columns.include?(:transformations)
  end

  def unlocked_transformations
    return [] unless transformations_supported?

    Array(transformations).map(&:to_s)
  end

  def active_transformation_key
    return nil unless transformations_supported?

    key = active_transformation.to_s
    unlocked_transformations.include?(key) ? key : nil
  end

  def active_transformation_name
    Engine::TransformationSystem.get(active_transformation_key)&.dig(:name)
  end

  def check_transformations!
    return [] unless transformations_supported?

    fresh = Engine::TransformationSystem::TRANSFORMATIONS.keys.reject { |k| unlocked_transformations.include?(k) }
                                                          .select { |k| Engine::TransformationSystem.eligible?(self, k) }
    return [] if fresh.empty?

    update(transformations: unlocked_transformations + fresh)
    fresh.map do |k|
      t = Engine::TransformationSystem.get(k)
      "**New hybrid form unlocked:** #{t[:name]} — _#{t[:description]}_ (take it with `/transformation`)"
    end
  end

  def select_transformation!(key)
    return { ok: false, message: 'Hybrid forms need `bundle exec rake db:migrate`.' } unless transformations_supported?

    if key.nil?
      update(active_transformation: nil)
      return { ok: true, message: 'Your body settles back into its human shape.' }
    end

    entry = Engine::TransformationSystem.get(key)
    return { ok: false, message: 'Unknown transformation.' } unless entry
    return { ok: false, message: "You haven't unlocked **#{entry[:name]}** yet." } unless unlocked_transformations.include?(key.to_s)

    update(active_transformation: key.to_s)
    { ok: true, message: "Your body shifts — you are now a **#{entry[:name]}** hybrid." }
  end

  def cycle_multiplier
    Engine::Tower.cycle_multiplier(current_cycle)
  end

  def depth_for(cycle, floor)
    ((cycle.to_i - 1) * Engine::Tower::FINAL_BOSS_FLOOR) + [floor.to_i, Engine::Tower::FINAL_BOSS_FLOOR].min
  end

  def deepest_depth
    [tracker('deepest_depth'), depth_for(1, highest_floor_reached)].max
  end

  def self.depth_label(depth)
    depth = [depth.to_i, 1].max
    cycle = ((depth - 1) / Engine::Tower::FINAL_BOSS_FLOOR) + 1
    floor = ((depth - 1) % Engine::Tower::FINAL_BOSS_FLOOR) + 1
    "Cycle #{cycle} · Floor #{floor}"
  end

  def complete_cycle!
    cleared = current_cycle.to_i
    reward = Engine::Tower.clear_reward_lp(cleared)
    gain_lp!(reward)
    expired = tick_conditions!

    data = tracker_hash.dup
    data['cycles_completed'] = data['cycles_completed'].to_i + 1
    data['highest_cycle'] = [data['highest_cycle'].to_i, cleared + 1].max
    update(
      trackers: data,
      current_cycle: cleared + 1,
      current_floor: 1,
      pos_x: 0,
      pos_y: 0,
      highest_boss_defeated: 0,
      in_combat: false,
      active_encounter: nil,
      active_event: nil
    )
    note_floor_reached!(1)
    { cleared_cycle: cleared, new_cycle: cleared + 1, lp: reward, conditions_expired: expired }
  end

  def body_parts_list
    parts = body_parts.is_a?(Array) ? body_parts.dup : []
    condition_list.each do |cond|
      parts -= Array(cond['remove_parts'])
      parts |= Array(cond['parts'])
    end
    parts
  end

  def body_parts_display
    list = body_parts_list
    list.empty? ? '_none_' : list.join(', ')
  end

  def active_curses
    curses_dataset.where(Sequel[:player_curses][:is_suppressed] => false).all
  end

  def suppressed_curses
    curses_dataset.where(Sequel[:player_curses][:is_suppressed] => true).all
  end

  def active_curse_count
    curses_dataset.where(Sequel[:player_curses][:is_suppressed] => false).count
  end

  def curse_effect_bags
    bags = Hash.new { |h, k| h[k] = [] }
    active_curses.each do |curse|
      curse.stat_modifiers.each do |key, value|
        bags[key.to_s] << value
      end
    end
    condition_list.each do |cond|
      Hash(cond['effects']).each { |key, value| bags[key.to_s] << value }
    end
    Engine::TransformationSystem.effects(self).each { |key, value| bags[key.to_s] << value }
    bags
  end

  def condition_list
    return [] unless self.class.columns.include?(:conditions)

    Array(conditions).select { |c| c.is_a?(Hash) && c['floors'].to_i.positive? }
  end

  def condition?(key)
    condition_list.any? { |c| c['key'] == key.to_s }
  end

  EXCLUSIVE_CONDITIONS = [%w[towering pocket_sized], %w[climax_exhaustion climax_high]].freeze

  def add_condition!(key, name:, floors:, effects:, summary:, parts: [], remove_parts: [])
    rivals = EXCLUSIVE_CONDITIONS.select { |group| group.include?(key.to_s) }.flatten - [key.to_s]
    replaced = condition_list.select { |c| rivals.include?(c['key']) }.map { |c| c['name'] }
    list = condition_list.reject { |c| c['key'] == key.to_s || rivals.include?(c['key']) }
    entry = { 'key' => key.to_s, 'name' => name, 'floors' => floors.to_i,
              'effects' => effects.transform_keys(&:to_s), 'summary' => summary }
    entry['parts'] = parts.map(&:to_s) if parts.any?
    entry['remove_parts'] = remove_parts.map(&:to_s) if remove_parts.any?
    list << entry
    update(conditions: list)
    clamp_defiance!
    replaced
  end

  def tick_conditions!
    list = condition_list
    return [] if list.empty?

    list = list.map { |c| c.merge('floors' => c['floors'].to_i - 1) }
    expired = list.reject { |c| c['floors'].positive? }.map { |c| c['name'] }
    update(conditions: list.select { |c| c['floors'].positive? })
    clamp_defiance!
    expired
  end

  def clear_conditions!
    update(conditions: []) if self.class.columns.include?(:conditions)
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
    [submission.to_i + equipment_effect_sum('submission').round + curse_effect_sum('submission').round, 0].max
  end

  def lust_damage_multiplier(monster_type: nil)
    mult = curse_effect_product('lust_mult', default: 1.0)
    mult *= equipment_effect_product('lust_mult')
    mult *= curse_effect_product('damage_reduction', default: 1.0)
    if monster_type
      mult *= curse_effect_product("#{monster_type}_lust_mult", default: 1.0)
    end
    mult *= Engine::ChastitySystem.arousal_multiplier(self)
    mult <= 0 ? 1.0 : mult
  end

  def encounter_rate_multiplier
    curse_effect_product('encounter_rate', default: 1.0) * equipment_effect_product('encounter_rate')
  end

  def flee_bonus
    equipment_effect_sum('flee_bonus') + curse_effect_sum('flee_bonus')
  end

  def trap_avoid_chance
    return 1.0 if Engine::Dev.debug?(self)

    ((0.1 + (0.02 * effective_agility)).clamp(0.1, 0.6) + curse_effect_sum('trap_avoid_bonus')).clamp(0.1, 0.85)
  end

  def event_escape_chance
    (0.05 + (0.02 * effective_agility)).clamp(0.05, 0.4)
  end

  def max_lp_base
    MAX_LP_BASE
  end

  DEFIANCE_SCALE = 10

  def self.calculate_max_hp(level, base_hp: MAX_DEFIANCE, scale_factor: DEFIANCE_SCALE)
    return base_hp if level.to_i <= 1

    (base_hp + (scale_factor * Math.sqrt(level.to_i - 1))).floor
  end

  def max_defiance
    bonus = curse_effect_sum('max_hp_bonus') + equipment_effect_sum('max_hp')
    [self.class.calculate_max_hp(level) + bonus.round, 1].max
  end

  def starting_defiance
    mult = curse_effect_product('defiance_start', default: 1.0)
    [[(max_defiance * mult).round, 1].max, max_defiance].min
  end

  def base_lust
    [[curse_effect_sum('lust_start_bonus').round, 0].max, CLIMAX_THRESHOLD - 10].min
  end

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

  def try_cheat_death!(lines)
    return false if phylactery_used
    return false unless equipment_effect_flag?('cheat_death')

    restored = [(max_defiance / 2.0).round, 1].max
    update(defiance: restored, lust: base_lust, phylactery_used: true)
    lines << "**Lich's Phylactery** cracks and pulls your soul back! Defiance restored to **#{restored}** " \
             '_(once per run)_.'
    true
  end

  def reset_run!
    old_level = level
    old_str = strength
    old_agi = agility
    old_res = resistance
    old_cycle = current_cycle.to_i

    stripped = strip_non_cursed_equipment!
    reactivated = reactivate_suppressed_curses!

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
      phylactery_used: false,
      current_cycle: 1,
      conditions: [],
      trackers: tracker_hash.merge(RUN_TRACKERS.to_h { |k| [k, 0] })
    )
    update(defiance: starting_defiance)

    {
      level_lost: [old_level - 1, 0].max,
      str_lost: [old_str - 5, 0].max,
      agi_lost: [old_agi - 5, 0].max,
      res_lost: [old_res - 5, 0].max,
      gear_lost: stripped,
      curses_reactivated: reactivated,
      cycle_lost: old_cycle > 1 ? old_cycle : nil
    }
  end

  def note_floor_reached!(floor = current_floor)
    floor = floor.to_i
    return current_floor if floor < 1

    best = [highest_floor_reached.to_i, floor].max
    attrs = {}
    attrs[:current_floor] = floor if floor != current_floor
    attrs[:highest_floor_reached] = best if best > highest_floor_reached.to_i
    depth = depth_for(current_cycle, floor)
    attrs[:trackers] = tracker_hash.merge('deepest_depth' => depth) if depth > tracker('deepest_depth')
    update(attrs) unless attrs.empty?
    current_floor
  end

  def advance_floor!
    bump_tracker!('floors_cleared')
    bump_tracker!('run_floors_cleared')
    bump_tracker!('floors_since_climax')
    streak = tracker('floors_since_climax')
    set_tracker!('best_climax_free_floors', streak) if streak > tracker('best_climax_free_floors')
    explore_lp = curse_effect_sum('explore_lp').round
    gain_lp!(explore_lp) if explore_lp.positive?
    expired = tick_conditions!
    note_floor_reached!(current_floor + 1)
    expired
  end

  def self.worn_off_line(names)
    return nil if names.nil? || names.empty?

    "_#{names.map { |n| "**#{n}**" }.join(', ')} #{names.size == 1 ? 'has' : 'have'} worn off._"
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
    amount = amount.to_i
    attrs = { lp: lp + amount }
    attrs[:trackers] = tracker_hash.merge('lp_earned' => tracker('lp_earned') + amount) if amount.positive?
    update(attrs)
  end

  def refund_lp!(amount)
    update(lp: lp + amount.to_i)
  end

  UPGRADE_STATS = %i[strength agility resistance].freeze
  LEVEL_DISCOUNT = 0.8

  def stat_upgrade_cost(stat)
    5 + public_send(stat.to_sym).to_i
  end

  def level_upgrade_cost
    (UPGRADE_STATS.sum { |s| stat_upgrade_cost(s) } * LEVEL_DISCOUNT).round
  end

  def upgrade_stat!(stat)
    stat = stat.to_sym
    unless UPGRADE_STATS.include?(stat)
      return { ok: false, error: :unknown_stat, message: 'Unknown stat.' }
    end

    cost = stat_upgrade_cost(stat)
    unless spend_lp!(cost)
      return { ok: false, error: :insufficient_lp, message: "You need **#{cost}** LP to raise #{stat} (you have `#{lp}`)." }
    end

    new_value = public_send(stat) + 1
    update(stat => new_value)
    {
      ok: true,
      stat: stat,
      value: new_value,
      message: "Your #{stat} increased to **#{new_value}** for #{cost} LP! (LP left: #{lp})"
    }
  end

  def upgrade_level!
    cost = level_upgrade_cost
    unless spend_lp!(cost)
      return { ok: false, error: :insufficient_lp, message: "You need **#{cost}** LP to level up (you have `#{lp}`)." }
    end

    old_max = max_defiance
    update(
      level: level + 1,
      strength: strength + 1,
      agility: agility + 1,
      resistance: resistance + 1
    )
    update(defiance: max_defiance)
    gained = max_defiance - old_max
    max_note = gained.positive? ? "Max defiance +#{gained} → **#{max_defiance}**" : "Max defiance **#{max_defiance}**"
    {
      ok: true,
      level: level,
      message: "You leveled up to **#{level}** for #{cost} LP! All stats +1 " \
               "(STR #{strength} · AGI #{agility} · RES #{resistance}). #{max_note}, fully restored. LP left: #{lp}"
    }
  end

  CLIMAX_THRESHOLD = 100
  CLIMAX_DEFIANCE_LOSS = 20
  DENIAL_DEFIANCE_LOSS = 6

  def climax_denied?
    curse_effect_flag?('deny_climax') || equipment_effect_flag?('deny_climax')
  end

  def gain_lust!(amount)
    update(lust: lust + amount)
  end

  def try_climax!(monster_type: nil)
    return nil if lust < CLIMAX_THRESHOLD

    lines = []
    type = monster_type&.to_s

    if climax_denied?
      lines.concat(Engine::ChastitySystem.denial_lines(self))
      update(lust: CLIMAX_THRESHOLD - 5)
      adjust_defiance!(-DENIAL_DEFIANCE_LOSS)
      gain_lp!(Engine::ChastitySystem::DENIAL_LP)
      bump_tracker!('denied_climaxes')
      lines << "Your climax is **denied**. The frustration costs **#{DENIAL_DEFIANCE_LOSS}** defiance " \
               "(now #{defiance}/#{max_defiance}), but your devotion earns **+#{Engine::ChastitySystem::DENIAL_LP} LP**. " \
               "Lust held at the edge (#{lust})."
    else
      overflow = lust - CLIMAX_THRESHOLD
      lines.concat(climax_flavour(overflow))
      update(lust: base_lust)
      climax_lp = type ? curse_effect_sum("#{type}_climax_lp").round : 0
      if climax_lp.positive?
        gain_lp!(climax_lp)
        lines << "You gain **#{climax_lp}** Lust Points from climaxing!"
      end

      adjust_defiance!(-CLIMAX_DEFIANCE_LOSS)
      lines << "You climax! Your defiance drops by **#{CLIMAX_DEFIANCE_LOSS}**! (now #{defiance}/#{max_defiance})"
      record_climax!(overflow, lines)
    end

    broken = defiance <= 0
    immortal = type && curse_effect_flag?("#{type}_no_death")
    broken = false if broken && !immortal && try_cheat_death!(lines)
    bump_tracker!('climaxes_survived') unless broken

    { lines: lines, broken: broken }
  end

  CLIMAX_ADDICTION_AT = 10
  CLIMAX_AFTERMATH_FLOORS = 2

  def climax_addicted?
    tracker('climax_addicted').positive?
  end

  def climax_flavour(overflow)
    text =
      if overflow >= 30
        ['Your body convulses with overwhelming pleasure as wave after wave of ecstasy crashes through you. ' \
         'Your cry echoes through the chamber as you climax harder than ever before.',
         'The sheer intensity leaves you trembling and gasping, your vision whited out by pleasure.']
      elsif overflow >= 15
        ['Pleasure erupts through your body in a torrent. You arch your back as your orgasm takes hold, ' \
         'every muscle tensing then releasing with each pulse.',
         'Your mind goes blank as sensation drowns out thought, leaving you panting as the waves slowly subside.']
      elsif overflow >= 5
        ['Heat builds in your core until it breaks. You gasp as pleasure spills through you, your body shuddering with release.',
         'It leaves you breathless but satisfied, warmth spreading through your limbs as your heartbeat slows.']
      else
        ['A gentle warmth spreads through you as you climax, a soft release that eases your need without overwhelming you.',
         'The brief moment of bliss leaves you calmer — though still craving more.']
      end
    text.map { |t| "_#{t}_" }
  end

  def record_climax!(overflow, lines)
    bump_tracker!('total_climaxes')
    bump_tracker!('run_climaxes')
    set_tracker!('floors_since_climax', 0)
    set_tracker!('max_climax_overflow', overflow) if overflow > tracker('max_climax_overflow')

    if !climax_addicted? && tracker('run_climaxes') >= CLIMAX_ADDICTION_AT
      set_tracker!('climax_addicted', 1)
      bump_tracker!('climax_addictions')
      lines << '**Orgasm Addict** — your body has grown used to constant release, and now it *craves* it. ' \
               'From now until your next defeat, climaxing leaves you stronger instead of drained.'
    end

    if climax_addicted?
      add_condition!('climax_high', name: 'Climax High', floors: CLIMAX_AFTERMATH_FLOORS,
                                    effects: { 'strength' => 1, 'satisfy_bonus' => 0.05, 'submit_lp_bonus' => 2 },
                                    summary: 'STR +1, satisfy +5%, +2 LP on submit')
      lines << "_The rush of release sharpens you — **Climax High** (STR +1, satisfy +5%, +2 LP on submit) for #{CLIMAX_AFTERMATH_FLOORS} floors._"
    else
      add_condition!('climax_exhaustion', name: 'Afterglow Exhaustion', floors: CLIMAX_AFTERMATH_FLOORS,
                                          effects: { 'strength' => -1, 'agility' => -1 },
                                          summary: 'STR -1, AGI -1')
      lines << "_Afterglow exhaustion sets in — **STR -1, AGI -1** for #{CLIMAX_AFTERMATH_FLOORS} floors._"
    end
  end

  def adjust_defiance!(delta)
    update(defiance: [[defiance + delta, 0].max, max_defiance].min)
  end

  CURSE_REMOVE_COST = 50
  CURSE_SUPPRESS_COST = CURSE_REMOVE_COST / 2

  def active_curses_ordered
    active_curses.sort_by { |c| [Engine::CurseCatalog.type_for(c.name).to_s, c.name] }
  end

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
      refund_lp!(CURSE_REMOVE_COST)
      return { ok: false, error: :curse_not_found, message: 'Curse not found.' }
    end

    {
      ok: true,
      curse: curse,
      message: "You've removed the curse: **#{curse.name}**! (LP left: #{lp})"
    }
  end

  def suppress_curse_at!(index)
    curse = active_curses_ordered[index]
    return { ok: false, error: :invalid_index, message: 'That curse number is invalid.' } unless curse

    result = suppress_curse!(curse.id, cost: CURSE_SUPPRESS_COST)
    return result.merge(curse: curse, message: "**#{curse.name}** is now **suppressed** until you are defeated. (LP left: #{lp})") if result[:ok]

    message =
      if result[:error] == :insufficient_lp
        "You don't have enough Lust Points! You need #{CURSE_SUPPRESS_COST} LP."
      else
        'That curse is already suppressed.'
      end
    result.merge(message: message)
  end

  def reactivate_suppressed_curses!
    names = suppressed_curses.map(&:name)
    DB[:player_curses].where(player_id: discord_id, is_suppressed: true).update(is_suppressed: false) if names.any?
    names
  end

  def purge_curse!(curse_id, cost: CURSE_REMOVE_COST)
    return { ok: false, error: :insufficient_lp } unless spend_lp!(cost)

    deleted = DB[:player_curses].where(player_id: discord_id, curse_id: curse_id).delete
    if deleted.zero?
      refund_lp!(cost)
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
      refund_lp!(cost)
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
    remember!('curses_seen', curse.name)
    count = active_curse_count
    set_tracker!('max_curses_simultaneous', count) if count > tracker('max_curses_simultaneous')
    true
  end

  TROPHY_SLOT = 'trophy'

  def apply_combat_start_effects!(monster_type)
    lines = []
    regen = curse_effect_sum("#{monster_type}_defiance_regen").round
    if regen.positive?
      gained = heal_defiance!(regen)
      lines << "Photosynthesis: you regain **#{gained}** defiance! (now #{defiance}/#{max_defiance})" if gained.positive?
    end
    rooted = curse_effect_sum('combat_start_regen').round
    if rooted.positive?
      gained = heal_defiance!(rooted)
      lines << "Your roots drink in the tower's light — **+#{gained}** defiance. (now #{defiance}/#{max_defiance})" if gained.positive?
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

    current = equipment_for_slot(item.slot)
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
    first_time = !cursed_shop_unlocked?(item.name)
    remember!('mimics_removed', item.name)
    unlock = first_time ? "\n_**#{item.name}** is now available for free in the Cursed Shop (`/cursedshop`)._" : ''
    {
      ok: true,
      message: "You spend **#{cost}** LP. **#{item.name}** turns to dust as it is torn free.#{unlock}"
    }
  end

  def cursed_shop_unlocks
    Array(tracker_hash['mimics_removed']).map(&:to_s)
  end

  def cursed_shop_unlocked?(name)
    cursed_shop_unlocks.include?(name.to_s)
  end

  def strip_non_cursed_equipment!
    rows = DB[:player_equipment]
           .join(:equipment, id: :equipment_id)
           .where(player_id: discord_id)
           .where(Sequel[:equipment][:cursed] => false)
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
      log << "Its attentions raise your lust by **#{lust_hit}**. (now #{lust})"
    end
  end

  def equipped_items
    equipment_dataset.where(Sequel[:player_equipment][:is_equipped] => true).all
  end

  def equipment_effect_values(key)
    equipped_items.map { |item| item.stat_modifiers[key.to_s] }.compact
  end

  def equipment_effect_sum(key)
    equipment_effect_values(key).sum { |v| v.is_a?(Numeric) ? v.to_f : 0.0 }
  end

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
