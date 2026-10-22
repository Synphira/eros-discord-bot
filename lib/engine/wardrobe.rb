# frozen_string_literal: true

module Engine
  # Hidden outfit sets. Pieces scattered across Berry's shelves, Vex's
  # rack, and the tower's chests belong to named sets; wear every piece
  # of one at once and the set wakes up with a passive of its own. The
  # sets are not written on any label — a delver finds them by dressing
  # the part completely, and the equipment menu names the bonus only
  # once it is active.
  module Wardrobe
    SETS = {
      'naughty_nurse' => {
        name: 'Naughty Nurse', bonus_name: 'Bedside Manner',
        pieces: ["Nurse's Cap", 'Naughty Nurse Uniform', "Nurse's Stockings"],
        effects: { 'defiance_regen' => 3, 'submit_lp_bonus' => 1 },
        blurb: 'The full uniform practices medicine the tower way: something in you knits back ' \
               'together every few moments, bedside and otherwise.'
      },
      'tower_maid' => {
        name: 'Tower Maid', bonus_name: 'In Service',
        pieces: ["Maid's Lace Cap", 'Satin Maid Dress', 'Service Heels'],
        effects: { 'victory_lp_bonus' => 2, 'explore_lp' => 1 },
        blurb: 'Fully in uniform, the tower treats you as staff: doors tip, victories tip better.'
      },
      'fallen_nun' => {
        name: 'Fallen Nun', bonus_name: 'Broken Vows',
        pieces: ["Fallen Nun's Veil", 'Penitent Habit', 'Confession Garter'],
        effects: { 'satisfy_bonus' => 0.06, 'submit_lp_bonus' => 2 },
        blurb: 'Veil, habit, and garter, worn all wrong together. The tower has been waiting to ' \
               'break a nun properly, and it pays in devotion.'
      },
      'velvet_bunny' => {
        name: 'Velvet Bunny', bonus_name: 'Warren Ways',
        pieces: ['Velvet Bunny Ears', 'Velvet Bunny Suit', 'Fishnet Tights'],
        effects: { 'agility' => 1, 'dodge_bonus' => 0.03 },
        blurb: 'Ears up, tail on, nowhere to run — and somehow harder to catch for it.'
      },
      'knight_of_the_tower' => {
        name: 'Knight of the Tower', bonus_name: 'Oathbound Plate',
        pieces: ["Knight's Helm", "Knight's Cuirass", "Knight's Greaves", "Knight's Sabatons"],
        effects: { 'max_hp' => 15, 'resistance' => 1 },
        blurb: 'A full harness of tower plate, vow and all: you simply endure more.'
      },
      'holy_orders' => {
        name: 'Holy Orders', bonus_name: 'Unbroken Vows',
        pieces: ["Exorcist's Censer", 'Sacred Rosary', 'Chaste Plate'],
        effects: { 'lust_mult' => 0.92, 'satisfy_bonus' => 0.03 },
        blurb: 'Censer, rosary, and chaste steel worn together: devotion, armoured — for whatever ' \
               'good the tower lets it do you.'
      },
      'hand_of_the_maker' => {
        name: "The Maker's Own", bonus_name: 'Hand of the Maker',
        pieces: ["Syn's Smudged Tiara", "Syn's Lace Scraps", "Syn's Garter of Vials",
                 "Syn's Smoked-Glass Wings"],
        effects: { 'satisfy_bonus' => 0.08, 'victory_lp_bonus' => 3, 'submit_lp_bonus' => 3 },
        blurb: 'Tiara, lace, garter, and wings, worn as their maker wears them: the tower ' \
               'recognises its first seamstress, and everything in it behaves accordingly.'
      }
    }.freeze

    # The developer's own signature gear: Syn's look, made wearable —
    # scraps of black lace, a garter hung with needle-case and ink
    # vials, smoked-glass wings, the infamous tiara, and the cursed
    # ink needle itself. Never stocked, never dropped, never synced
    # into any shop: it exists in the equipment table only so its one
    # rightful wearer can be given it by dev command. Every piece is
    # flagged dev_only, and Player#equip_item refuses it to anyone
    # but the developer.
    DEV_GEAR = [
      { name: "Syn's Cursed Ink Needle", type: 'weapon', slot: 'weapon', rarity: 5,
        description: 'The first needle. Its ink is cursed the slow way: whatever it writes on ' \
                     'skin, flesh remembers — monsters come away marked and strangely willing.',
        stat_modifiers: { 'damage' => 6, 'strength' => 3, 'crit_chance' => 0.15, 'appearance' => 10,
                          'satisfy_bonus' => 0.05, 'dev_only' => true } },
      { name: "Syn's Smudged Tiara", type: 'armor', slot: 'head', rarity: 5,
        description: 'The tiara that survived whatever happened to the tiara. Covar tells that ' \
                     'story in whispers and will not be hurried.',
        stat_modifiers: { 'appearance' => 9, 'satisfy_bonus' => 0.03, 'dev_only' => true } },
      { name: "Syn's Lace Scraps", type: 'armor', slot: 'chest', rarity: 5,
        description: 'Barely-there black lace over ink-covered skin. Her body is the catalogue; ' \
                     'this is just the frame.',
        stat_modifiers: { 'appearance' => 12, 'lust_mult' => 1.10, 'satisfy_bonus' => 0.03, 'dev_only' => true } },
      { name: "Syn's Garter of Vials", type: 'armor', slot: 'legs', rarity: 5,
        description: 'A garter belt hung with a needle-case and little ink vials, worn over ' \
                     'tally-marked thighs. Tools of the trade, kept close.',
        stat_modifiers: { 'appearance' => 10, 'victory_lp_bonus' => 2, 'dev_only' => true } },
      { name: "Syn's Smoked-Glass Wings", type: 'accessory', slot: 'accessory', rarity: 5,
        description: 'Drooping wings of smoked glass that catch candlelight like held breath. ' \
                     'Heavy-lidded, like their owner.',
        stat_modifiers: { 'appearance' => 9, 'agility' => 2, 'dodge_bonus' => 0.05, 'dev_only' => true } }
    ].freeze

    def sync_dev_gear!
      DEV_GEAR.each do |spec|
        record = ::Equipment.find_or_create(name: spec[:name]) do |e|
          e.type = spec[:type]
          e.slot = spec[:slot]
        end
        record.type = spec[:type]
        record.slot = spec[:slot]
        record.description = spec[:description]
        record.stat_modifiers = spec[:stat_modifiers]
        record.cost = 0
        record.rarity = spec[:rarity]
        record.cursed = false
        record.violation_type = nil
        record.removal_cost = 0
        record.save_changes
      end
    end
    module_function :sync_dev_gear!

    module_function

    def set(key)
      SETS[key.to_s]
    end

    # Sets whose every piece is on the delver's body right now,
    # as [key, spec] pairs.
    def active_sets(player)
      worn = player.equipped_items.map { |item| item.name.to_s }
      SETS.select { |_key, spec| (spec[:pieces] - worn).empty? }
    end

    def active?(player)
      active_sets(player).any?
    end

    # Merged bonus effects of every active set. Numeric values sum;
    # multiplier keys (anything ending in _mult) multiply.
    def effects(player)
      merged = {}
      active_sets(player).each_value do |spec|
        spec[:effects].each do |key, value|
          key = key.to_s
          merged[key] =
            if value.is_a?(Numeric) && key.end_with?('_mult') && merged[key]
              merged[key] * value
            elsif value.is_a?(Numeric) && merged[key].is_a?(Numeric)
              merged[key] + value
            else
              value
            end
        end
      end
      merged
    end

    def effect_sum(player, key)
      effects(player)[key.to_s].to_f
    end

    def describe_set(key, spec)
      rendered = Engine::FetishEvents.describe_effects(spec[:effects])
      "**#{spec[:bonus_name]}** _(#{spec[:name]} #{spec[:pieces].size}/#{spec[:pieces].size})_ — #{rendered}\n_#{spec[:blurb]}_"
    end
  end
end
