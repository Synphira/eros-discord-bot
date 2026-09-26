# frozen_string_literal: true

module Commands
  module Shop
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0x6b5b95

    module_function

    def run(event, category: 'weapon', page: 0, notice: nil)
      player = ErosHelpers.require_player(event) or return
      show(event, player, category: category, page: page, notice: notice)
    end

    def show(event, player, category: 'weapon', page: 0, notice: nil)
      category = Engine::Shop.normalize_category(category)
      pages = Engine::Shop.page_count(category)
      page = [[page.to_i, 0].max, pages - 1].min
      items = Engine::Shop.page_items(category, page)
      label = Engine::Shop::CATEGORY_LABELS[category]

      ErosUI.reply_v2(
        event,
        colour: COLOUR,
        with_actions: {
          shop: {
            category: category,
            page: page,
            pages: pages,
            items: items.map { |i| { id: i.id, name: i.name, cost: i.cost } }
          }
        }
      ) do |c|
        c.text_display(content: '## Endless Ruins of Sin — Shop')
        c.text_display(content: '_Clean steel and soft lies — no living gear sold here._')
        c.separator(divider: true, spacing: :small)
        c.text_display(content: "Your Lust Points: **#{player.lp}**")
        c.separator(divider: true, spacing: :small)
        c.text_display(content: "**#{label}** — page **#{page + 1}/#{pages}**")

        if items.empty?
          c.text_display(content: '_Nothing in this aisle._')
        else
          items.each do |item|
            owned = player.owns_equipment?(item.id) && item.type != 'special'
            tag = owned ? ' _(owned)_' : ''
            mods = Engine::Treasure.format_stat_changes(item.stat_modifiers)
            c.text_display(
              content: "• **#{item.name}**#{tag} — _#{item.description}_\n" \
                       "  #{mods} · **#{item.cost}** LP"
            )
          end
        end

        if notice
          c.separator(divider: true, spacing: :small)
          c.text_display(content: notice)
        end

        c.separator(divider: false, spacing: :small)
        c.text_display(content: '-# Category tabs · Buy buttons · Prev/Next · or `!buy` / `!sell` by name')
      end
    end

    def buy(event, item_name)
      player = ErosHelpers.require_player(event) or return
      return missing_name(event, 'buy') if item_name.nil? || item_name.to_s.strip.empty?

      item = ::Equipment
             .where(Sequel.ilike(:name, "%#{item_name}%"), cursed: false)
             .all
             .find { |e| Engine::Shop.shop_item?(e) }

      unless item
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: "Item '#{item_name}' is not sold in the shop.")
        end
        return
      end

      result = Engine::Shop.buy_item(player, item.id)
      colour = result[:ok] ? 0x4a7c59 : 0x8b1a1a
      ErosUI.reply_v2(event, colour: colour) do |c|
        c.text_display(content: result[:message])
      end
    end

    def buy_by_id(event, player, item_id, category:, page:)
      result = Engine::Shop.buy_item(player, item_id)
      notice = result[:ok] ? "✅ #{result[:message]}" : "❌ #{result[:message]}"
      player.refresh
      show(event, player, category: category, page: page, notice: notice)
    end

    def sell(event, item_name)
      player = ErosHelpers.require_player(event) or return
      return missing_name(event, 'sell') if item_name.nil? || item_name.to_s.strip.empty?

      row = DB[:player_equipment]
            .join(:equipment, id: :equipment_id)
            .where(player_id: player.discord_id)
            .where(Sequel.ilike(Sequel[:equipment][:name], "%#{item_name}%"))
            .select(
              Sequel[:equipment][:id].as(:equipment_id),
              Sequel[:equipment][:name],
              Sequel[:equipment][:cursed]
            )
            .first

      unless row
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: "You don't own any item matching '#{item_name}'.")
        end
        return
      end

      result = Engine::Shop.sell_item(player, row[:equipment_id])
      colour = result[:ok] ? 0x4a7c59 : 0x8b1a1a
      ErosUI.reply_v2(event, colour: colour) do |c|
        c.text_display(content: result[:message])
      end
    end

    def missing_name(event, verb)
      ErosUI.reply_v2(event, ephemeral: true) do |c|
        c.text_display(content: "Usage: `!#{verb} [item name]`")
      end
    end

    application_command(:shop) { |event| Commands::Shop.run(event) }
    application_command(:buy) { |event| Commands::Shop.buy(event, event.options['item']) }
    application_command(:sell) { |event| Commands::Shop.sell(event, event.options['item']) }

    command(:shop, description: 'Browse the shop by category') do |event, category|
      if category && !category.empty?
        Commands::Shop.run(event, category: category)
      else
        Commands::Shop.run(event)
      end
      nil
    end

    command(:buy, description: 'Buy an item from the shop') do |event, *parts|
      Commands::Shop.buy(event, parts.join(' '))
      nil
    end

    command(:sell, description: 'Sell an item to the shop') do |event, *parts|
      Commands::Shop.sell(event, parts.join(' '))
      nil
    end
  end
end
