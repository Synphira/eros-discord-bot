# frozen_string_literal: true

module Commands
  module Parlour
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0x9b2d6f

    INTRO = "## Syn & Berry's\n" \
            "_One half of the shop glows with clean steel and bottled light, where **Berry** — a strawberry-bright " \
            "fairy with a smile like sunrise and a grip like ownership — is already writing your name in her ledger. " \
            "The other half is velvet, ink and candle smoke, where her wife **Syn** lounges over the parlour bench: " \
            "a heavy-lidded fairy with a waist-length cascade of platinum-blonde hair and sleepless shadows " \
            "under her eyes, wearing next to nothing but a few scraps of black lace — because her own skin is " \
            "the catalogue. Every tattoo and piercing she sells is displayed on her own inked, pierced body, " \
            "from the sigil low on her belly to the gold rings through her nipples. \"Something permanent, " \
            "darling?\" Syn purrs, not looking up. \"My work never fades. Not " \
            "after defeat, not after a new cycle, not ever.\" Berry's wings flick. \"And if you're here for " \
            "errands, pet, my quest board is its own page now — `/quests`. She's mine — the marks are yours.\"_"

    module_function

    def show(event, notice: nil)
      player = ErosHelpers.require_player(event) or return

      if Eros.encounter_for(player)
        ErosUI.reply_v2(event, ephemeral: true, with_actions: :combat) do |c|
          c.text_display(content: 'Syn will not ink a delver mid-fight. Deal with the monster first — Berry is taking bets.')
        end
        return
      end

      owned = Engine::Marks.owned(player)
      offers = Engine::Marks.available(player)
      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: INTRO)
        c.text_display(content: notice) if notice
        if (regard = Engine::Regard.line(player, :parlour))
          c.text_display(content: regard)
        end
        lines = owned.map { |k| "◆ #{Engine::Marks.label(k)} — _#{Engine::Marks::MARKS[k][:perk]}_" }
        c.text_display(
          content: "**Your marks** #{owned.size}/#{Engine::Marks.max_marks(player)} · **LP** #{player.lp}\n" \
                   "#{lines.empty? ? '_Your skin is still bare. Syn is already sketching on it in her head._' : lines.join("\n")}"
        )
        c.separator(divider: true, spacing: :small)

        if offers.any? && owned.size < Engine::Marks.max_marks(player)
          c.row do |row|
            row.string_select(custom_id: "eros:parlour:buy:#{event.user.id}", placeholder: "Choose a design from Syn…",
                              min_values: 1, max_values: 1) do |menu|
              offers.first(25).each do |key, m|
                kind = m[:kind] == :tattoo ? 'Tattoo' : 'Piercing'
                menu.option(label: "#{m[:name]} — #{m[:cost]} LP"[0, 100], value: key,
                            description: "#{kind}, #{m[:place]} · #{m[:perk]}"[0, 100])
              end
            end
          end
        elsif owned.size >= Engine::Marks.max_marks(player)
          c.text_display(content: '-# You have no room for more marks. Remove one to make space.')
        else
          c.text_display(content: '-# Syn has nothing new for you right now. More designs unlock with themes in `/options`.')
        end

        if owned.any?
          c.row do |row|
            row.string_select(custom_id: "eros:parlour:remove:#{event.user.id}", placeholder: 'Remove a mark (free)…',
                              min_values: 1, max_values: 1) do |menu|
              owned.each do |key|
                menu.option(label: Engine::Marks::MARKS[key][:name], value: key)
              end
            end
          end
        end

        attach_story(c, player, event.user.id)

        c.row do |row|
          row.button(label: '🍓 Talk to Berry', style: :secondary, custom_id: "eros:talk:berry:#{event.user.id}")
          row.button(label: '🖤 Talk to Syn', style: :primary, custom_id: "eros:talk:syn:#{event.user.id}")
          row.button(label: 'All Shops', style: :secondary, custom_id: "eros:shop:menu:#{event.user.id}")
        end
      end
    end

    # Syn's secret only exists here, at her bench: hidden until a delver
    # wears five of her marks, gone again once the wedding is done.
    def attach_story(container, player, owner_id)
      if Engine::Quests.story_offered?(player)
        container.separator(divider: true, spacing: :small)
        container.text_display(
          content: "### 🖤 Syn Has a Secret\n" \
                   "_Syn has been watching you over her ledger for a while — five of her marks will do that " \
                   "to a fairy. She crooks one ink-stained finger at you. \"Closer, darling. This one's not " \
                   "for the board, and it's certainly not for my wife's ears. Yet.\"_"
        )
        container.row do |row|
          row.button(label: "Hear Syn's secret", style: :danger, custom_id: "eros:parlour:story_accept:#{owner_id}")
        end
      elsif (spec = Engine::Quests.story_current(player))
        done, target = Engine::Quests.story_progress(player)
        container.separator(divider: true, spacing: :small)
        container.text_display(
          content: "### 🖤 Syn's Secret — #{spec[:name]} (#{done}/#{target})\n_#{spec[:text]}_\n" \
                   "-# Reward **#{spec[:reward]} LP** · Step #{Engine::Quests.story_step(player) + 1}/#{Engine::Quests::STORY.size} · Berry suspects nothing"
        )
        if Engine::Quests.story_complete?(player)
          container.row do |row|
            row.button(label: "Report to Syn: #{spec[:name]} (#{spec[:reward]} LP)", style: :success,
                       custom_id: "eros:parlour:story_claim:#{owner_id}")
          end
        end
      end
    end

    def handle(event, action, key)
      player = ErosHelpers.require_player(event) or return
      if Eros.encounter_for(player)
        show(event)
        return
      end

      result = action == 'buy' ? Engine::Marks.buy!(player, key) : Engine::Marks.remove!(player, key)
      news = result[:ok] ? player.check_progress! : []
      show(event, notice: ([result[:message]] + news).join("\n"))
    end

    string_select(custom_id: /^eros:parlour:(buy|remove):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      action = event.custom_id[/\Aeros:parlour:(buy|remove):\d+\z/, 1]
      Commands::Parlour.handle(event, action, Array(event.values).first.to_s)
    end

    button(custom_id: /^eros:parlour:story_accept:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      result = Engine::Quests.accept_story!(player)
      Commands::Parlour.show(event, notice: result[:message])
    end

    button(custom_id: /^eros:parlour:story_claim:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      result = Engine::Quests.claim_story!(player)
      lines = [result[:message]] + Array(result[:news])
      Commands::Parlour.show(event, notice: lines.join("\n"))
    end

    button(custom_id: /^eros:parlour:view:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Parlour.show(event)
    end

    application_command(:parlour) { |event| Commands::Parlour.show(event) }

    command(:parlour, description: "Visit Syn's parlour bench at Syn & Berry's: tattoos and piercings") do |event|
      Commands::Parlour.show(event)
      nil
    end
  end
end
