Sequel.migration do
  up do
    alter_table(:mr_bulk_stock_adjustments) do
      add_foreign_key :business_process_id, :business_processes, null: false, key: [:id]
    end
  end

  down do
    alter_table(:mr_bulk_stock_adjustments) do
      drop_column :business_process_id
    end
  end
end
