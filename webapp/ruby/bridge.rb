# frozen_string_literal: true

# Glue between the browser and the game. In ruby.wasm the `js` library is
# available; under plain CRuby (tests) saves are kept in memory instead.
begin
  require 'js'
rescue LoadError
  nil
end

module Eros
  module Bridge
    SAVE_KEY = 'eros_webapp_save_v1'
    CODE_PREFIX = 'EROS1:'

    module_function

    def browser? = defined?(JS) && JS.respond_to?(:global)

    def read_save
      return @memory unless browser?

      value = JS.global[:localStorage].call(:getItem, SAVE_KEY)
      value.typeof == 'string' ? value.to_s : nil
    end

    def write_save(json)
      return @memory = json unless browser?

      storage = JS.global[:localStorage]
      json ? storage.call(:setItem, SAVE_KEY, json) : storage.call(:removeItem, SAVE_KEY)
    end

    def game
      @game ||= Game.new(read_save)
    end

    def export_code
      CODE_PREFIX + [game.save_json].pack('m0')
    end

    # Returns an error message, or nil after replacing the current game.
    def import_code(code)
      raw = code.to_s.gsub(/\s+/, '')
      return 'That is not an Endless Ruins save code.' unless raw.start_with?(CODE_PREFIX)

      json = raw.delete_prefix(CODE_PREFIX).unpack1('m0').force_encoding('UTF-8')
      data = JSON.parse(json)
      unless data.is_a?(Hash) && data['v'] == Game::SAVE_VERSION && (data['player'].is_a?(Hash) || data['legacy'])
        return 'That save code is from an incompatible version or is empty.'
      end

      @game = Game.new(json)
      nil
    rescue ArgumentError, JSON::ParserError
      'That save code is damaged. Copy the whole code and try again.'
    end

    # Called from JavaScript with a JSON string; returns a JSON string.
    def handle(json)
      input = JSON.parse(json)
      view =
        case input['action']
        when 'export_save'
          game.handle({ 'action' => 'init' }).merge(export: export_code)
        when 'import_save'
          error = import_code(input['value'])
          notice = error || 'Save imported. Welcome back.'
          game.handle({ 'action' => 'init' }, notice: notice).merge(error ? { import_prompt: true } : {})
        when 'import_prompt'
          game.handle({ 'action' => 'init' }).merge(import_prompt: true)
        else
          game.handle(input)
        end
      write_save(game.save_json)
      JSON.generate(view)
    rescue StandardError => e
      JSON.generate(error: "#{e.class}: #{e.message}", backtrace: e.backtrace&.first(8))
    end

    def handle_from_js
      handle(JS.global[:erosInput].to_s)
    end
  end
end
