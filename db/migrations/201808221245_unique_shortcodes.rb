# require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
    alter_table(:material_resource_types) do
      add_unique_constraint :short_code, name: :material_resource_type_short_codes
    end
    alter_table(:material_resource_sub_types) do
      add_unique_constraint [:material_resource_type_id, :short_code], name: :material_resource_sub_type_short_codes
    end
  end

  down do
    alter_table(:material_resource_sub_types) do
      drop_constraint :material_resource_sub_type_short_codes
    end
    alter_table(:material_resource_types) do
      drop_constraint :material_resource_type_short_codes
    end
  end
end
