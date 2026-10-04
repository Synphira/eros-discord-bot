# frozen_string_literal: true

module SlashCommands
  STRING = 3
  INTEGER = 4

  def self.opt(name, description, type: STRING, required: false, choices: nil)
    { type: type, name: name, description: description, required: required, choices: choices }.compact
  end

  def self.choices(*values)
    values.map { |v| { name: v, value: v } }
  end

  DEFINITIONS = [
    { name: 'help', description: 'List all Endless Ruins of Sin commands' },
    { name: 'create', description: 'Create your delver (body type select)' },
    { name: 'start', description: 'Alias of /create — begin character creation' },
    { name: 'status', description: 'Show character sheet, curses, and Threat' },
    { name: 'explore', description: 'Step deeper into the endless dungeon' },
    { name: 'rest', description: 'Clear all lust and fully restore defiance (5-minute cooldown)' },
    { name: 'parlour', description: "Madame Vex's parlour: permanent tattoos and piercings with small perks" },
    { name: 'fight', description: 'Attack the monster you are fighting' },
    { name: 'flee', description: 'Try to escape combat (AGI helps)' },
    { name: 'submit', description: 'Submit to the monster you are fighting' },
    { name: 'levelup', description: 'Spend Lust Points on STR / AGI / RES / Level',
      options: [opt('choice', 'Upgrade immediately', choices: choices('strength', 'agility', 'resistance', 'level'))] },
    { name: 'curses', description: 'List your active curses by monster type' },
    { name: 'removecurse', description: 'Spend 50 LP to purge a curse (or open the remove/suppress menu)',
      options: [opt('number', 'Curse number from the list', type: INTEGER)] },
    { name: 'suppresscurse', description: 'Spend 25 LP to silence a curse until your next defeat',
      options: [opt('number', 'Curse number from the list', type: INTEGER)] },
    { name: 'shop', description: 'Browse the shop by category',
      options: [opt('category', 'Shop aisle', choices: choices('weapon', 'armor', 'accessory', 'special'))] },
    { name: 'buy', description: 'Buy an item from the shop', options: [opt('item', 'Item name', required: true)] },
    { name: 'sell', description: 'Sell an item from your pack', options: [opt('item', 'Item name', required: true)] },
    { name: 'cursedshop', description: 'Re-summon living gear you have torn free before (free)' },
    { name: 'equipment', description: 'View your gear, trophy, and inventory' },
    { name: 'equip', description: 'Equip an item', options: [opt('item', 'Item name', required: true)] },
    { name: 'unequip', description: 'Unequip an item', options: [opt('item', 'Item name', required: true)] },
    { name: 'remove', description: 'Destroy cursed living gear for LP', options: [opt('item', 'Item name', required: true)] },
    { name: 'restart', description: 'Start over with a new delver (titles & achievements are kept)' },
    { name: 'profile', description: 'Your character profile, lifetime stats, and rename',
      options: [opt('name', "Another delver's character name")] },
    { name: 'name', description: 'Set your character name', options: [opt('name', 'New character name', required: true)] },
    { name: 'titles', description: 'View and equip earned titles' },
    { name: 'title', description: 'Equip a title by name (or "auto")', options: [opt('name', 'Title name or auto', required: true)] },
    { name: 'transformation', description: 'View hybrid forms, or take one by name',
      options: [opt('name', 'Form name, or "clear" to return to human')] },
    { name: 'achievements', description: 'View achievements and progress',
      options: [opt('category', 'Category', choices: choices('combat', 'submission', 'exploration', 'curses', 'lust', 'events', 'kinks', 'challenges'))] },
    { name: 'leaderboard', description: 'Top delvers by cycles, depth, kills, or LP earned',
      options: [opt('stat', 'Ranking', choices: choices('cycles', 'depth', 'kills', 'lp'))] },
    { name: 'options', description: 'Content preferences (fetish toggles) and body sizes' },
    { name: 'fetish_options', description: 'Toggle one content theme on or off (no option = list all)',
      options: [opt('option', 'Theme key or name, e.g. bimbofication'), opt('state', 'On or off', choices: choices('on', 'off'))] }
  ].freeze

  module_function

  def payloads
    DEFINITIONS.map do |defn|
      payload = { name: defn[:name], description: defn[:description], type: 1 }
      payload[:options] = defn[:options] if defn[:options]
      payload
    end
  end

  def register!(bot = nil, guild_id: nil, token: nil, application_id: nil)
    guild_id ||= ENV['DISCORD_GUILD_ID']
    guild_id = guild_id.to_s.strip
    guild_id = nil if guild_id.empty?

    token ||= bot&.token
    app_id = application_id || bot&.profile&.id
    raise ArgumentError, 'token and application_id (or a connected bot) required' if token.nil? || app_id.nil?

    token = token.strip
    token = "Bot #{token}" unless token.start_with?('Bot ')

    body = payloads

    if guild_id
      Discordrb::API::Application.bulk_overwrite_guild_commands(token, app_id, guild_id, body)
      puts "Registered #{body.size} guild slash commands on guild #{guild_id}."
    else
      Discordrb::API::Application.bulk_overwrite_global_commands(token, app_id, body)
      puts "Registered #{body.size} global slash commands (may take up to ~1 hour to appear)."
    end

    body.size
  end
end
