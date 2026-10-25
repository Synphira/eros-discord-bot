# frozen_string_literal: true

# Copy all table rows from the local SQLite DB into an empty (migrated) Postgres DB.
# Does not copy schema — run `bundle exec rake db:migrate` against Postgres first.
#
#   bundle exec ruby tools/copy_sqlite_to_postgres.rb
#
# Env:
#   SQLITE_URL   — source (default: sqlite://db/eros.db or SQLITE_PATH)
#   DATABASE_URL — destination Postgres URL (required)

require 'bundler/setup'
require 'dotenv/load'
require 'sequel'
require 'fileutils'

dest_url = ENV['DATABASE_URL']
abort 'Set DATABASE_URL to your postgres://… connection string.' if dest_url.to_s.empty? || dest_url.start_with?('sqlite')

src_url = ENV.fetch('SQLITE_URL') do
  path = ENV.fetch('SQLITE_PATH', File.expand_path('../db/eros.db', __dir__))
  "sqlite://#{path}"
end

puts "Source:      #{src_url}"
puts "Destination: #{dest_url.sub(%r{://([^:/@]+):[^@]+@}, '://\1:***@')}"

SRC = Sequel.connect(src_url)
DST = Sequel.connect(dest_url)

skip = %i[schema_info schema_migrations]
tables = SRC.tables - skip
abort 'No tables in SQLite source.' if tables.empty?

tables.each do |table|
  rows = SRC[table].all
  puts "→ #{table} (#{rows.size} rows)"
  DST.transaction do
    DST[table].delete
    rows.each { |row| DST[table].insert(row) }
  end
end

puts 'Done. Point the bot at DATABASE_URL and restart.'
