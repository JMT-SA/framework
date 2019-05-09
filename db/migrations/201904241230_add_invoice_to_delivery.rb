Sequel.migration do
  up do
    alter_table(:mr_deliveries) do
      add_column :supplier_invoice_date, DateTime
      add_column :invoice_completed, TrueClass, default: false
      add_column :invoice_error, TrueClass, default: false
      add_column :erp_purchase_order_number, String
      add_column :erp_purchase_invoice_number, String
    end
  end

  down do
    alter_table(:mr_deliveries) do
      drop_column :supplier_invoice_date
      drop_column :invoice_completed
      drop_column :invoice_error
      drop_column :erp_purchase_order_number
      drop_column :erp_purchase_invoice_number
    end
  end
end
