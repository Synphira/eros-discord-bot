# frozen_string_literal: true

# Loads the webapp's Ruby the same way js/main.js does: every file in
# manifest.json, in order, evaluated at the top level.
require 'json'

RUBY_DIR = File.expand_path('../ruby', __dir__)
SKIP = Array(defined?(BOOT_SKIP) ? BOOT_SKIP : [])

JSON.parse(File.read(File.join(RUBY_DIR, 'manifest.json'))).each do |file|
  next if SKIP.include?(file)

  eval(File.read(File.join(RUBY_DIR, file), encoding: 'UTF-8'), TOPLEVEL_BINDING, file) # rubocop:disable Security/Eval
end
