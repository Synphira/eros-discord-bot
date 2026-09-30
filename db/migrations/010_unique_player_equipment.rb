# frozen_string_literal: true

Sequel.migration do
  up do
    duplicates = DB[:player_equipment]
                 .select_group(:player_id, :equipment_id)
                 .select_append { count(id).as(cnt) }
                 .having { count(id) > 1 }
                 .all

    duplicates.each do |group|
      rows = DB[:player_equipment]
             .where(player_id: group[:player_id], equipment_id: group[:equipment_id])
             .order(:id)
             .all
      keep = rows.find { |r| r[:is_equipped] } || rows.first
      drop_ids = rows.map { |r| r[:id] } - [keep[:id]]
      DB[:player_equipment].where(id: drop_ids).delete unless drop_ids.empty?
      if rows.any? { |r| r[:is_equipped] } && !keep[:is_equipped]
        DB[:player_equipment].where(id: keep[:id]).update(is_equipped: true)
      end
    end

    alter_table(:player_equipment) do
      add_index %i[player_id equipment_id], unique: true, name: :player_equipment_unique_item
    end

    name_dups = DB[:equipment]
                .select_group(:name)
                .select_append { count(id).as(cnt) }
                .having { count(id) > 1 }
                .all

    name_dups.each do |group|
      items = DB[:equipment].where(name: group[:name]).order(:id).all
      keep = items.first
      items[1..].each do |dup|
        DB[:player_equipment].where(equipment_id: dup[:id]).update(equipment_id: keep[:id])
        DB[:equipment].where(id: dup[:id]).delete
      end
    end

    alter_table(:equipment) do
      add_index :name, unique: true, name: :equipment_name_unique
    end
  end

  down do
    alter_table(:player_equipment) do
      drop_index :player_equipment_unique_item
    end
    alter_table(:equipment) do
      drop_index :equipment_name_unique
    end
  end
end
