Sequel.migration do
  up do
    alter_table(:vehicle_job_units) do
      drop_column :mr_sku_location_from_id
    end
  end

  down do
    alter_table(:vehicle_job_units) do
      add_foreign_key :mr_sku_location_from_id, :mr_sku_locations, key: [:id]
    end
  end
end
