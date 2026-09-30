# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:players) do
      add_column :highest_boss_defeated, Integer, null: false, default: 0
    end
  end
end
