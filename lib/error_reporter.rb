# frozen_string_literal: true

require 'fileutils'

module ErrorReporter
  ROOT = File.expand_path('..', __dir__)
  LOG_FILE = File.join(ROOT, 'logs', 'errors.log')
  RULE = '=' * 70
  REPOST_WINDOW = 60
  DISCORD_LIMIT = 2000

  @bot = nil
  @recent = {}
  @lock = Mutex.new

  HINTS = [
    [/cannot exceed 40/i, 'A panel has more than 40 components (text blocks, dividers, buttons, rows). Trim what that screen renders.'],
    [/4000|content.*length|must be 4000/i, 'A message has more than 4000 characters of text. Shorten or split the content.'],
    [/Unknown interaction|10062/i, 'Discord expired the interaction: the bot took longer than 3 seconds to respond, or responded twice.'],
    [/already been acknowledged|40060/i, 'The interaction was answered twice (e.g. respond after update).'],
    [/Missing Access|Missing Permissions|50001|50013/i, 'The bot lacks permission in that channel or server.'],
    [/custom_id.*(duplicate|unique)|must be unique/i, 'Two components on one panel share the same custom_id.'],
    [/options.*25|must be less than or equal to 25/i, 'A select menu has more than 25 options.'],
    [/SQLite3|Sequel::/, 'Database error. Check that migrations are applied (`bundle exec rake db:migrate`).'],
    [/NoMethodError|NameError/, 'Code bug: something was called on the wrong kind of object (often nil).']
  ].freeze

  module_function

  def with_context(text)
    previous = Thread.current[:eros_context]
    Thread.current[:eros_context] = text
    yield
  ensure
    Thread.current[:eros_context] = previous
  end

  def describe_event(event)
    user = event.respond_to?(:user) && event.user ? "#{event.user.respond_to?(:username) ? event.user.username : '?'} (#{event.user.id})" : 'unknown user'
    what =
      if event.respond_to?(:custom_id) && event.custom_id
        kind = event.class.name.to_s.split('::').last.sub(/Event\z/, '')
        "#{kind} `#{event.custom_id}`"
      elsif event.is_a?(Discordrb::Events::ApplicationCommandEvent)
        "slash /#{event.command_name}"
      elsif event.respond_to?(:message) && event.message.respond_to?(:content)
        "message \"#{event.message.content.to_s[0, 60]}\""
      else
        event.class.name.to_s.split('::').last
      end
    "#{what} by #{user}"
  rescue StandardError
    event.class.name.to_s
  end

  def project_frames(backtrace)
    Array(backtrace).select { |l| l.start_with?(ROOT) || l.include?(ROOT.tr('\\', '/')) }
                    .map { |l| l.sub(%r{\A.*?eros-discord-bot[/\\]}, '').sub(/:in /, '  in ') }
  end

  def report(error)
    message = error.message.to_s.lines.map(&:strip).reject(&:empty?).join(' — ')
    frames = project_frames(error.backtrace)
    hidden = Array(error.backtrace).size - frames.size
    hint = HINTS.find { |pattern, _| pattern.match?("#{error.class} #{message}") }&.last

    lines = [
      RULE,
      "ERROR  #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}",
      "What:     #{error.class}: #{message}",
      "Trigger:  #{Thread.current[:eros_context] || 'background / not tied to a command'}",
      "Where:    #{frames.first || '(inside a gem — see trace)'}"
    ]
    lines << "Hint:     #{hint}" if hint
    if frames.size > 1
      lines << 'Our code (most recent first):'
      frames.first(8).each { |f| lines << "  #{f}" }
    end
    lines << "  (+#{hidden} library frames hidden; full trace in logs/errors.log)" if hidden.positive?
    lines << RULE
    text = lines.join("\n")

    $stderr.puts("\n#{text}\n")
    write_file(text, error)
    post_to_discord(text, "#{error.class}|#{frames.first}|#{message[0, 120]}")
  rescue StandardError => e
    warn "ErrorReporter failed (#{e.class}: #{e.message}); original: #{error.class}: #{error.message}"
  end

  def attach(bot)
    @bot = bot
  end

  def env_id(key)
    raw = ENV.fetch(key, '').strip
    raw.match?(/\A\d+\z/) ? raw.to_i : nil
  end

  def error_channel
    channel_id = env_id('ERROR_CHANNEL_ID')
    return nil unless @bot && channel_id

    channel = @bot.channel(channel_id)
    guild_id = env_id('ERROR_GUILD_ID')
    return nil if channel.nil? || (guild_id && channel.server&.id != guild_id)

    channel
  end

  def throttle(signature)
    @lock.synchronize do
      now = Time.now
      @recent.delete_if { |_, v| now - v[:at] > REPOST_WINDOW * 10 }
      entry = @recent[signature]
      if entry && now - entry[:at] < REPOST_WINDOW
        entry[:suppressed] += 1
        return nil
      end

      repeats = entry ? entry[:suppressed] : 0
      @recent[signature] = { at: now, suppressed: 0 }
      repeats
    end
  end

  def post_to_discord(text, signature)
    return unless @bot && env_id('ERROR_CHANNEL_ID')

    repeats = throttle(signature)
    return if repeats.nil?

    Thread.new do
      channel = error_channel
      if channel
        body = text.gsub('```', "'''")
        note = repeats.positive? ? "\n-# Also happened #{repeats} more time(s) since the last post." : ''
        room = DISCORD_LIMIT - note.size - 12
        body = "#{body[0, room - 20]}\n… (truncated)" if body.size > room
        channel.send_message("```\n#{body}\n```#{note}", false, nil, nil, { parse: [] })
      else
        warn '[error channel] ERROR_CHANNEL_ID not reachable (wrong ID, wrong server, or bot lacks access).'
      end
    rescue StandardError => e
      warn "[error channel] Posting failed: #{e.class}: #{e.message.to_s.lines.first&.strip}"
    end
  end

  def write_file(text, error)
    FileUtils.mkdir_p(File.dirname(LOG_FILE))
    File.open(LOG_FILE, 'a') do |f|
      f.puts(text)
      f.puts('Full trace:')
      Array(error.backtrace).each { |l| f.puts("  #{l}") }
      f.puts
    end
  end

  module HandlerContext
    def call(event)
      ErrorReporter.with_context(ErrorReporter.describe_event(event)) { super }
    end
  end

  module LoggerPatch
    def log_exception(error)
      ErrorReporter.report(error)
    end
  end
end

Discordrb::Events::EventHandler.prepend(ErrorReporter::HandlerContext)
Discordrb::Logger.prepend(ErrorReporter::LoggerPatch)
