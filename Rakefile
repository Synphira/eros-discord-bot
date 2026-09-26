# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv/load'
require 'sequel'
require 'rake'

# ---------------------------------------------------------------------------
# Database migration helpers
#   bundle exec rake db:migrate
#   bundle exec rake db:migrate[0]   # roll back to version 0
# ---------------------------------------------------------------------------

namespace :db do
  desc 'Run Sequel migrations (optional VERSION=, e.g. rake db:migrate[2])'
  task :migrate, [:version] do |_t, args|
    ENV['EROS_SKIP_MODELS'] = '1'
    require 'sequel/extensions/migration'
    require_relative 'config/database'

    migrations_path = File.expand_path('db/migrations', __dir__)
    version = args[:version]&.to_i

    if version
      puts "Migrating to version #{version}..."
      Sequel::Migrator.run(DB, migrations_path, target: version)
    else
      puts 'Migrating to latest...'
      Sequel::Migrator.run(DB, migrations_path)
    end

    puts "Current schema version: #{DB[:schema_info].get(:version)}"
  end

  desc 'Print current schema version'
  task :version do
    ENV['EROS_SKIP_MODELS'] = '1'
    require_relative 'config/database'
    puts DB.table_exists?(:schema_info) ? DB[:schema_info].get(:version) : 'none'
  end
end

namespace :commands do
  desc 'Register (bulk-overwrite) Discord slash commands. Optional DISCORD_GUILD_ID for instant guild sync.'
  task :register do
    load File.expand_path('register_commands.rb', __dir__)
  end
end
