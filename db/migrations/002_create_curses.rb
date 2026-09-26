# frozen_string_literal: true

# Catalog of dungeon curses. Categories match the E.R.O.S. setting bible.
# stat_modifier_json stores flexible per-curse modifiers as a JSON object.
Sequel.migration do
  change do
    create_table(:curses) do
      primary_key :id

      String :name, null: false, unique: true

      # Viscous | Infernal | Wild | Abyssal | Botanical | Necrotic | Mimetic
      String :category, null: false

      String :description, text: true, null: false, default: ''

      # e.g. {"endurance": -5, "threat_bonus": 10}
      String :stat_modifier_json, text: true, null: false, default: '{}'

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
