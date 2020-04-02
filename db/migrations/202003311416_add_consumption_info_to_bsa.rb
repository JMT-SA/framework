Sequel.migration do
  up do
    alter_table(:mr_bulk_stock_adjustments) do
      add_column :carton_assembly, TrueClass, default: false
      add_column :staging_consumption, TrueClass, default: false
    end
  end

  down do
    alter_table(:mr_bulk_stock_adjustments) do
      drop_column :carton_assembly
      drop_column :staging_consumption
    end
  end
end
