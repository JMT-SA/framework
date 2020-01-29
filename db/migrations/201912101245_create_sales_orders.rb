require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    create_table(:mr_sales_orders, ignore_index_errors: true) do
      primary_key :id
      foreign_key :customer_party_role_id, :party_roles, key: [:id]
      foreign_key :dispatch_location_id, :locations, key: [:id]
      foreign_key :issue_transaction_id, :mr_inventory_transactions, key: [:id]
      # foreign_key :vehicle_job_id, :vehicle_jobs, key: [:id]
      foreign_key :vat_type_id, :mr_vat_types, key: [:id]
      foreign_key :account_code_id, :account_codes, key: [:id]

      String :erp_customer_number
      String :created_by
      String :fin_object_code

      Integer :sales_order_number
      String :erp_invoice_number

      DateTime :shipped_at
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      TrueClass :integration_error, default: false
      TrueClass :integration_completed, default: false
      # TrueClass :consignment, default: false
      # TrueClass :internal, default: false
      # TrueClass :completed, default: false
      # TrueClass :transferring_to_dispatch, default: false
      TrueClass :shipped, default: false
      # TrueClass :active, default: true

      index [:customer_party_role_id], name: :fki_mr_sales_orders_customers
      index [:dispatch_location_id], name: :fki_mr_sales_orders_dispatch_locations
      index [:issue_transaction_id], name: :fki_mr_sales_orders_issue_transactions
      # index [:vehicle_job_id], name: :fki_mr_sales_orders_vehicle_jobs
      index [:vat_type_id], name: :fki_mr_sales_orders_vat_types
      index [:account_code_id], name: :fki_mr_sales_orders_account_codes
    end
    pgt_created_at(:mr_sales_orders, :created_at, function_name: :mr_sales_orders_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:mr_sales_orders, :updated_at, function_name: :mr_sales_orders_set_updated_at, trigger_name: :set_updated_at)
    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('mr_sales_orders', true, true, '{updated_at}'::text[]);"
    run 'CREATE SEQUENCE doc_seqs_sales_order_number;'

    create_table(:mr_sales_order_items, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_sales_order_id, :mr_sales_orders, null: false, key: [:id]
      foreign_key :mr_product_variant_id, :material_resource_product_variants, key: [:id]
      # foreign_key :inventory_uom_id, :uoms, null: false, key: [:id]

      String :remarks, text: true
      BigDecimal :quantity_required, size: [15,5]
      # BigDecimal :quantity_dispatched, size: [15,5]
      BigDecimal :unit_price, size: [17,5]

      # DateTime :dispatched_at
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      # TrueClass :dispatched, default: false
      # TrueClass :active, default: true

      index [:mr_sales_order_id], name: :fki_mr_sales_order_items_mr_sales_orders
      index [:mr_sales_order_id, :mr_product_variant_id], name: :fki_mr_sales_order_items_material_resource_product_variants, unique: true
      # index [:inventory_uom_id], name: :fki_mr_sales_order_items_uoms
    end
    pgt_created_at(:mr_sales_order_items, :created_at, function_name: :mr_sales_order_items_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:mr_sales_order_items, :updated_at, function_name: :mr_sales_order_items_set_updated_at, trigger_name: :set_updated_at)
    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('mr_sales_order_items', true, true, '{updated_at}'::text[]);"

    create_table(:sales_order_costs) do
      primary_key :id
      foreign_key :mr_sales_order_id, :mr_sales_orders, null: false, key: [:id]
      foreign_key :mr_cost_type_id, :mr_cost_types, null: false, key: [:id]

      BigDecimal :amount, size: [17,5]
    end

    # create_table(:dispatches, ignore_index_errors: true) do
    #   primary_key :id
    #   foreign_key :mr_sales_order_id, :mr_sales_orders, null: false, key: [:id]
    #   foreign_key :destination_location_id, :locations, key: [:id]
    #   foreign_key :mr_inventory_transaction_id, :mr_inventory_transactions, key: [:id]
    #   foreign_key :vehicle_id, :vehicles, key: [:id]
    #
    #   DateTime :dispatched_at
    #   DateTime :created_at, null: false
    #   DateTime :updated_at, null: false
    #
    #   index [:mr_sales_order_id], name: :fki_dispatches_mr_sales_orders
    #   index [:destination_location_id], name: :fki_dispatches_destination_locations
    #   index [:mr_inventory_transaction_id], name: :fki_dispatches_mr_inventory_transactions
    #   index [:vehicle_id], name: :fki_dispatches_vehicles
    # end
    # pgt_created_at(:dispatches, :created_at, function_name: :dispatches_set_created_at, trigger_name: :set_created_at)
    # pgt_updated_at(:dispatches, :updated_at, function_name: :dispatches_set_updated_at, trigger_name: :set_updated_at)
    # # Log changes to this table. Exclude changes to the updated_at column.
    # run "SELECT audit.audit_table('dispatches', true, true, '{updated_at}'::text[]);"
    #
    # create_table(:dispatch_items, ignore_index_errors: true) do
    #   primary_key :id
    #   foreign_key :mr_sales_order_item_id, :mr_sales_order_items, null: false, key: [:id]
    #   foreign_key :mr_inventory_transaction_item_id, :mr_inventory_transaction_items, key: [:id]
    #
    #   BigDecimal :quantity_dispatched, size: [12,2]
    #   TrueClass :dispatched, default: false
    #   DateTime :dispatched_at
    #   DateTime :created_at, null: false
    #   DateTime :updated_at, null: false
    #
    #   index [:mr_sales_order_item_id], name: :fki_dispatch_items_mr_sales_order_items
    #   index [:mr_inventory_transaction_item_id], name: :fki_dispatch_items_mr_inventory_transaction_items
    # end
    # pgt_created_at(:dispatch_items, :created_at, function_name: :dispatch_items_set_created_at, trigger_name: :set_created_at)
    # pgt_updated_at(:dispatch_items, :updated_at, function_name: :dispatch_items_set_updated_at, trigger_name: :set_updated_at)
    # # Log changes to this table. Exclude changes to the updated_at column.
    # run "SELECT audit.audit_table('dispatch_items', true, true, '{updated_at}'::text[]);"
  end

  down do
    # # Drop logging for this table.
    # drop_trigger(:dispatch_items, :audit_trigger_row)
    # drop_trigger(:dispatch_items, :audit_trigger_stm)
    # drop_trigger(:dispatch_items, :set_created_at)
    # drop_function(:dispatch_items_set_created_at)
    # drop_trigger(:dispatch_items, :set_updated_at)
    # drop_function(:dispatch_items_set_updated_at)
    # drop_table(:dispatch_items)
    #
    # # Drop logging for this table.
    # drop_trigger(:dispatches, :audit_trigger_row)
    # drop_trigger(:dispatches, :audit_trigger_stm)
    # drop_trigger(:dispatches, :set_created_at)
    # drop_function(:dispatches_set_created_at)
    # drop_trigger(:dispatches, :set_updated_at)
    # drop_function(:dispatches_set_updated_at)
    # drop_table(:dispatches)

    drop_table(:sales_order_costs)

    # Drop logging for this table.
    drop_trigger(:mr_sales_order_items, :audit_trigger_row)
    drop_trigger(:mr_sales_order_items, :audit_trigger_stm)
    drop_trigger(:mr_sales_order_items, :set_created_at)
    drop_function(:mr_sales_order_items_set_created_at)
    drop_trigger(:mr_sales_order_items, :set_updated_at)
    drop_function(:mr_sales_order_items_set_updated_at)
    drop_table(:mr_sales_order_items)

    # Drop logging for this table.
    drop_trigger(:mr_sales_orders, :audit_trigger_row)
    drop_trigger(:mr_sales_orders, :audit_trigger_stm)
    run 'DROP SEQUENCE doc_seqs_sales_order_number;'
    drop_trigger(:mr_sales_orders, :set_created_at)
    drop_function(:mr_sales_orders_set_created_at)
    drop_trigger(:mr_sales_orders, :set_updated_at)
    drop_function(:mr_sales_orders_set_updated_at)
    drop_table(:mr_sales_orders)
  end
end
