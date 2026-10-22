# frozen_string_literal: true

module Commands
  module CursedShop
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0x5c1a4a

    # Living gear is catalogued like the normal shop: one aisle per gear
    # type, five pieces to a page, each with its own Take button.
    CATEGORIES = %w[weapon armor accessory].freeze
    CATEGORY_LABELS = {
      'weapon' => 'Weapons',
      'armor' => 'Armor',
      'accessory' => 'Accessories'
    }.freeze
    PAGE_SIZE = 5

    module_function

    def run(event, category: 'weapon', page: 0, notice: nil)
      player = ErosHelpers.require_player(event) or return
      show(event, player, category: category, page: page, notice: notice)
    end

    def show(event, player, category: 'weapon', page: 0, notice: nil)
      category = normalize_category(category)
      items = stock_for(player, category)
      pages = page_count(items)
      page = [[page.to_i, 0].max, pages - 1].min
      page_items = items.slice(page * PAGE_SIZE, PAGE_SIZE) || []
      label = CATEGORY_LABELS[category]
      unlocked_total = (player.cursed_shop_unlocks & stock_names).size

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: '## Cursed Shop — Covar Zephyren')
        c.text_display(
          content: '_**Covar Zephyren** minds the living gear: curved horns, a lashing tail, and a pair of ' \
                   'large breasts making a warm spectacle of his open shirt. He was one of the first delvers ' \
                   'here; the tower remade him, and he stayed — happily. "Living gear you have worn and torn ' \
                   'free remembers you," he says. "Call it back for free. Removing it again costs its usual ' \
                   'LP. Conversation\'s free too — I charge in stories."_'
        )
        if (regard = Engine::Regard.line(player, :cursed))
          c.text_display(content: regard)
        end
        if Engine::Residents.vex_restored?(player)
          c.text_display(
            content: '_Covar is wearing the Original today — Syn\'s first work, restored, seams singing in ' \
                     'a new key around horns and tail and that impossible chest, and he turns once for you ' \
                     'without being asked. "It needed a body that would show it off," he says. "It had one ' \
                     'for decades. Now it has a louder one." Prices, you note, are his own kind ones again._'
          )
        elsif Engine::Residents.vex_exiled?(player)
          c.text_display(
            content: '_Covar\'s smile does not reach his eyes. He threw Vex out of the back room the day ' \
                     'her dress went onto the mannequin, and the dress now stands salvaged under every ' \
                     'light he owns. "Tearing free costs **double** now," he says. "Call it grief. Help ' \
                     'me make the dress whole again and I\'ll forgive the arithmetic."_'
          )
          c.row do |row|
            row.button(label: '🪡 Restore the Dress', style: :danger,
                       custom_id: "eros:cshop:dress:#{event.user.id}")
          end
        end
        c.separator(divider: true, spacing: :small)
        c.text_display(
          content: "Your Lust Points: **#{player.lp}** · Unlocked **#{unlocked_total}/#{stock_names.size}** pieces"
        )
        c.separator(divider: true, spacing: :small)
        c.text_display(content: "**#{label}** — page **#{page + 1}/#{pages}**")

        if page_items.empty?
          c.text_display(content: '_Nothing stirs in this aisle._')
        else
          page_items.each do |item|
            ErosUI.attach_cursed_item_section(
              c, item,
              player: player, category: category, page: page, owner_id: event.user.id
            )
          end
        end

        if notice
          c.separator(divider: true, spacing: :small)
          c.text_display(content: notice)
        end

        c.row do |row|
          CATEGORIES.each do |cat|
            row.button(
              label: CATEGORY_LABELS[cat],
              style: cat == category ? :primary : :secondary,
              custom_id: "eros:cshop:cat:#{cat}:#{event.user.id}"
            )
          end
        end

        if pages > 1
          c.row do |row|
            if page.positive?
              row.button(label: '◀ Prev', style: :secondary,
                         custom_id: "eros:cshop:page:#{category}:#{page - 1}:#{event.user.id}")
            end
            row.button(label: "Pg #{page + 1}/#{pages}", style: :secondary,
                       custom_id: "eros:cshop:page:#{category}:#{page}:#{event.user.id}")
            if page < pages - 1
              row.button(label: 'Next ▶', style: :secondary,
                         custom_id: "eros:cshop:page:#{category}:#{page + 1}:#{event.user.id}")
            end
          end
        end

        c.row do |row|
          row.button(label: '🔮 Talk to Covar', style: :primary, custom_id: "eros:talk:covar:#{event.user.id}")
          row.button(label: '🛏️ Go to bed with Covar', style: :danger, custom_id: "eros:cshop:bed:#{event.user.id}")
          row.button(label: 'All Shops', style: :secondary, custom_id: "eros:shop:menu:#{event.user.id}")
          row.button(label: 'Equipment', style: :secondary, custom_id: "eros:cshop:equipment:#{event.user.id}")
        end

        c.separator(divider: false, spacing: :small)
        c.text_display(content: '-# Category tabs · each piece has its own Take button · Prev/Next')
      end
    end

    # Restore the Dress: Covar's restoration quest, run from his counter
    # while Vex is exiled. Steps claim here; the two counsels are earned
    # on boss victory screens.
    def dress_quest(event, notice: nil)
      player = ErosHelpers.require_player(event) or return

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: "## 🪡 Restore the Dress — #{player.display_name}")
        c.text_display(content: notice) if notice
        if Engine::Residents.vex_restored?(player)
          c.text_display(
            content: '_The Original hangs — no. It does not hang. It is being *worn*, at the counter, by ' \
                     'an incubus who turns in it like a weather system. The dress is whole, the shop is ' \
                     'forgiven, and Madame Vex keeps her own rooms again across the tower._'
          )
        elsif !Engine::Residents.vex_exiled?(player)
          c.text_display(content: '_There is no dress to restore. Vex is in the back room, the Original is on its rightful shoulders, and Covar is insufferable about it._')
        else
          step = Engine::Residents.restoration_step(player)
          c.text_display(
            content: "_Step **#{step + 1}/#{Engine::Residents::RESTORATION.size}** — " \
                     'the Original stands salvaged under Covar\'s lights, seams remembering a shape._'
          )
          spec = Engine::Residents.restoration_current(player)
          if spec
            done, target = Engine::Residents.restoration_progress(player)
            progress = spec[:finale] ? '' : " — **#{done}/#{target}**"
            c.text_display(content: "**#{spec[:name]}**#{progress}\n#{spec[:text]}")
            if spec[:finale]
              c.row do |row|
                row.button(label: '🪡 Begin the Fitting', style: :danger,
                           custom_id: "eros:dress:finale:#{event.user.id}")
              end
            else
              ready = Engine::Residents.restoration_complete?(player)
              c.row do |row|
                row.button(label: 'Claim', style: :primary,
                           custom_id: "eros:dress:claim:#{event.user.id}", disabled: !ready)
              end
            end
          end
        end
        c.row do |row|
          row.button(label: '◀ Cursed Shop', style: :secondary, custom_id: "eros:cshop:open:#{event.user.id}")
          row.button(label: '🔮 Talk to Covar', style: :primary, custom_id: "eros:talk:covar:#{event.user.id}")
        end
      end
    end

    # Covar's bedroom is its own page behind the counter, so the shopfront
    # stays a shopfront. The sex options live here, nowhere else.
    def bedroom(event, notice: nil)
      player = ErosHelpers.require_player(event) or return

      if Eros.encounter_for(player)
        ErosUI.reply_v2(event, ephemeral: true, with_actions: :combat) do |c|
          c.text_display(content: 'Covar is not taking anyone to bed mid-fight. Deal with the monster first.')
        end
        return
      end

      unlocked = Engine::Conversations.covar_sex_unlocked?(player)
      heard = Engine::Conversations.covar_topics_heard(player).size
      required = Engine::Conversations::COVAR_SEX_TOPICS_REQUIRED

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: "## 🛏️ Covar's Bed — #{player.display_name}")
        c.text_display(
          content: '_Behind a bead curtain at the back of the Cursed Shop, the counter\'s keeper keeps a ' \
                   'bed made up like he was expecting company — because he always is. The living gear hung ' \
                   'nearby settles, politely, into sleep._'
        )
        c.text_display(content: notice) if notice
        if (milestone = Engine::Conversations.covar_milestone_line(player))
          c.text_display(content: milestone)
        end

        if unlocked
          trysts = player.tracker('covar_trysts')
          c.text_display(
            content: "Your lust stands at **#{player.lust}**. Covar will drain it to **0** — no defiance " \
                     "cost, no charge.#{trysts.positive? ? " He has taken you to bed **#{trysts}** time#{trysts == 1 ? '' : 's'}." : ''}"
          )
          Engine::Conversations::COVAR_SEX.each do |part, spec|
            available = Engine::Conversations.covar_sex_available?(player, part)
            c.section do |section|
              section.text_display(content: "**#{spec[:label]}** — #{spec[:blurb]}")
              section.button(
                label: available ? spec[:button] : 'Needs a cock of your own',
                style: :danger,
                custom_id: "eros:covar:sex:#{part}:#{event.user.id}",
                disabled: !available
              )
            end
          end
          unless player.body_parts_list.map(&:to_s).include?('penis')
            c.text_display(content: '-# Fucking his breasts or his ass needs a cock of your own — his cock is for everyone.')
          end
        else
          c.text_display(
            content: "_Covar folds his arms and shakes his head, fond but firm. \"Get to know me first, " \
                     "delver. I like to be courted.\"_"
          )
          c.text_display(
            content: "-# Get to know Covar: **#{heard}/#{required}** conversations heard at **🔮 Talk to " \
                     'Covar**. Hear out five different topics and this bed is yours.'
          )
        end

        c.row do |row|
          row.button(label: '🔮 Talk to Covar', style: :primary, custom_id: "eros:talk:covar:#{event.user.id}")
          row.button(label: '◀ Cursed Shop', style: :secondary, custom_id: "eros:cshop:open:#{event.user.id}")
          row.button(label: 'All Shops', style: :secondary, custom_id: "eros:shop:menu:#{event.user.id}")
        end
      end
    end

    def covar_sex(event, part)
      player = ErosHelpers.require_player(event) or return
      result = Engine::Conversations.covar_sex(player, part)
      notice =
        if result[:ok]
          "#{result[:text]}\n\n**Lust drained: #{result[:lust_cleared]} → 0** — and your defiance never " \
            'wavered. Covar adjusts his shirt like that was a business transaction.'
        else
          result[:message]
        end
      bedroom(event, notice: notice)
    end

    def take(event, equipment_id, category: 'weapon', page: 0)
      player = ErosHelpers.require_player(event) or return
      if Eros.encounter_for(player)
        ErosUI.reply_v2(event, ephemeral: true) { |c| c.text_display(content: 'Not mid-combat.') }
        return
      end

      item = ::Equipment[equipment_id.to_i]
      message =
        if item.nil? || !item.cursed
          'That item is not in the Cursed Shop.'
        elsif !player.cursed_shop_unlocked?(item.name)
          "You haven't unlocked **#{item.name}** yet — wear it and tear it free first."
        elsif !Engine::Treasure.template_allowed?(player, Engine::Treasure.template_for(item.name))
          "**#{item.name}** is sealed — #{Engine::Treasure.template_block_reason(player, Engine::Treasure.template_for(item.name))}."
        else
          player.grant_equipment!(item)[:message]
        end
      show(event, player, category: category, page: page, notice: message)
    end

    # -- catalogue ------------------------------------------------------

    def normalize_category(category)
      key = category.to_s.downcase
      CATEGORIES.include?(key) ? key : 'weapon'
    end

    def all_items
      Engine::Treasure.sync_to_db!
      Engine::Treasure.all_mimic_templates.map { |t| ::Equipment.first(name: t[:name]) }.compact
    end

    def stock_names
      all_items.map(&:name)
    end

    def stock_for(player, category)
      all_items
        .select { |item| item.type.to_s == category }
        .sort_by { |item| [status_rank(player, item), -item.rarity.to_i, item.name.to_s] }
    end

    # Ready pieces first, then bound, sealed, and undiscovered — so the
    # top of every aisle is what the delver can actually use.
    def status_rank(player, item)
      return 1 if player.owns_equipment?(item.id)
      return 3 unless player.cursed_shop_unlocked?(item.name)
      return 2 unless Engine::Treasure.template_allowed?(player, Engine::Treasure.template_for(item.name))

      0
    end

    def page_count(items)
      [(items.size + PAGE_SIZE - 1) / PAGE_SIZE, 1].max
    end

    # -- handlers ---------------------------------------------------------

    button(custom_id: /^eros:cshop:open:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::CursedShop.run(event)
    end

    button(custom_id: /^eros:cshop:cat:(weapon|armor|accessory):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      category = event.custom_id[/\Aeros:cshop:cat:(weapon|armor|accessory):\d+\z/, 1]
      Commands::CursedShop.run(event, category: category, page: 0)
    end

    button(custom_id: /^eros:cshop:page:(weapon|armor|accessory):\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      match = event.custom_id.match(/\Aeros:cshop:page:(weapon|armor|accessory):(\d+):(\d+)\z/)
      Commands::CursedShop.run(event, category: match[1], page: match[2].to_i)
    end

    button(custom_id: /^eros:cshop:dress:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::CursedShop.dress_quest(event)
    end

    button(custom_id: /^eros:dress:claim:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      result = Engine::Residents.claim_restoration!(player)
      player.refresh
      Commands::CursedShop.dress_quest(event, notice: "#{result[:ok] ? '✅' : '❌'} #{result[:message]}")
    end

    button(custom_id: /^eros:dress:finale:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      result = Engine::Residents.finish_restoration!(player)
      player.refresh
      Commands::CursedShop.dress_quest(event, notice: "#{result[:ok] ? '' : '❌ '}#{result[:message]}")
    end

    button(custom_id: /^eros:cshop:bed:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::CursedShop.bedroom(event)
    end

    button(custom_id: /^eros:covar:sex:(breasts|cock|ass):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      part = event.custom_id[/\Aeros:covar:sex:(breasts|cock|ass):\d+\z/, 1]
      Commands::CursedShop.covar_sex(event, part)
    end

    button(custom_id: /^eros:cshop:take:\d+:(weapon|armor|accessory):\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      match = event.custom_id.match(/\Aeros:cshop:take:(\d+):(weapon|armor|accessory):(\d+):(\d+)\z/)
      Commands::CursedShop.take(event, match[1], category: match[2], page: match[3].to_i)
    end

    # Panels posted before the catalogue rework used a shorter Take id.
    button(custom_id: /^eros:cshop:take:\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::CursedShop.take(event, event.custom_id[/\Aeros:cshop:take:(\d+):\d+\z/, 1])
    end

    button(custom_id: /^eros:cshop:equipment:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Equipment.run(event)
    end

    application_command(:cursedshop) { |event| Commands::CursedShop.run(event) }

    command(:cursedshop, description: 'Re-summon living gear you have previously torn free (free)') do |event, category|
      Commands::CursedShop.run(event, category: category.to_s)
      nil
    end
  end
end
