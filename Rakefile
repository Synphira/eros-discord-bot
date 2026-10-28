# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv/load'
require 'sequel'
require 'rake'

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

namespace :balance do
  desc 'Print combat TTK / climax pressure samples (softcap, HP, Submission lust)'
  task :combat do
    load File.expand_path('tools/balance_combat.rb', __dir__)
    BalanceCombat.report
  end
end

namespace :seasons do
  desc 'List MonsterTypes names missing from each pack MONSTER_ALIASES (optional PACK=halloween)'
  task :monster_alias_gaps do
    require_relative 'lib/engine/seasons'
    %w[
      halloween labor_day thanksgiving christmas new_year
      valentines mardi_gras easter april_fools may_day midsummer pride
    ].each { |pack| require_relative "lib/engine/#{pack}" }
    require_relative 'lib/engine/monster_types'

    keys = ENV['PACK'] ? [ENV['PACK']] : Engine::Seasons.packs.keys
    keys.each do |key|
      pack = Engine::Seasons.pack(key)
      unless pack&.respond_to?(:monster_alias)
        puts "#{key}: (no monster_alias)"
        next
      end
      gaps = Engine::Seasons.monster_alias_gaps(key)
      if gaps.empty?
        puts "#{key}: ok (#{Engine::MonsterTypes.all_names.uniq.size} aliases)"
      else
        puts "#{key}: MISSING #{gaps.size} — #{gaps.join(', ')}"
        exit 1
      end
    end
  end
end
