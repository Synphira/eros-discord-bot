# frozen_string_literal: true

require 'json'
require 'sequel'
require 'logger'
require 'fileutils'

module Sequel
  module SequelMethods
    def parse_json(json)
      JSON.parse(json)
    end
  end
end

db_url = ENV.fetch('DATABASE_URL') do
  path = ENV.fetch('SQLITE_PATH', File.expand_path('../db/eros.db', __dir__))
  FileUtils.mkdir_p(File.dirname(path))
  "sqlite://#{path}"
end

if db_url.start_with?('sqlite://')
  path = db_url.delete_prefix('sqlite://')
  FileUtils.mkdir_p(File.dirname(path)) unless path == ':memory:'
end

DB = Sequel.connect(db_url)

DB.loggers << Logger.new($stdout) if ENV['EROS_SQL_LOG'] == '1'

unless ENV['EROS_SKIP_MODELS'] == '1'
  require_relative '../lib/models/curse'
  require_relative '../lib/models/equipment'
  require_relative '../lib/models/player'
end
