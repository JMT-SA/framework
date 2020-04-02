Sequel.migration do
  up do
    alter_table(:mr_sales_orders) do
      add_column :erp_profit_loss_number, String
    end
  end

  down do
    alter_table(:mr_sales_orders) do
      drop_column :erp_profit_loss_number
    end
  end
end
