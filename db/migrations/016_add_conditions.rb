# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:players) do
      add_column :conditions, String, text: true, null: false, default: '[]'
    end
  end
end
