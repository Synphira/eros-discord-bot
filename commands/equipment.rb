# frozen_string_literal: true

module Commands
  module Equipment
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0x6b5b95
    SLOTS = %w[weapon head chest legs groin feet accessory trophy].freeze

    module_function

    def run(event, view: :equipped, slot: nil)
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
        end
        c.separator(divider: true, spacing: :small)

        if view == :inventory
          render_inventory(c, player, by_slot, equipped_ids, slot, event.user.id)
        else
          render_equipped(c, player, by_slot)
        end

        c.separator(divider: false, spacing: :small)
        c.text_display(
          content: '-# `!equip` / `!unequip` for normal gear · `!remove [name]` to destroy cursed gear with LP · ' \
                   'one trophy at a time; trophies are lost on defeat.'
        )
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
        lines << "_Lich's Phylactery: **#{player.phylactery_used ? 'spent this run' : 'ready'}**_"
      end
      container.text_display(content: lines.join("\n"))
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
        bits << "remove #{item.removal_cost} LP" if item.cursed
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
          c.text_display(content: 'Specify which cursed item to remove. Use `!equipment` to list gear.')
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
        c.text_display(content: "Usage: `!#{verb} [item name]`")
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
