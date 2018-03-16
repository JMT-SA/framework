# require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
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

    alter_table(:material_resource_sub_types) do
      add_column :product_code_separator, String, default: '_', null: false
      add_column :has_suppliers, TrueClass, default: false, null: false
      add_column :has_marketers, TrueClass, default: false, null: false
      add_column :has_retailer, TrueClass, default: false, null: false
      add_column :product_column_ids, 'integer[]'
      add_column :product_code_ids, 'integer[]'
    end
  end

  down do
    alter_table(:material_resource_sub_types) do
      drop_column :product_code_separator
      drop_column :has_suppliers
      drop_column :has_marketers
      drop_column :has_retailer
    end

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
end
