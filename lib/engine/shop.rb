# frozen_string_literal: true

module Engine
  module Shop
    # Canonical shop stock only — cursed / treasure / boss trophies stay out of the shop.
    INVENTORY = [
      {
        name: 'Rusty Dagger',
        type: 'weapon',
        slot: 'weapon',
        description: 'A slightly rusty but still sharp dagger.',
        stat_modifiers: { 'strength' => 2 },
        cost: 20,
        rarity: 1
      },
      {
        name: 'Enchanted Whip',
        type: 'weapon',
        slot: 'weapon',
        description: 'A whip that glows with faint magical energy.',
        stat_modifiers: { 'agility' => 3 },
        cost: 35,
        rarity: 2
      },
      {
        name: 'Soul-Draining Blade',
        type: 'weapon',
        slot: 'weapon',
        description: 'A dark blade that feeds on the life force of its victims.',
        stat_modifiers: { 'strength' => 4, 'lust_damage' => 2 },
        cost: 60,
        rarity: 3
      },
      {
        name: 'Leather Harness',
        type: 'armor',
        slot: 'chest',
        description: 'Minimal leather protection that allows for maximum mobility.',
        stat_modifiers: { 'resistance' => 2 },
        cost: 25,
        rarity: 1
      },
      {
        name: 'Enchanted Loincloth',
        type: 'armor',
        slot: 'legs',
        description: 'A magically reinforced loincloth that provides surprising protection.',
        stat_modifiers: { 'resistance' => 3, 'lust_resist' => 1 },
        cost: 40,
        rarity: 2
      },
      {
        name: 'Abyssal Plate',
        type: 'armor',
        slot: 'chest',
        description: 'Armor forged in the deepest parts of the abyss.',
        stat_modifiers: { 'resistance' => 5, 'max_hp' => 10 },
        cost: 80,
        rarity: 4
      },
      {
        name: 'Lust Ward Amulet',
        type: 'accessory',
        slot: 'accessory',
        description: 'An amulet that helps ward off unwanted arousal.',
        stat_modifiers: { 'lust_resist' => 2 },
        cost: 30,
        rarity: 2
      },
      {
        name: 'Talisman of Escape',
        type: 'accessory',
        slot: 'accessory',
        description: 'A talisman that improves your chances of fleeing.',
        stat_modifiers: { 'flee_bonus' => 0.2 },
        cost: 35,
        rarity: 2
      },
      {
        name: 'Ring of Sustenance',
        type: 'accessory',
        slot: 'accessory',
        description: 'A ring that slowly restores your vitality.',
        stat_modifiers: { 'hp_regen' => 1 },
        cost: 45,
        rarity: 3
      },
      {
        name: 'Curse Purification Scroll',
        type: 'special',
        slot: 'consumable',
        description: 'A scroll that can remove one curse without spending LP.',
        cost: 100,
        rarity: 4
      },
      {
        name: 'Bottled Sanctuary',
        type: 'special',
        slot: 'consumable',
        description: 'A magical sanctuary that guarantees safety for your next exploration.',
        cost: 75,
        rarity: 3
      }
    ].freeze

    CATEGORIES = %w[weapon armor accessory special].freeze

    CATEGORY_LABELS = {
      'weapon' => 'Weapons',
      'armor' => 'Armor',
      'accessory' => 'Accessories',
      'special' => 'Special'
    }.freeze

    # Max buy buttons per category page (one Discord row = 5).
    PAGE_SIZE = 5

    module_function

    def sync_to_db!
      INVENTORY.each do |item|
        record = ::Equipment.find_or_create(name: item[:name]) do |e|
          apply_shop_template!(e, item)
        end
        apply_shop_template!(record, item)
        record.save_changes
      end
    end

    def apply_shop_template!(record, item)
      record.type = item[:type]
      record.slot = item[:slot]
      record.description = item[:description]
      record.stat_modifiers = item[:stat_modifiers] || {}
      record.cost = item[:cost]
      record.rarity = item[:rarity]
      record.cursed = false
      record.violation_type = nil
      record.removal_cost = 0
    end
    module_function :apply_shop_template!

    def shop_names
      INVENTORY.map { |i| i[:name] }
    end

    def shop_item?(equipment)
      return false unless equipment
      return false if equipment.cursed

      shop_names.include?(equipment.name)
    end

    # Stock for one category, cheapest first, never cursed / non-shop rows.
    def stock_for(category)
      category = normalize_category(category)
      names = INVENTORY.select { |i| i[:type] == category }.map { |i| i[:name] }
      ::Equipment.where(name: names, cursed: false).all.sort_by { |e| [e.cost.to_i, e.name] }
    end

    def normalize_category(category)
      key = category.to_s.downcase
      CATEGORIES.include?(key) ? key : 'weapon'
    end

    def page_count(category)
      total = stock_for(category).size
      return 1 if total.zero?

      (total + PAGE_SIZE - 1) / PAGE_SIZE
    end

    def page_items(category, page)
      category = normalize_category(category)
      page = [[page.to_i, 0].max, page_count(category) - 1].min
      stock_for(category).slice(page * PAGE_SIZE, PAGE_SIZE) || []
    end

    def buy_item(player, item_id)
      item = ::Equipment[item_id]
      return { ok: false, error: :not_found, message: 'Item not found.' } unless item
      return { ok: false, error: :not_sold, message: 'That item is not sold here.' } unless shop_item?(item)
      return { ok: false, error: :cursed, message: 'The shop refuses cursed living gear.' } if item.cursed

      if player.lp < item.cost
        return {
          ok: false,
          error: :insufficient_lp,
          message: "You don't have enough Lust Points! You need **#{item.cost}** LP (you have `#{player.lp}`)."
        }
      end

      if player.owns_equipment?(item.id) && item.type != 'special'
        return { ok: false, error: :already_owned, message: "You already own **#{item.name}**." }
      end

      if item.type == 'special'
        case item.name
        when 'Curse Purification Scroll'
          if player.active_curse_count.positive?
            player.spend_lp!(item.cost)
            curse_to_remove = player.active_curses_ordered.sample
            player.remove_curse_at!(player.active_curses_ordered.index(curse_to_remove))
            return { ok: true, message: "You used the scroll to remove the **#{curse_to_remove.name}** curse!" }
          end
          return { ok: false, error: :no_curses, message: "You don't have any curses to remove!" }
        when 'Bottled Sanctuary'
          player.spend_lp!(item.cost)
          if player.columns.include?(:sanctuary)
            player.update(sanctuary: true)
          end
          return { ok: true, message: 'You drink from the bottled sanctuary. Your next exploration will be safe!' }
        end
      end

      player.spend_lp!(item.cost)
      grant = player.grant_equipment!(item, auto_equip: false)
      unless grant[:ok]
        player.gain_lp!(item.cost)
        return grant
      end

      { ok: true, message: "You purchased **#{item.name}**! Check your inventory with `!equipment`." }
    end

    def sell_item(player, equipment_id)
      row = DB[:player_equipment]
            .where(player_id: player.discord_id, equipment_id: equipment_id)
            .first
      return { ok: false, error: :not_found, message: 'Item not found in your pack.' } unless row

      equipment = ::Equipment[row[:equipment_id]]
      return { ok: false, error: :not_found, message: 'Item not found.' } unless equipment

      if equipment.cursed
        return {
          ok: false,
          error: :cursed,
          message: "Living gear can't be sold — use `!remove #{equipment.name}` (costs LP)."
        }
      end

      sell_price = [(equipment.cost * 0.5).round, 1].max
      player.gain_lp!(sell_price)
      DB[:player_equipment].where(id: row[:id]).delete

      { ok: true, message: "You sold **#{equipment.name}** for **#{sell_price}** LP!" }
    end
  end
end
