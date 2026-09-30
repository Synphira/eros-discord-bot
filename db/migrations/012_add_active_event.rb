# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:players) do
      add_column :active_event, String, text: true, null: true
    end
  end
end
