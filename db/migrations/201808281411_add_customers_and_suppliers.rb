require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:customer_types, ignore_index_errors: true) do
      primary_key :id
      String :type_code, null: false
      index [:type_code], name: :customer_types_unique_type_code, unique: true
    end

    create_table(:customers, ignore_index_errors: true) do
      primary_key :id
      foreign_key :party_role_id, :party_roles, null: false, key: [:id]
      String :erp_customer_number
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:party_role_id], name: :fki_customers_party_roles, unique: true
    end
    pgt_created_at(:customers, :created_at, function_name: :customers_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:customers, :updated_at, function_name: :customers_set_updated_at, trigger_name: :set_updated_at)

    create_table(:customers_customer_types, ignore_index_errors: true) do
      foreign_key :customer_id, :customers, null: false, key: [:id]
      foreign_key :customer_type_id, :customer_types, null: false, key: [:id]
    end

    create_table(:supplier_types, ignore_index_errors: true) do
      primary_key :id
      String :type_code, null: false
      index [:type_code], name: :supplier_types_unique_type_code, unique: true
    end

    create_table(:suppliers, ignore_index_errors: true) do
      primary_key :id
      foreign_key :party_role_id, :party_roles, null: false, key: [:id]
      String :erp_supplier_number
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:party_role_id], name: :fki_suppliers_party_roles, unique: true
    end
    pgt_created_at(:suppliers, :created_at, function_name: :suppliers_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:suppliers, :updated_at, function_name: :suppliers_set_updated_at, trigger_name: :set_updated_at)

    create_table(:suppliers_supplier_types, ignore_index_errors: true) do
      foreign_key :supplier_id, :suppliers, null: false, key: [:id]
      foreign_key :supplier_type_id, :supplier_types, null: false, key: [:id]
    end

    drop_table(:party_roles_for_material_resource_variants)
    drop_trigger(:material_resource_variants, :set_created_at)
    drop_function(:material_resource_variants_set_created_at)
    drop_trigger(:material_resource_variants, :set_updated_at)
    drop_function(:material_resource_variants_set_updated_at)
    drop_table(:material_resource_variants)

    create_table(:material_resource_product_variants, ignore_index_errors: true) do
      primary_key :id
      foreign_key :sub_type_id, :material_resource_sub_types, null: false, key: [:id]
      Integer :product_variant_id, null: false
      String :product_variant_table_name, null: false
      Bignum :product_variant_number, null: false
      String :product_variant_code, null: false

      String :old_product_code
      Integer :supplier_lead_time
      Integer :minimum_stock_level
      Integer :re_order_stock_level

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
    pgt_created_at(:material_resource_product_variants, :created_at, function_name: :material_resource_product_variants_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:material_resource_product_variants, :updated_at, function_name: :material_resource_product_variants_set_updated_at, trigger_name: :set_updated_at)

    # create_table(:alternate_material_resource_product_variants, ignore_index_errors: true) do
    #   primary_key :id
    #   Integer :material_resource_product_variant_id, null: false
    #   Integer :alternate_product_variant_id
    #   Integer :co_use_product_variant_id
    # end

    create_table(:material_resource_product_variant_party_roles, ignore_index_errors: true) do
      primary_key :id
      foreign_key :material_resource_product_variant_id, :material_resource_product_variants, null: false, key: [:id]
      foreign_key :supplier_id, :suppliers, key: [:id]
      foreign_key :customer_id, :customers, key: [:id]

      String :party_stock_code
      Integer :supplier_lead_time
      TrueClass :is_preferred_supplier, default: true

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:material_resource_product_variant_id], name: :fki_matres_product_variant_party_role_variants
      index [:supplier_id], name: :fki_matres_product_variant_party_role_suppliers
      index [:customer_id], name: :fki_matres_product_variant_party_role_customers
    end
    pgt_created_at(:material_resource_product_variant_party_roles, :created_at, function_name: :material_resource_product_variant_party_roles_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:material_resource_product_variant_party_roles, :updated_at, function_name: :material_resource_product_variant_party_roles_set_updated_at, trigger_name: :set_updated_at)

    run "UPDATE programs SET program_name = 'Configuration' WHERE program_name = 'Config';"
    run "UPDATE program_functions SET program_function_name = 'Products' WHERE program_function_name = 'Product Codes';"
    run "UPDATE program_functions SET program_function_name = 'Product codes' WHERE program_function_name = 'Product Variants';"

    create_table(:alternative_material_resource_product_variants, ignore_index_errors: true) do
      foreign_key :material_resource_product_variant_id, :material_resource_product_variants, null: false, key: [:id]
      foreign_key :alternative_id, :material_resource_product_variants, null: false, key: [:id]
      unique [:material_resource_product_variant_id, :alternative_id]
    end

    create_table(:co_use_material_resource_product_variants, ignore_index_errors: true) do
      foreign_key :material_resource_product_variant_id, :material_resource_product_variants, null: false, key: [:id]
      foreign_key :co_use_id, :material_resource_product_variants, null: false, key: [:id]
      unique [:material_resource_product_variant_id, :co_use_id]
    end

    run "INSERT INTO material_resource_product_variants (product_variant_id, product_variant_table_name,
        product_variant_number, product_variant_code, sub_type_id)
        SELECT mrpv.id, 'pack_material_product_variants', mrpv.product_variant_number, mrpv.product_variant_code,
          pack_material_products.material_resource_sub_type_id
        from pack_material_product_variants mrpv
        join pack_material_products on mrpv.pack_material_product_id = pack_material_products.id"
  end

  down do
    drop_table(:co_use_material_resource_product_variants)
    drop_table(:alternative_material_resource_product_variants)

    run "UPDATE programs SET program_name = 'Config' WHERE program_name = 'Configuration';"
    run "UPDATE program_functions SET program_function_name = 'Product Codes' WHERE program_function_name = 'Products';"
    run "UPDATE program_functions SET program_function_name = 'Product Variants' WHERE program_function_name = 'Product codes';"

    create_table(:material_resource_variants, ignore_index_errors: true) do
      primary_key :id
    end
    pgt_created_at(:material_resource_variants, :created_at, function_name: :material_resource_variants_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:material_resource_variants, :updated_at, function_name: :material_resource_variants_set_updated_at, trigger_name: :set_updated_at)

    create_table(:party_roles_for_material_resource_variants, ignore_index_errors: true) do
      primary_key :id
    end

    drop_table(:material_resource_product_variant_party_roles)
    # drop_table(:alternate_material_resource_product_variants)

    drop_trigger(:material_resource_product_variants, :set_created_at)
    drop_function(:material_resource_product_variants_set_created_at)
    drop_trigger(:material_resource_product_variants, :set_updated_at)
    drop_function(:material_resource_product_variants_set_updated_at)
    drop_table(:material_resource_product_variants)

    drop_table(:suppliers_supplier_types)
    drop_trigger(:suppliers, :set_created_at)
    drop_function(:suppliers_set_created_at)
    drop_trigger(:suppliers, :set_updated_at)
    drop_function(:suppliers_set_updated_at)
    drop_table(:suppliers)
    drop_table(:supplier_types)

    drop_table(:customers_customer_types)
    drop_trigger(:customers, :set_created_at)
    drop_function(:customers_set_created_at)
    drop_trigger(:customers, :set_updated_at)
    drop_function(:customers_set_updated_at)
    drop_table(:customers)
    drop_table(:customer_types)
  end
end
