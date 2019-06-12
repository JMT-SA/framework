Sequel.migration do
  up do
    run 'ALTER TABLE mr_bulk_stock_adjustment_items ALTER COLUMN product_variant_number TYPE bigint USING (product_variant_number::bigint);'
  end

  down do
    run 'ALTER TABLE mr_bulk_stock_adjustment_items ALTER COLUMN product_variant_number TYPE text USING (product_variant_number::text);'
  end
end
