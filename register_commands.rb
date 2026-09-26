# frozen_string_literal: true

# One-shot slash-command registrar (REST only — no gateway / websocket).
#
#   bundle exec ruby register_commands.rb
#   DISCORD_GUILD_ID=your_guild_id bundle exec ruby register_commands.rb

require 'bundler/setup'
require 'dotenv/load'
require 'discordrb'
require_relative 'config/slash_commands'

TOKEN = ENV.fetch('DISCORD_TOKEN') do
  warn 'Missing DISCORD_TOKEN. Copy .env.example → .env and set your bot token.'
  exit 1
end

APP_ID = ENV.fetch('DISCORD_CLIENT_ID') do
  warn 'Missing DISCORD_CLIENT_ID (Discord application / client id).'
  exit 1
end

puts 'Registering slash commands via Discord REST API...'
begin
  SlashCommands.register!(token: TOKEN, application_id: APP_ID)
rescue Discordrb::Errors::CodeError => e
  warn "Slash registration failed: #{e.message}"
  exit 1
end
