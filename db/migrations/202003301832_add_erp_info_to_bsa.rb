Sequel.migration do
  up do
    alter_table(:mr_bulk_stock_adjustments) do
      add_column :integration_error, TrueClass, default: false
      add_column :integration_completed, TrueClass, default: false
      add_column :integrated_at, DateTime
      add_column :erp_depreciation_number, String
    end
  end

  down do
    alter_table(:mr_bulk_stock_adjustments) do
      drop_column :integration_error
      drop_column :integration_completed
      drop_column :integrated_at
      drop_column :erp_depreciation_number
    end
  end
end
