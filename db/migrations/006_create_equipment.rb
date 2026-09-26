Sequel.migration do
  change do
    create_table(:equipment) do
      primary_key :id
      
      String :name, null: false
      String :type, null: false  # weapon, armor, accessory
      String :slot, null: false   # weapon, head, chest, legs, feet, accessory
      String :description, text: true, null: false, default: ''
      String :stat_modifier_json, text: true, null: false, default: '{}'
      
      Integer :cost, null: false, default: 0  # LP cost to buy
      Integer :rarity, null: false, default: 1  # 1-5, affects cost and power
      
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:player_equipment) do
      primary_key :id
      
      Bignum :player_id, null: false
      foreign_key [:player_id], :players, key: :discord_id, on_delete: :cascade
      
      foreign_key :equipment_id, :equipment, null: false, on_delete: :cascade
      
      TrueClass :is_equipped, null: false, default: false
      
      DateTime :acquired_at
    end
  end
end
