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

    module_function

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

        GROUPS.each do |group, spec|
          on = spec[:keys].select { |k| prefs[k] }
          summary = on.empty? ? '_none_' : on.map { |k| Engine::ContentOptions.preference(k)[:label] }.join(', ')
          c.text_display(content: "**#{spec[:title]} enabled:** #{summary}")
          c.row do |row|
            row.string_select(
              custom_id: "eros:opts:#{group}:#{event.user.id}",
              placeholder: spec[:placeholder],
              min_values: 0,
              max_values: spec[:keys].size
            ) do |menu|
              spec[:keys].each do |key|
                p = Engine::ContentOptions.preference(key)
                menu.option(label: p[:label], value: key, description: p[:description][0, 100], default: prefs[key])
              end
            end
          end
        end

        sizes = Engine::ContentOptions.applicable_sizes(player)
        unless sizes.empty?
          c.separator(divider: true, spacing: :small)
          current = sizes.keys.map { |part| "#{sizes[part][:label]} **#{Engine::ContentOptions.size_of(player, part)}**" }
          c.text_display(content: "**Body:** #{current.join(' · ')}")
          sizes.each do |part, spec|
            c.row do |row|
              row.string_select(
                custom_id: "eros:opts:size:#{part}:#{event.user.id}",
                placeholder: "#{spec[:label]} size",
                min_values: 1,
                max_values: 1
              ) do |menu|
                chosen = Engine::ContentOptions.size_of(player, part)
                spec[:options].each do |size|
                  menu.option(label: "#{spec[:label]}: #{size}", value: size, default: size == chosen)
                end
              end
            end
          end
        end
        c.text_display(
          content: '-# Changes save instantly. Sizes appear in scenes and some opt-in events. ' \
                   'Quick toggle: `e,fetish_options <option> <on/off>`.'
        )
      end
    end

    def set_group!(player, group, values)
      keys = GROUPS.dig(group, :keys) or return
      saved = player.preferences.is_a?(Hash) ? player.preferences.dup : {}
      keys.each { |k| saved[k] = values.include?(k) }
      player.update(preferences: saved)
    end

    def set_size!(player, part, value)
      spec = Engine::ContentOptions::BODY_SIZES[part] or return false
      return false unless spec[:options].include?(value)
      return false unless Engine::ContentOptions.applicable_sizes(player).key?(part)

      sizes = player.body_sizes.is_a?(Hash) ? player.body_sizes.dup : {}
      player.update(body_sizes: sizes.merge(part => value))
      true
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

    string_select(custom_id: /^eros:opts:(core|body|kink|fetish):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      group = event.custom_id[/\Aeros:opts:(core|body|kink|fetish):\d+\z/, 1]
      Commands::Options.set_group!(player, group, Array(event.values))
      Commands::Options.show(event, notice: '_Preferences saved._')
    end

    string_select(custom_id: /^eros:opts:size:[a-z]+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      part = event.custom_id[/\Aeros:opts:size:([a-z]+):\d+\z/, 1]
      ok = Commands::Options.set_size!(player, part, Array(event.values).first.to_s)
      Commands::Options.show(event, notice: ok ? '_Body size saved._' : '_That size is not available._')
    end

    application_command(:options) { |event| Commands::Options.show(event) }

    command(:options, description: 'Content preferences and body sizes') do |event|
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
