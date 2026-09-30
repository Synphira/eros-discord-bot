# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:players) do
      add_column :phylactery_used, TrueClass, null: false, default: false
      add_column :sanctuary, TrueClass, null: false, default: false
    end
  end
end
