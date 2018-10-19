# require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
    alter_table(:material_resource_sub_types) do
      drop_index :sub_type_name, name: :material_resource_sub_types_unique_sub_type_name
      add_unique_constraint [:material_resource_type_id, :sub_type_name], name: :material_resource_sub_types_unique_sub_type_name_per_type
    end
  end

  down do
    alter_table(:material_resource_sub_types) do
      add_index [:sub_type_name], name: :material_resource_sub_types_unique_sub_type_name, unique: true
      drop_constraint :material_resource_sub_types_unique_sub_type_name_per_type
    end
  end
end
