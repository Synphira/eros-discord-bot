# frozen_string_literal: true

# Cursed living gear + treasure chest loot.
Sequel.migration do
  change do
    alter_table(:equipment) do
      add_column :cursed, TrueClass, null: false, default: false
      add_column :violation_type, String, null: true
      add_column :removal_cost, Integer, null: false, default: 0
    end
  end
end
