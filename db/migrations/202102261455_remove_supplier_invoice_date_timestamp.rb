Sequel.migration do
  up do
    alter_table(:mr_deliveries) do
      set_column_type :supplier_invoice_date, Date
    end
  end

  down do
    alter_table(:mr_deliveries) do
      set_column_type :supplier_invoice_date, DateTime
    end
  end
end
