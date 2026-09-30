# frozen_string_literal: true

module Commands
  module CursedShop
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0x5c1a4a

    module_function

    def run(event, notice: nil)
      player = ErosHelpers.require_player(event) or return
      Engine::Treasure.sync_to_db!
      items = Engine::Treasure.all_mimic_templates.map { |t| ::Equipment.first(name: t[:name]) }.compact
      unlocked = player.cursed_shop_unlocks

      ErosUI.reply_v2(event, colour: COLOUR) do |c|
        c.text_display(content: '## Cursed Shop')
        c.text_display(
          content: '_Living gear you have worn and torn free remembers you. Call it back for free — ' \
                   'removing it again costs its usual LP._'
        )
        c.text_display(content: notice) if notice
        c.separator(divider: true, spacing: :small)

        takeable = []
        lines = items.map do |item|
          if player.owns_equipment?(item.id)
            "◆ **#{item.name}** — _already bound to you_"
          elsif unlocked.include?(item.name)
            takeable << item
            "◈ **#{item.name}** (#{item.slot}) — _#{item.description}_\n  " \
              "#{Engine::Treasure.format_stat_changes(item.stat_modifiers)} · **Free** · removal #{item.removal_cost} LP"
          else
            "◇ ??? (#{item.slot}) — _find it in a chest, wear it, and tear it free to unlock_"
          end
        end
        c.text_display(content: lines.join("\n"))
        c.text_display(content: "-# Unlocked #{(unlocked & items.map(&:name)).size}/#{items.size}")

        takeable.each_slice(5) do |slice|
          c.row do |row|
            slice.each do |item|
              row.button(label: "Take #{item.name}"[0, 80], style: :danger,
                         custom_id: "eros:cshop:take:#{item.id}:#{event.user.id}")
            end
          end
        end
        c.row do |row|
          row.button(label: 'Shop', style: :secondary, custom_id: "eros:shop:cat:weapon:#{event.user.id}")
          row.button(label: 'Equipment', style: :secondary, custom_id: "eros:cshop:equipment:#{event.user.id}")
        end
      end
    end

    def take(event, equipment_id)
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
        else
          player.grant_equipment!(item)[:message]
        end
      run(event, notice: message)
    end

    button(custom_id: /^eros:cshop:open:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::CursedShop.run(event)
    end

    button(custom_id: /^eros:cshop:take:\d+:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::CursedShop.take(event, event.custom_id[/\Aeros:cshop:take:(\d+):\d+\z/, 1])
    end

    button(custom_id: /^eros:cshop:equipment:\d+$/) do |event|
      next unless ErosHelpers.assert_button_owner!(event)

      Commands::Equipment.run(event)
    end

    application_command(:cursedshop) { |event| Commands::CursedShop.run(event) }

    command(:cursedshop, description: 'Re-summon living gear you have previously torn free (free)') do |event|
      Commands::CursedShop.run(event)
      nil
    end
  end
end
