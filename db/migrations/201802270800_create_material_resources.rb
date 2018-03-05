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
  end

  down do
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
