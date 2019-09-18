Sequel.migration do
  up do
    alter_table(:mr_purchase_order_items) do
      set_column_type :quantity_required, BigDecimal, size: [15, 5]
      set_column_type :unit_price, BigDecimal, size: [15, 5]
    end
  end

  down do
    alter_table(:mr_purchase_order_items) do
      set_column_type :quantity_required, BigDecimal, size: [12, 2]
      set_column_type :unit_price, BigDecimal, size: [7, 2]
    end
  end
end
