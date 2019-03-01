# require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
    alter_table(:mr_deliveries) do
      add_column :putaway_completed, TrueClass, default: false
    end

    alter_table(:mr_delivery_items) do
      add_column :putaway_completed, TrueClass, default: false
      set_column_default :quantity_received, 0
      set_column_default :quantity_on_note, 0
      set_column_default :quantity_over_supplied, 0
      set_column_default :quantity_under_supplied, 0
      add_column :quantity_putaway, BigDecimal, size: [7, 2], default: 0
    end

    alter_table(:mr_delivery_item_batches) do
      add_column :putaway_completed, TrueClass, default: false
      set_column_default :quantity_received, 0
      set_column_default :quantity_on_note, 0
      add_column :quantity_putaway, BigDecimal, size: [7, 2], default: 0
    end

    alter_table(:mr_sku_locations) do
      set_column_allow_null :mr_sku_id, false
      set_column_allow_null :location_id, false
    end
  end

  down do
    alter_table(:mr_sku_locations) do
      set_column_allow_null :mr_sku_id, true
      set_column_allow_null :location_id, true
    end

    alter_table(:mr_deliveries) do
      drop_column :putaway_completed
    end

    alter_table(:mr_delivery_items) do
      drop_column :putaway_completed
      drop_column :quantity_putaway
    end

    alter_table(:mr_delivery_item_batches) do
      drop_column :putaway_completed
      drop_column :quantity_putaway
    end
  end
end
