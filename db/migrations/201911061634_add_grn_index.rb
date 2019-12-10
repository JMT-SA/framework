Sequel.migration do
  up do
    alter_table(:mr_goods_returned_notes) do
      add_foreign_key :dispatch_location_id, :locations, null: true, key: [:id]
      add_index [:dispatch_location_id], name: :fki_mr_grn_dispatch_location
      add_column :invoice_error, TrueClass, default: false
      add_column :invoice_completed, TrueClass, default: false
      add_column :erp_purchase_order_number, String
      add_column :erp_purchase_invoice_number, String
    end

    alter_table(:mr_goods_returned_note_items) do
      drop_index [:mr_delivery_item_id], name: :goods_returned_notes_unique_delivery_items
      drop_index [:mr_delivery_item_batch_id], name: :goods_returned_notes_unique_delivery_item_batches

      add_index [:mr_delivery_item_id, :mr_delivery_item_batch_id, :mr_goods_returned_note_id], name: :grn_unique_delivery_items_batches, unique: true
    end
    run 'CREATE UNIQUE INDEX grn_unique_delivery_items_null_batches ON mr_goods_returned_note_items (mr_delivery_item_id, mr_goods_returned_note_id) WHERE mr_delivery_item_batch_id IS NULL;'

    run "INSERT INTO location_types (location_type_code, short_code) VALUES ('DISPATCH', 'DISP');"
  end

  down do
    alter_table(:mr_goods_returned_notes) do
      drop_index [:dispatch_location_id], name: :fki_mr_grn_dispatch_location
      drop_column :dispatch_location_id
      drop_column :invoice_error
      drop_column :invoice_completed
      drop_column :erp_purchase_order_number
      drop_column :erp_purchase_invoice_number
    end

    run "DELETE FROM location_types WHERE short_code = 'DISP';"

    alter_table(:mr_goods_returned_note_items) do
      drop_index [:mr_delivery_item_id, :mr_delivery_item_batch_id, :mr_goods_returned_note_id], name: :grn_unique_delivery_items_batches

      add_index [:mr_delivery_item_id], name: :goods_returned_notes_unique_delivery_items, unique: true
      add_index [:mr_delivery_item_batch_id], name: :goods_returned_notes_unique_delivery_item_batches, unique: true
    end
    run 'DROP INDEX grn_unique_delivery_items_null_batches;'
  end
end
