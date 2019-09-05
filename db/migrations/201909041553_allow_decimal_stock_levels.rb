Sequel.migration do
  up do
    alter_table(:material_resource_product_variants) do
      set_column_type :minimum_stock_level, BigDecimal
      set_column_type :re_order_stock_level, BigDecimal
    end
  end

  down do
    alter_table(:material_resource_product_variants) do
      set_column_type :minimum_stock_level, Integer
      set_column_type :re_order_stock_level, Integer
    end
  end
end
