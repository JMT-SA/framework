# require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
    alter_table(:mr_bulk_stock_adjustment_items) do
      set_column_type :system_quantity, BigDecimal, size: [12, 2]
      set_column_type :actual_quantity, BigDecimal, size: [12, 2]
    end

    alter_table(:material_resource_product_variants) do
      set_column_type :current_price, BigDecimal, size: [12, 2]
      set_column_type :stock_adj_price, BigDecimal, size: [12, 2]
    end

    alter_table(:mr_purchase_invoice_costs) do
      set_column_type :amount, BigDecimal, size: [12, 2]
    end

    alter_table(:mr_bulk_stock_adjustment_prices) do
      set_column_type :stock_adj_price, BigDecimal, size: [12, 2]
    end

    alter_table(:mr_purchase_order_costs) do
      set_column_type :amount, BigDecimal, size: [12, 2]
    end

    alter_table(:mr_purchase_order_items) do
      set_column_type :quantity_required, BigDecimal, size: [12, 2]
    end

    alter_table(:mr_inventory_transaction_items) do
      set_column_type :quantity, BigDecimal, size: [12, 2]
    end

    alter_table(:mr_delivery_items) do
      set_column_type :quantity_on_note, BigDecimal, size: [12, 2]
      set_column_type :quantity_over_supplied, BigDecimal, size: [12, 2]
      set_column_type :quantity_under_supplied, BigDecimal, size: [12, 2]
      set_column_type :quantity_received, BigDecimal, size: [12, 2]
      set_column_type :quantity_putaway, BigDecimal, size: [12, 2]
    end

    alter_table(:mr_delivery_item_batches) do
      set_column_type :quantity_on_note, BigDecimal, size: [12, 2]
      set_column_type :quantity_received, BigDecimal, size: [12, 2]
      set_column_type :quantity_putaway, BigDecimal, size: [12, 2]
    end

    alter_table(:mr_sku_locations) do
      set_column_type :quantity, BigDecimal, size: [12, 2]
    end

    alter_table(:vehicle_job_units) do
      set_column_type :quantity_to_move, BigDecimal, size: [12, 2]
      set_column_type :quantity_moved, BigDecimal, size: [12, 2]
    end

    alter_table(:mr_delivery_items) do
      set_column_type :quantity_returned, BigDecimal, size: [12, 2]
    end
  end

  down do
    alter_table(:mr_bulk_stock_adjustment_items) do
      set_column_type :system_quantity, BigDecimal, size: [7, 2]
      set_column_type :actual_quantity, BigDecimal, size: [7, 2]
    end

    alter_table(:material_resource_product_variants) do
      set_column_type :current_price, BigDecimal, size: [7, 2]
      set_column_type :stock_adj_price, BigDecimal, size: [7, 2]
    end

    alter_table(:mr_purchase_invoice_costs) do
      set_column_type :amount, BigDecimal, size: [7, 2]
    end

    alter_table(:mr_bulk_stock_adjustment_prices) do
      set_column_type :stock_adj_price, BigDecimal, size: [7, 2]
    end

    alter_table(:mr_purchase_order_costs) do
      set_column_type :amount, BigDecimal, size: [7, 2]
    end

    alter_table(:mr_purchase_order_items) do
      set_column_type :quantity_required, BigDecimal, size: [7, 2]
    end

    alter_table(:mr_inventory_transaction_items) do
      set_column_type :quantity, BigDecimal, size: [7, 2]
    end

    alter_table(:mr_delivery_items) do
      set_column_type :quantity_on_note, BigDecimal, size: [7, 2]
      set_column_type :quantity_over_supplied, BigDecimal, size: [7, 2]
      set_column_type :quantity_under_supplied, BigDecimal, size: [7, 2]
      set_column_type :quantity_received, BigDecimal, size: [7, 2]
      set_column_type :quantity_putaway, BigDecimal, size: [7, 2]
    end

    alter_table(:mr_delivery_item_batches) do
      set_column_type :quantity_on_note, BigDecimal, size: [7, 2]
      set_column_type :quantity_received, BigDecimal, size: [7, 2]
      set_column_type :quantity_putaway, BigDecimal, size: [7, 2]
    end

    alter_table(:mr_sku_locations) do
      set_column_type :quantity, BigDecimal, size: [7, 2]
    end

    alter_table(:vehicle_job_units) do
      set_column_type :quantity_to_move, BigDecimal, size: [7, 2]
      set_column_type :quantity_moved, BigDecimal, size: [7, 2]
    end

    alter_table(:mr_delivery_items) do
      set_column_type :quantity_returned, BigDecimal, size: [7, 2]
    end
  end
end
