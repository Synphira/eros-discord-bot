# frozen_string_literal: true

module Commands
  module Create
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    # discord_id => { archetype_id: Integer }
    PENDING = {}

    module_function

    def show_menu(event)
      if Player[event.user.id]
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'You already have a character! Use `/status` or `!status`.')
        end
        return
      end

      PENDING.delete(event.user.id)

      ErosUI.reply_v2(event, colour: 0xff00ff) do |c|
        c.text_display(content: CharacterArchetypes.menu_text)
        c.separator(divider: true, spacing: :small)
        c.text_display(content: '_Pick a button below, or type `!create 1`–`!create 5`._')
        ErosUI.attach_create_buttons(c, event.user.id)
      end
    end

    def show_submission_menu(event, archetype_id)
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

      PENDING[event.user.id] = { archetype_id: archetype_id.to_i }

      ErosUI.reply_v2(event, colour: 0xff00ff) do |c|
        c.text_display(
          content: "**Body:** #{archetype[:label]} _(#{archetype[:blurb]})_\n\n" \
                   "#{CharacterArchetypes.submission_menu_text}"
        )
        c.separator(divider: true, spacing: :small)
        c.text_display(content: '_Choose a button, or `!create eager|curious|neutral|reluctant|resistant`._')
        ErosUI.attach_submission_buttons(c, event.user.id)
      end
    end

    def finish(event, archetype_id: nil, submission_choice: 'neutral')
      if Player[event.user.id]
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'You already have a character!')
        end
        return
      end

      pending = PENDING[event.user.id]
      archetype_id ||= pending&.dig(:archetype_id)
      archetype = CharacterArchetypes.fetch(archetype_id)
      unless archetype
        ErosUI.reply_v2(event, ephemeral: true) do |c|
          c.text_display(content: 'Start with `/create` and pick a body type first.')
        end
        return
      end

      submission = CharacterArchetypes.submission_value(submission_choice)
      player = Player.create_from_archetype!(
        discord_id: event.user.id,
        archetype: archetype,
        submission: submission
      )
      PENDING.delete(event.user.id)

      ErosUI.reply_v2(event, colour: 0xff00ff) do |c|
        c.text_display(content: '## Welcome to Endless Ruins of Sin')
        c.text_display(content: '_Descend. Endure. Desire._')
        c.separator(divider: true, spacing: :small)
        c.text_display(
          content: "Profile sealed for <@#{player.discord_id}>.\n" \
                   "**#{player.gender}** — #{player.body_parts_display}\n" \
                   "Lv #{player.level} · Defiance `#{player.defiance}` · Lust `#{player.lust}` · LP `#{player.lp}`\n" \
                   "STR #{player.strength} · AGI #{player.agility} · RES #{player.resistance}\n" \
                   "Submission `#{player.submission}` _(#{player.submission_display})_"
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
        if choice.match?(/\A[1-5]\z/)
          Commands::Create.show_submission_menu(event, choice.to_i)
        elsif CharacterArchetypes::SUBMISSION_CHOICES.key?(choice.downcase) ||
              %w[willing open].include?(choice.downcase)
          Commands::Create.finish(event, submission_choice: choice)
        else
          ErosUI.reply_v2(event, ephemeral: true) do |c|
            c.text_display(
              content: 'Use `!create 1`–`5` for body type, then ' \
                       '`!create eager|curious|neutral|reluctant|resistant`.'
            )
          end
        end
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
