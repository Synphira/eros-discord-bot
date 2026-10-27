# frozen_string_literal: true

require 'fileutils'

module ErrorReporter
  ROOT = File.expand_path('..', __dir__)
  LOG_FILE = File.join(ROOT, 'logs', 'errors.log')
  RULE = '=' * 70
  REPOST_WINDOW = 60
  EMBED_COLOUR = 0xED4245 # Discord red
  FIELD_LIMIT = 1024
  TITLE_LIMIT = 256
  DESC_LIMIT = 400

  @bot = nil
  @recent = {}
  @lock = Mutex.new

  HINTS = [
    [/cannot exceed 40/i, 'A panel has more than 40 components. Trim what that screen renders.'],
    [/4000|content.*length|must be 4000/i, 'A message has more than 4000 characters. Shorten or split.'],
    [/Unknown interaction|10062/i, 'Interaction expired (>3s) or was answered twice.'],
    [/already been acknowledged|40060/i, 'Interaction answered twice (e.g. respond after update).'],
    [/Missing Access|Missing Permissions|50001|50013/i, 'Bot lacks permission in that channel or server.'],
    [/custom_id.*(duplicate|unique)|must be unique/i, 'Two components share the same custom_id.'],
    [/options.*25|must be less than or equal to 25/i, 'A select menu has more than 25 options.'],
    [/SQLite3|Sequel::/, 'Database error — check migrations (`bundle exec rake db:migrate`).'],
    [/NoMethodError|NameError/, 'Called something on the wrong object (often nil).']
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
    # Discord API errors (e.g. InvalidFormBody) carry field-level details in
    # `errors` — which exact component/field was rejected. Never drop them:
    # "Invalid Form Body" alone does not say what to fix.
    details = error.respond_to?(:errors) ? Array(error.errors).map(&:to_s).reject(&:empty?) : []
    frames = project_frames(error.backtrace)
    hidden = Array(error.backtrace).size - frames.size
    hint = HINTS.find { |pattern, _| pattern.match?("#{error.class} #{message} #{details.join(' ')}") }&.last
    trigger = Thread.current[:eros_context] || 'background / not tied to a command'
    where = frames.first || '(inside a gem — see logs/errors.log)'

    summary = {
      klass: error.class.name.to_s,
      message: message,
      trigger: trigger,
      where: where,
      details: details.first(5),
      hint: hint,
      frames: frames.first(4)
    }

    # Full dump stays on disk / stderr; Discord only gets the compact embed.
    lines = [
      RULE,
      "ERROR  #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}",
      "What:     #{summary[:klass]}: #{message}",
      "Trigger:  #{trigger}",
      "Where:    #{where}"
    ]
    lines << "Details:  #{summary[:details].join(' | ')}" if summary[:details].any?
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
    signature = "#{summary[:klass]}|#{where}|#{message[0, 120]}|#{summary[:details].first.to_s[0, 120]}"
    post_to_discord(summary, signature)
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

  def clip(text, limit)
    text = text.to_s
    return text if text.size <= limit

    "#{text[0, limit - 1]}…"
  end

  def post_to_discord(summary, signature)
    return unless @bot && env_id('ERROR_CHANNEL_ID')

    repeats = throttle(signature)
    return if repeats.nil?

    Thread.new do
      channel = error_channel
      unless channel
        warn '[error channel] ERROR_CHANNEL_ID not reachable (wrong ID, wrong server, or bot lacks access).'
        next
      end

      title = clip(summary[:klass], TITLE_LIMIT)
      desc = clip(summary[:message], DESC_LIMIT)

      # send_embed(message, embed, attachments, tts, allowed_mentions, ...)
      channel.send_embed('', nil, nil, false, { parse: [] }) do |embed, _view|
        embed.title = title
        embed.description = desc unless desc.empty?
        embed.colour = EMBED_COLOUR
        embed.timestamp = Time.now
        embed.add_field(name: 'Trigger', value: clip(summary[:trigger], FIELD_LIMIT), inline: false)
        embed.add_field(name: 'Where', value: "```#{clip(summary[:where], FIELD_LIMIT - 6)}```", inline: false)
        if summary[:details]&.any?
          embed.add_field(name: 'Details', value: clip(summary[:details].join("\n"), FIELD_LIMIT), inline: false)
        end
        if summary[:hint]
          embed.add_field(name: 'Hint', value: clip(summary[:hint], FIELD_LIMIT), inline: false)
        end
        extra = Array(summary[:frames])
        if extra.size > 1
          stack = extra.map { |f| "• #{f}" }.join("\n")
          embed.add_field(name: 'Stack', value: clip(stack, FIELD_LIMIT), inline: false)
        end
        footer = 'Full trace → logs/errors.log'
        footer = "×#{repeats + 1} in last minute · #{footer}" if repeats.positive?
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: footer)
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
