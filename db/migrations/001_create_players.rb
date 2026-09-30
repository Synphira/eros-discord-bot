# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:players) do
      Bignum :discord_id, primary_key: true

      Integer :hp, null: false, default: 100
      Integer :max_hp, null: false, default: 100

      Integer :lp, null: false, default: 0

      Integer :current_floor, null: false, default: 1

      TrueClass :in_combat, null: false, default: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
