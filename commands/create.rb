# frozen_string_literal: true

module Commands
  module Create
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    module_function

    def show_menu(event)

      if Player[event.user.id]
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'You already have a character! Use `/status` or `!status`.')
        end
        return
      end

      ErosUI.reply_v2(event, colour: 0xff00ff) do |c|
        c.text_display(content: CharacterArchetypes.menu_text)
        c.separator(divider: true, spacing: :small)
        c.text_display(content: '_Pick a button below, or type `!create 1`–`!create 5`._')
        ErosUI.attach_create_buttons(c, event.user.id)
      end
    end

    def finish(event, archetype_id)

      if Player[event.user.id]
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'You already have a character!')
        end
        return
      end

      archetype = CharacterArchetypes.fetch(archetype_id)
      unless archetype
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'Unknown type. Use `/create` and choose **1–5**.')
        end
        return
      end

      player = Player.create_from_archetype!(
        discord_id: event.user.id,
        archetype: archetype
      )

      ErosUI.reply_v2(event, colour: 0xff00ff) do |c|
        c.text_display(content: '## Welcome to Endless Ruins of Sin')
        c.text_display(content: '_Descend. Endure. Desire._')
        c.separator(divider: true, spacing: :small)
        c.text_display(
          content: "Profile sealed for <@#{player.discord_id}>.\n" \
                   "**#{player.gender}** — #{player.body_parts_display}\n" \
                   "Lv #{player.level} · Defiance `#{player.defiance}` · Lust `#{player.lust}` · LP `#{player.lp}`\n" \
                   "STR #{player.strength} · AGI #{player.agility} · RES #{player.resistance}"
        )
        c.separator(divider: false, spacing: :small)
        c.text_display(
          content: 'Seek the **Seal of the Abyss** — or be remade by what finds you first.'
        )
        c.text_display(content: '-# Next: `/explore` or `!explore`')
      end
    end

    application_command(:create) { |event| Commands::Create.show_menu(event) }
    application_command(:start) { |event| Commands::Create.show_menu(event) }

    command(:create, description: 'Create your Endless Ruins of Sin delver (!create or !create 1-5)') do |event, choice|
      if choice && !choice.empty?
        Commands::Create.finish(event, choice.to_i)
      else
        Commands::Create.show_menu(event)
      end
      nil
    end

    command(:start, description: 'Create your Endless Ruins of Sin delver profile') do |event|
      Commands::Create.show_menu(event)
      nil
    end
  end
end
