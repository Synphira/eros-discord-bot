# frozen_string_literal: true

module Engine
  # Monster admirers. Satisfy enough monsters of one kind and one of them
  # gets attached: it starts leaving gifts, interfering with its own kind
  # on your behalf — and getting jealous of the others.
  module Admirers
    THRESHOLD = 3
    # Rooms an admirer keeps following you before it loses your scent and
    # wanders off — admirers are a passing favour, not a collection.
    LIFESPAN_ROOMS = 20
    # At most this many admirers at once; a newcomer drives off the one
    # closest to losing your scent anyway.
    MAX_ADMIRERS = 3
    TYPES_TRACKER = 'admirer_types'
    NAMES_TRACKER = 'admirer_names'
    ROOMS_TRACKER = 'admirer_rooms'
    TOTAL_TRACKER = 'admirers_total'

    module_function

    def count(player, type)
      player.tracker("admirer_#{type}")
    end

    def types(player)
      Array(player.tracker_hash[TYPES_TRACKER]).map(&:to_s)
    end

    # How many admirers you have right this moment, and how many you have
    # ever had (legacy saves predate the total, so never show fewer than
    # the ones currently following).
    def current_count(player)
      types(player).size
    end

    def total(player)
      [player.tracker(TOTAL_TRACKER), current_count(player)].max
    end

    def rooms_left(player, type)
      rooms = player.tracker_hash[ROOMS_TRACKER]
      rooms.is_a?(Hash) && rooms.key?(type.to_s) ? rooms[type.to_s].to_i : LIFESPAN_ROOMS
    end

    def admirer?(player, type)
      types(player).include?(type.to_s)
    end

    def name_for(player, type)
      names = player.tracker_hash[NAMES_TRACKER]
      names.is_a?(Hash) ? names[type.to_s] : nil
    end

    def rooms_hash(player)
      rooms = player.tracker_hash[ROOMS_TRACKER]
      rooms.is_a?(Hash) ? rooms.transform_keys(&:to_s) : {}
    end

    def set_rooms_left!(player, type, rooms)
      player.update(trackers: player.tracker_hash.merge(ROOMS_TRACKER => rooms_hash(player).merge(type.to_s => rooms)))
    end

    def evict!(player, type)
      names = player.tracker_hash[NAMES_TRACKER]
      names = names.is_a?(Hash) ? names.transform_keys(&:to_s) : {}
      player.update(trackers: player.tracker_hash.merge(
                      TYPES_TRACKER => types(player) - [type.to_s],
                      NAMES_TRACKER => names.reject { |k, _| k == type.to_s },
                      ROOMS_TRACKER => rooms_hash(player).reject { |k, _| k == type.to_s }
                    ))
    end

    # One explored room passes: every admirer's remaining rooms tick down,
    # and any that reach zero lose your scent and vanish. Returns the
    # departed admirers' display names so the caller can say goodbye.
    def tick_rooms!(player)
      owned = types(player)
      return [] if owned.empty?

      rooms = rooms_hash(player)
      departed = []
      kept = owned.select do |type|
        left = (rooms.key?(type) ? rooms[type].to_i : LIFESPAN_ROOMS) - 1
        rooms[type] = left
        departed << type if left <= 0
        left.positive?
      end
      names = player.tracker_hash[NAMES_TRACKER]
      names = names.is_a?(Hash) ? names.transform_keys(&:to_s) : {}
      departed_names = departed.map { |type| names[type] || type }
      player.update(trackers: player.tracker_hash.merge(
                      TYPES_TRACKER => kept,
                      NAMES_TRACKER => names.reject { |k, _| departed.include?(k) },
                      ROOMS_TRACKER => rooms.reject { |k, _| departed.include?(k) }
                    ))
      departed_names
    end

    def record_satisfaction!(player, enc, log)
      type = enc[:type].to_s
      return if type.empty?

      player.bump_tracker!("admirer_#{type}")
      if admirer?(player, type)
        # Pleasing it again reminds it why it follows you: full lifespan anew.
        set_rooms_left!(player, type, LIFESPAN_ROOMS)
        return
      end
      return unless count(player, type) >= THRESHOLD

      if types(player).size >= MAX_ADMIRERS
        evicted = types(player).min_by { |t| rooms_left(player, t) }
        evicted_name = name_for(player, evicted) || evicted
        evict!(player, evicted)
        log << "Your scent is crowded, though — the newcomer drives off your **#{evicted_name}** admirer, " \
               'which slinks away with a last, longing look.'
      end

      player.update(trackers: player.tracker_hash.merge(
                      TYPES_TRACKER => types(player) + [type],
                      NAMES_TRACKER => (player.tracker_hash[NAMES_TRACKER] || {}).merge(type => enc[:name].to_s),
                      ROOMS_TRACKER => rooms_hash(player).merge(type => LIFESPAN_ROOMS)
                    ))
      player.bump_tracker!(TOTAL_TRACKER)
      log << "**A monster has become your admirer!** The **#{enc[:name]}** you pleased so thoroughly now " \
             "follows your scent through the tower. Its kind will go easier on you — and it leaves gifts."
      others = types(player) - [type]
      return if others.empty?

      log << "_Somewhere in the dark, your #{name_for(player, others.first) || 'other admirer'} makes a jealous noise._"
    end

    # Called when a fight starts: a kindred admirer may hamper its own kind.
    def intervene_start!(player, enc, lines)
      type = enc[:type].to_s
      if admirer?(player, type) && rand < 0.35
        enc[:strength] = [(enc[:strength].to_i * 0.85).round, 1].max
        lines << "Your admirer, the **#{name_for(player, type) || enc[:name]}**, has been here before you — " \
                 'the foe is already flustered, distracted, and weaker for it. _(foe STR reduced)_'
        return
      end

      jealous = (types(player) - [type]).first
      return unless jealous && rand < 0.2

      enc[:lust_damage] = (enc[:lust_damage].to_i * 1.1).round
      lines << "Your admirer (the **#{name_for(player, jealous)}**) smells another kind on you and sulks — " \
               'word spreads, and this foe presses you harder out of spite. _(foe lust hit up)_'
    end

    # Called on victory: admirers leave gifts for delvers who survive.
    def gift!(player, log)
      owned = types(player)
      return if owned.empty? || rand >= 0.25

      type = owned.sample
      lp = 10 + player.current_floor
      player.gain_lp!(lp)
      log << "A gift from your **#{name_for(player, type) || type}** admirer waits where you can find it — " \
             "**+#{lp} LP**, still warm."
    end
  end
end
