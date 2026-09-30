# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:player_curses) do
      primary_key :id

      Bignum :player_id, null: false
      foreign_key [:player_id], :players, key: :discord_id, on_delete: :cascade

      foreign_key :curse_id, :curses, null: false, on_delete: :cascade

      TrueClass :is_suppressed, null: false, default: false

      DateTime :acquired_at, null: false

      index %i[player_id curse_id], unique: true
    end
  end
end
