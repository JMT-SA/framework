Sequel.migration do
  up do
    alter_table(:mr_sales_orders) do
      add_column :client_reference_number, String
    end
  end

  down do
    alter_table(:mr_sales_orders) do
      drop_column :client_reference_number
    end
  end
end
