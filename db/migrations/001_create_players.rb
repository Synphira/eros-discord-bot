# frozen_string_literal: true

# Players are keyed by Discord snowflake IDs (64-bit). Persist LP across
# deaths; floor resets to 1 on death while LP and curses carry over.
Sequel.migration do
  change do
    create_table(:players) do
      # Discord user snowflake — fits in a signed 64-bit integer (Bignum).
      Bignum :discord_id, primary_key: true

      Integer :hp, null: false, default: 100
      Integer :max_hp, null: false, default: 100

      # Lust / Life Pressure points. Boosts endurance and fuels Overdrive Surges.
      # High LP also raises Threat (see ThreatCalculator).
      Integer :lp, null: false, default: 0

      # Endless dungeon floor. Resets to 1 on death; LP & curses persist.
      Integer :current_floor, null: false, default: 1

      # True while an encounter is active (gates Use Surge / combat resolve).
      TrueClass :in_combat, null: false, default: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
