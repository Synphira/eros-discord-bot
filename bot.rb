# frozen_string_literal: true

# Endless Ruins of Sin
# Discord entrypoint: boots the bot and loads command handlers.
#
# Slash commands are registered separately (avoids Discord rate limits on restart):
#   bundle exec rake commands:register
#
# Handlers live under commands/ — slash + prefix share the same run().

require 'bundler/setup'
require 'dotenv/load'
require 'discordrb'
require 'fileutils'

require_relative 'config/database'
require_relative 'lib/engine/threat_calculator'
require_relative 'lib/engine/monster_types'
require_relative 'lib/engine/monster_scenes'
require_relative 'lib/engine/curse_catalog'
require_relative 'lib/engine/exploration'
require_relative 'lib/engine/combat_engine'
require_relative 'lib/engine/shop'
require_relative 'lib/character_archetypes'
require_relative 'lib/eros_ui'
require_relative 'lib/eros_helpers'

TOKEN = ENV.fetch('DISCORD_TOKEN') do
  warn 'Missing DISCORD_TOKEN. Copy .env.example → .env and set your bot token.'
  exit 1
end

CLIENT_ID = ENV['DISCORD_CLIENT_ID']

bot = Discordrb::Commands::CommandBot.new(
  token: TOKEN,
  client_id: CLIENT_ID,
  prefix: ENV.fetch('BOT_PREFIX', '!'),
  intents: %i[servers server_messages]
)

def refresh_presence!(bot)
  total = bot.servers.values.sum { |server| server.member_count.to_i }
  noun = total == 1 ? 'user' : 'users'
  bot.game = "with #{total} #{noun}"
rescue StandardError => e
  warn "Presence update failed: #{e.message}"
end

Dir[File.expand_path('commands/**/*.rb', __dir__)].sort.each { |path| require path }

[
  Commands::Help,
  Commands::Create,
  Commands::Status,
  Commands::Explore,
  Commands::Combat,
  Commands::LevelUp,
  Commands::Curses,
  Commands::RemoveCurse,
  Commands::Shop,
  Commands::Equipment,
  Commands::Buttons::CreateCharacter,
  Commands::Buttons::ExplorePath,
  Commands::Buttons::Rest,
  Commands::Buttons::Fight,
  Commands::Buttons::Flee,
  Commands::Buttons::Submit,
  Commands::Buttons::LevelUp,
  Commands::Buttons::Curses
].each { |mod| bot.include!(mod) }

bot.ready do |_event|
  begin
    Engine::CurseCatalog.sync_to_db!
    puts "Curse catalog synced (#{Curse.count} curses)."
    
    Engine::Shop.sync_to_db!
    puts "Shop inventory synced (#{Equipment.count} items)."
  rescue StandardError => e
    warn "Curse catalog sync warning: #{e.message}"
    warn "Shop inventory sync warning: #{e.message}"
  end

  refresh_presence!(bot)
  puts "Endless Ruins of Sin online as #{bot.profile&.username}"
  puts 'Slash commands are not re-registered on boot — run: bundle exec rake commands:register'
end

bot.server_create { refresh_presence!(bot) }
bot.server_delete { refresh_presence!(bot) }

# Member counts drift as people join/leave; refresh periodically.
Thread.new do
  loop do
    sleep 300
    refresh_presence!(bot) if bot.connected?
  end
end

puts 'Starting Endless Ruins of Sin Discord bot...'
bot.run
