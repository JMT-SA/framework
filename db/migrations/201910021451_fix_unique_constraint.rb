Sequel.migration do
  up do
    alter_table(:vehicle_job_units) do
      drop_index :mr_sku_location_from_id, name: :vehicle_job_units_unique_mr_sku_location_from_id
      drop_foreign_key :mr_sku_location_from_id
      add_foreign_key :mr_sku_location_from_id, :mr_sku_locations, key: [:id]
      add_index [:mr_sku_location_from_id, :vehicle_job_id], name: :vehicle_job_units_unique_mr_sku_location_from_id_vehicle_job, unique: true
    end
  end

  down do
    alter_table(:vehicle_job_units) do
      drop_index [:mr_sku_location_from_id, :vehicle_job_id], name: :vehicle_job_units_unique_mr_sku_location_from_id_vehicle_job
      drop_foreign_key :mr_sku_location_from_id
      add_foreign_key :mr_sku_location_from_id, :locations, key: [:id]
      add_index [:mr_sku_location_from_id], name: :vehicle_job_units_unique_mr_sku_location_from_id, unique: true
    end
  end
end
