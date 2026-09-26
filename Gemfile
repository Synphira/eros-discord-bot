# frozen_string_literal: true

source 'https://rubygems.org'

ruby '>= 3.1.0'

# Discord API client with slash commands, buttons, and CommandBot
gem 'discordrb', '~> 3.5'

# ORM + SQLite persistence for player/curse state
gem 'sequel', '~> 5.0'
gem 'sqlite3', '~> 1.7'

# Load DISCORD_TOKEN / DATABASE_URL from .env in development
gem 'dotenv', '~> 3.0'

# Rake tasks for Sequel migrations (bundle exec rake db:migrate)
gem 'rake', '~> 13.0'

group :development do
  gem 'rubocop', require: false
end
