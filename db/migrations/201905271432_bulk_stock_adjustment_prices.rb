Sequel.migration do
  up do
    create_table(:mr_price_adjustments, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_bulk_stock_adjustment_id, :mr_bulk_stock_adjustments, null: false, key: [:id]
      foreign_key :mr_product_variant_id, :material_resource_product_variants, null: false, key: [:id]

      BigDecimal :stock_adj_price, size: [7, 2]
      unique [:mr_bulk_stock_adjustment_id, :mr_product_variant_id], name: :unique_mr_bulk_stock_adjustment_product_variant_pair
    end
  end

  down do
    drop_table(:mr_price_adjustments)
  end
end
