# frozen_string_literal: true

require 'json'

# ---------------------------------------------------------------------------
# Player — Discord-bound dungeon delver.
#
# Game rules encoded here:
#   • Endless dungeon: climb floors toward the Seal of the Abyss.
#   • Death: floor resets to 1; LP and persistent curses carry over.
#   • LP boosts endurance and fuels 1-turn Overdrive Surges.
#   • High LP raises Threat (see Engine::ThreatCalculator).
# ---------------------------------------------------------------------------
class Player < Sequel::Model(:players)
  # Canonical baseline for Threat % = (lp / MAX_LP_BASE * 100) + ...
  # Treat this as the "expected full" LP pool for threat scaling, not a hard cap.
  MAX_LP_BASE = 100

  plugin :timestamps, update_on_create: true
  set_primary_key :discord_id
  # Discord snowflake is assigned by us on create — allow mass-assignment.
  unrestrict_primary_key

  # many_to_many through player_curses; join model also exposes is_suppressed.
  many_to_many :curses,
               left_key: :player_id,
               right_key: :curse_id,
               join_table: :player_curses

  one_to_many :player_curse_rows,
              class: :PlayerCurse,
              key: :player_id

  plugin :validation_helpers

  def validate
    super
    validates_presence %i[discord_id hp max_hp lp current_floor]
    validates_operator(:>=, 0, :hp)
    validates_operator(:>=, 0, :lp)
    validates_operator(:>=, 1, :current_floor)
  end

  # --- Curse helpers -------------------------------------------------------

  # Active = not suppressed. These count toward Threat.
  def active_curses
    curses_dataset.where(Sequel[:player_curses][:is_suppressed] => false).all
  end

  def suppressed_curses
    curses_dataset.where(Sequel[:player_curses][:is_suppressed] => true).all
  end

  def active_curse_count
    curses_dataset.where(Sequel[:player_curses][:is_suppressed] => false).count
  end

  def max_lp_base
    MAX_LP_BASE
  end

  # --- Life / death --------------------------------------------------------

  # Death: floor → 1; HP restored to max; leave combat.
  # LP and curses intentionally persist across death.
  def die!
    update(current_floor: 1, hp: max_hp, in_combat: false)
  end

  def dead?
    hp <= 0
  end

  # Apply damage; trigger death reset if HP hits 0.
  # Returns a symbol outcome: :survived | :died
  def take_damage!(amount)
    new_hp = [hp - amount, 0].max
    update(hp: new_hp)
    if dead?
      die!
      :died
    else
      :survived
    end
  end

  # Heal up to max_hp.
  def heal!(amount)
    update(hp: [hp + amount, max_hp].min)
  end

  # Spend LP if available. Returns true on success, false if insufficient.
  def spend_lp!(cost)
    return false if lp < cost

    update(lp: lp - cost)
    true
  end

  def gain_lp!(amount)
    update(lp: lp + amount)
  end

  # --- Shrine hooks (stubs for Purge / Suppress) ---------------------------
  # Shrines let players spend LP to Purge (remove) or Suppress a curse.
  # Full Discord wiring comes later; these are the engine entry points.

  # Purge: permanently remove a curse from this player. Costs LP.
  def purge_curse!(curse_id, cost:)
    return { ok: false, error: :insufficient_lp } unless spend_lp!(cost)

    deleted = DB[:player_curses].where(player_id: discord_id, curse_id: curse_id).delete
    if deleted.zero?
      # Refund if the curse was not present.
      gain_lp!(cost)
      return { ok: false, error: :curse_not_found }
    end

    { ok: true, action: :purged, curse_id: curse_id, lp_spent: cost }
  end

  # Suppress: mark curse dormant (no longer counts as active / Threat). Costs LP.
  def suppress_curse!(curse_id, cost:)
    return { ok: false, error: :insufficient_lp } unless spend_lp!(cost)

    updated = DB[:player_curses]
              .where(player_id: discord_id, curse_id: curse_id, is_suppressed: false)
              .update(is_suppressed: true)

    if updated.zero?
      gain_lp!(cost)
      return { ok: false, error: :curse_not_found_or_already_suppressed }
    end

    { ok: true, action: :suppressed, curse_id: curse_id, lp_spent: cost }
  end

  # Afflict the player with a catalog curse (no-op if already owned).
  def afflict!(curse)
    return false if curses_dataset.where(curse_id: curse.id).any?

    DB[:player_curses].insert(
      player_id: discord_id,
      curse_id: curse.id,
      is_suppressed: false,
      acquired_at: Time.now
    )
    true
  end
end

# Lightweight join-row model for the player_curses table.
class PlayerCurse < Sequel::Model(:player_curses)
  many_to_one :player, key: :player_id, primary_key: :discord_id
  many_to_one :curse
end
