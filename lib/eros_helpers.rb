# frozen_string_literal: true

module ErosHelpers
  module_function

  # Inside a server, the bot only answers in NSFW channels. Direct
  # messages are between the delver and the tower, and always allowed.
  def channel_blocked?(event)
    return false unless event.respond_to?(:channel) && event.channel
    return false unless event.respond_to?(:server) && event.server

    channel = event.channel
    return false unless channel.respond_to?(:nsfw?)

    !channel.nsfw?
  rescue StandardError
    false
  end

  # For interactions: explains the refusal privately and returns true
  # when the caller must stop. Prefix commands never reach this — the
  # dispatch gate in bot.rb ignores them silently instead.
  def guard_channel!(event)
    return false unless channel_blocked?(event)

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
