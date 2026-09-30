# frozen_string_literal: true

module ErosHelpers
  module_function

  def find_player(discord_id)
    Player[discord_id]
  end

  def require_player(event)
    player = find_player(event.user.id)
    return player if player

    ErosUI.reply_v2(event, ephemeral: true) do |c|
      c.text_display(content: 'No profile yet. Use `/create` or `!create` to descend into the Abyss.')
    end
    nil
  end

  def assert_button_owner!(event)
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
