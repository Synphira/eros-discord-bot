# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:players) do
      add_column :gender, String, null: false, default: 'Unset'
      add_column :body_parts, String, null: false, default: '[]'
      add_column :level, Integer, null: false, default: 1
      add_column :defiance, Integer, null: false, default: 100
      add_column :lust, Integer, null: false, default: 0
      add_column :strength, Integer, null: false, default: 5
      add_column :agility, Integer, null: false, default: 5
      add_column :resistance, Integer, null: false, default: 5
      add_column :pos_x, Integer, null: false, default: 0
      add_column :pos_y, Integer, null: false, default: 0
    end
  end
end
