# frozen_string_literal: true

require 'date'

module Engine
  # Calendar seasons for the temple. Packs register themselves; Weekly and
  # world hooks ask Seasons what is active. Keep-forever rewards live on
  # each pack — seasons only gate earning.
  #
  # Pack contract (module_function):
  #   key, name, window?(now), ends_at(now), weekly -> Hash
  #   optional: dress_line(who), clergy_line(boss, kind), biome_weight_mult(key),
  #             room_weight_mult(kind), monster_alias(base_name), presence_suffix,
  #             chest_bonus!(player), note_submit!(player),
  #             status_consumables(player) -> [{id:, label:, count:}]
  module Seasons
    # Only one week-season weekly at a time. First match wins.
    PRIORITY = %w[
      valentines mardi_gras easter april_fools may_day midsummer pride
      labor_day halloween thanksgiving christmas new_year
    ].freeze

    # Vex rack tiers that are seasonal souvenirs (not basic / restored stock).
    PERMANENT_TIERS = %w[basic restored].freeze

    @packs = {}
    @force_key = nil
    @force_friday13 = false

    module_function

    def register!(key, pack)
      @packs[key.to_s] = pack
    end

    def packs
      @packs.dup
    end

    def pack(key)
      @packs[key.to_s]
    end

    def force!(key)
      key = key&.to_s
      if key.nil? || key.empty? || key == 'auto'
        @force_key = nil
        @force_friday13 = false
        return nil
      end
      if key == 'friday_13'
        @force_friday13 = true
        return 'friday_13'
      end
      @force_key = @packs.key?(key) ? key : nil
      @force_key
    end

    def forced_key
      @force_key
    end

    # Anonymous Gregorian algorithm — Easter Sunday for a given year.
    def easter_sunday(year)
      year = year.to_i
      a = year % 19
      b, c = year.divmod(100)
      d, e = b.divmod(4)
      f = (b + 8) / 25
      g = (b - f + 1) / 3
      h = (19 * a + b - d - g + 15) % 30
      i, k = c.divmod(4)
      l = (32 + 2 * e + 2 * i - h - k) % 7
      m = (a + 11 * h + 22 * l) / 451
      month, day = (h + l - 7 * m + 114).divmod(31)
      Time.new(year, month, day + 1)
    end

    def fat_tuesday(year)
      # Calendar days, not raw seconds — DST would otherwise land a day early.
      easter = easter_sunday(year)
      d = Date.new(easter.year, easter.month, easter.day) - 47
      Time.new(d.year, d.month, d.day)
    end

    # First Monday of September (US Labor Day).
    def labor_day_monday(year)
      year = year.to_i
      day = 1
      wday = Time.new(year, 9, day).wday
      day += (1 - wday) % 7
      Time.new(year, 9, day)
    end

    def friday_13?(now = Time.now)
      return true if @force_friday13

      now.friday? && now.day == 13
    end

    def active(now = Time.now)
      if @force_key && (forced = @packs[@force_key])
        return forced
      end

      PRIORITY.each do |key|
        p = @packs[key]
        next unless p
        return p if p.window?(now)
      end
      nil
    end

    def active?(key = nil, now = Time.now)
      pack = active(now)
      return !pack.nil? if key.nil?

      pack && pack.key.to_s == key.to_s
    end

    def season_keys
      PRIORITY.select { |k| @packs.key?(k) }
    end

    def dress_line(who, now = Time.now)
      pack = active(now)
      return nil unless pack&.respond_to?(:dress_line)

      pack.dress_line(who)
    end

    def clergy_line(boss_name, kind = :victory, now = Time.now)
      pack = active(now)
      return nil unless pack&.respond_to?(:clergy_line)

      pack.clergy_line(boss_name, kind)
    end

    def biome_weight_mult(biome_key, now = Time.now)
      pack = active(now)
      return 1.0 unless pack&.respond_to?(:biome_weight_mult)

      pack.biome_weight_mult(biome_key)
    end

    # Exploration room pool multipliers (:monster, :trap, :treasure, :empty, :stairs).
    def room_weight_mult(kind, now = Time.now)
      pack = active(now)
      return 1.0 unless pack&.respond_to?(:room_weight_mult)

      pack.room_weight_mult(kind).to_f
    end

    # Seasonal display name for a base MonsterTypes roster entry (100% swap while active).
    def monster_alias(base_name, now = Time.now)
      pack = active(now)
      return nil unless pack&.respond_to?(:monster_alias)

      pack.monster_alias(base_name.to_s)
    end

    # Names in MonsterTypes missing from a pack's MONSTER_ALIASES (dev/smoke).
    def monster_alias_gaps(pack_key)
      pack = @packs[pack_key.to_s]
      return [] unless pack&.respond_to?(:monster_alias)

      require_relative 'monster_types' unless defined?(Engine::MonsterTypes)
      Engine::MonsterTypes.all_names.uniq.reject { |n| pack.monster_alias(n).to_s.strip != '' }
    end

    def seasonal_tier?(tier)
      !PERMANENT_TIERS.include?(tier.to_s)
    end

    def holiday_outfit_names
      return [] unless defined?(Engine::Residents::VEX_OUTFITS)

      Engine::Residents::VEX_OUTFITS.select { |s| seasonal_tier?(s[:tier]) }.map { |s| s[:name].to_s }
    end

    def holiday_piece?(name)
      holiday_outfit_names.include?(name.to_s)
    end

    def reconcile_holiday_outfits!(player)
      return [] unless player

      names = holiday_outfit_names
      return [] if names.empty?

      owned = player.equipment.map { |e| e.name.to_s } & names
      have = Array(player.tracker_hash['holiday_outfits']).map(&:to_s)
      merged = (have + owned).uniq
      return have if merged == have

      player.set_tracker!('holiday_outfits', merged)
      merged
    end

    def presence_text(users, towers, now = Time.now)
      base = "with #{users} #{users == 1 ? 'user' : 'users'} in #{towers} #{towers == 1 ? 'tower' : 'towers'}"
      pack = active(now)
      suffix = pack.respond_to?(:presence_suffix) ? pack.presence_suffix : nil
      if friday_13?(now)
        extra = ' — unlucky Friday the 13th in the temple'
        return suffix ? "#{base}#{suffix.sub(/\.\z/, '')}#{extra}." : "#{base}#{extra}."
      end
      return "#{base}." unless suffix

      "#{base}#{suffix}"
    end

    def chest_bonus!(player, now = Time.now)
      pack = active(now)
      return [] unless pack&.respond_to?(:chest_bonus!)

      pack.chest_bonus!(player)
    end

    def note_submit!(player, now = Time.now)
      pack = active(now)
      pack.note_submit!(player) if pack&.respond_to?(:note_submit!)
    end

    def status_consumables(player, _now = Time.now)
      # Stockpiles persist after the season — every pack may report leftovers.
      lines = []
      @packs.each_value do |p|
        next unless p.respond_to?(:status_consumables)

        lines.concat(Array(p.status_consumables(player)))
      end
      lines.uniq { |c| c[:id] }
    end

    def weekly_for(now = Time.now)
      active(now)&.weekly
    end

    def ends_at(now = Time.now)
      active(now)&.ends_at(now)
    end
  end
end
