# frozen_string_literal: true

require 'json'

module Presence
  DEFAULT_INTERVAL = 120
  MIN_INTERVAL = 30
  DEBOUNCE_SECONDS = 15

  @counts = {}
  @last_text = nil
  @pending = false
  @lock = Mutex.new

  module_function

  def members_intent?
    ENV.fetch('SERVER_MEMBERS_INTENT', '').strip.casecmp?('true')
  end

  def interval
    [ENV.fetch('PRESENCE_REFRESH_SECONDS', DEFAULT_INTERVAL).to_i, MIN_INTERVAL].max
  end

  def text_for(users, towers)
    "with #{users} #{users == 1 ? 'user' : 'users'} in #{towers} #{towers == 1 ? 'tower' : 'towers'}."
  end

  def fetch_counts!(bot)
    fresh = {}
    bot.servers.each_value do |server|
      data = JSON.parse(Discordrb::API::Server.resolve(bot.token, server.id, true))
      fresh[server.id] = data['approximate_member_count'] || server.member_count.to_i
    rescue StandardError
      fresh[server.id] = @counts[server.id] || server.member_count.to_i
    end
    @lock.synchronize { @counts = fresh }
  end

  def apply!(bot, use_cache: false)
    counts = @lock.synchronize { @counts.dup }
    servers = bot.servers
    users = servers.each_value.sum do |s|
      use_cache || !counts.key?(s.id) ? s.member_count.to_i : counts[s.id]
    end
    text = text_for(users, servers.size)
    return if text == @last_text

    bot.game = text
    @last_text = text
  rescue StandardError => e
    warn "[presence] Update failed: #{e.message}"
  end

  def refresh!(bot)
    fetch_counts!(bot)
    apply!(bot)
  end

  def schedule_cached!(bot)
    @lock.synchronize do
      return if @pending

      @pending = true
    end
    Thread.new do
      sleep DEBOUNCE_SECONDS
      @lock.synchronize { @pending = false }
      @lock.synchronize { bot.servers.each_value { |s| @counts[s.id] = s.member_count.to_i } }
      apply!(bot, use_cache: true)
    end
  end

  def install!(bot)
    bot.ready { Thread.new { refresh!(bot) } }
    bot.server_create { Thread.new { refresh!(bot) } }
    bot.server_delete { Thread.new { refresh!(bot) } }
    if members_intent?
      bot.member_join { schedule_cached!(bot) }
      bot.member_leave { schedule_cached!(bot) }
    end

    Thread.new do
      loop do
        sleep interval
        refresh!(bot) if bot.connected?
      rescue StandardError => e
        warn "[presence] Loop error: #{e.message}"
      end
    end
  end
end
