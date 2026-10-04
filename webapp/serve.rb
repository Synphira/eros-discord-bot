# frozen_string_literal: true

# Tiny static file server for local play (no gems needed):
#   ruby webapp/serve.rb        then open http://localhost:8000
require 'socket'

ROOT = File.expand_path(__dir__)
PORT = (ENV['PORT'] || 8000).to_i
TYPES = {
  '.html' => 'text/html; charset=utf-8', '.js' => 'text/javascript; charset=utf-8', '.css' => 'text/css; charset=utf-8',
  '.json' => 'application/json; charset=utf-8', '.rb' => 'text/plain; charset=utf-8', '.wasm' => 'application/wasm',
  '.png' => 'image/png', '.svg' => 'image/svg+xml', '.ico' => 'image/x-icon'
}.freeze

def respond(client, status, type, body)
  client.write("HTTP/1.1 #{status}\r\nContent-Type: #{type}\r\nContent-Length: #{body.bytesize}\r\n" \
               "Cache-Control: no-store\r\nConnection: close\r\n\r\n")
  client.write(body)
end

server = TCPServer.new('127.0.0.1', PORT)
puts "Serving #{ROOT} at http://localhost:#{PORT} (Ctrl+C to stop)"
loop do
  client = server.accept
  begin
    request = client.gets.to_s
    path = request.split[1].to_s.split('?').first.to_s
    path = '/index.html' if path.empty? || path == '/'
    file = File.expand_path(".#{path}", ROOT)
    if file.start_with?("#{ROOT}/") && File.file?(file)
      respond(client, '200 OK', TYPES.fetch(File.extname(file), 'application/octet-stream'), File.binread(file))
    else
      respond(client, '404 Not Found', 'text/plain', 'Not found')
    end
  rescue StandardError => e
    warn "#{e.class}: #{e.message}"
  ensure
    client.close
  end
end
