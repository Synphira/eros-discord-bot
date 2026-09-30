# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:players) do
      add_column :preferences, String, text: true, null: false, default: '{}'
      add_column :body_sizes, String, text: true, null: false, default: '{}'
    end

    create_table(:legacy_progress) do
      Bignum :discord_id, primary_key: true
      String :trackers, text: true, null: false, default: '{}'
      String :titles, text: true, null: false, default: '[]'
      String :achievements, text: true, null: false, default: '[]'
      String :selected_title
      Integer :highest_floor_reached, null: false, default: 1
      String :preferences, text: true, null: false, default: '{}'
      DateTime :saved_at
    end

    trophy_ids = self[:equipment].where(slot: 'trophy').select_map(:id)
    unless trophy_ids.empty?
      seen = {}
      self[:player_equipment].where(equipment_id: trophy_ids, is_equipped: true).order(:id).each do |row|
        if seen[row[:player_id]]
          self[:player_equipment].where(id: row[:id]).update(is_equipped: false)
        else
          seen[row[:player_id]] = true
        end
      end
    end
  end

  down do
    drop_table(:legacy_progress)
    alter_table(:players) do
      drop_column :preferences
      drop_column :body_sizes
    end
  end
end
