Sequel.migration do
  up do
    alter_table(:mr_bulk_stock_adjustment_items) do
      add_column :old_product_code, String, text: true
    end

    unless ENV['RACK_ENV'] == 'test'
      run <<~SQL
        UPDATE mr_bulk_stock_adjustment_items
        SET old_product_code = (select material_resource_product_variants.old_product_code
                                from mr_bulk_stock_adjustment_items bi
                                join mr_skus on mr_skus.id = bi.mr_sku_id
                                join material_resource_product_variants on mr_skus.mr_product_variant_id = material_resource_product_variants.id
                                WHERE bi.id = mr_bulk_stock_adjustment_items.id);
      SQL
    end
  end

  down do
    alter_table(:mr_bulk_stock_adjustment_items) do
      drop_column :old_product_code
    end
  end
end
