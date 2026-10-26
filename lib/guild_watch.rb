# frozen_string_literal: true

require 'json'

# Posts join/leave notices to a support-server channel (name, members, owner, icon).
module GuildWatch
  DEFAULT_CHANNEL_ID = 1_564_014_755_595_948_213
  JOIN_COLOUR = 0x57F287  # green
  LEAVE_COLOUR = 0xED4245 # red

  @bot = nil

  module_function

  def install!(bot)
    @bot = bot
    bot.server_create { |event| Thread.new { announce!(:joined, event.server) } }
    bot.server_delete { |event| Thread.new { announce!(:left, event.server) } }
  end

  def channel_id
    raw = ENV['GUILD_LOG_CHANNEL_ID'].to_s.strip
    id = raw.empty? ? DEFAULT_CHANNEL_ID : raw.to_i
    id.positive? ? id : DEFAULT_CHANNEL_ID
  end

  def announce!(kind, server)
    return unless @bot && server

    channel = @bot.channel(channel_id)
    unless channel
      warn "[guild_watch] channel #{channel_id} not reachable (wrong ID or missing access)."
      return
    end

    # Don't log the support server's own join/leave into itself.
    return if server.id == channel.server&.id

    name = server.name.to_s
    name = '(unknown server)' if name.empty?
    members = member_count_of(server)
    owner = owner_label(server)
    icon = icon_url_of(server)

    joined = kind == :joined
    title = joined ? 'Joined a server' : 'Left a server'
    colour = joined ? JOIN_COLOUR : LEAVE_COLOUR

    channel.send_embed do |embed|
      embed.title = title
      embed.colour = colour
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: icon) if icon
      embed.add_field(name: 'Server', value: name, inline: true)
      embed.add_field(name: 'Members', value: members.to_s, inline: true)
      embed.add_field(name: 'Owner', value: owner, inline: true)
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "ID #{server.id}")
      embed.timestamp = Time.now
    end
  rescue StandardError => e
    warn "[guild_watch] announce failed: #{e.class}: #{e.message}"
  end

  def member_count_of(server)
    count = server.respond_to?(:member_count) ? server.member_count.to_i : 0
    return count if count.positive?

    approx = server.respond_to?(:approximate_member_count) ? server.approximate_member_count.to_i : 0
    approx.positive? ? approx : '?'
  rescue StandardError
    '?'
  end

  def owner_label(server)
    begin
      owner = server.owner if server.respond_to?(:owner)
      if owner
        name = owner.respond_to?(:username) ? owner.username.to_s : ''
        return name unless name.empty?
      end
    rescue StandardError
      # fall through to API / id
    end

    oid = server.respond_to?(:owner_id) ? server.owner_id : nil
    return 'unknown' unless oid

    begin
      data = JSON.parse(Discordrb::API::User.resolve(@bot.token, oid))
      name = data['username'].to_s
      return name unless name.empty?
    rescue StandardError
      # keep id fallback
    end

    "unknown (#{oid})"
  end

  def icon_url_of(server)
    return nil unless server.respond_to?(:icon_url)

    url = server.icon_url
    url.is_a?(String) && !url.empty? ? url : nil
  rescue StandardError
    nil
  end

  private_class_method :member_count_of, :owner_label, :icon_url_of
end
