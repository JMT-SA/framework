Sequel.migration do
  up do
    alter_table(:mr_sales_orders) do
      add_foreign_key :vehicle_job_id, :vehicle_jobs, null: true, key: [:id]
      add_index [:vehicle_job_id], name: :fki_mr_sales_orders_vehicle_jobs
    end
  end

  down do
    alter_table(:mr_sales_orders) do
      drop_index [:vehicle_job_id], name: :fki_mr_sales_orders_vehicle_jobs
      drop_column :vehicle_job_id
    end
  end
end
