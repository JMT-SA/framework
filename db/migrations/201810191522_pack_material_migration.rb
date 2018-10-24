require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    drop_table(:measurement_units_for_matres_types)
    drop_table(:measurement_units)

    create_table(:business_processes) do
      primary_key :id
      String :business_process_name # String :name ? || code?
      String :description
    end

    # UNITS OF MEASURE
    # ----------------
    create_table(:units_of_measure_types, ignore_index_errors: true) do
      primary_key :id
      String :uom_type_code, null: false # code?

      index [:uom_type_code], name: :units_of_measure_types_unique_code, unique: true
    end

    create_table(:units_of_measure, ignore_index_errors: true) do
      primary_key :id
      foreign_key :units_of_measure_type_id, :units_of_measure_types, null: false, key: [:id]
      String :unit_of_measure_code, null: false
      # String :code ??

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:unit_of_measure_code, :units_of_measure_type_id], name: :fki_units_of_measure_codes_units_of_measure_types, unique: true
    end
    pgt_created_at(:units_of_measure,
                   :created_at,
                   function_name: :units_of_measure_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:units_of_measure,
                   :updated_at,
                   function_name: :units_of_measure_set_updated_at,
                   trigger_name: :set_updated_at)

    # MATERIAL RESOURCES UNITS OF MEASURE
    # -----------------------------------
    # create_table(:location_assignments_locations, ignore_index_errors: true) do
    #   foreign_key :location_assignment_id, :location_assignments, null: false, key: [:id]
    #   foreign_key :location_id, :locations, null: false, key: [:id]
    #
    #   primary_key [:location_assignment_id, :location_id], name: :location_assignments_locations_pk
    # end
    # I would rather want this to be two join tables
    # ignore index errors?
    # There will be one inventory type UOM and multiple conversions to that UOM
    #
    # alter_table(:material_resource_sub_types) do
    #   should there rather be an inventory_type_uom on here?
    # end
    # See: material_resource_purchase_order_items
    create_table(:material_resources_units_of_measure, ignore_index_errors: true) do
      primary_key :id
      foreign_key :units_of_measure_id, :units_of_measure, null: false, key: [:id]
      foreign_key :material_resource_sub_type_id, :material_resource_sub_types, key: [:id]
      foreign_key :material_resource_product_variant_id, :material_resource_product_variants, key: [:id]

      index [:material_resource_sub_type_id, :units_of_measure_id], name: :fki_material_resource_sub_types_units_of_measure, unique: true
      index [:material_resource_product_variant_id, :units_of_measure_id], name: :fki_material_resource_product_variants_units_of_measure, unique: true
    end

    create_table(:material_resources_units_of_measure_conversions, ignore_index_errors: true) do
      # Inventory type UOM of matres Sub type?
      primary_key :id
      foreign_key :from_uom_id, :material_resources_units_of_measure, null: false, key: [:id]
      foreign_key :to_uom_id, :material_resources_units_of_measure, null: false, key: [:id]
      BigDecimal :quantity, size: [7, 2]     # numeric(7, 2)

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:from_uom_id, :to_uom_id], name: :fki_material_resources_unit_of_measure_conversions, unique: true
    end
    pgt_created_at(:material_resources_units_of_measure_conversions,
                   :created_at,
                   function_name: :material_resources_units_of_measure_conversions_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:material_resources_units_of_measure_conversions,
                   :updated_at,
                   function_name: :material_resources_units_of_measure_conversions_set_updated_at,
                   trigger_name: :set_updated_at)

    # PURCHASE ORDERS
    # ---------------
    create_table(:material_resource_vat_types) do
      primary_key :id
      String :vat_type_code
      BigDecimal :percentage_applicable, size: [7, 2]     # numeric(7, 2)
      TrueClass :vat_not_applicable, default: false

      index [:vat_type_code], name: :material_resource_vat_types_unique_vat_type_code, unique: true
    end

    create_table(:material_resource_delivery_terms) do
      primary_key :id
      String :delivery_term_code
      TrueClass :is_consignment_stock, default: false

      index [:delivery_term_code], name: :material_resource_delivery_terms_unique_delivery_term_code, unique: true
    end

    create_table(:material_resource_cost_types) do
      primary_key :id
      String :cost_code_string

      index [:cost_code_string], name: :material_resource_cost_types_unique_cost_code_string, unique: true
    end

    create_table(:material_resource_purchase_orders) do
      primary_key :id
      foreign_key :material_resource_delivery_term_id, :material_resource_delivery_terms, key: [:id]
      foreign_key :supplier_party_role_id, :party_roles, key: [:id]
      foreign_key :material_resource_vat_type_id, :material_resource_vat_types, key: [:id]
      foreign_key :delivery_address_id, :addresses, key: [:id]

      # String :erp_supplier_number - a lookup from the supplier
      String :purchase_account_code
      String :fin_object_code # What is this?
      # String :process_status
      DateTime :valid_until
      Integer :purchase_order_number

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:purchase_order_number], name: :material_resource_purchase_orders_unique_purchase_order_number, unique: true
      index [:material_resource_delivery_term_id], name: :fki_material_resource_purchase_orders_material_resource_delivery_terms
      index [:supplier_party_role_id], name: :fki_material_resource_purchase_orders_supplier_party_roles
      index [:material_resource_vat_type_id], name: :fki_material_resource_purchase_orders_material_resource_vat_types
      index [:delivery_address_id], name: :fki_material_resource_purchase_orders_delivery_addresses
    end
    pgt_created_at(:material_resource_purchase_orders,
                   :created_at,
                   function_name: :material_resource_purchase_orders_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:material_resource_purchase_orders,
                   :updated_at,
                   function_name: :material_resource_purchase_orders_set_updated_at,
                   trigger_name: :set_updated_at)


    create_table(:material_resource_costs_for_purchase_order) do
      primary_key :id
      foreign_key :material_resource_cost_type_id, :material_resource_cost_types, key: [:id]
      foreign_key :material_resource_purchase_order_id, :material_resource_purchase_orders, key: [:id]
      BigDecimal :amount, size: [7, 2]

      #???

    end

    create_table(:material_resource_purchase_order_items) do
      primary_key :id
      foreign_key :material_resource_purchase_order_id, :material_resource_purchase_orders, key: [:id]
      foreign_key :material_resource_product_variant_id, :material_resource_product_variants, key: [:id]
      # foreign_key :purchasing_uom_id
      # foreign_key :inventory_uom_id
      BigDecimal :quantity_required, size: [7, 2]
      BigDecimal :unit_price, size: [7, 2]
      # String :process_status
      #
      # ??? fki
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

    end
    pgt_created_at(:material_resource_purchase_order_items,
                   :created_at,
                   function_name: :material_resource_purchase_order_items_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:material_resource_purchase_order_items,
                   :updated_at,
                   function_name: :material_resource_purchase_order_items_set_updated_at,
                   trigger_name: :set_updated_at)

    # SKUs, Batches & Inventory Transactions
    # --------------------------------------
    create_table(:user_defined_batches) do
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

    create_table(:material_resource_delivery_item_batches) do
      primary_key :id
      String :client_batch_number, text: true
      Integer :internal_batch_number
      BigDecimal :quantity_received_on_note, size: [7, 2]
      BigDecimal :actual_quantity_received, size: [7, 2]
      # String :process_status

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:internal_batch_number], name: :material_resource_delivery_item_batches_unique_internal_batch_number, unique: true
    end
    pgt_created_at(:material_resource_delivery_item_batches,
                   :created_at,
                   function_name: :material_resource_delivery_item_batches_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:material_resource_delivery_item_batches,
                   :updated_at,
                   function_name: :material_resource_delivery_item_batches_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:material_resource_skus) do
      primary_key :id
      foreign_key :material_resource_product_variant_id, :material_resource_product_variants, key: [:id]
      foreign_key :owner_party_role_id, :party_roles, key: [:id]
      foreign_key :material_resource_delivery_item_batch_id, :material_resource_delivery_item_batches, key: [:id]
      foreign_key :user_defined_batch_id, :user_defined_batches, key: [:id]

      TrueClass :is_consignment_stock, default: false
      Integer :quantity
      Integer :sku_number

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:sku_number], name: :material_resource_skus_unique_sku_number, unique: true
      index [:material_resource_product_variant_id], name: :fki_material_resource_skus_material_resource_product_variants
      index [:owner_party_role_id], name: :fki_material_resource_skus_party_roles
      index [:material_resource_delivery_item_batch_id], name: :fki_material_resource_skus_material_resource_item_batches
      index [:user_defined_batch_id], name: :fki_material_resource_skus_user_defined_batches
    end
    pgt_created_at(:material_resource_skus,
                   :created_at,
                   function_name: :material_resource_skus_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:material_resource_skus,
                   :updated_at,
                   function_name: :material_resource_skus_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:material_resource_sku_locations) do
      primary_key :id
      foreign_key :material_resource_sku_id, :material_resource_skus, key: [:id]
      foreign_key :location_id, :locations, key: [:id]

      Integer :material_resource_quantity
      index [:material_resource_sku_id, :location_id], name: :fki_material_resource_sku_locations #is this correct?
    end

    create_table(:material_resource_inventory_transaction_types) do
      primary_key :id
      String :transaction_type_name

      index [:transaction_type_name], name: :material_resource_inventory_transaction_types_unique_transaction_type_names, unique: true
    end

    create_table(:material_resource_inventory_transactions) do
      primary_key :id
      foreign_key :material_resource_inventory_transaction_type_id, :material_resource_inventory_transaction_types, key: [:id]
      foreign_key :to_location_id, :locations, key: [:id]
      foreign_key :business_process_id, :business_processes, key: [:id]

      String :created_by, null: false
      String :ref_no
      TrueClass :is_adhoc, default: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:ref_no, :material_resource_inventory_transaction_type_id], name: :material_resource_inventory_transactions_unique_ref_no, unique: true
    end
    pgt_created_at(:material_resource_inventory_transactions,
                   :created_at,
                   function_name: :material_resource_inventory_transactions_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:material_resource_inventory_transactions,
                   :updated_at,
                   function_name: :material_resource_inventory_transactions_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:material_resource_inventory_transaction_items) do
      primary_key :id
      foreign_key :material_resource_sku_id
      foreign_key :inventory_uom_id
      foreign_key :from_location_id
      foreign_key :material_resource_inventory_transaction_id

      BigDecimal :quantity, size: [7, 2]
    end

    # VEHICLES
    # --------
    create_table(:vehicle_types) do
      primary_key :id
      String :vehicle_type_code

      index [:vehicle_type_code], name: :vehicle_types_unique_vehicle_type_code, unique: true
    end

    create_table(:vehicles) do
      primary_key :id
      foreign_key :vehicle_type_id, :vehicle_types, key: [:id]
      String :vehicle_code

      index [:vehicle_code, :vehicle_type_id], name: :vehicles_unique_vehicle_code_per_type, unique: true
    end

    create_table(:vehicle_jobs) do
      primary_key :id
      foreign_key :business_process_id, :business_processes, key: [:id]
      foreign_key :vehicle_id, :vehicles, key: [:id]
      foreign_key :departure_location_id, :locations, key: [:id]

      Integer :trip_sheet_number
      String :planned_location_to
      DateTime :loaded
      DateTime :offloaded
      # String :process_status

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      # index [:business_process_id], name: :fki_vehicle_jobs_business_processes ???
    end
    pgt_created_at(:vehicle_jobs,
                   :created_at,
                   function_name: :vehicle_jobs_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:vehicle_jobs,
                   :updated_at,
                   function_name: :vehicle_jobs_set_updated_at,
                   trigger_name: :set_updated_at)


    create_table(:vehicle_job_units) do
      primary_key :id
      foreign_key :material_resource_sku_location_from_id, :locations, key: [:id]
      foreign_key :material_resource_inventory_transaction_item_id, :material_resource_inventory_transaction_items, key: [:id]

      Integer :vehicle_job_id
      # String :process_status
      Integer :quantity_to_move
      DateTime :loaded
      DateTime :offloaded
      DateTime :offloading
      Integer :quantity_moved

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

    end
    pgt_created_at(:vehicle_job_units,
                   :created_at,
                   function_name: :vehicle_job_units_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:vehicle_job_units,
                   :updated_at,
                   function_name: :vehicle_job_units_set_updated_at,
                   trigger_name: :set_updated_at)

    # DELIVERIES
    # ----------
    create_table(:material_resource_deliveries) do
      primary_key :id
      foreign_key :material_resource_inventory_receipt_transaction_id, :material_resource_inventory_transactions, key: [:id]
      foreign_key :material_resource_inventory_putaway_transaction_id, :material_resource_inventory_transactions, key: [:id]
      foreign_key :material_resource_purchase_order_id, :material_resource_purchase_orders, key: [:id], null: false
      # foreign_key :receiving_warehouse_location_id, :material_resource_purchase_orders, key: [:id] - is this still neccessary?
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
    end
    pgt_created_at(:material_resource_deliveries,
                   :created_at,
                   function_name: :material_resource_deliveries_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:material_resource_deliveries,
                   :updated_at,
                   function_name: :material_resource_deliveries_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:material_resource_delivery_items) do
      primary_key :id
      foreign_key :material_resource_delivery_id, :material_resource_deliveries, key: [:id]
      foreign_key :material_resource_purchase_order_item_id, :material_resource_purchase_order_items, key: [:id], null: false
      foreign_key :material_resource_product_variant_id, :material_resource_product_variants, key: [:id]

      BigDecimal :quantity_received_on_note, size: [7, 2]
      BigDecimal :quantity_over_supplied, size: [7, 2]
      BigDecimal :quantity_under_supplied, size: [7, 2]
      BigDecimal :actual_quantity_received, size: [7, 2]
      BigDecimal :invoiced_unit_price, size: [7, 2]
      # BigDecimal :received_on_note, size: [7, 2]
      # BigDecimal :over_supplied, size: [7, 2]
      # BigDecimal :under_supplied, size: [7, 2]
      # BigDecimal :actual_received, size: [7, 2]
      # BigDecimal :invoiced_unit_price, size: [7, 2]
      String :remarks # over_or_under_supply_remarks
    end
    pgt_created_at(:material_resource_delivery_items,
                   :created_at,
                   function_name: :material_resource_delivery_items_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:material_resource_delivery_items,
                   :updated_at,
                   function_name: :material_resource_delivery_items_set_updated_at,
                   trigger_name: :set_updated_at)
  end

  down do
    drop_table(:material_resource_delivery_items)
    drop_table(:material_resource_deliveries)

    drop_trigger(:vehicle_job_units, :set_created_at)
    drop_function(:vehicle_job_units_set_created_at)
    drop_trigger(:vehicle_job_units, :set_updated_at)
    drop_function(:vehicle_job_units_set_updated_at)
    drop_table(:vehicle_job_units)

    drop_trigger(:vehicle_jobs, :set_created_at)
    drop_function(:vehicle_jobs_set_created_at)
    drop_trigger(:vehicle_jobs, :set_updated_at)
    drop_function(:vehicle_jobs_set_updated_at)
    drop_table(:vehicle_jobs)

    drop_table(:vehicles)
    drop_table(:vehicle_types)

    drop_table(:material_resource_inventory_transaction_items)
    drop_table(:material_resource_inventory_transactions)
    drop_table(:material_resource_inventory_transaction_types)

    drop_table(:material_resource_sku_locations)
    drop_trigger(:material_resource_skus, :set_created_at)
    drop_function(:material_resource_skus_set_created_at)
    drop_trigger(:material_resource_skus, :set_updated_at)
    drop_function(:material_resource_skus_set_updated_at)
    drop_table(:material_resource_skus)

    drop_trigger(:material_resource_delivery_item_batches, :set_created_at)
    drop_function(:material_resource_delivery_item_batches_set_created_at)
    drop_trigger(:material_resource_delivery_item_batches, :set_updated_at)
    drop_function(:material_resource_delivery_item_batches_set_updated_at)
    drop_table(:material_resource_delivery_item_batches)

    drop_trigger(:user_defined_batches, :set_created_at)
    drop_function(:user_defined_batches_set_created_at)
    drop_trigger(:user_defined_batches, :set_updated_at)
    drop_function(:user_defined_batches_set_updated_at)
    drop_table(:user_defined_batches)

    drop_trigger(:material_resource_purchase_order_items, :set_created_at)
    drop_function(:material_resource_purchase_order_items_set_created_at)
    drop_trigger(:material_resource_purchase_order_items, :set_updated_at)
    drop_function(:material_resource_purchase_order_items_set_updated_at)
    drop_table(:material_resource_purchase_order_items)

    drop_table(:material_resource_costs_for_purchase_order)

    drop_trigger(:material_resource_purchase_orders, :set_created_at)
    drop_function(:material_resource_purchase_orders_set_created_at)
    drop_trigger(:material_resource_purchase_orders, :set_updated_at)
    drop_function(:material_resource_purchase_orders_set_updated_at)
    drop_table(:material_resource_purchase_orders)

    drop_table(:material_resource_cost_types)
    drop_table(:material_resource_delivery_terms)
    drop_table(:material_resource_vat_types)

    drop_trigger(:material_resources_units_of_measure_conversions, :set_created_at)
    drop_function(:material_resources_units_of_measure_conversions_set_created_at)
    drop_trigger(:material_resources_units_of_measure_conversions, :set_updated_at)
    drop_function(:material_resources_units_of_measure_conversions_set_updated_at)
    drop_table(:material_resources_units_of_measure_conversions)

    drop_table(:material_resources_units_of_measure)

    drop_trigger(:units_of_measure, :set_created_at)
    drop_function(:units_of_measure_set_created_at)
    drop_trigger(:units_of_measure, :set_updated_at)
    drop_function(:units_of_measure_set_updated_at)
    drop_table(:units_of_measure)

    drop_table(:units_of_measure_types)

    drop_table(:business_processes)

    create_table(:measurement_units_for_matres_types)
    create_table(:measurement_units)
  end
end
