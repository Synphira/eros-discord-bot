# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:players) do
      add_column :submission, Integer, null: false, default: 0
    end
  end
end
