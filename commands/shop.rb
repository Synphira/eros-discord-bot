# frozen_string_literal: true

module Commands
  module Shop
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0x6b5b95

    module_function

    def run(event, category: nil, page: 0, notice: nil)
      return menu(event, notice: notice) if category.nil?

      player = ErosHelpers.require_player(event) or return
      show(event, player, category: category, page: page, notice: notice)
    end

    # The storefront menu: each shop is a section with its own Visit
    # button, so new shops join this list instead of Berry's shelves.
    def menu(event, notice: nil)
      player = ErosHelpers.require_player(event) or return
      unlocked = (player.cursed_shop_unlocks & Commands::CursedShop.stock_names).size
      total = Commands::CursedShop.stock_names.size

      shops = [
        ["Berry's Gear",
         'Weapons, armour, and accessories in clean steel and soft lies — Berry\'s own counter. ' \
         'No living gear; she has standards.',
         "eros:shop:cat:weapon:#{event.user.id}"],
        ["Berry's Potions",
         'Draughts and elixirs, growth and shrinking tonics, and the Becoming draughts. ' \
         'Everything is drunk on the spot — no takeaway.',
         "eros:shop:cat:special:#{event.user.id}"],
        ['Cursed Gear — Covar',
         "Living gear that remembers being worn. Call back what you have torn free " \
         "(**#{unlocked}/#{total}** pieces unlocked), or talk to the keeper.",
         "eros:cshop:open:#{event.user.id}"],
        ["Berry's Quests",
         'Errands from the quest board. Berry pays in Lust Points and opinions.',
         "eros:quests:view:#{event.user.id}"],
        ["Syn's Parlour",
         'Syn\'s bench behind the curtain: ink, marks, and designs that unlock with your themes.',
         "eros:parlour:view:#{event.user.id}"],
        ['The Residents',
         'The tower\'s settled souls and their trades: Madame Vex, who listens to living gear; Pip, who ' \
         'worships the traps; Sister Nectar of the milking shrine; and the Pale Cartographer, who reads ' \
         'the dreaming land.',
         "eros:residents:view:#{event.user.id}"]
      ]

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: '## The Shops')
        c.text_display(
          content: '_A strawberry-bright fairy zips overhead on iridescent wings, seed-freckles on her cheeks ' \
                   'and a ledger under one arm. "Welcome in, sugar!" **Berry** chirps. "Pick a counter — ' \
                   'mine are the tidy ones."_'
        )
        c.text_display(content: notice) if notice
        c.text_display(content: "Your Lust Points: **#{player.lp}**")
        shops.each do |name, blurb, custom_id|
          c.section do |section|
            section.text_display(content: "**#{name}**\n#{blurb}")
            section.button(label: 'Visit', style: :primary, custom_id: custom_id)
          end
        end
        c.text_display(content: '-# Or `e,buy` / `e,sell` by name from anywhere.')
      end
    end

    def show(event, player, category: 'weapon', page: 0, notice: nil)
      category = Engine::Shop.normalize_category(category)
      pages = Engine::Shop.page_count(category)
      page = [[page.to_i, 0].max, pages - 1].min
      items = Engine::Shop.page_items(category, page)
      label = Engine::Shop::CATEGORY_LABELS[category]
      potions = category == 'special'

      ErosUI.reply_v2(
        event,
        colour: COLOUR,
        with_actions: {
          shop: {
            category: category,
            page: page,
            pages: pages
          }
        }
      ) do |c|
        c.text_display(content: potions ? "## Berry's Potions" : "## Berry's Gear")
        c.text_display(
          content: if potions
                     '_Berry wipes a row of bright bottles. "Potions are drunk on the spot, sugar — no ' \
                       'takeaway. The body tonics do one size at a time, and those Becoming draughts? Pick ' \
                       'the shape you want to keep, darling — those changes are for good."_'
                   else
                     '_Berry pats the counter. "Clean steel and soft lies, sugar — no living gear at my ' \
                       'counter. That wriggling nonsense is Covar\'s department, through the Shops menu."_'
                   end
        )
        if (regard = Engine::Regard.line(player, :shop))
          c.text_display(content: regard)
        end
        c.separator(divider: true, spacing: :small)
        aisle = "**#{label}** — page **#{page + 1}/#{pages}** · Your Lust Points: **#{player.lp}**"
        if potions && (theme = Engine::Shop::POTION_PAGE_LABELS[page])
          aisle = "**#{label} · #{theme}** — page **#{page + 1}/#{pages}** · Your Lust Points: **#{player.lp}**"
        end
        c.text_display(content: aisle)

        if items.empty?
          c.text_display(content: '_Nothing in this aisle._')
        else
          items.each do |item|
            ErosUI.attach_shop_item_section(
              c, item,
              player: player, category: category, page: page, owner_id: event.user.id
            )
          end
        end

        if notice
          c.separator(divider: true, spacing: :small)
          c.text_display(content: notice)
        end

        c.separator(divider: false, spacing: :small)
        c.text_display(
          content: potions ? '-# Shelf tabs · each potion is drunk where you stand · All Shops to switch counter'
                           : '-# Category tabs · each item has its own Buy button · Prev/Next · All Shops to switch counter'
        )
      end
    end

    def buy(event, item_name)
      player = ErosHelpers.require_player(event) or return
      return missing_name(event, 'buy') if item_name.nil? || item_name.to_s.strip.empty?

      matches = ::Equipment
                .where(cursed: false)
                .where(Sequel.ilike(:name, "%#{item_name}%"))
                .all
                .select { |e| Engine::Shop.shop_item?(e) }
      item = matches.find { |e| e.name.casecmp?(item_name.to_s.strip) } || matches.first

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
        c.text_display(content: "Usage: `e,#{verb} [item name]`")
      end
    end

    application_command(:shop) do |event|
      category = event.options['category']
      category ? Commands::Shop.run(event, category: category) : Commands::Shop.run(event)
    end
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
