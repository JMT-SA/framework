Sequel.migration do
  up do
    alter_table(:mr_bulk_stock_adjustment_prices) do
      set_column_type :stock_adj_price, BigDecimal, size: [15, 5]
    end

    alter_table(:material_resource_product_variants) do
      set_column_type :current_price, BigDecimal, size: [15, 5]
      set_column_type :stock_adj_price, BigDecimal, size: [15, 5]
    end
  end

  down do
    alter_table(:mr_bulk_stock_adjustment_prices) do
      set_column_type :stock_adj_price, BigDecimal, size: [12, 2]
    end

    alter_table(:material_resource_product_variants) do
      set_column_type :current_price, BigDecimal, size: [12, 2]
      set_column_type :stock_adj_price, BigDecimal, size: [12, 2]
    end
  end
end
