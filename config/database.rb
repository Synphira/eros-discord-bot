# frozen_string_literal: true

require 'sequel'
require 'logger'
require 'fileutils'

# ---------------------------------------------------------------------------
# SQLite connection for E.R.O.S.
#
# Prefers DATABASE_URL (e.g. sqlite://db/eros.db). Falls back to
# SQLITE_PATH or the default path under db/eros.db.
# ---------------------------------------------------------------------------

db_url = ENV.fetch('DATABASE_URL') do
  path = ENV.fetch('SQLITE_PATH', File.expand_path('../db/eros.db', __dir__))
  # Ensure the parent directory exists before Sequel opens the file.
  FileUtils.mkdir_p(File.dirname(path))
  "sqlite://#{path}"
end

# Ensure directory exists for sqlite:// relative/absolute paths
if db_url.start_with?('sqlite://')
  path = db_url.delete_prefix('sqlite://')
  FileUtils.mkdir_p(File.dirname(path)) unless path == ':memory:'
end

DB = Sequel.connect(db_url)

# Helpful SQL logging in development
DB.loggers << Logger.new($stdout) if ENV['EROS_SQL_LOG'] == '1'

# Load models once the connection is ready. Migrations do not need models,
# so callers that only migrate may skip requiring this file's model requires
# by setting EROS_SKIP_MODELS=1.
unless ENV['EROS_SKIP_MODELS'] == '1'
  require_relative '../lib/models/player'
  require_relative '../lib/models/curse'
end
