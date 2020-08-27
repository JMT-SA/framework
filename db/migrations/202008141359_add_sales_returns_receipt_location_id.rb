Sequel.migration do
  up do
    alter_table(:mr_sales_returns) do
      add_foreign_key :receipt_location_id, :locations, key: [:id]
    end
  end

  down do
    alter_table(:mr_sales_returns) do
      drop_column :receipt_location_id
    end
  end
end
