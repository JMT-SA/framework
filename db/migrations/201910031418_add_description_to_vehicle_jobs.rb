Sequel.migration do
  up do
    alter_table(:vehicle_jobs) do
      add_column :description, String, text: true
    end
  end

  down do
    alter_table(:vehicle_jobs) do
      drop_column :description
    end
  end
end
