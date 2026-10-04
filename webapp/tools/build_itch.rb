# frozen_string_literal: true

# Builds a ready-to-upload itch.io HTML5 zip in webapp/dist/:
# syncs the bot engine, bundles the Ruby runtime, runs a quick smoke test,
# then zips index.html, css/, js/, ruby/ and vendor/ with index.html at the root.
#
#   ruby webapp/tools/build_itch.rb [--skip-test]

require 'fileutils'
require 'zlib'

WEBAPP = File.expand_path('..', __dir__)
DIST = File.join(WEBAPP, 'dist')
INCLUDE = %w[index.html css js ruby vendor].freeze

def run!(*cmd)
  system(RbConfig.ruby, *cmd) or abort "build: `#{cmd.join(' ')}` failed"
end

# Minimal zip writer (deflate, forward-slash paths, UTF-8 names).
class ZipWriter
  def initialize(path)
    @io = File.open(path, 'wb')
    @entries = []
  end

  def add(name, data)
    deflater = Zlib::Deflate.new(Zlib::BEST_COMPRESSION, -Zlib::MAX_WBITS)
    packed = deflater.deflate(data, Zlib::FINISH)
    deflater.close
    method = packed.bytesize < data.bytesize ? 8 : 0
    packed = data if method.zero?
    entry = { name: name.b, crc: Zlib.crc32(data), size: data.bytesize, packed: packed.bytesize,
              method: method, offset: @io.pos }
    @io.write([0x04034b50, 20, 0x0800, method, 0, 0x21, entry[:crc], entry[:packed], entry[:size],
               entry[:name].bytesize, 0].pack('VvvvvvVVVvv'), entry[:name], packed)
    @entries << entry
  end

  def close
    start = @io.pos
    @entries.each do |e|
      @io.write([0x02014b50, 20, 20, 0x0800, e[:method], 0, 0x21, e[:crc], e[:packed], e[:size],
                 e[:name].bytesize, 0, 0, 0, 0, 0, e[:offset]].pack('VvvvvvvVVVvvvvvVV'), e[:name])
    end
    size = @io.pos - start
    @io.write([0x06054b50, 0, 0, @entries.size, @entries.size, size, start, 0].pack('VvvvvVVv'))
    @io.close
  end
end

run!(File.join(__dir__, 'sync_from_bot.rb'))
run!(File.join(__dir__, 'vendor_ruby.rb'))
run!(File.join(WEBAPP, 'test', 'smoke.rb'), '800') unless ARGV.include?('--skip-test')

files = INCLUDE.flat_map do |entry|
  path = File.join(WEBAPP, entry)
  File.directory?(path) ? Dir.glob('**/*', base: path).map { |f| "#{entry}/#{f}" } : [entry]
end
files = files.select { |f| File.file?(File.join(WEBAPP, f)) }.sort
abort 'build: index.html missing' unless files.include?('index.html')
abort 'build: Ruby runtime missing from vendor/' unless files.include?('vendor/ruby-stdlib.wasm')

FileUtils.mkdir_p(DIST)
zip_path = File.join(DIST, "endless-ruins-web-#{Time.now.strftime('%Y-%m-%d')}.zip")
FileUtils.rm_f(zip_path)
zip = ZipWriter.new(zip_path)
files.each { |f| zip.add(f, File.binread(File.join(WEBAPP, f))) }
zip.close

puts "Built #{zip_path} (#{files.size} files, #{(File.size(zip_path) / 1024.0 / 1024).round(1)} MB)"
