Sequel.migration do
  up do
    alter_table(:material_resource_sub_types) do
      add_foreign_key :inventory_uom_id, :uoms, null: true, key: [:id]
    end

    alter_table(:mr_bulk_stock_adjustment_items) do
      add_foreign_key :inventory_uom_id, :uoms, null: true, key: [:id]
    end

    alter_table(:mr_purchase_order_items) do
      drop_column :purchasing_uom_id
    end
  end

  down do
    alter_table(:material_resource_sub_types) do
      drop_column :inventory_uom_id
    end

    alter_table(:mr_bulk_stock_adjustment_items) do
      drop_column :inventory_uom_id
    end

    alter_table(:mr_purchase_order_items) do
      add_foreign_key :purchasing_uom_id, :uoms, key: [:id]
    end
  end
end
