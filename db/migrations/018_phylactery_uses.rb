# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:players) do
      add_column :phylactery_uses, Integer, null: false, default: 0
    end

    self[:players].where(phylactery_used: true).update(phylactery_uses: 1)
  end

  down do
    alter_table(:players) do
      drop_column :phylactery_uses
    end
  end
end
