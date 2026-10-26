# frozen_string_literal: true

require 'json'

module Engine
  # Discord support-server perks. Tag (User primary_guild) and Server
  # Booster (member role in the support guild) are detected even when the
  # delver is in DMs or another server — as long as they belong to the
  # support guild and wear the tag and/or boost. Web never observes these.
  module SupportBonuses
    DEFAULT_GUILD_ID = 1_552_733_580_067_872_798
    DEFAULT_BOOSTER_ROLE_ID = 1_562_618_450_730_553_354
    INVITE_URL = 'https://discord.gg/fXWCsyCUyU'
    DEFAULT_TAG_MULT = 1.05
    DEFAULT_BOOSTER_MULT = 1.05
    DEFAULT_PRICE_MULT = 0.9
    CACHE_TTL = 300

    SUPPORT_TITLE_KEYS = %w[support_tag support_boost support_beloved].freeze

    @bot = nil
    @lock = Mutex.new
    @state = {}

    module_function

    def install!(bot)
      @bot = bot
    end

    def guild_id
      raw = ENV['SUPPORT_GUILD_ID'].to_s.strip
      raw = ENV['ERROR_GUILD_ID'].to_s.strip if raw.empty?
      id = raw.empty? ? DEFAULT_GUILD_ID : raw.to_i
      id.positive? ? id : DEFAULT_GUILD_ID
    end

    def booster_role_id
      raw = ENV['SUPPORT_BOOSTER_ROLE_ID'].to_s.strip
      id = raw.empty? ? DEFAULT_BOOSTER_ROLE_ID : raw.to_i
      id.positive? ? id : DEFAULT_BOOSTER_ROLE_ID
    end

    def tag_multiplier_value
      mult_from_env('SUPPORT_TAG_LP_MULT', DEFAULT_TAG_MULT)
    end

    def booster_multiplier_value
      mult_from_env('SUPPORT_BOOSTER_LP_MULT', DEFAULT_BOOSTER_MULT)
    end

    def purchase_multiplier_value
      mult_from_env('SUPPORT_BOOSTER_PRICE_MULT', DEFAULT_PRICE_MULT)
    end

    def tag_bonus_percent
      ((tag_multiplier_value - 1.0) * 100).round
    end

    def booster_bonus_percent
      ((booster_multiplier_value - 1.0) * 100).round
    end

    def price_discount_percent
      ((1.0 - purchase_multiplier_value) * 100).round
    end

    # Final LP cost after the booster purchase discount (floored at 1 when base > 0).
    def lp_price(player, base)
      raw = base.to_i
      return raw if raw <= 0

      mult = boosting?(discord_id_of(player)) ? purchase_multiplier_value : 1.0
      [(raw * mult).round, 1].max
    end

    def phylactery_max_uses(player)
      1 + (boosting?(discord_id_of(player)) ? 1 : 0)
    end

    # Refresh tag from the interaction user; refresh booster (and optionally
    # tag via User.resolve) from the support guild when stale or forced.
    # Returns optional title sync lines when a player row is provided.
    def observe!(user, bot: nil, force: false, player: nil)
      return [] unless user

      id = user.respond_to?(:id) ? user.id.to_i : nil
      return [] unless id&.positive?

      bot ||= @bot
      now = Time.now
      entry = @lock.synchronize { @state[id]&.dup }

      # Keep cache across partial interaction payloads (primary_guild is not
      # always present). Interaction can only *confirm* a worn tag; clearing
      # it waits on User.resolve / TTL. Booster always comes from the guild.
      tag = entry ? !!entry[:tag] : false
      booster = entry ? !!entry[:booster] : false
      fetched_at = entry&.dig(:at)
      tag = true if tagged_from_user?(user)

      needs_fetch = force || fetched_at.nil? || (now - fetched_at) >= CACHE_TTL
      if needs_fetch && bot
        remote = fetch_support_state(bot, id)
        if remote
          tag = remote[:tag] if remote.key?(:tag)
          # Re-apply interaction confirmation after a fetch that may have raced.
          tag = true if tagged_from_user?(user)
          booster = remote[:booster]
          fetched_at = now
        elsif entry.nil?
          fetched_at = now
        end
      end

      write_state!(id, tag: tag, booster: booster, at: fetched_at || now)

      player ||= Player[id] if defined?(Player)
      player ? sync_titles!(player) : []
    end

    def tagged?(discord_id)
      !!state_for(discord_id)[:tag]
    end

    def boosting?(discord_id)
      !!state_for(discord_id)[:booster]
    end

    def active_count(player)
      id = discord_id_of(player)
      n = 0
      n += 1 if tagged?(id)
      n += 1 if boosting?(id)
      n
    end

    def lp_multiplier(player)
      id = discord_id_of(player)
      mult = 1.0
      mult *= tag_multiplier_value if tagged?(id)
      mult *= booster_multiplier_value if boosting?(id)
      mult
    end

    def desired_support_title(discord_id)
      id = discord_id.to_i
      tag = tagged?(id)
      boost = boosting?(id)
      return 'support_beloved' if tag && boost
      return 'support_tag' if tag
      return 'support_boost' if boost

      nil
    end

    # Grant/revoke the three support titles to match current tag/boost state.
    def sync_titles!(player)
      return [] unless player

      id = discord_id_of(player)
      desired = desired_support_title(id)
      have = player.earned_titles & SUPPORT_TITLE_KEYS
      want = desired ? [desired] : []

      to_add = want - have
      to_drop = have - want
      return [] if to_add.empty? && to_drop.empty?

      lines = []
      titles = player.earned_titles.dup
      to_drop.each do |key|
        titles.delete(key)
        entry = Engine::TitleSystem.title(key)
        next unless entry

        reason =
          case key
          when 'support_beloved' then 'tag or boost lapsed'
          when 'support_boost' then 'no longer boosting'
          else 'no longer wearing the support tag'
          end
        lines << "**Title removed:** #{entry[:name]} — _#{reason}._"
      end
      to_add.each do |key|
        titles << key unless titles.include?(key)
        entry = Engine::TitleSystem.title(key)
        lines << "**New title unlocked:** #{entry[:name]} — _#{entry[:description]}_ (equip with `/titles`)" if entry
      end

      attrs = { titles: titles }
      if player.selected_title && to_drop.include?(player.selected_title.to_s)
        attrs[:selected_title] = nil
      end
      player.update(attrs)
      lines
    end

    def bonus_lines(player)
      id = discord_id_of(player)
      lines = []

      if tagged?(id)
        lines << "✅ **Support server tag** — **+#{tag_bonus_percent}% LP** from all sources."
      else
        lines << '▫️ **Support server tag** — not equipped.'
      end

      if boosting?(id)
        lines << "✅ **Server booster** — **+#{booster_bonus_percent}% LP** from all sources; " \
                 "**#{price_discount_percent}% off** all LP prices; " \
                 "**+1 Lich's Phylactery** use per run."
      else
        lines << '▫️ **Server booster** — not boosting the support server.'
      end

      lines
    end

    def promo_text
      "You can **wear the support server tag** (+#{tag_bonus_percent}% LP) and/or **boost the support server** " \
        "(+#{booster_bonus_percent}% LP, #{price_discount_percent}% off LP prices, extra Phylactery charge). " \
        'Both apply even in DMs or other servers while you\'re in the support server. ' \
        'Stack them for **Beloved of the Tower**.'
    end

    def tagged_from_user?(user)
      return false unless user

      target = guild_id

      if user.respond_to?(:primary_server)
        ps = user.primary_server
        return false unless ps
        return ps.server_id.to_i == target if ps.respond_to?(:server_id)
      end

      raw =
        if user.respond_to?(:primary_guild)
          user.primary_guild
        elsif user.is_a?(Hash)
          user['primary_guild'] || user[:primary_guild]
        end
      tagged_from_primary_guild?(raw)
    end

    def tagged_from_primary_guild?(raw)
      return false unless raw.is_a?(Hash)

      enabled = raw.key?('identity_enabled') ? raw['identity_enabled'] : raw[:identity_enabled]
      return false unless enabled

      gid = (raw['identity_guild_id'] || raw[:identity_guild_id]).to_i
      gid == guild_id
    end

    def fetch_support_state(bot, user_id)
      result = { booster: false }

      begin
        member = bot.member(guild_id, user_id)
        if member
          role_ids = member.roles.map(&:id)
          # Prefer the configured booster role; premium_since is Discord's
          # native boost flag if the role id ever drifts.
          result[:booster] = role_ids.include?(booster_role_id) ||
                             (member.respond_to?(:boosting?) && member.boosting?)
        else
          result[:booster] = false
        end
      rescue Discordrb::Errors::UnknownUser, Discordrb::Errors::UnknownMember
        result[:booster] = false
      rescue StandardError => e
        warn "[support_bonuses] member lookup failed for #{user_id}: #{e.class}: #{e.message}"
        return nil
      end

      begin
        user_data = JSON.parse(Discordrb::API::User.resolve(bot.token, user_id))
        result[:tag] = tagged_from_primary_guild?(user_data['primary_guild'])
      rescue StandardError => e
        warn "[support_bonuses] user lookup failed for #{user_id}: #{e.class}: #{e.message}"
      end

      result
    end

    def state_for(discord_id)
      id = discord_id.to_i
      return { tag: false, booster: false } unless id.positive?

      @lock.synchronize { (@state[id] || { tag: false, booster: false }).dup }
    end

    def write_state!(discord_id, tag:, booster:, at:)
      id = discord_id.to_i
      return unless id.positive?

      @lock.synchronize do
        @state[id] = { tag: !!tag, booster: !!booster, at: at }
      end
    end

    def discord_id_of(player)
      player.respond_to?(:discord_id) ? player.discord_id : player
    end

    def mult_from_env(key, default)
      raw = ENV[key].to_s.strip
      return default if raw.empty?

      mult = raw.to_f
      mult.positive? ? mult : default
    end

    private_class_method :tagged_from_primary_guild?, :fetch_support_state, :state_for,
                         :write_state!, :discord_id_of, :mult_from_env
  end

  # Back-compat alias for the first tag-only pass.
  SupportTag = SupportBonuses
end
