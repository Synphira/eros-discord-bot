# frozen_string_literal: true

# Persist in-progress random events (choice / multi-turn) across restarts.
Sequel.migration do
  change do
    alter_table(:players) do
      add_column :active_event, String, text: true, null: true
    end
  end
end
