# require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
    alter_table(:material_resource_sub_types) do
      add_column :product_variant_code_ids, 'integer[]'
      add_column :optional_product_variant_code_ids, 'integer[]'
    end
  end

  down do
    alter_table(:material_resource_sub_types) do
      drop_column :product_variant_code_ids
      drop_column :optional_product_variant_code_ids
    end
  end
end
