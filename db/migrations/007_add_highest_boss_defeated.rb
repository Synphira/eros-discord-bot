# frozen_string_literal: true

# Track which boss floors have been cleared this run so explore
# doesn't re-trigger the same boss on floors 5/10/15...
Sequel.migration do
  change do
    alter_table(:players) do
      add_column :highest_boss_defeated, Integer, null: false, default: 0
    end
  end
end
