# frozen_string_literal: true

module Commands
  module Help
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COMMANDS = [
  ['/create · /start', '!create · !start', 'Create your delver (body type select)'],
  ['/status', '!status', 'Character sheet: body, stats, defiance, lust, LP, Threat'],
  ['/explore', '!explore', 'Room roll — monster / trap / treasure / stairs / empty'],
  ['/levelup', '!levelup', 'Spend LP on STR / AGI / RES (10) or Level (50)'],
  ['/curses', '!curses', 'List active curses by monster type'],
  ['/removecurse', '!removecurse [N]', 'Purge a curse for 50 LP'],
  ['/shop', '!shop', 'View shop inventory and buy items'],
  ['/buy', '!buy [item]', 'Buy an item from the shop'],
  ['/sell', '!sell [item]', 'Sell an item to the shop'],
  ['/equipment', '!equipment', 'View and manage your equipment'],
  ['/equip', '!equip [item]', 'Equip an item'],
  ['/unequip', '!unequip [item]', 'Unequip an item'],
  ['/help', '!help', 'List all commands'],
  ['—', '!fight · !flee · !submit', 'Combat actions (also buttons)']
].freeze

    module_function

    def run(event)
      lines = COMMANDS.map do |slash, prefix, desc|
        "**#{slash}** / `#{prefix}`\n#{desc}"
      end

      ErosUI.reply_v2(event, colour: 0x6b5b95) do |c|
        c.text_display(content: '## Endless Ruins of Sin Commands')
        c.text_display(content: '_Slash and prefix commands share the same handlers._')
        c.separator(divider: true, spacing: :small)
        c.text_display(content: lines.join("\n\n"))
        c.separator(divider: false, spacing: :small)
        c.text_display(content: '-# Prefix defaults to `!` (set `BOT_PREFIX` in `.env`).')
      end
    end

    application_command(:help) { |event| Commands::Help.run(event) }

    command(:help, description: 'List all Endless Ruins of Sin commands') do |event|
      Commands::Help.run(event)
      nil
    end
  end
end
