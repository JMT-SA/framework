Sequel.migration do
  up do
    alter_table(:mr_bulk_stock_adjustment_items) do
      drop_column :product_number
      drop_column :product_code
      drop_column :mr_sku_location_id
    end

    alter_table(:mr_bulk_stock_adjustments) do
      add_column :ref_no, :Text
      drop_column :mr_inventory_transaction_id
      add_foreign_key :create_transaction_id, :mr_inventory_transactions, key: [:id]
      add_foreign_key :destroy_transaction_id, :mr_inventory_transactions, key: [:id]
    end
  end

  down do
    alter_table(:mr_bulk_stock_adjustment_items) do
      add_column :product_number, :Bignum
      add_column :product_code, :Text
      add_column :mr_sku_location_id, :Integer
    end

    alter_table(:mr_bulk_stock_adjustments) do
      drop_column :ref_no
      add_foreign_key :mr_inventory_transaction_id, :mr_inventory_transactions, key: [:id]
      drop_column :create_transaction_id
      drop_column :destroy_transaction_id
    end
  end
end
