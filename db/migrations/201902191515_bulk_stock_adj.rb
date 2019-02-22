require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers

    run 'CREATE SEQUENCE doc_seqs_stock_adjustment_number;'
    create_table(:mr_bulk_stock_adjustments, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_inventory_transaction_id, :mr_inventory_transactions, null: false, key: [:id]
      Integer :stock_adjustment_number, null: false, default: Sequel.function(:nextval, 'doc_seqs_stock_adjustment_number')
      column :sku_numbers, 'integer[]'
      column :location_ids, 'integer[]'
      TrueClass :active, default: true
      TrueClass :is_stock_take, default: false

      TrueClass :completed, default: false
      TrueClass :approved, default: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
    run "SELECT audit.audit_table('mr_bulk_stock_adjustments', true, true,'{updated_at}'::text[]);"
    pgt_created_at(:mr_bulk_stock_adjustments,
                   :created_at,
                   function_name: :mr_bulk_stock_adjustments_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:mr_bulk_stock_adjustments,
                   :updated_at,
                   function_name: :mr_bulk_stock_adjustments_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:mr_bulk_stock_adjustment_items, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_bulk_stock_adjustment_id, :mr_bulk_stock_adjustments, null: false, key: [:id]
      foreign_key :mr_inventory_transaction_item_id, :mr_inventory_transaction_items, null: false, key: [:id]
      foreign_key :mr_sku_location_id, :mr_sku_locations, null: false, key: [:id]
      Integer :sku_number, null: false
      Integer :product_variant_number
      Integer :product_number

      String :mr_type_name, null: false
      String :mr_sub_type_name, null: false
      String :product_variant_code, null: false
      String :product_code, null: false
      String :location_code
      String :inventory_uom_code
      String :scan_to_location_code

      BigDecimal :system_quantity, size: [7, 2]
      BigDecimal :actual_quantity, size: [7, 2]

      TrueClass :stock_take_complete, default: false
      TrueClass :active, default: true

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:mr_bulk_stock_adjustment_id], name: :fki_mr_bulk_stock_adjustment_items_mr_bulk_stock_adjustments
      index [:mr_sku_location_id], name: :fki_mr_bulk_stock_adjustment_items_mr_sku_locations
    end
    run "SELECT audit.audit_table('mr_bulk_stock_adjustment_items', true, true,'{updated_at}'::text[]);"
    pgt_created_at(:mr_bulk_stock_adjustment_items,
                   :created_at,
                   function_name: :mr_bulk_stock_adjustment_items_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:mr_bulk_stock_adjustment_items,
                   :updated_at,
                   function_name: :mr_bulk_stock_adjustment_items_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:mr_bulk_stock_adjustments_sku_numbers, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_bulk_stock_adjustment_id, :mr_bulk_stock_adjustments, type: :integer, null: false
      foreign_key :mr_sku_id, :mr_skus, type: :integer, null: false

      index [:mr_bulk_stock_adjustment_id], name: :fki_bulk_stock_adjustments_sku_numbers_mr_bulk_stock_adjustment_id
    end

    create_table(:mr_bulk_stock_adjustments_locations, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_bulk_stock_adjustment_id, :mr_bulk_stock_adjustments, type: :integer, null: false
      foreign_key :location_id, :locations, type: :integer, null: false

      index [:mr_bulk_stock_adjustment_id], name: :fki_bulk_stock_adjustments_sku_numbers_mr_bulk_stock_adjustment_id
    end
  end

  down do
    drop_table(:mr_bulk_stock_adjustments_locations)
    drop_table(:mr_bulk_stock_adjustments_sku_numbers)

    drop_trigger(:mr_bulk_stock_adjustment_items, :set_created_at)
    drop_function(:mr_bulk_stock_adjustment_items_set_created_at)
    drop_trigger(:mr_bulk_stock_adjustment_items, :set_updated_at)
    drop_function(:mr_bulk_stock_adjustment_items_set_updated_at)
    drop_table(:mr_bulk_stock_adjustment_items)

    drop_trigger(:mr_bulk_stock_adjustments, :set_created_at)
    drop_function(:mr_bulk_stock_adjustments_set_created_at)
    drop_trigger(:mr_bulk_stock_adjustments, :set_updated_at)
    drop_function(:mr_bulk_stock_adjustments_set_updated_at)
    drop_table(:mr_bulk_stock_adjustments)
    run 'DROP SEQUENCE doc_seqs_stock_adjustment_number;'
  end
end
