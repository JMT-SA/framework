Sequel.migration do
  up do
    alter_table(:material_resource_product_variants) do
      change_column :minimum_stock_level, type: BigDecimal
      change_column :re_order_stock_level, type: BigDecimal
    end
  end

  down do
    change_column :minimum_stock_level, type: Integer
    change_column :re_order_stock_level, type: Integer
  end
end
