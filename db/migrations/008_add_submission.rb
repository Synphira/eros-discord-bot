# frozen_string_literal: true

# How willing a delver is to submit to monsters (character creation).
Sequel.migration do
  change do
    alter_table(:players) do
      add_column :submission, Integer, null: false, default: 0
    end
  end
end
