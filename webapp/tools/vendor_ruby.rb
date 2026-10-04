# frozen_string_literal: true

# Downloads the Ruby runtime into webapp/vendor/ so the game loads without a
# CDN (needed for itch.io uploads). Safe to re-run; pass --force to refresh.
#
#   ruby webapp/tools/vendor_ruby.rb [--force]

require 'fileutils'
require 'net/http'
require 'uri'

VENDOR = File.expand_path('../vendor', __dir__)
CDN = 'https://cdn.jsdelivr.net/npm'
SHIM_PATH = '/npm/@bjorn3/browser_wasi_shim@0.4.2/+esm'

FILES = {
  'ruby-stdlib.wasm' => "#{CDN}/@ruby/3.4-wasm-wasi@2.10.1/dist/ruby+stdlib.wasm",
  'ruby-wasm-wasi.js' => "#{CDN}/@ruby/wasm-wasi@2.10.1/dist/browser/+esm",
  'browser_wasi_shim.js' => "https://cdn.jsdelivr.net#{SHIM_PATH}"
}.freeze

def fetch(url, limit = 5)
  raise "too many redirects for #{url}" if limit.zero?

  response = Net::HTTP.get_response(URI(url))
  case response
  when Net::HTTPSuccess then response.body
  when Net::HTTPRedirection then fetch(URI.join(url, response['location']).to_s, limit - 1)
  else raise "#{url} -> HTTP #{response.code}"
  end
end

force = ARGV.include?('--force')
FileUtils.mkdir_p(VENDOR)
FILES.each do |name, url|
  path = File.join(VENDOR, name)
  next puts("have #{name}") if File.size?(path) && !force

  body = fetch(url)
  if name == 'ruby-wasm-wasi.js'
    abort 'vendor: loader no longer imports the expected shim; update SHIM_PATH' unless body.include?(SHIM_PATH)
    body = body.gsub(SHIM_PATH, './browser_wasi_shim.js')
  end
  if name.end_with?('.js') && body.match?(%r{from\s*"/npm/})
    abort "vendor: #{name} imports another CDN module; vendor it too"
  end
  File.binwrite(path, body)
  puts "saved #{name} (#{(body.bytesize / 1024.0 / 1024).round(1)} MB)"
end
