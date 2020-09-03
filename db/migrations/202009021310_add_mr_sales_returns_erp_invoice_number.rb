Sequel.migration do
  up do
    alter_table(:mr_sales_returns) do
      add_column :erp_invoice_number, String
      add_column :erp_profit_loss_number, String
    end
  end

  down do
    alter_table(:mr_sales_returns) do
      drop_column :erp_invoice_number
      drop_column :erp_profit_loss_number
    end
  end
end
