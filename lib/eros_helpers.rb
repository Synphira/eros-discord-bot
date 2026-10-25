# frozen_string_literal: true

require 'json'

module ErosHelpers
  module_function

  # Inside a server, the bot only answers in NSFW channels. Direct
  # messages are between the delver and the tower, and always allowed.
  # An age-restricted server (guild nsfw_level 3) marks every channel
  # in it, whatever each channel's own flag says.
  AGE_RESTRICTED_SERVER = 3

  def channel_blocked?(event)
    return false unless event.respond_to?(:channel) && event.channel
    return false unless event.respond_to?(:server) && event.server
    return false if nsfw_channel?(event.channel)
    return false if age_restricted_server?(event)

    true
  rescue StandardError
    false
  end

  def nsfw_level_cache
    @nsfw_level_cache ||= {}
  end

  def cache_nsfw_level(server_id, level)
    nsfw_level_cache[server_id.to_i] = level
  end

  def age_restricted_server?(event)
    server = event.server
    return false unless server

    level = nsfw_level_cache[server.id.to_i]
    if level.nil?
      level = fetch_nsfw_level(event, server.id)
      cache_nsfw_level(server.id, level) unless level.nil?
    end
    level == AGE_RESTRICTED_SERVER
  rescue StandardError
    false
  end

  # discordrb's Server object never parses the guild's nsfw_level, so
  # ask the API once per server and remember the answer.
  def fetch_nsfw_level(event, server_id)
    return nil unless event.respond_to?(:bot) && event.bot

    raw = Discordrb::API::Server.resolve(event.bot.token, server_id)
    JSON.parse(raw.to_s)['nsfw_level']&.to_i
  rescue StandardError
    nil
  end

  # Discord omits the nsfw flag on thread objects (forum posts and
  # channel threads), where the age gate lives on the parent channel
  # instead — so a thread counts when its parent is marked.
  def nsfw_channel?(channel)
    return false unless channel.respond_to?(:nsfw?)
    return true if channel.nsfw?

    if channel.respond_to?(:thread?) && channel.thread?
      parent = channel.parent
      return true if parent && parent.respond_to?(:nsfw?) && parent.nsfw?
    end
    false
  rescue StandardError
    false
  end

  # Blocked attempts are worth one console line each: channel type and
  # raw nsfw value are exactly what diagnoses a gate that misreads a
  # channel shape.
  def log_blocked!(event, via)
    channel = event.channel
    warn "[channel-gate] blocked #{via} in channel #{channel&.id} " \
         "(type=#{channel&.type.inspect} nsfw=#{channel&.nsfw.inspect} " \
         "thread=#{channel.respond_to?(:thread?) ? channel.thread? : '?'}) " \
         "guild=#{event.server&.id} guild_nsfw_level=#{nsfw_level_cache[event.server&.id.to_i].inspect}"
  rescue StandardError
    nil
  end

  # For interactions: explains the refusal privately and returns true
  # when the caller must stop. Prefix commands never reach this — the
  # dispatch gate in bot.rb ignores them silently instead.
  def guard_channel!(event)
    return false unless channel_blocked?(event)

    log_blocked!(event, 'interaction')
    ErosUI.reply_v2(event, ephemeral: true) do |c|
      c.text_display(
        content: 'The tower only answers in **NSFW channels** inside a server — or right here, ' \
                 'in direct messages. Take it somewhere appropriate, delver.'
      )
    end
    true
  end

  def find_player(discord_id)
    Player[discord_id]
  end

  def require_player(event)
    return nil if guard_channel!(event)

    Engine::SupportTag.observe!(event.user) if defined?(Engine::SupportTag)

    player = find_player(event.user.id)
    return player if player

    ErosUI.reply_v2(event, ephemeral: true) do |c|
      c.text_display(content: 'No profile yet. Use `/create` or `e,create` to descend into the Abyss.')
    end
    nil
  end

  def assert_button_owner!(event)
    return false if guard_channel!(event)

    owner_id = button_owner_id(event.custom_id)
    unless owner_id
      ErosUI.reply_v2(event, ephemeral: true) do |c|
        c.text_display(content: 'That panel is outdated. Run the command again.')
      end
      return false
    end

    return true if owner_id == event.user.id

    ErosUI.reply_v2(event, ephemeral: true) do |c|
      c.text_display(content: "That's not your panel — only the delver who opened it can use these buttons.")
    end
    false
  end

  def button_owner_id(custom_id)
    last = custom_id.to_s.split(':').last
    return nil unless last&.match?(/\A\d{5,}\z/)

    last.to_i
  end
end

module Eros
  ENCOUNTERS = {}

  module_function

  def encounter_for(player)
    id = player.discord_id
    player.refresh if player.respond_to?(:refresh)

    data = player.reconcile_encounter!
    if data
      ENCOUNTERS[id] = data
    else
      ENCOUNTERS.delete(id)
    end
    data
  end

  def set_encounter!(player, snapshot)
    snap =
      if snapshot.is_a?(Hash)
        snapshot.transform_keys(&:to_sym)
      else
        Engine::CombatEngine.encounter_snapshot(snapshot)
      end
    player.store_encounter!(snap)
    ENCOUNTERS[player.discord_id] = snap
    snap
  end

  def clear_encounter!(player)
    player.clear_encounter!
    ENCOUNTERS.delete(player.discord_id)
  end
end
