# frozen_string_literal: true

module Commands
  module Options
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0x7d3c98
    GROUPS = {
      'core' => { keys: Engine::ContentOptions::CORE_KEYS, title: 'Core',
                  placeholder: 'Core content (everything ticked is shown)' },
      'body' => { keys: Engine::ContentOptions::BODY_KEYS, title: 'Opt-in bodies',
                  placeholder: 'Body & transformation events (opt-in)' },
      'kink' => { keys: Engine::ContentOptions::KINK_KEYS, title: 'Opt-in kinks',
                  placeholder: 'Kink & scenario events (opt-in)' },
      'fetish' => { keys: Engine::ContentOptions::FETISH_KEYS, title: 'Opt-in fetishes',
                    placeholder: 'More fetish events (opt-in)' }
    }.freeze

    PER_PAGE = 5

    # The Desire Magnet's kinds: every pool type (eldritch is not a
    # kind that wanders, and the tower will not be magnetised to it).
    MAGNET_KINDS = %w[beast demon slime undead plant mimic clown].freeze

    module_function

    def magnet_kind(player)
      kind = player.tracker_hash['desire_magnet'].to_s
      return nil unless MAGNET_KINDS.include?(kind)
      return nil unless Engine::MonsterTypes.option_allows?(player, kind)

      kind
    end

    def magnet_kinds_for(player)
      MAGNET_KINDS.select { |kind| Engine::MonsterTypes.option_allows?(player, kind) }
    end

    # The options home: one button per family of toggles, with its tally.
    def show(event, notice: nil)
      player = ErosHelpers.require_player(event) or return
      prefs = Engine::ContentOptions.preferences_for(player)

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: "## Content Options — #{player.display_name}")
        c.text_display(
          content: '_Choose what the tower may show you. Scenes touching disabled **core** themes are re-rolled or ' \
                   'toned down; **opt-in** themes add new random events when enabled._'
        )
        c.text_display(content: notice) if notice
        c.text_display(content: 'Pick a family to fine-tune its toggles:')
        c.row do |row|
          GROUPS.each do |group, spec|
            on = spec[:keys].count { |k| prefs[k] }
            row.button(
              label: "#{spec[:title]} · #{on}/#{spec[:keys].size} on",
              style: :primary,
              custom_id: "eros:opts:group:#{group}:#{event.user.id}"
            )
          end
        end
        magnet = magnet_kind(player)
        c.text_display(
          content: "**🧲 Desire Magnet** — the tower approves of honesty: " \
                   "#{magnet ? "you are honest about **#{Engine::MonsterTypes.fetch(magnet)[:name]}**, and they find you more often" : 'no favourite chosen — the tower guesses'}. " \
                   'Costs nothing. Changes nothing but the odds of being found by what you already want.'
        )
        c.row do |row|
          row.string_select(custom_id: "eros:opts:magnet:#{event.user.id}", placeholder: 'Choose a favourite monster kind…',
                            min_values: 1, max_values: 1) do |menu|
            menu.option(label: 'No favourite — let the tower guess', value: 'none', default: magnet.nil?)
            magnet_kinds_for(player).each do |kind|
              menu.option(label: Engine::MonsterTypes.fetch(kind)[:name], value: kind,
                          description: Engine::MonsterTypes.fetch(kind)[:description][0, 100],
                          default: magnet == kind)
            end
          end
        end
        c.text_display(
          content: '-# Changes save instantly. Quick toggle: `e,fetish_options <option> <on/off>`.'
        )
      end
    end

    # One page of a family's toggles: five themes, each with its own
    # button — lit and checked when on, grey when off.
    def show_group(event, group, page: 0, notice: nil)
      player = ErosHelpers.require_player(event) or return
      spec = GROUPS[group.to_s] or return show(event, notice: notice)
      prefs = Engine::ContentOptions.preferences_for(player)
      pages = [(spec[:keys].size.to_f / PER_PAGE).ceil, 1].max
      page = page.to_i % pages
      slice = spec[:keys].slice(page * PER_PAGE, PER_PAGE) || []
      on = spec[:keys].count { |k| prefs[k] }

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: "## Content Options — #{spec[:title]} (#{on}/#{spec[:keys].size} on)")
        c.text_display(content: notice) if notice
        lines = slice.map do |key|
          p = Engine::ContentOptions.preference(key)
          "#{prefs[key] ? '✅' : '⬜'} **#{p[:label]}** — #{p[:description]}"
        end
        c.text_display(content: lines.join("\n"))
        c.row do |row|
          slice.each do |key|
            p = Engine::ContentOptions.preference(key)
            row.button(
              label: "#{prefs[key] ? '✅' : '⬜'} #{p[:label]}",
              style: prefs[key] ? :success : :secondary,
              custom_id: "eros:opts:toggle:#{group}:#{page}:#{key}:#{event.user.id}"
            )
          end
        end
        c.row do |row|
          row.button(label: '◀ Prev', style: :secondary, custom_id: "eros:opts:page:#{group}:#{page - 1}:#{event.user.id}")
          row.button(label: "Page #{page + 1}/#{pages}", style: :secondary,
                     custom_id: "eros:opts:page:#{group}:info:#{event.user.id}", disabled: true)
          row.button(label: 'Next ▶', style: :secondary, custom_id: "eros:opts:page:#{group}:#{page + 1}:#{event.user.id}")
        end
        c.row do |row|
          row.button(label: '◀ All Categories', style: :primary, custom_id: "eros:opts:home:#{event.user.id}")
        end
        c.text_display(content: '-# Press a theme to switch it on or off. Changes save instantly.')
      end
    end

    def set_group!(player, group, values)
      keys = GROUPS.dig(group, :keys) or return
      saved = player.preferences.is_a?(Hash) ? player.preferences.dup : {}
      keys.each { |k| saved[k] = values.include?(k) }
      player.update(preferences: saved)
    end

    def toggle(event, option, state)
      player = ErosHelpers.require_player(event) or return
      prefs = Engine::ContentOptions.preferences_for(player)
      key = option.to_s.strip.empty? ? nil : Engine::ContentOptions.resolve_key(option)
      value = { 'on' => true, 'off' => false, 'true' => true, 'false' => false, 'yes' => true, 'no' => false,
                'enable' => true, 'disable' => false }[state.to_s.downcase.strip]

      message =
        if option.to_s.strip.empty?
          GROUPS.map do |_, spec|
            items = spec[:keys].map { |k| "#{prefs[k] ? '✅' : '⬜'} `#{k}`" }
            "**#{spec[:title]}**\n#{items.join(' · ')}"
          end.join("\n\n") + "\n\n-# Usage: `e,fetish_options <option> <on/off>` — or use `/options` for menus."
        elsif key.nil?
          "Unknown option **#{option}**. Use `e,fetish_options` to list them."
        elsif value.nil?
          "**#{Engine::ContentOptions.preference(key)[:label]}** is currently **#{prefs[key] ? 'on' : 'off'}**. " \
            "Add `on` or `off` to change it."
        else
          Engine::ContentOptions.set!(player, key, value)
          "**#{Engine::ContentOptions.preference(key)[:label]}** is now **#{value ? 'on' : 'off'}**."
        end
      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: '## Fetish Options')
        c.text_display(content: message)
      end
    end

    string_select(custom_id: /^eros:opts:magnet:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      kind = Array(event.values).first.to_s
      if Commands::Options::MAGNET_KINDS.include?(kind)
        player.set_tracker!('desire_magnet', kind)
        Commands::Options.show(event, notice: "_🧲 Desire Magnet set to **#{Engine::MonsterTypes.fetch(kind)[:name]}** — they will find you more often._")
      else
        player.set_tracker!('desire_magnet', '')
        Commands::Options.show(event, notice: '_🧲 Desire Magnet cleared — the tower guesses again._')
      end
    end

    string_select(custom_id: /^eros:opts:(core|body|kink|fetish):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      group = event.custom_id[/\Aeros:opts:(core|body|kink|fetish):\d+\z/, 1]
      Commands::Options.set_group!(player, group, Array(event.values))
      Commands::Options.show_group(event, group, notice: '_Preferences saved._')
    end

    button(custom_id: /^eros:opts:home:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Options.show(event)
    end

    button(custom_id: /^eros:opts:group:(core|body|kink|fetish):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      group = event.custom_id[/\Aeros:opts:group:(core|body|kink|fetish):\d+\z/, 1]
      Commands::Options.show_group(event, group)
    end

    button(custom_id: /^eros:opts:page:(core|body|kink|fetish):-?\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      _, group, page = event.custom_id.match(/\Aeros:opts:page:(core|body|kink|fetish):(-?\d+):\d+\z/).to_a
      Commands::Options.show_group(event, group, page: page.to_i)
    end

    button(custom_id: /^eros:opts:toggle:(core|body|kink|fetish):\d+:[a-z_]+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      _, group, page, key = event.custom_id.match(/\Aeros:opts:toggle:(core|body|kink|fetish):(\d+):([a-z_]+):\d+\z/).to_a
      next unless Commands::Options::GROUPS.dig(group, :keys)&.include?(key)

      prefs = Engine::ContentOptions.preferences_for(player)
      Engine::ContentOptions.set!(player, key, !prefs[key])
      label = Engine::ContentOptions.preference(key)[:label]
      Commands::Options.show_group(event, group, page: page.to_i,
                                   notice: "_#{prefs[key] ? '⬜' : '✅'} **#{label}** is now **#{prefs[key] ? 'off' : 'on'}**._")
    end

    application_command(:options) { |event| Commands::Options.show(event) }

    command(:options, description: 'Content preferences') do |event|
      Commands::Options.show(event)
      nil
    end

    def sluttify(event, state)
      player = ErosHelpers.require_player(event) or return
      keys = Engine::ContentOptions::PREFERENCES.keys
      prefs = Engine::ContentOptions.preferences_for(player)
      value =
        case state.to_s.downcase.strip
        when 'on', 'true', 'yes', 'enable' then true
        when 'off', 'false', 'no', 'disable' then false
        else !keys.all? { |k| prefs[k] }
        end
      saved = player.preferences.is_a?(Hash) ? player.preferences.dup : {}
      keys.each { |k| saved[k] = value }
      player.update(preferences: saved)

      message =
        if value
          "**All #{keys.size} themes enabled.** Every fetish event and scene can now appear."
        else
          "**All #{keys.size} themes disabled.** Scenes are toned down and opt-in events won't appear."
        end
      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: '## Sluttify')
        c.text_display(content: message)
        c.text_display(content: '-# Run `e,sluttify` again to flip back, or fine-tune in `/options`.')
      end
    end

    command(:sluttify, description: 'Enable or disable every content toggle at once: e,sluttify [on/off]') do |event, state|
      Commands::Options.sluttify(event, state)
      nil
    end

    application_command(:fetish_options) do |event|
      Commands::Options.toggle(event, event.options['option'], event.options['state'])
    end

    command(:fetish_options, aliases: [:fetish], description: 'Toggle a content theme: e,fetish_options <option> <on/off>') do |event, *args|
      state = args.size > 1 ? args.pop : nil
      Commands::Options.toggle(event, args.join(' '), state)
      nil
    end
  end
end
