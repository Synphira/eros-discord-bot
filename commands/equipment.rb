# frozen_string_literal: true

module Commands
  module Equipment
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0x6b5b95
    SLOTS = %w[weapon head chest legs groin feet accessory trophy].freeze

    module_function

    def run(event, view: :equipped, slot: nil, notice: nil)
      player = ErosHelpers.require_player(event) or return

      equipped_ids = player.equipped_items.map(&:id)
      by_slot = player.equipment.group_by(&:slot)

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: '## Endless Ruins of Sin — Equipment')
        c.row do |row|
          row.button(label: 'Equipped', style: view == :equipped ? :primary : :secondary,
                     custom_id: "eros:equip:view:equipped:#{event.user.id}")
          row.button(label: "Inventory (#{player.equipment.size})", style: view == :inventory ? :primary : :secondary,
                     custom_id: "eros:equip:view:inventory:#{event.user.id}")
          row.button(label: 'Outfits', style: view == :outfits ? :primary : :secondary,
                     custom_id: "eros:equip:outfits:#{event.user.id}")
        end
        c.text_display(content: notice) if notice
        c.separator(divider: true, spacing: :small)

        if view == :inventory
          render_inventory(c, player, by_slot, equipped_ids, slot, event.user.id)
        elsif view == :outfits
          render_outfits(c, player, event.user.id)
        else
          c.text_display(content: Engine::ThreatCalculator.appearance_line(player))
          c.separator(divider: true, spacing: :small)
          render_equipped(c, player, by_slot)
        end

        c.separator(divider: false, spacing: :small)
        c.text_display(
          content: '-# `e,equip` / `e,unequip` for normal gear · `e,remove [name]` to destroy cursed gear with LP · ' \
                   'one trophy at a time; trophies are lost on defeat.'
        )
      end
    end

    def render_outfits(container, player, owner_id)
      container.text_display(content: Engine::ThreatCalculator.appearance_line(player))
      container.text_display(
        content: '**Saved outfits** — save what you are wearing into a slot, then load it back whenever ' \
                 'you like. Loading swaps the covered slots to the saved pieces. If living gear is in the ' \
                 'way, loading tears it off and destroys it at its usual removal price — the cost is ' \
                 'listed on the slot before you commit. Your trophy is never part of an outfit.'
      )
      (1..Player::OUTFIT_SLOT_COUNT).each do |slot|
        items = player.saved_outfit(slot)
        cost = items ? player.outfit_swap_cost(slot) : 0
        lines = ["**Outfit #{slot}** — #{items ? items.map(&:name).join(', ') : '_empty_'}"]
        if items && cost.positive?
          names = player.outfit_swap_conflicts(slot).map { |i| i.name }.join(', ')
          lines << "⚠️ Loading tears off **#{names}** — **#{cost} LP** in cursed removal."
        end
        container.text_display(content: lines.join("\n"))
        container.row do |row|
          row.button(label: "Save into #{slot}", style: :primary,
                     custom_id: "eros:equip:outfit:save:#{slot}:#{owner_id}")
          row.button(label: cost.positive? ? "Load #{slot} (#{cost} LP removal)"[0, 80] : "Load #{slot}",
                     style: :success,
                     custom_id: "eros:equip:outfit:load:#{slot}:#{owner_id}",
                     disabled: items.nil?)
        end
      end
    end

    def render_equipped(container, player, by_slot)
      lines = (SLOTS - [Player::TROPHY_SLOT]).filter_map do |slot|
        next if slot == 'groin' && by_slot['groin'].nil?

        item = player.equipment_for_slot(slot)
        label = item ? "#{item.name}#{item.cursed ? ' _(cursed)_' : ''}" : 'None'
        "**#{slot.capitalize}:** #{label}"
      end

      trophy = player.equipment_for_slot(Player::TROPHY_SLOT)
      spare = (by_slot[Player::TROPHY_SLOT] || []).reject { |t| trophy && t.id == trophy.id }
      spare_note = spare.empty? ? '' : " _(#{spare.size} more in your pack — `/equip` to swap)_"
      lines << "**Trophy:** #{trophy ? trophy.name : 'None'}#{spare_note}"
      if trophy&.stat_modifiers&.dig('cheat_death')
        left = player.phylactery_charges_left
        max = player.phylactery_max_uses
        status =
          if left <= 0
            "spent this run (#{max}/#{max})"
          elsif left == max
            "ready (#{left}/#{max})"
          else
            "#{left}/#{max} left"
          end
        lines << "_Lich's Phylactery: **#{status}**_"
      end
      container.text_display(content: lines.join("\n"))

      sets = Engine::Wardrobe.active_sets(player)
      return if sets.empty?

      container.text_display(
        content: (["**Something about the whole outfit…**"] +
                  sets.map { |key, spec| Engine::Wardrobe.describe_set(key, spec) }).join("\n")
      )
    end

    def render_inventory(container, player, by_slot, equipped_ids, slot, owner_id)
      if player.equipment.empty?
        container.text_display(content: '_Your pack is empty — seek chests or the shop._')
        return
      end

      slots = SLOTS | by_slot.keys
      slot = slot.to_s
      slot = slots.find { |s| by_slot[s]&.any? } unless slots.include?(slot)
      items = by_slot[slot] || []

      container.row do |row|
        row.string_select(custom_id: "eros:equip:slot:#{owner_id}", placeholder: 'Choose a slot…',
                          min_values: 1, max_values: 1) do |menu|
          slots.each do |s|
            count = (by_slot[s] || []).size
            menu.option(label: "#{s.capitalize} (#{count})", value: s, default: s == slot)
          end
        end
      end

      if items.empty?
        container.text_display(content: "_Nothing in your **#{slot}** slot yet._")
        return
      end

      lines = items.map do |item|
        bits = []
        bits << '[EQUIPPED]' if equipped_ids.include?(item.id)
        bits << '[CURSED]' if item.cursed
        bits << "remove #{player.cursed_removal_cost(item)} LP" if item.cursed
        status = bits.empty? ? '' : " #{bits.join(' · ')}"
        effects = item.stat_modifiers.empty? ? '' : "\n#{Engine::Treasure.format_stat_changes(item.stat_modifiers)}"
        "**#{item.name}**#{status}\n_#{item.description}_#{effects}"
      end
      container.text_display(content: "### #{slot.capitalize}\n#{lines.join("\n\n")}"[0, 3500])
    end

    button(custom_id: /^eros:equip:view:(equipped|inventory):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      view = event.custom_id[/\Aeros:equip:view:(\w+):\d+\z/, 1].to_sym
      Commands::Equipment.run(event, view: view)
    end

    button(custom_id: /^eros:equip:outfits:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Equipment.run(event, view: :outfits)
    end

    button(custom_id: /^eros:equip:outfit:(save|load):[123]:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      action, slot = event.custom_id.match(/\Aeros:equip:outfit:(save|load):([123]):\d+\z/).captures
      result = action == 'save' ? player.save_outfit!(slot.to_i) : player.load_outfit!(slot.to_i)
      player.refresh
      notice = "#{result[:ok] ? '✅' : '❌'} #{result[:message]}"
      Commands::Equipment.run(event, view: :outfits, notice: notice)
    end

    string_select(custom_id: /^eros:equip:slot:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Equipment.run(event, view: :inventory, slot: Array(event.values).first)
    end

    def equip(event, item_name)
      player = ErosHelpers.require_player(event) or return
      return missing_name(event, 'equip') if item_name.nil? || item_name.strip.empty?

      player_items = find_owned(player, item_name)
      if player_items.empty?
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: "You don't own any item matching '#{item_name}'.")
        end
        return
      end

      result = player.equip_item(player_items.first[:id])
      colour = result[:ok] ? 0x4a7c59 : 0x8b1a1a
      ErosUI.reply_v2(event, colour: colour) do |c|
        c.text_display(content: result[:message])
      end
    end

    def unequip(event, item_name)
      player = ErosHelpers.require_player(event) or return
      return missing_name(event, 'unequip') if item_name.nil? || item_name.strip.empty?

      player_items = find_owned(player, item_name, equipped_only: true)
      if player_items.empty?
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: "You don't have any equipped item matching '#{item_name}'.")
        end
        return
      end

      result = player.unequip_item(player_items.first[:id])
      colour = result[:ok] ? 0x4a7c59 : 0x8b1a1a
      ErosUI.reply_v2(event, colour: colour) do |c|
        c.text_display(content: result[:message])
      end
    end

    def remove_cursed(event, item_name)
      player = ErosHelpers.require_player(event) or return
      if item_name.nil? || item_name.strip.empty?
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'Specify which cursed item to remove. Use `e,equipment` to list gear.')
        end
        return
      end

      player_items = find_owned(player, item_name).select { |row| row[:cursed] }
      if player_items.empty?
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: "You're not wearing any cursed item matching '#{item_name}'.")
        end
        return
      end

      result = player.remove_cursed_equipment!(player_items.first[:id])
      colour = result[:ok] ? 0x4a7c59 : 0x8b1a1a
      ErosUI.reply_v2(event, colour: colour) do |c|
        c.text_display(content: result[:message])
      end
    end

    def find_owned(player, item_name, equipped_only: false)
      ds = DB[:player_equipment]
           .join(:equipment, id: :equipment_id)
           .where(player_id: player.discord_id)
           .where(Sequel.ilike(Sequel[:equipment][:name], "%#{item_name}%"))
           .select(
             Sequel[:equipment][:id],
             Sequel[:equipment][:name],
             Sequel[:equipment][:cursed],
             Sequel[:player_equipment][:is_equipped]
           )
      ds = ds.where(is_equipped: true) if equipped_only
      ds.all
    end

    def missing_name(event, verb)
      ErosUI.reply_v2(event, ephemeral: true) do |c|
        c.text_display(content: "Usage: `e,#{verb} [item name]`")
      end
    end

    application_command(:equipment) { |event| Commands::Equipment.run(event) }
    application_command(:equip) { |event| Commands::Equipment.equip(event, event.options['item']) }
    application_command(:unequip) { |event| Commands::Equipment.unequip(event, event.options['item']) }
    application_command(:remove) { |event| Commands::Equipment.remove_cursed(event, event.options['item']) }

    command(:equipment, description: 'View your equipment') do |event|
      Commands::Equipment.run(event)
      nil
    end

    command(:equip, description: 'Equip an item') do |event, *parts|
      Commands::Equipment.equip(event, parts.join(' '))
      nil
    end

    command(:unequip, description: 'Unequip an item') do |event, *parts|
      Commands::Equipment.unequip(event, parts.join(' '))
      nil
    end

    command(:remove, description: 'Destroy cursed mimic gear for LP') do |event, *parts|
      Commands::Equipment.remove_cursed(event, parts.join(' '))
      nil
    end
  end
end
