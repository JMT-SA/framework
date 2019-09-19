Sequel.migration do
  up do
    alter_table(:mr_delivery_items) do
      set_column_type :invoiced_unit_price, BigDecimal, size: [15, 5]
    end
  end

  down do
    alter_table(:mr_delivery_items) do
      set_column_type :invoiced_unit_price, BigDecimal, size: [7, 2]
    end
  end
end
