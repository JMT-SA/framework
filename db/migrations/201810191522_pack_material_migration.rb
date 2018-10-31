require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    drop_table(:measurement_units_for_matres_types)
    drop_table(:measurement_units)

    create_table(:business_processes, ignore_index_errors: true) do
      primary_key :id
      String :process
      String :description

      index [:process], name: :business_processes_unique_process, unique: true
    end

    create_table(:uom_types, ignore_index_errors: true) do
      primary_key :id
      String :code, null: false

      index [:code], name: :uom_types_unique_code, unique: true
    end

    create_table(:uoms, ignore_index_errors: true) do
      primary_key :id
      foreign_key :uoms_type_id, :uom_types, null: false, key: [:id]
      String :uom_code, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:uom_code, :uoms_type_id], name: :fki_uoms_codes_uom_types, unique: true
    end
    pgt_created_at(:uoms,
                   :created_at,
                   function_name: :uoms_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:uoms,
                   :updated_at,
                   function_name: :uoms_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:mr_uoms, ignore_index_errors: true) do
      primary_key :id
      foreign_key :uom_id, :uoms, null: false, key: [:id]
      foreign_key :mr_sub_type_id, :material_resource_sub_types, key: [:id]
      foreign_key :mr_product_variant_id, :material_resource_product_variants, key: [:id]

      index [:mr_sub_type_id, :uom_id], name: :fki_mr_sub_types_uoms, unique: true
      index [:mr_product_variant_id, :uom_id], name: :fki_mr_product_variants_uoms, unique: true
    end

    create_table(:mr_vat_types, ignore_index_errors: true) do
      primary_key :id
      String :vat_type_code
      BigDecimal :percentage_applicable, size: [7, 2]     # numeric(7, 2)
      TrueClass :vat_not_applicable, default: false

      index [:vat_type_code], name: :mr_vat_types_unique_vat_type_code, unique: true
    end

    create_table(:mr_delivery_terms, ignore_index_errors: true) do
      primary_key :id
      String :delivery_term_code
      TrueClass :is_consignment_stock, default: false

      index [:delivery_term_code], name: :mr_delivery_terms_unique_delivery_term_code, unique: true
    end

    create_table(:mr_cost_types, ignore_index_errors: true) do
      primary_key :id
      String :cost_code_string

      index [:cost_code_string], name: :mr_cost_types_unique_cost_code_string, unique: true
    end

    create_table(:mr_purchase_orders, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_delivery_term_id, :mr_delivery_terms, key: [:id]
      foreign_key :supplier_party_role_id, :party_roles, key: [:id]
      foreign_key :mr_vat_type_id, :mr_vat_types, key: [:id]
      foreign_key :delivery_address_id, :addresses, key: [:id]

      # String :erp_supplier_number - a lookup from the supplier
      String :purchase_account_code
      String :fin_object_code # What is this?
      # String :process_status
      DateTime :valid_until
      Integer :purchase_order_number
      TrueClass :approved, default: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:purchase_order_number], name: :mr_purchase_orders_unique_purchase_order_number, unique: true
      index [:supplier_party_role_id], name: :fki_mr_purchase_orders_supplier_party_roles
    end
    pgt_created_at(:mr_purchase_orders,
                   :created_at,
                   function_name: :mr_purchase_orders_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:mr_purchase_orders,
                   :updated_at,
                   function_name: :mr_purchase_orders_set_updated_at,
                   trigger_name: :set_updated_at)
    run "SELECT audit.audit_table('mr_purchase_orders', true, true,'{updated_at}'::text[]);"
    run 'CREATE SEQUENCE doc_seqs_po_number;'

    create_table(:mr_purchase_order_costs, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_cost_type_id, :mr_cost_types, key: [:id]
      foreign_key :mr_purchase_order_id, :mr_purchase_orders, key: [:id]
      BigDecimal :amount, size: [7, 2]

      index [:mr_cost_type_id], name: :fki_mr_purchase_order_costs_mr_cost_types
      index [:mr_purchase_order_id], name: :fki_mr_purchase_order_costs_mr_purchase_orders
    end
    run "SELECT audit.audit_table('mr_purchase_order_costs', true, true,'{updated_at}'::text[]);"

    create_table(:mr_purchase_order_items, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_purchase_order_id, :mr_purchase_orders, key: [:id]
      foreign_key :mr_product_variant_id, :material_resource_product_variants, key: [:id]
      foreign_key :purchasing_uom_id, :uoms, key: [:id]
      foreign_key :inventory_uom_id, :uoms, key: [:id]
      BigDecimal :quantity_required, size: [7, 2]
      BigDecimal :unit_price, size: [7, 2]
      # String :process_status

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:mr_purchase_order_id], name: :fki_mr_purchase_order_items_mr_purchase_orders
      index [:mr_product_variant_id], name: :fki_mr_purchase_order_items_mr_product_variants
    end
    pgt_created_at(:mr_purchase_order_items,
                   :created_at,
                   function_name: :mr_purchase_order_items_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:mr_purchase_order_items,
                   :updated_at,
                   function_name: :mr_purchase_order_items_set_updated_at,
                   trigger_name: :set_updated_at)
    run "SELECT audit.audit_table('mr_purchase_order_items', true, true,'{updated_at}'::text[]);"

    # SKUs, Batches & Inventory Transactions
    # --------------------------------------
    create_table(:user_defined_batches, ignore_index_errors: true) do
      primary_key :id
      Integer :batch_number
      String :description
      # <static>seed_number - Hans said this gets sequentially generated and that they decide where it starts from

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:batch_number], name: :user_defined_batches_unique_batch_number, unique: true
    end
    pgt_created_at(:user_defined_batches,
                   :created_at,
                   function_name: :user_defined_batches_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:user_defined_batches,
                   :updated_at,
                   function_name: :user_defined_batches_set_updated_at,
                   trigger_name: :set_updated_at)
    run "SELECT audit.audit_table('user_defined_batches', true, true,'{updated_at}'::text[]);"

    create_table(:mr_delivery_item_batches, ignore_index_errors: true) do
      primary_key :id
      String :client_batch_number, text: true
      Integer :internal_batch_number
      BigDecimal :quantity_on_note, size: [7, 2]
      BigDecimal :quantity_received, size: [7, 2]
      # String :process_status

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:internal_batch_number], name: :mr_delivery_item_batches_unique_internal_batch_number, unique: true
    end
    pgt_created_at(:mr_delivery_item_batches,
                   :created_at,
                   function_name: :mr_delivery_item_batches_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:mr_delivery_item_batches,
                   :updated_at,
                   function_name: :mr_delivery_item_batches_set_updated_at,
                   trigger_name: :set_updated_at)
    run "SELECT audit.audit_table('mr_delivery_item_batches', true, true,'{updated_at}'::text[]);"

    create_table(:mr_skus, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_product_variant_id, :material_resource_product_variants, key: [:id]
      foreign_key :owner_party_role_id, :party_roles, key: [:id]
      foreign_key :mr_delivery_item_batch_id, :mr_delivery_item_batches, key: [:id]
      foreign_key :user_defined_batch_id, :user_defined_batches, key: [:id]

      TrueClass :is_consignment_stock, default: false
      BigDecimal :quantity, size: [7,2]
      Integer :sku_number

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:sku_number], name: :mr_skus_unique_sku_number, unique: true
      index [:mr_product_variant_id], name: :fki_mr_skus_mr_product_variants
      index [:owner_party_role_id], name: :fki_mr_skus_party_roles
      index [:mr_delivery_item_batch_id], name: :fki_mr_skus_mr_item_batches
      index [:user_defined_batch_id], name: :fki_mr_skus_user_defined_batches
    end
    pgt_created_at(:mr_skus,
                   :created_at,
                   function_name: :mr_skus_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:mr_skus,
                   :updated_at,
                   function_name: :mr_skus_set_updated_at,
                   trigger_name: :set_updated_at)
    run "SELECT audit.audit_table('mr_skus', true, true,'{updated_at}'::text[]);"

    create_table(:mr_sku_locations, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_sku_id, :mr_skus, key: [:id]
      foreign_key :location_id, :locations, key: [:id]

      BigDecimal :quantity, size: [7, 2]

      index [:mr_sku_id, :location_id], name: :fki_mr_sku_locations, unique: true
    end
    run "SELECT audit.audit_table('mr_sku_locations', true, true,'{updated_at}'::text[]);"

    create_table(:mr_inventory_transaction_types, ignore_index_errors: true) do
      primary_key :id
      String :type_name

      index [:type_name], name: :mr_inventory_transaction_types_unique_type_names, unique: true
    end

    create_table(:mr_inventory_transactions, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_inventory_transaction_type_id, :mr_inventory_transaction_types, key: [:id]
      foreign_key :to_location_id, :locations, key: [:id]
      foreign_key :business_process_id, :business_processes, key: [:id]

      String :created_by, null: false
      String :ref_no
      TrueClass :is_adhoc, default: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:ref_no, :mr_inventory_transaction_type_id], name: :mr_inventory_transactions_unique_ref_no, unique: true
    end
    pgt_created_at(:mr_inventory_transactions,
                   :created_at,
                   function_name: :mr_inventory_transactions_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:mr_inventory_transactions,
                   :updated_at,
                   function_name: :mr_inventory_transactions_set_updated_at,
                   trigger_name: :set_updated_at)
    run "SELECT audit.audit_table('mr_inventory_transactions', true, true,'{updated_at}'::text[]);"

    create_table(:mr_inventory_transaction_items, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_sku_id
      foreign_key :inventory_uom_id
      foreign_key :from_location_id
      foreign_key :mr_inventory_transaction_id

      BigDecimal :quantity, size: [7, 2]

      index [:mr_sku_id], name: :fki_mr_inventory_transaction_items_mr_skus
      index [:mr_inventory_transaction_id], name: :fki_mr_inventory_transaction_items_mr_inventory_transactions
    end
    run "SELECT audit.audit_table('mr_inventory_transaction_items', true, true,'{updated_at}'::text[]);"

    create_table(:vehicle_types, ignore_index_errors: true) do
      primary_key :id
      String :type_code

      index [:type_code], name: :vehicle_types_unique_type_code, unique: true
    end

    create_table(:vehicles, ignore_index_errors: true) do
      primary_key :id
      foreign_key :vehicle_type_id, :vehicle_types, key: [:id]
      String :vehicle_code

      index [:vehicle_code, :vehicle_type_id], name: :vehicles_unique_vehicle_code_per_type, unique: true
    end

    create_table(:vehicle_jobs, ignore_index_errors: true) do
      primary_key :id
      foreign_key :business_process_id, :business_processes, key: [:id]
      foreign_key :vehicle_id, :vehicles, key: [:id]
      foreign_key :departure_location_id, :locations, key: [:id]

      Integer :trip_sheet_number
      String :planned_location_to
      DateTime :when_loaded
      DateTime :when_offloaded
      # String :process_status

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:business_process_id], name: :fki_vehicle_jobs_business_processes
      index [:vehicle_id], name: :fki_vehicle_jobs_vehicles
    end
    pgt_created_at(:vehicle_jobs,
                   :created_at,
                   function_name: :vehicle_jobs_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:vehicle_jobs,
                   :updated_at,
                   function_name: :vehicle_jobs_set_updated_at,
                   trigger_name: :set_updated_at)
    run "SELECT audit.audit_table('vehicle_jobs', true, true,'{updated_at}'::text[]);"

    create_table(:vehicle_job_units, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_sku_location_from_id, :locations, key: [:id]
      foreign_key :mr_inventory_transaction_item_id, :mr_inventory_transaction_items, key: [:id]

      Integer :vehicle_job_id
      # String :process_status
      BigDecimal :quantity_to_move, size: [7, 2]
      DateTime :when_loaded
      DateTime :when_offloaded
      DateTime :when_offloading
      BigDecimal :quantity_moved, size: [7, 2]

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:mr_sku_location_from_id], name: :fki_vehicle_job_units_mr_sku_locations
      index [:mr_inventory_transaction_item_id], name: :fki_vehicle_job_units_mr_inventory_transaction_items
    end
    pgt_created_at(:vehicle_job_units,
                   :created_at,
                   function_name: :vehicle_job_units_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:vehicle_job_units,
                   :updated_at,
                   function_name: :vehicle_job_units_set_updated_at,
                   trigger_name: :set_updated_at)
    run "SELECT audit.audit_table('vehicle_job_units', true, true,'{updated_at}'::text[]);"

    create_table(:mr_deliveries, ignore_index_errors: true) do
      primary_key :id
      foreign_key :receipt_transaction_id, :mr_inventory_transactions, key: [:id]
      foreign_key :putaway_transaction_id, :mr_inventory_transactions, key: [:id]
      foreign_key :mr_purchase_order_id, :mr_purchase_orders, key: [:id], null: false
      # foreign_key :receiving_warehouse_location_id, :mr_purchase_orders, key: [:id] - is this still neccessary?
      foreign_key :transporter_party_role_id, :party_roles, key: [:id]

      DateTime :received_on, null: false
      # String :process_status
      String :driver_name, null: false
      String :client_delivery_ref_number, null: false
      Integer :delivery_number, null: false
      String :vehicle_registration, null: false
      String :supplier_invoice_ref_number

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:receipt_transaction_id], name: :fki_mr_deliveries_mr_inventory_transactions_receipts
      index [:putaway_transaction_id], name: :fki_mr_deliveries_mr_inventory_transactions_putaways
      index [:mr_purchase_order_id], name: :fki_mr_deliveries_mr_purchase_orders
      index [:transporter_party_role_id], name: :fki_mr_deliveries_party_roles
    end
    pgt_created_at(:mr_deliveries,
                   :created_at,
                   function_name: :mr_deliveries_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:mr_deliveries,
                   :updated_at,
                   function_name: :mr_deliveries_set_updated_at,
                   trigger_name: :set_updated_at)
    run "SELECT audit.audit_table('mr_deliveries', true, true,'{updated_at}'::text[]);"

    create_table(:mr_delivery_items, ignore_index_errors: true) do
      primary_key :id
      foreign_key :mr_delivery_id, :mr_deliveries, key: [:id]
      foreign_key :mr_purchase_order_item_id, :mr_purchase_order_items, key: [:id], null: false
      foreign_key :mr_product_variant_id, :material_resource_product_variants, key: [:id]

      BigDecimal :quantity_on_note, size: [7, 2]
      BigDecimal :quantity_over_supplied, size: [7, 2]
      BigDecimal :quantity_under_supplied, size: [7, 2]
      BigDecimal :quantity_received, size: [7, 2]
      BigDecimal :invoiced_unit_price, size: [7, 2]
      String :remarks

      index [:mr_delivery_id], name: :fki_mr_delivery_items_mr_deliveries
      index [:mr_purchase_order_item_id], name: :fki_mr_delivery_items_mr_purchase_order_items
      index [:mr_product_variant_id], name: :fki_mr_delivery_items_material_resource_product_variants
    end
    pgt_created_at(:mr_delivery_items,
                   :created_at,
                   function_name: :mr_delivery_items_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:mr_delivery_items,
                   :updated_at,
                   function_name: :mr_delivery_items_set_updated_at,
                   trigger_name: :set_updated_at)
    run "SELECT audit.audit_table('mr_delivery_items', true, true,'{updated_at}'::text[]);"
  end

  down do
    drop_trigger(:mr_delivery_items, :audit_trigger_row)
    drop_trigger(:mr_delivery_items, :audit_trigger_stm)
    drop_table(:mr_delivery_items)

    drop_trigger(:mr_deliveries, :audit_trigger_row)
    drop_trigger(:mr_deliveries, :audit_trigger_stm)
    drop_table(:mr_deliveries)

    drop_trigger(:vehicle_job_units, :audit_trigger_row)
    drop_trigger(:vehicle_job_units, :audit_trigger_stm)
    drop_trigger(:vehicle_job_units, :set_created_at)
    drop_function(:vehicle_job_units_set_created_at)
    drop_trigger(:vehicle_job_units, :set_updated_at)
    drop_function(:vehicle_job_units_set_updated_at)
    drop_table(:vehicle_job_units)

    drop_trigger(:vehicle_jobs, :audit_trigger_row)
    drop_trigger(:vehicle_jobs, :audit_trigger_stm)
    drop_trigger(:vehicle_jobs, :set_created_at)
    drop_function(:vehicle_jobs_set_created_at)
    drop_trigger(:vehicle_jobs, :set_updated_at)
    drop_function(:vehicle_jobs_set_updated_at)
    drop_table(:vehicle_jobs)

    drop_table(:vehicles)
    drop_table(:vehicle_types)

    drop_trigger(:mr_inventory_transaction_items, :audit_trigger_row)
    drop_trigger(:mr_inventory_transaction_items, :audit_trigger_stm)
    drop_table(:mr_inventory_transaction_items)

    drop_trigger(:mr_inventory_transactions, :audit_trigger_row)
    drop_trigger(:mr_inventory_transactions, :audit_trigger_stm)
    drop_table(:mr_inventory_transactions)
    drop_table(:mr_inventory_transaction_types)

    drop_trigger(:mr_sku_locations, :audit_trigger_row)
    drop_trigger(:mr_sku_locations, :audit_trigger_stm)
    drop_table(:mr_sku_locations)

    drop_trigger(:mr_skus, :audit_trigger_row)
    drop_trigger(:mr_skus, :audit_trigger_stm)
    drop_trigger(:mr_skus, :set_created_at)
    drop_function(:mr_skus_set_created_at)
    drop_trigger(:mr_skus, :set_updated_at)
    drop_function(:mr_skus_set_updated_at)
    drop_table(:mr_skus)

    drop_trigger(:mr_delivery_item_batches, :audit_trigger_row)
    drop_trigger(:mr_delivery_item_batches, :audit_trigger_stm)
    drop_trigger(:mr_delivery_item_batches, :set_created_at)
    drop_function(:mr_delivery_item_batches_set_created_at)
    drop_trigger(:mr_delivery_item_batches, :set_updated_at)
    drop_function(:mr_delivery_item_batches_set_updated_at)
    drop_table(:mr_delivery_item_batches)


    drop_trigger(:user_defined_batches, :audit_trigger_row)
    drop_trigger(:user_defined_batches, :audit_trigger_stm)
    drop_trigger(:user_defined_batches, :set_created_at)
    drop_function(:user_defined_batches_set_created_at)
    drop_trigger(:user_defined_batches, :set_updated_at)
    drop_function(:user_defined_batches_set_updated_at)
    drop_table(:user_defined_batches)

    drop_trigger(:mr_purchase_order_items, :audit_trigger_row)
    drop_trigger(:mr_purchase_order_items, :audit_trigger_stm)
    drop_trigger(:mr_purchase_order_items, :set_created_at)
    drop_function(:mr_purchase_order_items_set_created_at)
    drop_trigger(:mr_purchase_order_items, :set_updated_at)
    drop_function(:mr_purchase_order_items_set_updated_at)
    drop_table(:mr_purchase_order_items)

    drop_trigger(:mr_purchase_order_costs, :audit_trigger_row)
    drop_trigger(:mr_purchase_order_costs, :audit_trigger_stm)
    drop_table(:mr_purchase_order_costs)

    run 'DROP SEQUENCE doc_seqs_po_number;'
    drop_trigger(:mr_purchase_orders, :audit_trigger_row)
    drop_trigger(:mr_purchase_orders, :audit_trigger_stm)
    drop_trigger(:mr_purchase_orders, :set_created_at)
    drop_function(:mr_purchase_orders_set_created_at)
    drop_trigger(:mr_purchase_orders, :set_updated_at)
    drop_function(:mr_purchase_orders_set_updated_at)
    drop_table(:mr_purchase_orders)

    drop_table(:mr_cost_types)
    drop_table(:mr_delivery_terms)
    drop_table(:mr_vat_types)
    drop_table(:mr_uoms)

    drop_trigger(:uoms, :set_created_at)
    drop_function(:uoms_set_created_at)
    drop_trigger(:uoms, :set_updated_at)
    drop_function(:uoms_set_updated_at)
    drop_table(:uoms)

    drop_table(:uom_types)

    drop_table(:business_processes)

    create_table(:measurement_units_for_matres_types)
    create_table(:measurement_units)
  end
end
