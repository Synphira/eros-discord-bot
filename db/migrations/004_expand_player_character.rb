# frozen_string_literal: true

# Expand players with the Endless Ruins of Sin character sheet:
# gender / body parts, level, defiance, lust, combat stats, dungeon position.
Sequel.migration do
  change do
    alter_table(:players) do
      add_column :gender, String, null: false, default: 'Unset'
      # JSON array of anatomy tags, e.g. ["penis","anus"]
      add_column :body_parts, String, null: false, default: '[]'
      add_column :level, Integer, null: false, default: 1
      # Will to resist corruption / climax pressure (distinct from combat HP).
      add_column :defiance, Integer, null: false, default: 100
      # Current lust meter (0+). Separate from lp (Lust Points currency).
      add_column :lust, Integer, null: false, default: 0
      add_column :strength, Integer, null: false, default: 5
      add_column :agility, Integer, null: false, default: 5
      add_column :resistance, Integer, null: false, default: 5
      add_column :pos_x, Integer, null: false, default: 0
      add_column :pos_y, Integer, null: false, default: 0
    end
  end
end
