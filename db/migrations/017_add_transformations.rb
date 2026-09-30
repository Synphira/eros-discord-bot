# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:players) do
      add_column :transformations, String, text: true, null: false, default: '[]'
      add_column :active_transformation, String
    end
    alter_table(:legacy_progress) do
      add_column :transformations, String, text: true, null: false, default: '[]'
      add_column :active_transformation, String
    end
  end
end
