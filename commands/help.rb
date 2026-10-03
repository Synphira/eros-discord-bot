# frozen_string_literal: true

module Commands
  module Help
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COMMANDS = [
  ['/create · /start', '!create · !start', 'Create your delver (body type select)'],
  ['/status', '!status', 'Character sheet: stats, deepest floor, Threat (curses via /curses)'],
  ['/explore', '!explore', 'Room roll — monster / trap / treasure / stairs / empty'],
  ['/rest', '!rest', 'Clear all lust and fully restore defiance — once every 5 minutes (also a button)'],
  ['/fight · /flee · /submit', '!fight · !flee · !submit', 'Combat actions (also buttons)'],
  ['/levelup', '!levelup [stat|level]', 'Spend LP on STR / AGI / RES or a Level (+max defiance, full heal)'],
  ['/curses', '!curses', 'List active curses by monster type'],
  ['/removecurse', '!removecurse [N]', 'Purge a curse for 50 LP'],
  ['/suppresscurse', '!suppresscurse [N]', 'Silence a curse for 25 LP until your next defeat'],
  ['/shop', '!shop [category]', 'Browse shop by category (buy buttons + pages)'],
  ['/buy', '!buy [item]', 'Buy a shop item by name'],
  ['/sell', '!sell [item]', 'Sell non-cursed gear by name'],
  ['/cursedshop', '!cursedshop', 'Free living gear you have previously worn and torn free'],
  ['/equipment', '!equipment', 'View gear, your trophy, and inventory'],
  ['/equip', '!equip [item]', 'Equip an item (one trophy at a time)'],
  ['/unequip', '!unequip [item]', 'Unequip normal gear'],
  ['/remove', '!remove [item]', 'Destroy cursed mimic gear for LP'],
  ['/options', '!options', 'Content preferences (fetish toggles) and body sizes'],
  ['/fetish_options', '!fetish_options [option] [on/off]', 'Quick-toggle one content theme (no args lists them all)'],
  ['—', '!sluttify [on/off]', 'Turn every content theme on or off at once (prefix only)'],
  ['/restart', '!restart', 'New delver and body type — titles, achievements, and progress are kept'],
  ['/profile', '!profile [name]', 'Your profile & lifetime stats (or look up a delver by character name)'],
  ['/name', '!name [name]', 'Set or change your character name (also `/profile` → Rename)'],
  ['/titles · /title', '!titles · !title [name|auto]', 'View and equip earned titles'],
  ['/transformation', '!transformation [name|clear]', 'Hybrid forms — unlock, switch, or return to human (alias `!hybrid`)'],
  ['/achievements', '!achievements [category]', 'Achievements by category'],
  ['/leaderboard', '!leaderboard [cycles|depth|kills|lp]', 'Top delvers by character name'],
  ['/help', '!help', 'List all commands']
].freeze

    module_function

    def run(event)
      lines = COMMANDS.map do |slash, prefix, desc|
        slash == '—' ? "`#{prefix}`\n#{desc}" : "**#{slash}** / `#{prefix}`\n#{desc}"
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
