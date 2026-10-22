# frozen_string_literal: true

module Commands
  module Residents
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0x8a6d6b

    module_function

    def hub(event, notice: nil)
      player = ErosHelpers.require_player(event) or return

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: '## The Residents')
        c.text_display(content: notice) if notice
        c.text_display(
          content: '_Not every soul in the tower is hunting you. Some of them settled, took up a trade, ' \
                   'and now keep hours. Berry points them out the way she points out her own counters: ' \
                   'proudly, and with opinions._'
        )
        Engine::Residents::RESIDENTS.each do |id, spec|
          exiled = id.to_s == 'vex' && Engine::Residents.vex_exiled?(player)
          blurb = if exiled
                    'Her back room at the Cursed Shop stands empty under a sheet. Covar threw her out, and ' \
                    'the whole tower is pretending not to listen.'
                  elsif id.to_s == 'vex' && Engine::Residents.vex_restored?(player)
                    'Back in business in a rundown room with a kettle and strong opinions. Her fees have ' \
                    'doubled — rent, she says, and she will itemise it.'
                  else
                    spec[:blurb]
                  end
          c.section do |section|
            section.text_display(content: "**#{spec[:name]}** — _#{spec[:title]}_\n#{blurb}")
            section.button(label: exiled ? 'Gone' : 'Visit', style: :primary,
                           custom_id: "eros:resident:show:#{id}:#{event.user.id}", disabled: exiled)
          end
        end
        c.row do |row|
          row.button(label: 'All Shops', style: :secondary, custom_id: "eros:shop:menu:#{event.user.id}")
        end
      end
    end

    def show(event, id, notice: nil)
      player = ErosHelpers.require_player(event) or return
      spec = Engine::Residents.resident(id)
      return hub(event, notice: 'That resident has wandered off.') unless spec

      if id.to_s == 'vex' && Engine::Residents.vex_exiled?(player)
        ErosUI.reply_v2(event, colour: COLOUR) do |c|
          c.text_display(content: '## Madame Vex — the Listener')
          c.text_display(content: notice) if notice
          c.text_display(
            content: '_The back room at the Cursed Shop is empty. Her bench stands under a sheet, her ' \
                     'chair is pushed in with terrible neatness, and there is a Covar-shaped silence where ' \
                     'the listening used to be. He threw her out the day the Original went onto the ' \
                     'mannequin — salvaged the dress himself and refuses, point blank, to let anyone near ' \
                     'her until it is whole again._'
          )
          c.text_display(
            content: '_If anyone is going to fix this, it is apparently you. Covar is behind his counter, ' \
                     'charging double and daring the tower to comment._'
          )
          c.row do |row|
            row.button(label: 'Cursed Shop', style: :primary, custom_id: "eros:cshop:open:#{event.user.id}")
            row.button(label: 'Residents', style: :secondary, custom_id: "eros:residents:view:#{event.user.id}")
          end
        end
        return
      end

      Engine::Residents.mark_met!(player, id)
      owner = event.user.id

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: "## #{spec[:name]} — #{spec[:title]}")
        c.text_display(content: notice) if notice
        c.text_display(content: spec[:intro])
        if id.to_s == 'vex' && Engine::Residents.vex_restored?(player)
          c.text_display(
            content: '_The new room is rundown and entirely hers: a kettle, a worktable, a sign in her own ' \
                     'hand. The Original is gone from her — worn now, gloriously, by her landlord — and she ' \
                     'has opinions about the arrangement that she delivers like weather. Her fees have ' \
                     'doubled. Rent, she says. Kettle. Standards._'
          )
        end

        topics = Engine::Residents.topics(id)
        if topics.any?
          c.row do |row|
            topics.each do |topic|
              row.button(label: topic[:label], style: :secondary,
                         custom_id: "eros:resident:topic:#{id}:#{topic[:key]}:#{owner}")
            end
          end
        end

        case id.to_s
        when 'vex' then vex_services(c, player, owner)
        when 'pip' then pip_services(c, player, owner)
        when 'nectar' then nectar_services(c, player, owner)
        when 'cartographer' then cartographer_services(c, player, owner)
        end

        story_block(c, player, id, owner)

        c.row do |row|
          row.button(label: 'Residents', style: :primary, custom_id: "eros:residents:view:#{owner}")
          row.button(label: 'All Shops', style: :secondary, custom_id: "eros:shop:menu:#{owner}")
        end
      end
    end

    def vex_services(c, player, owner)
      c.separator(divider: true, spacing: :small)
      worn = player.equipped_mimics
      if worn.empty?
        c.text_display(
          content: '**Her bench** — _"Nothing worn, nothing to translate. Bring me a living piece on your ' \
                   'body, delver, and I will tell you what it has been saying."_'
        )
        return
      end

      restored = Engine::Residents.vex_restored?(player)
      c.text_display(
        content: '**Her bench** — negotiate a worn piece off intact ' \
                 "(**from #{Engine::Residents::NEGOTIATE_MIN * (restored ? 2 : 1)} LP** — " \
                 "#{restored ? 'four times' : 'twice'} its tear-free price, so the piece " \
                 'survives), or refit its ' \
                 "temperament (**#{Engine::Residents::REFIT_COST} LP**, once per piece)." \
                 "#{restored ? ' _Her fees doubled with the new room — rent, she says._' : ''}"
      )
      worn.each do |item|
        refitted = Engine::Residents.refitted_names(player).include?(item.name)
        c.row do |row|
          row.button(label: "Negotiate off: #{item.name}"[0, 80], style: :primary,
                     custom_id: "eros:resident:vex:off:#{item.id}:#{owner}",
                     disabled: player.lp < Engine::Residents.negotiate_cost(player, item))
          row.button(label: "Refit: #{item.name}"[0, 80], style: :secondary,
                     custom_id: "eros:resident:vex:refit:#{item.id}:#{owner}",
                     disabled: refitted || player.lp < Engine::Residents::REFIT_COST)
        end
      end
    end

    def pip_services(c, player, owner)
      if (review = Engine::Residents.review_line(player))
        c.text_display(content: review)
        player.set_tracker!('pip_reviewed', player.tracker_hash['last_trap_name'].to_s)
      end
      c.separator(divider: true, spacing: :small)
      price = Engine::Residents.spotting_price(player)
      wedges = player.tracker('pip_wedges')
      c.text_display(
        content: "**Her services** — **Queen-watching** (#{price} LP): Pip reads the floor's pattern and " \
                 'your next trap is spotted in time. **A scavenged wedge** ' \
                 "(#{Engine::Residents::WEDGE_COST} LP, after 10 catches): jams your next sprung trap " \
                 "harmless. _Wedges carried: #{wedges}_ · _Traps sprung on you: #{player.tracker('traps_triggered')}_"
      )
      c.row do |row|
        row.button(label: "Queen-watching (#{price} LP)", style: :primary,
                   custom_id: "eros:resident:pip:spotting:#{owner}",
                   disabled: player.tracker('pip_spotting').positive? || player.lp < price)
        row.button(label: "Wedge (#{Engine::Residents::WEDGE_COST} LP)", style: :secondary,
                   custom_id: "eros:resident:pip:wedge:#{owner}",
                   disabled: player.tracker('traps_triggered') < 10 || wedges >= Engine::Residents::MAX_WEDGES ||
                             player.lp < Engine::Residents::WEDGE_COST)
        if Engine::Residents.pip_beat_available?(player, 50) && !player.tracker('pip_note_delivered').positive?
          row.button(label: "Deliver Pip's note", style: :danger, custom_id: "eros:resident:pip:note:#{owner}")
        end
      end

      beats = Engine::Residents::PIP_MILESTONES.select { |t, _| Engine::Residents.pip_beat_available?(player, t) }
      return if beats.empty?

      c.row do |row|
        beats.each do |threshold, beat|
          row.button(label: beat[:label], style: :secondary, custom_id: "eros:resident:pipbeat:#{threshold}:#{owner}")
        end
      end
    end

    def nectar_services(c, player, owner)
      c.separator(divider: true, spacing: :small)
      milkings = player.tracker('nectar_milkings')
      c.text_display(
        content: "**The shrine provides** — be milked by Sister Nectar herself: LP, a little defiance " \
                 "back, and **Milked Dry** for 2 floors. Once per floor. _Sessions kept by her: #{milkings}_"
      )
      c.row do |row|
        row.button(label: 'Be milked at the shrine', style: :primary,
                   custom_id: "eros:resident:nectar:shrine:#{owner}")
      end
    end

    def cartographer_services(c, player, owner)
      c.text_display(content: Engine::Residents.rapport_line(player))
      warning = Engine::Residents.boss_warning(player)
      c.text_display(content: warning) if warning
      c.separator(divider: true, spacing: :small)
      queue = Engine::Residents.active_sketch(player)
      sketch_line =
        if queue
          "Current sketch: #{queue.map { |k| "#{Engine::Residents::SKETCH_ICONS[k]} #{Engine::Residents::SKETCH_LABELS[k]}" }.join(' · ')} " \
          '— served room by room while the gates allow.'
        else
          'No sketch in hand.'
        end
      price = Engine::Residents.sketch_price(player)
      c.text_display(
        content: "**His dictation** — a sketch of the next 3 rooms the land is dreaming " \
                 "(**#{price} LP** at this depth). Bosses, altars, and events keep their own counsel and " \
                 "override it without consuming it; descending voids it. _#{sketch_line}_"
      )
      c.row do |row|
        row.button(label: "Buy a sketch (#{price} LP)", style: :primary,
                   custom_id: "eros:resident:carto:buy:#{owner}", disabled: player.lp < price)
      end
    end

    def story_block(c, player, id, owner)
      return unless Engine::Residents.chain(id)

      c.separator(divider: true, spacing: :small)
      if Engine::Residents.story_done?(player, id)
        ending = Engine::Residents::ENDINGS.dig(id.to_s, player.tracker_hash["#{id}_ending"].to_s)
        c.text_display(content: "**Story finished.**#{ending ? " _You chose: #{ending[:label]}._" : ''}")
        return
      end

      spec = Engine::Residents.story_current(player, id)
      done, target = Engine::Residents.story_progress(player, id)
      progress = spec[:action] || spec[:choice] ? '' : " — **#{done}/#{target}**"
      c.text_display(content: "**Her story: #{spec[:name]}**#{progress}\n#{spec[:text]}")
      if spec[:choice]
        c.row do |row|
          Engine::Residents::ENDINGS[id.to_s].each do |key, ending|
            row.button(label: ending[:label], style: :danger,
                       custom_id: "eros:resident:ending:#{id}:#{key}:#{owner}")
          end
        end
      else
        ready = Engine::Residents.story_complete?(player, id)
        c.row do |row|
          row.button(label: spec[:action] ? 'Do it' : 'Claim', style: :primary,
                     custom_id: "eros:resident:claim:#{id}:#{owner}", disabled: !ready)
        end
      end
    end

    button(custom_id: /^eros:residents:view:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Residents.hub(event)
    end

    button(custom_id: /^eros:resident:show:[a-z_]+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Residents.show(event, event.custom_id[/\Aeros:resident:show:([a-z_]+):\d+\z/, 1])
    end

    button(custom_id: /^eros:resident:topic:[a-z_]+:[a-z_]+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      id, key = event.custom_id.match(/\Aeros:resident:topic:([a-z_]+):([a-z_]+):\d+\z/).captures
      topic = Engine::Residents.topics(id).find { |t| t[:key] == key }
      Commands::Residents.show(event, id, notice: topic ? "_#{topic[:text]}_" : nil)
    end

    button(custom_id: /^eros:resident:pipbeat:\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      threshold = event.custom_id[/\Aeros:resident:pipbeat:(\d+):\d+\z/, 1]
      result = Engine::Residents.read_pip_beat!(player, threshold)
      Commands::Residents.show(event, 'pip', notice: "#{result[:ok] ? '' : '❌ '}#{result[:message]}")
    end

    button(custom_id: /^eros:resident:vex:(off|refit):\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      action, item_id = event.custom_id.match(/\Aeros:resident:vex:(off|refit):(\d+):\d+\z/).captures
      result = action == 'off' ? Engine::Residents.negotiate_off!(player, item_id) : Engine::Residents.refit!(player, item_id)
      player.refresh
      Commands::Residents.show(event, 'vex', notice: "#{result[:ok] ? '✅' : '❌'} #{result[:message]}")
    end

    button(custom_id: /^eros:resident:pip:(spotting|wedge|note):\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      action = event.custom_id[/\Aeros:resident:pip:(spotting|wedge|note):\d+\z/, 1]
      result =
        case action
        when 'spotting' then Engine::Residents.buy_spotting!(player)
        when 'wedge' then Engine::Residents.buy_wedge!(player)
        else Engine::Residents.deliver_pip_note!(player)
        end
      player.refresh
      Commands::Residents.show(event, 'pip', notice: "#{result[:ok] ? '✅' : '❌'} #{result[:message]}")
    end

    button(custom_id: /^eros:resident:nectar:shrine:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      result = Engine::Residents.shrine_visit!(player)
      player.refresh
      Commands::Residents.show(event, 'nectar', notice: "#{result[:ok] ? '' : '❌ '}#{result[:message]}")
    end

    button(custom_id: /^eros:resident:carto:buy:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      result = Engine::Residents.buy_sketch!(player)
      player.refresh
      Commands::Residents.show(event, 'cartographer', notice: "#{result[:ok] ? '🗺️' : '❌'} #{result[:message]}")
    end

    button(custom_id: /^eros:resident:claim:[a-z_]+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      id = event.custom_id[/\Aeros:resident:claim:([a-z_]+):\d+\z/, 1]
      result = Engine::Residents.claim_story!(player, id)
      player.refresh
      Commands::Residents.show(event, id, notice: "#{result[:ok] ? '✅' : '❌'} #{result[:message]}")
    end

    button(custom_id: /^eros:resident:ending:[a-z_]+:[a-z_]+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      player = Player[event.user.id]
      next unless player

      id, ending = event.custom_id.match(/\Aeros:resident:ending:([a-z_]+):([a-z_]+):\d+\z/).captures
      result = Engine::Residents.choose_ending!(player, id, ending)
      player.refresh
      Commands::Residents.show(event, id, notice: "#{result[:ok] ? '' : '❌ '}#{result[:message]}")
    end

    command(:residents, description: "The tower's settled residents: Vex, Pip, Sister Nectar, the Cartographer") do |event|
      Commands::Residents.hub(event)
    end
  end
end
