Sequel.migration do
  up do
    alter_table(:mr_delivery_items) do
      add_foreign_key :mr_sku_id, :mr_skus, key: [:id]
    end

    alter_table(:mr_delivery_item_batches) do
      add_foreign_key :mr_sku_id, :mr_skus, key: [:id]
    end

    # To Add mr_sku_ids to existing delivery items and item batches:
    # run 'UPDATE mr_delivery_item_batches batches
    #     SET mr_sku_id = (select id from mr_skus where mr_skus.mr_delivery_item_batch_id = batches.id);
    #     UPDATE mr_delivery_items items
    #     set mr_sku_id = (select id from mr_skus where mr_skus.mr_product_variant_id = items.mr_product_variant_id and mr_skus.mr_delivery_item_batch_id = null)
    #     where not exists(select id from mr_delivery_item_batches where mr_delivery_item_id = items.id);'
  end

  down do
    alter_table(:mr_delivery_item_batches) do
      drop_column :mr_sku_id
    end

    alter_table(:mr_delivery_items) do
      drop_column :mr_sku_id
    end
  end
end
