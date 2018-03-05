# require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  change do
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
  end
end
