# frozen_string_literal: true

# Persist mid-fight monster snapshot so combat survives bot restarts.
Sequel.migration do
  change do
    alter_table(:players) do
      add_column :active_encounter, String, text: true, default: nil
    end
  end
end
