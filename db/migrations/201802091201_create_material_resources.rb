require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:material_resource_domains, ignore_index_errors: true) do
      primary_key :id
      String :domain_name, null: false
      String :product_table_name, null: false
      String :variant_table_name, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:domain_name], name: :material_resource_domains_unique_domain_name, unique: true
      index [:product_table_name], name: :material_resource_domains_unique_product_table_name, unique: true
      index [:variant_table_name], name: :material_resource_domains_unique_variant_table_name, unique: true
    end
    pgt_created_at(:material_resource_domains, :created_at, function_name: :material_resource_domains_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:material_resource_domains, :updated_at, function_name: :material_resource_domains_set_updated_at, trigger_name: :set_updated_at)

    create_table(:material_resource_types, ignore_index_errors: true) do
      primary_key :id
      foreign_key :material_resource_domain_id, :material_resource_domains, null: false, key: [:id]
      String :type_name, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:type_name], name: :material_resource_types_unique_type_name, unique: true
      index [:material_resource_domain_id], name: :fki_material_resource_types_material_resource_domains
    end
    pgt_created_at(:material_resource_types, :created_at, function_name: :material_resource_types_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:material_resource_types, :updated_at, function_name: :material_resource_types_set_updated_at, trigger_name: :set_updated_at)

    create_table(:material_resource_sub_types, ignore_index_errors: true) do
      primary_key :id
      foreign_key :material_resource_type_id, :material_resource_types, null: false, key: [:id]
      String :sub_type_name, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:sub_type_name], name: :material_resource_sub_types_unique_sub_type_name, unique: true
      index [:material_resource_type_id], name: :fki_material_resource_sub_types_material_resource_types
    end
    pgt_created_at(:material_resource_sub_types, :created_at, function_name: :material_resource_sub_types_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:material_resource_sub_types, :updated_at, function_name: :material_resource_sub_types_set_updated_at, trigger_name: :set_updated_at)

    create_table(:material_resource_product_columns, ignore_index_errors: true) do
      primary_key :id
      foreign_key :material_resource_domain_id, :material_resource_domains, null: false, key: [:id]
      String :column_name, null: false
      String :group_name, null: false
      TrueClass :is_variant_column, default: false, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:column_name], name: :material_resource_product_columns_unique_column_name, unique: true
      index [:material_resource_domain_id], name: :fki_material_resource_product_columns_material_resource_domains
    end
    pgt_created_at(:material_resource_product_columns, :created_at, function_name: :material_resource_product_columns_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:material_resource_product_columns, :updated_at, function_name: :material_resource_product_columns_set_updated_at, trigger_name: :set_updated_at)

    create_table(:material_resource_type_configs, ignore_index_errors: true) do
      primary_key :id
      foreign_key :material_resource_sub_type_id, :material_resource_sub_types, null: false, key: [:id]
      String :product_code_separator, default: '_', null: false
      TrueClass :has_suppliers, default: false, null: false
      TrueClass :has_marketers, default: false, null: false
      TrueClass :has_retailer, default: false, null: false

      # user field label

      TrueClass :active, default: true, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
    pgt_created_at(:material_resource_type_configs, :created_at, function_name: :material_resource_type_configs_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:material_resource_type_configs, :updated_at, function_name: :material_resource_type_configs_set_updated_at, trigger_name: :set_updated_at)

    create_table(:material_resource_product_columns_for_material_resource_types, ignore_index_errors: true) do
      primary_key :id
      foreign_key :material_resource_product_column_id, :material_resource_product_columns, null: false, key: [:id]
      foreign_key :material_resource_type_config_id, :material_resource_type_configs, null: false, key: [:id]

      index [:material_resource_product_column_id], name: :fki_material_resource_product_columns_for_material_resource_types_material_resource_product_columns
      index [:material_resource_type_config_id], name: :fki_material_resource_product_columns_for_material_resource_types_material_resource_type_configs
    end

    create_table(:material_resource_type_product_code_columns, ignore_index_errors: true) do
      primary_key :id
      foreign_key :material_resource_product_columns_for_material_resource_type_id, :material_resource_product_columns_for_material_resource_types, null: false, key: [:id]
      Integer :position, default: 0, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:material_resource_product_columns_for_material_resource_type_id], name: :fki_mr_type_product_code_columns_mr_product_columns_for_mr_type_id
    end
    pgt_created_at(:material_resource_type_product_code_columns, :created_at, function_name: :material_resource_type_product_code_columns_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:material_resource_type_product_code_columns, :updated_at, function_name: :material_resource_type_product_code_columns_set_updated_at, trigger_name: :set_updated_at)

    create_table(:pack_material_products, ignore_index_errors: true) do
      primary_key :id
      foreign_key :material_resource_sub_type_id, :material_resource_sub_types, null: false, key: [:id]
      Integer :product_number, null: false
      String :description

      foreign_key :commodity_id, :commodities, null: false, key: [:id]
      # foreign_key :variety_id, :varieties, null: false, key: [:id]
      # String :commodity_id #Lookup
      String :variety_id #Lookup
      # String :variant
      String :style
      String :assembly_type
      String :market_major
      String :ctn_size_basic #Lookup
      String :ctn_size_old_pack #Lookup
      String :pls_pack_code #Lookup
      Numeric :fruit_mass_nett_kg #NOTE: should we add a unit in here for LB or KG
      String :holes
      String :perforation
      String :image, text: true
      Numeric :length_mm
      Numeric :width_mm
      Numeric :height_mm
      Numeric :diameter_mm
      Numeric :thick_mm
      Numeric :thick_mic
      String :colour
      String :grade
      String :mass
      String :material_type
      String :treatment
      String :specification_notes, text: true
      String :artwork_commodity
      String :artwork_marketing_variety_group
      String :artwork_variety
      String :artwork_nett_mass
      String :artwork_brand
      String :artwork_class
      Numeric :artwork_plu_number
      String :artwork_other
      String :artwork_image, text: true
      String :marketer #Lookup
      String :retailer #Lookup
      String :supplier #Lookup #AlwaysActive
      String :supplier_stock_code #AlwaysActive
      String :product_alternative #Validate if the product code given here is a valid entry
      String :product_joint_use #Validate if the product code given here is a valid entry
      String :ownership
      TrueClass :consignment_stock, default: false
      Date :start_date #AlwaysActive
      Date :end_date #AlwaysActive
      TrueClass :active, default: true #AlwaysActive
      String :remarks, text: true #AlwaysActive

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:material_resource_sub_type_id], name: :fki_pack_material_products_material_resource_sub_types
    end
    pgt_created_at(:pack_material_products, :created_at, function_name: :pack_material_products_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:pack_material_products, :updated_at, function_name: :pack_material_products_set_updated_at, trigger_name: :set_updated_at)

    create_table(:pack_material_product_variants, ignore_index_errors: true) do
      primary_key :id
      foreign_key :pack_material_product_id, :pack_material_products, null: false, key: [:id]
      TrueClass :standard, default: false
      Integer :product_variant_number

      # Some of the fields from the products table needs to move/copy over to here
      # This one is placed here as an example
      String :colour

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:pack_material_product_id], name: :fki_pack_material_product_variants_pack_material_products
    end
    pgt_created_at(:pack_material_product_variants, :created_at, function_name: :pack_material_product_variants_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:pack_material_product_variants, :updated_at, function_name: :pack_material_product_variants_set_updated_at, trigger_name: :set_updated_at)

    create_table(:material_resource_variants, ignore_index_errors: true) do
      primary_key :id
      foreign_key :parent_id, :material_resource_variants, key: [:id]
      Integer :variant_id
      Integer :product_variant_number
      String :variant_table_name
      TrueClass :standard, default: false
      TrueClass :is_composite, default: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:pack_material_product_id], name: :fki_pack_material_product_variants_pack_material_products
    end
    pgt_created_at(:material_resource_variants, :created_at, function_name: :material_resource_variants_set_created_at, trigger_name: :set_created_at)
    pgt_updated_at(:material_resource_variants, :updated_at, function_name: :material_resource_variants_set_updated_at, trigger_name: :set_updated_at)

    create_table(:party_roles_for_material_resource_variants, ignore_index_errors: true) do
      primary_key :id
      foreign_key :material_resource_variant_id, :material_resource_variants, null: false, key: [:id]
      foreign_key :party_role_id, :party_roles, null: false, key: [:id]

      index [:material_resource_variant_id], name: :fki_party_roles_for_material_resource_variants_material_resource_variants
      index [:party_role_id], name: :fki_party_roles_for_material_resource_variants_party_roles
    end
  end

  down do
    drop_table(:party_roles_for_material_resource_variants)

    drop_trigger(:material_resource_variants, :set_created_at)
    drop_function(:material_resource_variants_set_created_at)
    drop_trigger(:material_resource_variants, :set_updated_at)
    drop_function(:material_resource_variants_set_updated_at)
    drop_table(:material_resource_variants)

    drop_trigger(:pack_material_product_variants, :set_created_at)
    drop_function(:pack_material_product_variants_set_created_at)
    drop_trigger(:pack_material_product_variants, :set_updated_at)
    drop_function(:pack_material_product_variants_set_updated_at)
    drop_table(:pack_material_product_variants)

    drop_trigger(:pack_material_products, :set_created_at)
    drop_function(:pack_material_products_set_created_at)
    drop_trigger(:pack_material_products, :set_updated_at)
    drop_function(:pack_material_products_set_updated_at)
    drop_table(:pack_material_products)

    drop_trigger(:material_resource_type_product_code_columns, :set_created_at)
    drop_function(:material_resource_type_product_code_columns_set_created_at)
    drop_trigger(:material_resource_type_product_code_columns, :set_updated_at)
    drop_function(:material_resource_type_product_code_columns_set_updated_at)
    drop_table(:material_resource_type_product_code_columns)

    drop_table(:material_resource_product_columns_for_material_resource_types)

    drop_trigger(:material_resource_type_configs, :set_created_at)
    drop_function(:material_resource_type_configs_set_created_at)
    drop_trigger(:material_resource_type_configs, :set_updated_at)
    drop_function(:material_resource_type_configs_set_updated_at)
    drop_table(:material_resource_type_configs)

    drop_trigger(:material_resource_product_columns, :set_created_at)
    drop_function(:material_resource_product_columns_set_created_at)
    drop_trigger(:material_resource_product_columns, :set_updated_at)
    drop_function(:material_resource_product_columns_set_updated_at)
    drop_table(:material_resource_product_columns)

    drop_trigger(:material_resource_sub_types, :set_created_at)
    drop_function(:material_resource_sub_types_set_created_at)
    drop_trigger(:material_resource_sub_types, :set_updated_at)
    drop_function(:material_resource_sub_types_set_updated_at)
    drop_table(:material_resource_sub_types)

    drop_trigger(:material_resource_types, :set_created_at)
    drop_function(:material_resource_types_set_created_at)
    drop_trigger(:material_resource_types, :set_updated_at)
    drop_function(:material_resource_types_set_updated_at)
    drop_table(:material_resource_types)

    drop_trigger(:material_resource_domains, :set_created_at)
    drop_function(:material_resource_domains_set_created_at)
    drop_trigger(:material_resource_domains, :set_updated_at)
    drop_function(:material_resource_domains_set_updated_at)
    drop_table(:material_resource_domains)
  end
end
