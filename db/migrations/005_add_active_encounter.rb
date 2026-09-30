# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:players) do
      add_column :active_encounter, String, text: true, default: nil
    end
  end
end
