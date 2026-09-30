# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:players) do
      add_column :character_name, String, null: true
      add_column :current_cycle, Integer, null: false, default: 1
      add_column :selected_title, String, null: true
      add_column :trackers, String, text: true, null: false, default: '{}'
      add_column :titles, String, text: true, null: false, default: '[]'
      add_column :achievements, String, text: true, null: false, default: '[]'
      add_index :character_name, unique: true
    end
  end
end
