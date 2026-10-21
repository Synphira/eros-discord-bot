# frozen_string_literal: true

module Commands
  module Curses
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0x9b2d6f
    PAGE_SIZE = 5

    module_function

    # [entries on this page, total pages, clamped page]. Entries keep
    # their global index so the numbering always matches the numbers
    # accepted by `e,removecurse N` / `e,suppresscurse N`.
    def page_entries(player, page)
      all = player.curses_grouped_by_type.flat_map do |type, entries|
        entries.map { |entry| entry.merge(type: type) }
      end
      pages = [(all.size.to_f / PAGE_SIZE).ceil, 1].max
      page = page.to_i.clamp(0, pages - 1)
      [all.slice(page * PAGE_SIZE, PAGE_SIZE) || [], pages, page]
    end

    def show(event, page: 0, notice: nil)
      player = ErosHelpers.require_player(event) or return

      if Eros.encounter_for(player)
        ErosUI.reply_v2(event, ephemeral: true, with_actions: :combat) do |c|
          c.text_display(
            content: '_Syn\'s voice drifts from the parlour curtain: "Not while something has its hands ' \
                     'on you, pet. Survive first — then bring me your blessings. And yes, I call them ' \
                     'blessings, whatever you call them."_'
          )
        end
        return
      end

      entries, pages, page = page_entries(player, page)
      suppressed = player.suppressed_curses.sort_by(&:name)

      if entries.empty? && notice.nil?
        if suppressed.empty?
          ErosUI.reply_v2(event, ephemeral: true) do |c|
            c.text_display(
              content: '_Syn looks you over, slow and faintly bereaved. "Clean, unblessed skin, pet. ' \
                       'Nothing here for me to admire. The tower will fix that, I\'m sure."_'
            )
          end
        else
          show_sleeping(event, player, suppressed)
        end
        return
      end

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: "## 🖤 Syn's Curse Ledger — #{player.display_name}")
        c.text_display(
          content: '_Syn catches your chin and turns you toward the parlour light. Her expression ' \
                   'softens as she reads your skin. "Beautiful," she murmurs. "The tower blesses you, ' \
                   'and you come to me asking for vandalism." Her needle taps the ledger. "Understand ' \
                   'me, pet: these curses are blessings — works of art. I loathe removing them, and I ' \
                   'only smother them under protest. But Lust Points talk. Pay me, and I will ruin the ' \
                   'artwork. Just do not mistake payment for approval."_'
        )
        c.text_display(content: notice) if notice
        c.separator(divider: true, spacing: :small)
        c.text_display(
          content: "**Active blessings:** #{player.active_curse_count} · **Smothered:** #{suppressed.size} · " \
                   "**Your LP:** #{player.lp}\n" \
                   "_**Remove** (#{Player::CURSE_REMOVE_COST} LP) pays Syn to destroy one for good. " \
                   "**Suppress** (#{Player::CURSE_SUPPRESS_COST} LP) pays her to smother one until your " \
                   'next defeat. She accepts the Lust Points. She does not accept your taste._'
        )

        entries.each do |entry|
          curse = entry[:curse]
          type_name = Engine::CurseCatalog.type_label(entry[:type])
          c.text_display(
            content: "**#{entry[:index] + 1}. #{curse.name}** · _#{type_name}_\n#{curse.description}"
          )
          c.row do |row|
            row.button(
              label: "Suppress ##{entry[:index] + 1} · #{Player::CURSE_SUPPRESS_COST} LP",
              style: :primary,
              custom_id: "eros:curses:act:suppress:#{curse.id}:#{page}:#{event.user.id}",
              disabled: player.lp < Player::CURSE_SUPPRESS_COST
            )
            row.button(
              label: "Remove ##{entry[:index] + 1} · #{Player::CURSE_REMOVE_COST} LP",
              style: :danger,
              custom_id: "eros:curses:act:remove:#{curse.id}:#{page}:#{event.user.id}",
              disabled: player.lp < Player::CURSE_REMOVE_COST
            )
          end
        end

        if entries.empty?
          c.text_display(content: '_No active blessings remain. Syn mourns all that blank, unadorned skin._')
        end

        if page == pages - 1 && suppressed.any?
          lines = suppressed.map { |curse| "• ~~#{curse.name}~~" }
          c.text_display(
            content: "**Smothered under Syn's ink, under protest** _(they wake when you are defeated)_:\n#{lines.join("\n")}"
          )
        end

        Commands::Profile.attach_pager(c, 'eros:curses:page', page, pages, event.user.id) if pages > 1

        c.row do |row|
          if player.active_curse_count > 1
            cost = player.remove_all_curses_cost
            row.button(
              label: "Remove ALL #{player.active_curse_count} · #{cost} LP",
              style: :danger,
              custom_id: "eros:curses:remove_all:#{page}:#{event.user.id}",
              disabled: player.lp < cost
            )
          end
          row.button(label: '🖤 Talk to Syn', style: :secondary, custom_id: "eros:talk:syn:#{event.user.id}")
          row.button(label: 'Parlour', style: :secondary, custom_id: "eros:parlour:view:#{event.user.id}")
        end

        c.separator(divider: false, spacing: :small)
        c.text_display(
          content: '-# Curse numbers stay the same on every page · or use `e,removecurse N` / `e,suppresscurse N`'
        )
      end
    end

    def show_sleeping(event, player, suppressed)
      lines = suppressed.map { |curse| "• ~~#{curse.name}~~" }
      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: "## 🖤 Syn's Curse Ledger — #{player.display_name}")
        c.text_display(
          content: '_Syn regards the covered names with open distaste. "There they are, pet — beautiful ' \
                   'things, gagged under my ink because you paid me to smother them. I hate seeing blessings ' \
                   'muffled. They wake when you are defeated, at least. I look forward to that."_'
        )
        c.text_display(content: "**Smothered blessings:**\n#{lines.join("\n")}")
        c.row do |row|
          row.button(label: '🖤 Talk to Syn', style: :secondary, custom_id: "eros:talk:syn:#{event.user.id}")
          row.button(label: 'Parlour', style: :secondary, custom_id: "eros:parlour:view:#{event.user.id}")
        end
      end
    end

    # Buttons carry the curse's catalogue id rather than a bare number,
    # so a stale panel can never quietly act on the wrong curse after
    # the numbering shifts.
    def apply(event, action, curse_id, page: 0)
      player = ErosHelpers.require_player(event) or return

      if Eros.encounter_for(player)
        ErosUI.reply_v2(event, ephemeral: true, with_actions: :combat) do |c|
          c.text_display(content: '_Syn\'s voice, flat: "Not mid-fight, pet."_')
        end
        return
      end

      action = action.to_s == 'suppress' ? :suppress : :remove
      index = player.active_curses_ordered.index { |curse| curse.id == curse_id.to_i }
      result =
        if index.nil?
          { ok: false, error: :stale, message: 'That curse is already gone from your skin.' }
        elsif action == :suppress
          player.suppress_curse_at!(index)
        else
          player.remove_curse_at!(index)
        end
      show(event, page: page, notice: syn_result_notice(result, action))
    end

    def apply_all(event, page: 0)
      player = ErosHelpers.require_player(event) or return

      if Eros.encounter_for(player)
        ErosUI.reply_v2(event, ephemeral: true, with_actions: :combat) do |c|
          c.text_display(content: '_Syn\'s voice, flat: "Not mid-fight, pet."_')
        end
        return
      end

      result = player.remove_all_curses!
      show(event, page: page, notice: syn_bulk_notice(result))
    end

    def syn_result_notice(result, action)
      unless result[:ok]
        case result[:error]
        when :insufficient_lp
          return "_🖤 **Syn:** \"No.\" She closes the ledger. \"Your Lust Points are the only reason " \
                 "I agree to this vandalism, pet. #{result[:message]}\"_"
        when :stale
          return '_🖤 **Syn:** "That blessing has already been taken from you, pet. Even I cannot ' \
                 'destroy the same work of art twice."_'
        else
          return "_🖤 **Syn:** \"Not so fast, pet.\" #{result[:message]}_"
        end
      end

      curse = result[:curse]
      lp_left = result[:message][/LP left: (\d+)/, 1]
      cost = action.to_sym == :suppress ? Player::CURSE_SUPPRESS_COST : Player::CURSE_REMOVE_COST
      line =
        if action.to_sym == :suppress
          "\"There,\" she says, like the word tastes bad. **#{curse.name}** is smothered under her " \
          'ink until your next defeat — still beautiful, still there, just silenced because your ' \
          'Lust Points asked louder than her principles.'
        else
          "\"Vandal.\" Syn watches **#{curse.name}** leave your skin. \"Gone. Permanently. Your " \
          'Lust Points bought the deed, pet. They did not buy my forgiveness."'
        end
      "_🖤 **Syn:** #{line} _(#{cost} LP#{lp_left ? " · LP left: #{lp_left}" : ''})_"
    end

    def syn_bulk_notice(result)
      unless result[:ok]
        if result[:error] == :insufficient_lp
          return "_🖤 **Syn:** \"No.\" She closes the ledger. \"Your Lust Points are the only reason " \
                 "I agree to this vandalism, pet. #{result[:message]}\"_"
        end

        return "_🖤 **Syn:** \"Not so fast, pet.\" #{result[:message]}_"
      end

      lp_left = result[:message][/LP left: (\d+)/, 1]
      "_🖤 **Syn:** \"Monster.\" She works over your skin until the whole gallery is stripped. \"I " \
        "did that for your Lust Points, pet. Do not expect me to call it anything but vandalism.\" " \
        "_(**#{result[:count]} blessings** destroyed · #{result[:cost]} LP#{lp_left ? " · LP left: #{lp_left}" : ''})_"
    end

    def run(event)
      show(event)
    end

    button(custom_id: /^eros:curses:page:-?\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      page = event.custom_id[/\Aeros:curses:page:(-?\d+):\d+\z/, 1].to_i
      Commands::Curses.show(event, page: page)
    end

    button(custom_id: /^eros:curses:act:(remove|suppress):\d+:\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      match = event.custom_id.match(/\Aeros:curses:act:(remove|suppress):(\d+):(\d+):(\d+)\z/)
      Commands::Curses.apply(event, match[1], match[2], page: match[3].to_i)
    end

    button(custom_id: /^eros:curses:remove_all:\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      page = event.custom_id[/\Aeros:curses:remove_all:(\d+):\d+\z/, 1].to_i
      Commands::Curses.apply_all(event, page: page)
    end

    application_command(:curses) { |event| Commands::Curses.run(event) }

    command(:curses, description: "Syn's curse ledger: pay her to suppress or remove blessings she would rather keep") do |event|
      Commands::Curses.run(event)
      nil
    end
  end
end
