Sequel.migration do
  up do
    run 'CREATE SEQUENCE doc_seqs_tripsheet_number;'
    alter_table(:vehicle_jobs) do
      drop_column :planned_location_to
      add_foreign_key :planned_location_id, :locations, key: [:id]

      drop_column :trip_sheet_number
      add_column :tripsheet_number, String, default: Sequel.function(:nextval, 'doc_seqs_tripsheet_number')

      add_column :when_loading, DateTime
      add_column :loaded, TrueClass, default: false
      add_column :offloaded, TrueClass, default: false

      add_foreign_key :load_transaction_id, :mr_inventory_transactions, key: [:id]
      add_foreign_key :putaway_transaction_id, :mr_inventory_transactions, key: [:id]
      add_foreign_key :offload_transaction_id, :mr_inventory_transactions, key: [:id]
      add_index [:load_transaction_id], name: :fki_vehicle_jobs_mr_inventory_transactions_loads
      add_index [:putaway_transaction_id], name: :fki_vehicle_jobs_mr_inventory_transactions_putaways
      add_index [:offload_transaction_id], name: :fki_vehicle_jobs_mr_inventory_transactions_offloads
    end

    alter_table(:vehicle_job_units) do
      add_column :when_loading, DateTime
    end
  end

  down do
    alter_table(:vehicle_job_units) do
      drop_column :when_loading
    end

    alter_table(:vehicle_jobs) do
      drop_column :planned_location_id
      add_column :planned_location_to, String, text: true

      drop_column :tripsheet_number
      add_column :trip_sheet_number, String

      drop_column :when_loading
      drop_column :loaded
      drop_column :offloaded

      drop_index :load_transaction_id, name: :fki_vehicle_jobs_mr_inventory_transactions_loads
      drop_index :putaway_transaction_id, name: :fki_vehicle_jobs_mr_inventory_transactions_putaways
      drop_index :offload_transaction_id, name: :fki_vehicle_jobs_mr_inventory_transactions_offloads
      drop_column :load_transaction_id
      drop_column :putaway_transaction_id
      drop_column :offload_transaction_id
    end
    run 'DROP SEQUENCE doc_seqs_tripsheet_number;'
  end
end
