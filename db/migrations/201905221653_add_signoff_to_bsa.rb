Sequel.migration do
  up do
    alter_table(:mr_bulk_stock_adjustments) do
      add_column :signed_off, :boolean, default: false
    end
  end

  down do
    alter_table(:mr_bulk_stock_adjustments) do
      drop_column :signed_off
    end
  end
end
