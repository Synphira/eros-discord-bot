# frozen_string_literal: true

# Canonical slash-command definitions for Discord registration.
# Handlers live under commands/; this file is only the Discord API registry.
#
# Register once (or after changing names/descriptions):
#   bundle exec rake commands:register
#   bundle exec ruby register_commands.rb
#
# Optional guild-scoped (instant sync while testing):
#   DISCORD_GUILD_ID=123 bundle exec rake commands:register
module SlashCommands
  # type 1 = CHAT_INPUT
  DEFINITIONS = [
    { name: 'help', description: 'List all Endless Ruins of Sin commands' },
    { name: 'create', description: 'Create your delver (body type select)' },
    { name: 'start', description: 'Alias of /create — begin character creation' },
    { name: 'status', description: 'Show character sheet, curses, and Threat' },
    { name: 'explore', description: 'Step deeper into the endless dungeon' },
    { name: 'levelup', description: 'Spend Lust Points on STR / AGI / RES / Level' },
    { name: 'curses', description: 'List your active curses by monster type' },
    { name: 'removecurse', description: 'Spend 50 LP to purge a curse' }
  ].freeze

  module_function

  def payloads
    DEFINITIONS.map do |defn|
      {
        name: defn[:name],
        description: defn[:description],
        type: 1
      }
    end
  end

  # Bulk-overwrite slash commands (one PUT). Prefer REST args; bot is optional fallback.
  def register!(bot = nil, guild_id: nil, token: nil, application_id: nil)
    guild_id ||= ENV['DISCORD_GUILD_ID']
    guild_id = guild_id.to_s.strip
    guild_id = nil if guild_id.empty?

    token ||= bot&.token
    app_id = application_id || bot&.profile&.id
    raise ArgumentError, 'token and application_id (or a connected bot) required' if token.nil? || app_id.nil?

    # Discordrb API expects Authorization: "Bot <token>" (Bot#token already has the prefix).
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
