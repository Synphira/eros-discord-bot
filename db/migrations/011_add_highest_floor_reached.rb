# frozen_string_literal: true

# Lifetime deepest floor for status / prestige (survives run reset).
Sequel.migration do
  change do
    alter_table(:players) do
      add_column :highest_floor_reached, Integer, null: false, default: 1
    end
  end
end
