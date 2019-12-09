Sequel.migration do
  up do
    alter_table(:mr_delivery_item_batches) do
      add_column :grn_returned, TrueClass, default: false
      add_column :grn_qty_returned, BigDecimal, size: [15,5], default: 0.0
    end

    alter_table(:mr_delivery_items) do
      add_column :grn_returned, TrueClass, default: false
      add_column :grn_qty_returned, BigDecimal, size: [15,5], default: 0.0
    end

    alter_table(:mr_deliveries) do
      add_column :grn_returned, TrueClass, default: false
    end
  end

  down do
    alter_table(:mr_delivery_item_batches) do
      drop_column :grn_returned
      drop_column :grn_qty_returned
    end

    alter_table(:mr_delivery_items) do
      drop_column :grn_returned
      drop_column :grn_qty_returned
    end

    alter_table(:mr_deliveries) do
      drop_column :grn_returned
    end
  end
end
