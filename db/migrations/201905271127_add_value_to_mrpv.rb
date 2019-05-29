Sequel.migration do
  up do
    alter_table(:material_resource_product_variants) do
      add_column :current_price, BigDecimal, size: [7, 2], default: 0
      add_column :stock_adj_price, BigDecimal, size: [7, 2], default: 0
    end
  end

  down do
    alter_table(:material_resource_product_variants) do
      drop_column :current_price
      drop_column :stock_adj_price
    end
  end
end
