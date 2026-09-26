module Commands
  module Shop
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    module_function

    def run(event)
      player = ErosHelpers.require_player(event) or return

      ErosUI.reply_v2(event, colour: 0x6b5b95) do |c|
        c.text_display(content: '## Endless Ruins of Sin Shop')
        c.text_display(content: '_Welcome to the lone shop in the depths. Spend your Lust Points wisely._')
        c.separator(divider: true, spacing: :small)
        c.text_display(content: 'Your Lust Points: **' + player.lp.to_s + '**')
        c.separator(divider: true, spacing: :small)
        
        # Display shop items by category
        c.text_display(content: '**Weapons:**')
        ::Equipment.where(type: 'weapon').order(Sequel.desc(:cost)).each do |item|
          c.text_display(content: "• **#{item.name}** - #{item.description} (Cost: #{item.cost} LP)")
        end
        
        c.text_display(content: '**Armor:**')
        ::Equipment.where(type: 'armor').order(Sequel.desc(:cost)).each do |item|
          c.text_display(content: "• **#{item.name}** - #{item.description} (Cost: #{item.cost} LP)")
        end
        
        c.text_display(content: '**Accessories:**')
        ::Equipment.where(type: 'accessory').order(Sequel.desc(:cost)).each do |item|
          c.text_display(content: "• **#{item.name}** - #{item.description} (Cost: #{item.cost} LP)")
        end
        
        c.text_display(content: '**Special Items:**')
        ::Equipment.where(type: 'special').order(Sequel.desc(:cost)).each do |item|
          c.text_display(content: "• **#{item.name}** - #{item.description} (Cost: #{item.cost} LP)")
        end
        
        c.text_display(content: "\n_Use `!buy [item name]` or `!sell [item name]` to transact._")
      end
    end

    def buy(event, item_name)
      player = ErosHelpers.require_player(event) or return

      item = ::Equipment.where(Sequel.ilike(:name, "%#{item_name}%")).first
      unless item
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: "Item '#{item_name}' not found in the shop.")
        end
        return
      end

      result = Engine::Shop.buy_item(player, item.id)
      colour = result[:ok] ? 0x4a7c59 : 0x8b1a1a

      ErosUI.reply_v2(event, colour: colour) do |c|
        c.text_display(content: result[:message])
      end
    end

    def sell(event, item_name)
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

      # If multiple items match, just sell the first one
      item_to_sell = player_items.first
      result = Engine::Shop.sell_item(player, item_to_sell[:id])
      colour = result[:ok] ? 0x4a7c59 : 0x8b1a1a

      ErosUI.reply_v2(event, colour: colour) do |c|
        c.text_display(content: result[:message])
      end
    end

    application_command(:shop) { |event| Commands::Shop.run(event) }
    application_command(:buy) { |event| Commands::Shop.buy(event, event.options['item']) }
    application_command(:sell) { |event| Commands::Shop.sell(event, event.options['item']) }

    command(:shop, description: 'View the shop inventory') do |event|
      Commands::Shop.run(event)
      nil
    end

    command(:buy, description: 'Buy an item from the shop') do |event, item_name|
      Commands::Shop.buy(event, item_name)
      nil
    end

    command(:sell, description: 'Sell an item to the shop') do |event, item_name|
      Commands::Shop.sell(event, item_name)
      nil
    end
  end
end