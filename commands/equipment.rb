module Commands
  module Equipment
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    module_function

    def run(event)
      player = ErosHelpers.require_player(event) or return

      ErosUI.reply_v2(event, colour: 0x6b5b95) do |c|
        c.text_display(content: '## Endless Ruins of Sin Equipment')
        c.text_display(content: '_Your acquired equipment and gear._')
        c.separator(divider: true, spacing: :small)
        
        # Group equipment by slot
        equipment_by_slot = {}
        player.equipment.each do |item|
          slot = item.slot
          equipment_by_slot[slot] ||= []
          equipment_by_slot[slot] << item
        end
        
        # Display each slot with equipped item
        %w[weapon head chest legs feet accessory].each do |slot|
          equipped = equipment_by_slot[slot]&.find { |item| 
            DB[:player_equipment].where(player_id: player.discord_id, equipment_id: item.id, is_equipped: true).count > 0
          }
          
          c.text_display(content: "**#{slot.capitalize}:** #{equipped ? equipped.name : 'None'}")
        end
        
        c.separator(divider: true, spacing: :small)
        c.text_display(content: '**Inventory:**')
        
        # List all equipment
        player.equipment.each_with_index do |item, index|
          equipped = DB[:player_equipment].where(player_id: player.discord_id, equipment_id: item.id, is_equipped: true).count > 0
          status = equipped ? '[EQUIPPED]' : ''
          c.text_display(content: "#{index + 1}. #{item.name} #{status}")
        end
        
        c.text_display(content: "\n_Use `!equip [item name]` or `!unequip [item name]` to manage gear._")
      end
    end

    def equip(event, item_name)
      player = ErosHelpers.require_player(event) or return

      # Find player's item by name
      player_items = DB[:player_equipment].join(:equipment, id: :equipment_id)
                               .where(player_id: player.discord_id)
                               .where(Sequel.ilike(Sequel[:equipment][:name], "%#{item_name}%"))
                               .select_all(:equipment)
                               .all

      if player_items.empty?
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: "You don't own any item named '#{item_name}'.")
        end
        return
      end

      # If multiple items match, just equip the first one
      item_to_equip = player_items.first
      result = player.equip_item(item_to_equip[:id])
      colour = result[:ok] ? 0x4a7c59 : 0x8b1a1a

      ErosUI.reply_v2(event, colour: colour) do |c|
        c.text_display(content: result[:message])
      end
    end

    def unequip(event, item_name)
      player = ErosHelpers.require_player(event) or return

      # Find player's equipped item by name
      player_items = DB[:player_equipment].join(:equipment, id: :equipment_id)
                               .where(player_id: player.discord_id, is_equipped: true)
                               .where(Sequel.ilike(Sequel[:equipment][:name], "%#{item_name}%"))
                               .select_all(:equipment)
                               .all

      if player_items.empty?
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: "You don't have any equipped item named '#{item_name}'.")
        end
        return
      end

      # If multiple items match, just unequip the first one
      item_to_unequip = player_items.first
      result = player.unequip_item(item_to_unequip[:id])
      colour = result[:ok] ? 0x4a7c59 : 0x8b1a1a

      ErosUI.reply_v2(event, colour: colour) do |c|
        c.text_display(content: result[:message])
      end
    end

    application_command(:equipment) { |event| Commands::Equipment.run(event) }
    application_command(:equip) { |event| Commands::Equipment.equip(event, event.options['item']) }
    application_command(:unequip) { |event| Commands::Equipment.unequip(event, event.options['item']) }

    command(:equipment, description: 'View your equipment') do |event|
      Commands::Equipment.run(event)
      nil
    end

    command(:equip, description: 'Equip an item') do |event, item_name|
      Commands::Equipment.equip(event, item_name)
      nil
    end

    command(:unequip, description: 'Unequip an item') do |event, item_name|
      Commands::Equipment.unequip(event, item_name)
      nil
    end
  end
end