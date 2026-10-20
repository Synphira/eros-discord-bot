# frozen_string_literal: true

module Engine
  # Monster admirers. Satisfy enough monsters of one kind and one of them
  # gets attached: it starts leaving gifts, interfering with its own kind
  # on your behalf — and getting jealous of the others.
  module Admirers
    THRESHOLD = 3
    TYPES_TRACKER = 'admirer_types'
    NAMES_TRACKER = 'admirer_names'

    module_function

    def count(player, type)
      player.tracker("admirer_#{type}")
    end

    def types(player)
      Array(player.tracker_hash[TYPES_TRACKER]).map(&:to_s)
    end

    def admirer?(player, type)
      types(player).include?(type.to_s)
    end

    def name_for(player, type)
      names = player.tracker_hash[NAMES_TRACKER]
      names.is_a?(Hash) ? names[type.to_s] : nil
    end

    def record_satisfaction!(player, enc, log)
      type = enc[:type].to_s
      return if type.empty?

      player.bump_tracker!("admirer_#{type}")
      return unless count(player, type) >= THRESHOLD && !admirer?(player, type)

      player.update(trackers: player.tracker_hash.merge(
                      TYPES_TRACKER => types(player) + [type],
                      NAMES_TRACKER => (player.tracker_hash[NAMES_TRACKER] || {}).merge(type => enc[:name].to_s)
                    ))
      log << "💌 **A monster has become your admirer!** The **#{enc[:name]}** you pleased so thoroughly now " \
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
        lines << "💌 Your admirer, the **#{name_for(player, type) || enc[:name]}**, has been here before you — " \
                 'the foe is already flustered, distracted, and weaker for it. _(foe STR reduced)_'
        return
      end

      jealous = (types(player) - [type]).first
      return unless jealous && rand < 0.2

      enc[:lust_damage] = (enc[:lust_damage].to_i * 1.1).round
      lines << "💌 Your admirer (the **#{name_for(player, jealous)}**) smells another kind on you and sulks — " \
               'word spreads, and this foe presses you harder out of spite. _(foe lust hit up)_'
    end

    # Called on victory: admirers leave gifts for delvers who survive.
    def gift!(player, log)
      owned = types(player)
      return if owned.empty? || rand >= 0.25

      type = owned.sample
      lp = 10 + player.current_floor
      player.gain_lp!(lp)
      log << "💌 A gift from your **#{name_for(player, type) || type}** admirer waits where you can find it — " \
             "**+#{lp} LP**, still warm."
    end
  end
end
