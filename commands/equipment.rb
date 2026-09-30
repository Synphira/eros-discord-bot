# frozen_string_literal: true

module Commands
  module Equipment
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    module_function

    def run(event)
      player = ErosHelpers.require_player(event) or return

      ErosUI.reply_v2(event, colour: 0x6b5b95) do |c|
        c.text_display(content: '## Endless Ruins of Sin — Equipment')
        c.text_display(content: '_Gear and living (cursed) bindings._')
        c.separator(divider: true, spacing: :small)

        equipment_by_slot = {}
        player.equipment.each do |item|
          equipment_by_slot[item.slot] ||= []
          equipment_by_slot[item.slot] << item
        end

        %w[weapon head chest legs groin feet accessory].each do |slot|
          next if slot == 'groin' && equipment_by_slot['groin'].nil?

          equipped = equipment_by_slot[slot]&.find do |item|
            DB[:player_equipment]
              .where(player_id: player.discord_id, equipment_id: item.id, is_equipped: true)
              .count.positive?
          end

          label =
            if equipped
              tag = equipped.cursed ? ' _(cursed)_' : ''
              "#{equipped.name}#{tag}"
            else
              'None'
            end
          c.text_display(content: "**#{slot.capitalize}:** #{label}")
        end

        trophy = player.equipment_for_slot(Player::TROPHY_SLOT)
        spare = (equipment_by_slot[Player::TROPHY_SLOT] || []).reject { |t| trophy && t.id == trophy.id }
        spare_note = spare.empty? ? '' : " _(#{spare.size} more in your pack — `/equip` to swap)_"
        c.text_display(content: "**Trophy:** #{trophy ? trophy.name : 'None'}#{spare_note}")
        phylactery = trophy&.stat_modifiers&.dig('cheat_death')
        if phylactery
          state = player.phylactery_used ? 'spent this run' : 'ready'
          c.text_display(content: "_Lich's Phylactery: **#{state}**_")
        end

        c.separator(divider: true, spacing: :small)
        c.text_display(content: '**Inventory:**')

        if player.equipment.empty?
          c.text_display(content: '_Empty — seek chests or the shop._')
        else
          player.equipment.each_with_index do |item, index|
            equipped = DB[:player_equipment]
                       .where(player_id: player.discord_id, equipment_id: item.id, is_equipped: true)
                       .count.positive?
            bits = []
            bits << '[EQUIPPED]' if equipped
            bits << '[CURSED]' if item.cursed
            bits << "remove #{item.removal_cost} LP" if item.cursed
            status = bits.empty? ? '' : " #{bits.join(' · ')}"
            effects = item.stat_modifiers.empty? ? '' : "\n#{Engine::Treasure.format_stat_changes(item.stat_modifiers)}"
            c.text_display(content: "#{index + 1}. **#{item.name}**#{status}\n_#{item.description}_#{effects}")
          end
        end

        c.separator(divider: false, spacing: :small)
        c.text_display(
          content: '_`!equip` / `!unequip` for normal gear · `!remove [name]` to destroy cursed gear with LP · ' \
                   'one trophy at a time; trophies are lost on defeat._'
        )
      end
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
