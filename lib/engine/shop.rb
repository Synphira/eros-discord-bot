# frozen_string_literal: true

module Engine
  module Shop
    def self.item(name, type, slot, cost, rarity, description, mods = nil)
      { name: name, type: type, slot: slot, description: description, stat_modifiers: mods, cost: cost, rarity: rarity }
    end

    INVENTORY = [
      # Weapons
      item('Rusty Dagger', 'weapon', 'weapon', 20, 1,
           'A slightly rusty but still sharp dagger.', { 'strength' => 2 }),
      item('Enchanted Whip', 'weapon', 'weapon', 35, 2,
           'A whip that glows with faint magical energy. Quick hands land the odd surprise hit.',
           { 'agility' => 3, 'crit_chance' => 0.05, 'appearance' => 1 }),
      item("Delver's Shortsword", 'weapon', 'weapon', 45, 2,
           'Honest steel, well balanced. Nothing fancy, nothing missing.', { 'strength' => 3, 'damage' => 1 }),
      item('Riding Crop of Mastery', 'weapon', 'weapon', 55, 2,
           'Every flick reminds a monster who is in charge, and leaves it eager to be satisfied.',
           { 'damage' => 2, 'satisfy_bonus' => 0.05, 'appearance' => 2 }),
      item('Soul-Draining Blade', 'weapon', 'weapon', 60, 3,
           'A dark blade that drinks the will of whatever it cuts and pours it into you.',
           { 'strength' => 4, 'damage' => 2, 'lifesteal' => 0.2, 'appearance' => 1 }),
      item('Silvered Rapier', 'weapon', 'weapon', 75, 3,
           'A needle-thin blade that finds every gap. Often lands a double-damage surprise hit.',
           { 'agility' => 2, 'damage' => 1, 'crit_chance' => 0.12 }),
      item('Beastbane Spear', 'weapon', 'weapon', 75, 3,
           'A long hunting spear. Keeps snouts and claws at arm\'s length.',
           { 'strength' => 3, 'beast_thorns' => 4, 'beast_lust_mult' => 0.85 }),
      item("Exorcist's Censer", 'weapon', 'weapon', 85, 3,
           'A swinging censer of holy smoke. Demons and the dead recoil from it.',
           { 'damage' => 2, 'demon_thorns' => 3, 'undead_thorns' => 3, 'demon_lust_mult' => 0.9, 'undead_lust_mult' => 0.9,
             'appearance' => 3 }),
      item('Sinbreaker Maul', 'weapon', 'weapon', 150, 4,
           'A huge two-handed hammer. Slow, but whatever it hits stays hit.',
           { 'strength' => 6, 'damage' => 4, 'agility' => -1 }),

      # Armour
      item('Leather Harness', 'armor', 'chest', 25, 1,
           'Minimal leather protection that allows for maximum mobility.',
           { 'resistance' => 2, 'lust_resist' => 1, 'appearance' => 3 }),
      item('Iron Circlet', 'armor', 'head', 30, 1,
           'A plain band of cold iron that keeps your head clear.', { 'resistance' => 2, 'lust_resist' => 1, 'appearance' => 1 }),
      item('Reinforced Chaps', 'armor', 'legs', 35, 1,
           'Thick leather leggings that are hard to grab hold of.', { 'resistance' => 2, 'flee_bonus' => 0.1, 'appearance' => 2 }),
      item('Enchanted Loincloth', 'armor', 'legs', 40, 2,
           'A magically reinforced loincloth that provides surprising protection.',
           { 'resistance' => 3, 'lust_resist' => 1, 'appearance' => 4 }),
      item('Brigandine Vest', 'armor', 'chest', 45, 2,
           'Steel plates riveted inside a padded vest.', { 'resistance' => 3, 'max_hp' => 8, 'appearance' => -1 }),
      item('Silent Slippers', 'armor', 'feet', 45, 2,
           'Soft-soled slippers that let you twist away at the last moment.', { 'agility' => 2, 'dodge_bonus' => 0.05, 'appearance' => 1 }),
      item('Warded Greaves', 'armor', 'legs', 60, 3,
           'Rune-etched shin guards that tingle a warning before you step on a trap.',
           { 'resistance' => 3, 'trap_avoid_bonus' => 0.12 }),
      item('Wayfinder Boots', 'armor', 'feet', 65, 3,
           'Boots that always seem to find something worth picking up.',
           { 'agility' => 1, 'explore_lp' => 2, 'trap_avoid_bonus' => 0.05 }),
      item('Hood of the Unseen', 'armor', 'head', 90, 3,
           'A shadowy hood. Monsters have a harder time noticing you at all.',
           { 'agility' => 1, 'encounter_rate' => 0.85, 'appearance' => -3 }),
      item('Abyssal Plate', 'armor', 'chest', 80, 4,
           'Armor forged in the deepest parts of the abyss.', { 'resistance' => 5, 'max_hp' => 15, 'appearance' => 1 }),
      item('Chaste Plate', 'armor', 'chest', 120, 4,
           'Cold, heavy steel that dulls every touch that reaches you.',
           { 'resistance' => 4, 'lust_mult' => 0.88, 'agility' => -1, 'appearance' => -4 }),
      item('Crown of Defiance', 'armor', 'head', 160, 4,
           'A crown of black iron. Some monsters lose their nerve and back off without touching you.',
           { 'max_hp' => 10, 'resistance' => 2, 'intimidate_chance' => 0.1, 'appearance' => 2 }),
      item("Knight's Helm", 'armor', 'head', 70, 3,
           'A polished helm with the visor permanently raised. The tower prefers to see your face.',
           { 'resistance' => 2, 'max_hp' => 5, 'appearance' => 1 }),
      item("Knight's Cuirass", 'armor', 'chest', 95, 3,
           'Bright plate fitted close and polished to a mirror shine. It reflects whoever is looking.',
           { 'resistance' => 4, 'max_hp' => 8, 'appearance' => 1 }),
      item("Knight's Greaves", 'armor', 'legs', 65, 3,
           'Articulated steel for the legs, engraved with a vow nobody remembers taking.',
           { 'resistance' => 3, 'appearance' => 1 }),
      item("Knight's Sabatons", 'armor', 'feet', 55, 2,
           'Steel shoes that ring on the tower stone like small bells announcing you.',
           { 'resistance' => 2, 'appearance' => 1 }),

      # Accessories
      item('Lust Ward Amulet', 'accessory', 'accessory', 30, 2,
           'An amulet that helps ward off unwanted arousal.', { 'lust_resist' => 3, 'appearance' => 2 }),
      item('Talisman of Escape', 'accessory', 'accessory', 35, 2,
           'A talisman that makes it much easier to slip away.', { 'flee_bonus' => 0.25 }),
      item('Lucky Coin', 'accessory', 'accessory', 50, 2,
           'Flip it before you open anything. It is never wrong.', { 'treasure_lp' => 5, 'victory_lp_bonus' => 1 }),
      item('Ring of Sustenance', 'accessory', 'accessory', 45, 3,
           'A ring that slowly restores your vitality every combat round.', { 'defiance_regen' => 3 }),
      item('Sacred Rosary', 'accessory', 'accessory', 90, 3,
           'Prayer beads that cool your blood whenever a monster touches you.',
           { 'lust_resist' => 2, 'lust_mult' => 0.92, 'appearance' => 4 }),
      item("Trophy Hunter's Charm", 'accessory', 'accessory', 110, 3,
           'A string of claws and fangs. The tower pays well for every kill you add to it.',
           { 'victory_lp_bonus' => 4, 'crit_chance' => 0.05, 'appearance' => 1 }),

      # Potions (drunk on the spot)
      { name: 'Defiance Draught', type: 'special', slot: 'consumable', cost: 30, rarity: 1,
        description: 'Drink on the spot: restores 40% of your max defiance.' },
      { name: 'Cooling Elixir', type: 'special', slot: 'consumable', cost: 25, rarity: 1,
        description: 'Drink on the spot: −40 lust.' },
      { name: 'Bottled Sanctuary', type: 'special', slot: 'consumable', cost: 75, rarity: 3,
        description: 'Your next exploration is safe: no monsters, traps, or events.' },
      { name: 'Bottled Ceremony', type: 'special', slot: 'consumable', cost: 60, rarity: 3,
        description: 'Carry it (up to 3): your next monster starts charmed by the tea — far easier ' \
                     'to satisfy. Berry also bottles what delvers decant at tea ceremonies.' },
      { name: 'Potion of Purity', type: 'special', slot: 'consumable', cost: 500, rarity: 3,
        description: 'Drink on the spot: washes away all of your corruption.' },
      { name: 'Potion of Depravity', type: 'special', slot: 'consumable', cost: 10, rarity: 3,
        description: 'Drink on the spot: deepens your corruption by 25, toward Fully Corrupted.' },
      { name: 'Male Becoming Draught', type: 'special', slot: 'consumable', cost: 100, rarity: 4,
        description: 'Drink on the spot: permanently become male (penis, anus). Also washes away any ' \
                     'condition that changed your gender.' },
      { name: 'FtM Becoming Draught', type: 'special', slot: 'consumable', cost: 100, rarity: 4,
        description: 'Drink on the spot: permanently become male (FtM: vagina, anus). Also washes away any ' \
                     'condition that changed your gender.' },
      { name: 'Female Becoming Draught', type: 'special', slot: 'consumable', cost: 100, rarity: 4,
        description: 'Drink on the spot: permanently become female (vagina, anus, breasts). Also washes away ' \
                     'any condition that changed your gender.' },
      { name: 'MtF Becoming Draught', type: 'special', slot: 'consumable', cost: 100, rarity: 4,
        description: 'Drink on the spot: permanently become female (MtF: penis, anus, breasts). Also washes ' \
                     'away any condition that changed your gender.' },
      { name: 'Hermaphrodite Becoming Draught', type: 'special', slot: 'consumable', cost: 100, rarity: 4,
        description: 'Drink on the spot: permanently become a hermaphrodite (penis, vagina, anus, breasts). ' \
                     'Also washes away any condition that changed your gender.' },
      { name: 'Breast Growth Tonic', type: 'special', slot: 'consumable', cost: 40, rarity: 2,
        description: 'Drink on the spot: your breasts grow one size.' },
      { name: 'Breast Shrinking Tonic', type: 'special', slot: 'consumable', cost: 40, rarity: 2,
        description: 'Drink on the spot: your breasts shrink one size.' },
      { name: 'Cock Growth Tonic', type: 'special', slot: 'consumable', cost: 40, rarity: 2,
        description: 'Drink on the spot: your cock grows one size.' },
      { name: 'Cock Shrinking Tonic', type: 'special', slot: 'consumable', cost: 40, rarity: 2,
        description: 'Drink on the spot: your cock shrinks one size.' },
      { name: 'Butt Growth Tonic', type: 'special', slot: 'consumable', cost: 40, rarity: 2,
        description: 'Drink on the spot: your butt grows one size.' },
      { name: 'Butt Shrinking Tonic', type: 'special', slot: 'consumable', cost: 40, rarity: 2,
        description: 'Drink on the spot: your butt shrinks one size.' }
    ].freeze

    DRAUGHT_PCT = 0.4
    ELIXIR_LUST = 40

    # Potion name => [body part, size steps]. Applied on the spot at buy time.
    SIZE_POTIONS = {
      'Breast Growth Tonic' => ['breasts', 1],
      'Breast Shrinking Tonic' => ['breasts', -1],
      'Cock Growth Tonic' => ['penis', 1],
      'Cock Shrinking Tonic' => ['penis', -1],
      'Butt Growth Tonic' => ['butt', 1],
      'Butt Shrinking Tonic' => ['butt', -1]
    }.freeze

    # Becoming draughts: potion name => the gender it permanently makes you.
    GENDER_POTIONS = {
      'Male Becoming Draught' => 'Male',
      'FtM Becoming Draught' => 'Male (FtM)',
      'Female Becoming Draught' => 'Female',
      'MtF Becoming Draught' => 'Female (MtF)',
      'Hermaphrodite Becoming Draught' => 'Hermaphrodite'
    }.freeze

    # The Potions aisle is shelved by theme — each list is exactly one page.
    POTION_PAGES = [
      ['Cooling Elixir', 'Defiance Draught', 'Potion of Purity', 'Potion of Depravity'],
      ['Breast Growth Tonic', 'Cock Growth Tonic', 'Butt Growth Tonic'],
      ['Breast Shrinking Tonic', 'Cock Shrinking Tonic', 'Butt Shrinking Tonic'],
      ['Male Becoming Draught', 'FtM Becoming Draught', 'Female Becoming Draught', 'MtF Becoming Draught',
       'Hermaphrodite Becoming Draught'],
      ['Bottled Sanctuary', 'Bottled Ceremony']
    ].freeze

    POTION_PAGE_LABELS = ['Draughts & Elixirs', 'Growth Tonics', 'Shrinking Tonics', 'Becoming Draughts',
                          'Bottled Curios'].freeze

    CATEGORIES = %w[weapon armor accessory special].freeze

    CATEGORY_LABELS = {
      'weapon' => 'Weapons',
      'armor' => 'Armor',
      'accessory' => 'Accessories',
      'special' => 'Potions'
    }.freeze

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

    def stock_for(category)
      category = normalize_category(category)
      names = INVENTORY.select { |i| i[:type] == category }.map { |i| i[:name] }
      items = ::Equipment.where(name: names, cursed: false).all
      return items.sort_by { |e| [e.cost.to_i, e.name] } unless category == 'special'

      order = POTION_PAGES.flatten
      items.sort_by { |e| order.index(e.name) || order.size }
    end

    def normalize_category(category)
      key = category.to_s.downcase
      key = 'special' if %w[potion potions].include?(key)
      CATEGORIES.include?(key) ? key : 'weapon'
    end

    def page_count(category)
      category = normalize_category(category)
      return POTION_PAGES.size if category == 'special'

      total = stock_for(category).size
      return 1 if total.zero?

      (total + PAGE_SIZE - 1) / PAGE_SIZE
    end

    def page_items(category, page)
      category = normalize_category(category)
      page = [[page.to_i, 0].max, page_count(category) - 1].min
      return potion_page_items(page) if category == 'special'

      stock_for(category).slice(page * PAGE_SIZE, PAGE_SIZE) || []
    end

    def potion_page_items(page)
      by_name = stock_for('special').to_h { |e| [e.name, e] }
      (POTION_PAGES[page.to_i] || []).filter_map { |name| by_name[name] }
    end

    # What this delver actually pays: Berry quietly rewards a delver
    # who arrives looking like an invitation.
    def price_for(player, item)
      [(item.cost.to_i * Engine::ThreatCalculator.price_multiplier(player)).round, 1].max
    end

    def buy_item(player, item_id)
      item = ::Equipment[item_id]
      return { ok: false, error: :not_found, message: 'Item not found.' } unless item
      return { ok: false, error: :not_sold, message: 'That item is not sold here.' } unless shop_item?(item)
      return { ok: false, error: :cursed, message: 'The shop refuses cursed living gear.' } if item.cursed

      cost = price_for(player, item)
      if player.lp < cost
        return {
          ok: false,
          error: :insufficient_lp,
          message: "You don't have enough Lust Points! You need **#{cost}** LP (you have `#{player.lp}`)."
        }
      end

      if player.owns_equipment?(item.id) && item.type != 'special'
        return { ok: false, error: :already_owned, message: "You already own **#{item.name}**." }
      end

      if item.type == 'special'
        if (potion = SIZE_POTIONS[item.name])
          return buy_size_potion(player, item, *potion, cost)
        end

        if (target_gender = GENDER_POTIONS[item.name])
          return buy_gender_potion(player, item, target_gender, cost)
        end

        case item.name
        when 'Potion of Purity'
          return buy_purity(player, item, cost)
        when 'Potion of Depravity'
          return buy_depravity(player, item, cost)
        when 'Bottled Sanctuary'
          if player.sanctuary
            return { ok: false, error: :already_active, message: 'Your sanctuary is already active — explore first.' }
          end

          player.spend_lp!(cost)
          player.update(sanctuary: true)
          return { ok: true, message: 'You drink from the bottled sanctuary. Your next exploration will be safe!' }
        when 'Bottled Ceremony'
          held = player.tracker('bottled_ceremony')
          if held >= 3
            return { ok: false, error: :full, message: 'You already carry 3 Bottled Ceremonies — ' \
                                                      'Berry refuses to let you slosh.' }
          end

          player.spend_lp!(cost)
          player.bump_tracker!('bottled_ceremony')
          return { ok: true, message: "Berry stoppers the little vial with ceremony. **Bottled Ceremony " \
                                      "carried (#{held + 1}/3)** — your next monster starts charmed by " \
                                      'the tea and far easier to satisfy.' }
        when 'Defiance Draught'
          if player.defiance >= player.max_defiance
            return { ok: false, error: :full, message: 'Your defiance is already full.' }
          end

          player.spend_lp!(cost)
          gained = player.heal_defiance!((player.max_defiance * DRAUGHT_PCT).round)
          return { ok: true, message: "You down the draught. **+#{gained} Defiance** " \
                                      "(now `#{player.defiance}/#{player.max_defiance}`)." }
        when 'Cooling Elixir'
          return { ok: false, error: :calm, message: "You're not aroused enough to need it." } if player.lust <= 0

          player.spend_lp!(cost)
          before = player.lust
          player.update(lust: [player.lust - ELIXIR_LUST, 0].max)
          return { ok: true, message: "The elixir spreads through you like cool water. **−#{before - player.lust} Lust** " \
                                      "(now `#{player.lust}`)." }
        end
      end

      player.spend_lp!(cost)
      grant = player.grant_equipment!(item, auto_equip: false)
      unless grant[:ok]
        player.refund_lp!(cost)
        return grant
      end

      note = cost < item.cost.to_i ? " _(Berry knocks #{item.cost.to_i - cost} LP off — \"for the view, sugar.\")_" : ''
      { ok: true, message: "You purchased **#{item.name}**! Check your inventory with `e,equipment`.#{note}" }
    end

    def buy_purity(player, item, cost = nil)
      cost ||= item.cost
      level = Engine::Corruption.level(player)
      if level <= 0
        return { ok: false, error: :already_pure,
                 message: "There's no corruption on you to wash away — Berry keeps your LP." }
      end

      player.spend_lp!(cost)
      player.set_tracker!(Engine::Corruption::KEY, 0)
      Engine::Corruption.refresh!(player)
      { ok: true,
        message: "You down the potion. A cool clarity washes through you — **corruption #{level} → 0**. Untouched again." }
    end

    def buy_depravity(player, item, cost = nil)
      cost ||= item.cost
      unless Engine::Corruption.enabled?(player)
        return { ok: false, error: :corruption_disabled,
                 message: 'The potion sits inert. Corruption is closed to you — enable **Corruption** in `/options` first.' }
      end

      old = Engine::Corruption.level(player)
      if old >= Engine::Corruption::MAX
        return { ok: false, error: :fully_corrupted,
                 message: 'You are already **Fully Corrupted**. The potion could not make you worse if it tried.' }
      end

      player.spend_lp!(cost)
      new_level = [old + 25, Engine::Corruption::MAX].min
      player.set_tracker!(Engine::Corruption::KEY, new_level)
      Engine::Corruption.refresh!(player)
      stage_name = Engine::Corruption.stage(new_level)&.at(1) || 'Touched'
      { ok: true,
        message: "You down the potion. Heat settles under your skin and stays there — **corruption " \
                 "#{old} → #{new_level}** (#{stage_name})." }
    end

    def buy_size_potion(player, item, part, delta, cost = nil)
      cost ||= item.cost
      spec = Engine::ContentOptions::BODY_SIZES[part]
      label = spec[:label].downcase
      if spec[:requires] && !player.body_parts_list.map(&:to_s).include?(spec[:requires].to_s)
        return { ok: false, error: :no_part,
                 message: "The tonic fizzes uselessly — you have no #{label} for it to work on." }
      end

      old, new_size = Engine::ContentOptions.step_size(player, part, delta)
      if old == new_size
        edge = delta.positive? ? 'as large as tonics can make it' : 'as small as tonics can make it'
        return { ok: false, error: :at_limit, message: "Your #{label} is already #{edge}." }
      end

      player.spend_lp!(cost)
      sizes = player.body_sizes.is_a?(Hash) ? player.body_sizes.dup : {}
      player.update(body_sizes: sizes.merge(part => new_size))
      { ok: true,
        message: "You down the tonic. Your #{label}: **#{Engine::ContentOptions.size_label(part, old)} → " \
                 "#{Engine::ContentOptions.size_label(part, new_size)}**." }
    end

    def buy_gender_potion(player, item, target_gender, cost = nil)
      cost ||= item.cost
      same_gender = player.gender.to_s == target_gender
      # Already that gender on paper is only a refusal when the body agrees;
      # a delver wearing a borrowed shape can drink to make it truly theirs
      # (or to melt the borrowed shape off and be themselves again).
      if same_gender && gender_conditions(player).empty?
        return { ok: false, error: :already,
                 message: "You are already **#{target_gender.downcase}** — Berry slides the draught back. " \
                          '"That one would be a very expensive sip of nothing, sugar."' }
      end

      target = CharacterArchetypes::ALL.values.find { |a| a[:gender] == target_gender }
      player.spend_lp!(cost)
      cleared = clear_gender_conditions!(player)
      player.update(gender: target[:gender], body_parts: target[:body_parts])
      player.bump_tracker!('gender_bending_events')
      message =
        if same_gender
          "You down the draught. The borrowed shape melts off you — **#{target_gender.downcase}**, in your " \
            'own body again, and this time it stays.'
        else
          "You down the draught. Heat rewrites you from the inside out — you are **#{target_gender.downcase}** " \
            'now, body and all.'
        end
      if cleared.any?
        names = cleared.map { |n| "**#{n}**" }.join(', ')
        message += " The gender-changing #{names} #{cleared.size == 1 ? 'condition washes' : 'conditions wash'} away with it."
      end
      { ok: true, message: message }
    end

    # Conditions that rewrote the delver's sex (adding or removing parts).
    def gender_conditions(player)
      player.condition_list.select do |c|
        Array(c['parts']).any? || Array(c['remove_parts']).any?
      end
    end

    # ...do not survive a true gender change.
    def clear_gender_conditions!(player)
      gender_conditions, kept = player.condition_list.partition do |c|
        Array(c['parts']).any? || Array(c['remove_parts']).any?
      end
      player.update(conditions: kept) if gender_conditions.any?
      gender_conditions.map { |c| c['name'] }
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
          message: "Living gear can't be sold — use `e,remove #{equipment.name}` (costs LP)."
        }
      end

      sell_price = [(equipment.cost * 0.5).round, 1].max
      player.refund_lp!(sell_price)
      DB[:player_equipment].where(id: row[:id]).delete

      { ok: true, message: "You sold **#{equipment.name}** for **#{sell_price}** LP!" }
    end
  end
end
