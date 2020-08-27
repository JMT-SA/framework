Sequel.migration do
  up do
    alter_table(:mr_sales_returns) do
      add_column :integration_error, TrueClass, default: false
    end
  end

  down do
    alter_table(:mr_sales_returns) do
      drop_column :integration_error
    end
  end
end
