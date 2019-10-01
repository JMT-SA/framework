Sequel.migration do
  up do
    run 'CREATE SEQUENCE doc_seqs_tripsheet_number;'
    alter_table(:vehicle_jobs) do
      drop_column :planned_location_to
      add_foreign_key :planned_location_id, :locations, key: [:id]
      add_foreign_key :virtual_location_id, :locations, key: [:id]

      drop_column :trip_sheet_number
      add_column :tripsheet_number, String, default: Sequel.function(:nextval, 'doc_seqs_tripsheet_number')

      add_column :when_loading, DateTime
      add_column :when_offloading, DateTime
      add_column :loaded, TrueClass, default: false
      add_column :offloaded, TrueClass, default: false
      add_column :arrival_confirmed, TrueClass, default: false

      add_foreign_key :load_transaction_id, :mr_inventory_transactions, key: [:id]
      add_foreign_key :offload_transaction_id, :mr_inventory_transactions, key: [:id]
      add_index [:load_transaction_id], name: :fki_vehicle_jobs_mr_inventory_transactions_loads
      add_index [:offload_transaction_id], name: :fki_vehicle_jobs_mr_inventory_transactions_offloads
    end

    alter_table(:vehicle_job_units) do
      drop_column :mr_inventory_transaction_item_id

      rename_column :quantity_moved, :quantity_offloaded
      add_column :quantity_loaded, BigDecimal, size: [15, 5]

      add_column :when_loading, DateTime
      add_column :sku_number, Integer
      add_column :loaded, TrueClass, default: false
      add_column :offloaded, TrueClass, default: false

      add_foreign_key :mr_sku_id, :mr_skus, key: [:id]
      add_foreign_key :location_id, :locations, key: [:id]
      add_index [:mr_sku_id], name: :fki_vehicle_job_units_mr_skus
      add_index [:location_id], name: :fki_vehicle_job_units_locations
      add_index [:mr_sku_location_from_id], name: :vehicle_job_units_unique_mr_sku_location_from_id, unique: true
    end

    create_table(:vehicle_jobs_sku_numbers, ignore_index_errors: true) do
      primary_key :id
      foreign_key :vehicle_job_id, :vehicle_jobs, type: :integer, null: false
      foreign_key :mr_sku_id, :mr_skus, type: :integer, null: false

      index [:vehicle_job_id], name: :fki_vehicle_jobs_sku_numbers_vehicle_job_id
    end

    create_table(:vehicle_jobs_locations, ignore_index_errors: true) do
      primary_key :id
      foreign_key :vehicle_job_id, :vehicle_jobs, type: :integer, null: false
      foreign_key :location_id, :locations, type: :integer, null: false

      index [:vehicle_job_id], name: :fki_vehicle_jobs_locations_vehicle_job_id
    end

    run "INSERT INTO location_assignments (assignment_code) VALUES ('VEHICLE TRANSFERS');"
    run "INSERT INTO location_types (location_type_code, short_code) VALUES ('VEHICLE TRANSFERS', 'VEHTR');"
    run "INSERT INTO mr_inventory_transaction_types (type_name) VALUES ('LOAD VEHICLE');"
    run "INSERT INTO mr_inventory_transaction_types (type_name) VALUES ('OFFLOAD VEHICLE');"
  end

  down do
    run "DELETE FROM location_assignments WHERE assignment_code = 'VEHICLE TRANSFERS';"
    run "DELETE FROM location_types WHERE short_code = 'VEHTR';"
    run "DELETE FROM mr_inventory_transaction_types WHERE type_name = 'LOAD VEHICLE';"
    run "DELETE FROM mr_inventory_transaction_types WHERE type_name = 'OFFLOAD VEHICLE';"

    drop_table(:vehicle_jobs_locations)
    drop_table(:vehicle_jobs_sku_numbers)

    alter_table(:vehicle_job_units) do
      add_foreign_key :mr_inventory_transaction_item_id, :mr_inventory_transaction_items, key: [:id]

      rename_column :quantity_offloaded, :quantity_moved
      drop_column :quantity_loaded

      drop_column :when_loading
      drop_column :sku_number
      drop_column :loaded
      drop_column :offloaded

      drop_index :mr_sku_location_from_id, name: :vehicle_job_units_unique_mr_sku_location_from_id
      drop_index :mr_sku_id, name: :fki_vehicle_job_units_mr_skus
      drop_index :location_id, name: :fki_vehicle_job_units_locations
      drop_column :mr_sku_id
      drop_column :location_id
    end

    alter_table(:vehicle_jobs) do
      drop_column :planned_location_id
      drop_column :virtual_location_id
      add_column :planned_location_to, String, text: true

      drop_column :tripsheet_number
      add_column :trip_sheet_number, String

      drop_column :when_loading
      drop_column :when_offloading
      drop_column :loaded
      drop_column :offloaded
      drop_column :arrival_confirmed

      drop_index :load_transaction_id, name: :fki_vehicle_jobs_mr_inventory_transactions_loads
      drop_index :offload_transaction_id, name: :fki_vehicle_jobs_mr_inventory_transactions_offloads
      drop_column :load_transaction_id
      drop_column :offload_transaction_id
    end
    run 'DROP SEQUENCE doc_seqs_tripsheet_number;'
  end
end
