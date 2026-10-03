# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv/load'
require 'discordrb'
require 'fileutils'

require_relative 'lib/error_reporter'
require_relative 'lib/presence'
require_relative 'config/database'
require_relative 'lib/engine/tower'
require_relative 'lib/engine/title_system'
require_relative 'lib/engine/transformation_system'
require_relative 'lib/engine/chastity_system'
require_relative 'lib/engine/profile_system'
require_relative 'lib/engine/threat_calculator'
require_relative 'lib/engine/monster_types'
require_relative 'lib/engine/monster_scenes'
require_relative 'lib/engine/curse_catalog'
require_relative 'lib/engine/exploration'
require_relative 'lib/engine/combat_engine'
require_relative 'lib/engine/shop'
require_relative 'lib/engine/treasure'
require_relative 'lib/engine/fetish_events'
require_relative 'lib/engine/random_events'
require_relative 'lib/engine/content_options'
require_relative 'lib/engine/extra_events'
require_relative 'lib/engine/dev'
require_relative 'lib/character_archetypes'
require_relative 'lib/eros_ui'
require_relative 'lib/eros_helpers'

TOKEN = ENV.fetch('DISCORD_TOKEN') do
  warn 'Missing DISCORD_TOKEN. Copy .env.example → .env and set your bot token.'
  exit 1
end

CLIENT_ID = ENV['DISCORD_CLIENT_ID']

intents = %i[servers server_messages]
intents << :server_members if Presence.members_intent?

bot = Discordrb::Commands::CommandBot.new(
  token: TOKEN,
  client_id: CLIENT_ID,
  prefix: ENV.fetch('BOT_PREFIX', '!'),
  intents: intents
)
ErrorReporter.attach(bot)

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
  Commands::Restart,
  Commands::Profile,
  Commands::Transformation,
  Commands::Rest,
  Commands::Options,
  Commands::CursedShop,
  Commands::Dev,
  Commands::Buttons::CreateCharacter,
  Commands::Buttons::ExplorePath,
  Commands::Buttons::Fight,
  Commands::Buttons::Flee,
  Commands::Buttons::Submit,
  Commands::Buttons::LevelUp,
  Commands::Buttons::Curses,
  Commands::Buttons::RandomEvent,
  Commands::Buttons::Shop
].each { |mod| bot.include!(mod) }

bot.ready do |_event|
  begin
    Engine::CurseCatalog.sync_to_db!
    puts "Curse catalog synced (#{Curse.count} curses)."
    
    Engine::Shop.sync_to_db!
    Engine::Treasure.sync_to_db!
    Engine::BossFights.sync_trophies!
    puts "Shop / treasure inventory synced (#{Equipment.count} items)."
  rescue StandardError => e
    warn "Curse catalog sync warning: #{e.message}"
    warn "Shop inventory sync warning: #{e.message}"
  end

  puts "Endless Ruins of Sin online as #{bot.profile&.username}"
  puts 'Slash commands are not re-registered on boot — run: bundle exec rake commands:register'
end

Presence.install!(bot)

puts 'Starting Endless Ruins of Sin Discord bot...'
bot.run
