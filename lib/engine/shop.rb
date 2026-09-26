module Engine
  module Shop
    # Define shop inventory with equipment and special items
    INVENTORY = [
      # Weapons
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
      # Armor
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
      # Accessories
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
      # Special items
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

    module_function

    def sync_to_db!
      INVENTORY.each do |item|
        Equipment.find_or_create(name: item[:name]) do |e|
          e.type = item[:type]
          e.slot = item[:slot]
          e.description = item[:description]
          e.stat_modifiers = item[:stat_modifiers]
          e.cost = item[:cost]
          e.rarity = item[:rarity]
        end
      end
    end

    def buy_item(player, item_id)
      item = Equipment[item_id]
      return { ok: false, error: :not_found, message: 'Item not found.' } unless item

      if player.lp < item.cost
        return { ok: false, error: :insufficient_lp, message: "You don't have enough Lust Points! You need #{item.cost} LP." }
      end

      # Check if player already has this item
      existing = DB[:player_equipment].where(player_id: player.discord_id, equipment_id: item_id).first
      if existing
        return { ok: false, error: :already_owned, message: "You already own this item!" }
      end

      # Handle special consumables
      if item.type == 'special'
        case item.name
        when 'Curse Purification Scroll'
          if player.active_curse_count > 0
            player.spend_lp!(item.cost)
            # Remove a random curse
            curse_to_remove = player.active_curses_ordered.sample
            player.remove_curse_at!(player.active_curses_ordered.index(curse_to_remove))
            return { ok: true, message: "You used the scroll to remove the **#{curse_to_remove.name}** curse!" }
          else
            return { ok: false, error: :no_curses, message: "You don't have any curses to remove!" }
          end
        when 'Bottled Sanctuary'
          player.spend_lp!(item.cost)
          # Persist via encounter-style column if present; otherwise skip flag.
          if player.columns.include?(:sanctuary)
            player.update(sanctuary: true)
          end
          return { ok: true, message: 'You drink from the bottled sanctuary. Your next exploration will be safe!' }
        end
      end

      # Regular equipment
      player.spend_lp!(item.cost)
      DB[:player_equipment].insert(
        player_id: player.discord_id,
        equipment_id: item_id,
        is_equipped: false,
        acquired_at: Time.now
      )

      { ok: true, message: "You purchased **#{item.name}**! Check your inventory with !equipment." }
    end

    def sell_item(player, equipment_id)
      item = DB[:player_equipment].where(player_id: player.discord_id, id: equipment_id).first
      return { ok: false, error: :not_found, message: 'Item not found.' } unless item

      equipment = Equipment[item[:equipment_id]]
      sell_price = (equipment.cost * 0.5).round  # Sell for 50% of purchase price

      player.gain_lp!(sell_price)
      DB[:player_equipment].where(id: equipment_id).delete

      { ok: true, message: "You sold **#{equipment.name}** for **#{sell_price}** LP!" }
    end
  end
end