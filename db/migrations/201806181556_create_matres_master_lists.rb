Sequel.migration do
  up do
    create_table(:material_resource_master_lists, ignore_index_errors: true) do
      primary_key :id
      foreign_key :material_resource_sub_type_id, :material_resource_sub_types, null: false, key: [:id]
      foreign_key :material_resource_product_column_id, :material_resource_product_columns, null: false, key: [:id]

      index [:material_resource_sub_type_id], name: :fki_material_resource_master_lists_sub_types
      index [:material_resource_product_column_id], name: :fki_material_resource_master_lists_product_columns
    end

    create_table(:material_resource_master_list_items, ignore_index_errors: true) do
      primary_key :id
      foreign_key :material_resource_master_list_id, :material_resource_master_lists, null: false, key: [:id]
      String :short_code, null: false
      String :long_name
      String :description
      TrueClass :active, default: true

      unique [:short_code, :material_resource_master_list_id]
    end
  end

  down do
    drop_table(:material_resource_master_list_items)
    drop_table(:material_resource_master_lists)
  end
end
