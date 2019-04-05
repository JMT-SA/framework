require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:location_storage_definitions, ignore_index_errors: true) do
      primary_key :id
      String :storage_definition_code, null: false
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:storage_definition_code], name: :location_storage_definitions_unique_, unique: true
    end
    pgt_created_at(:location_storage_definitions,
                   :created_at,
                   function_name: :location_storage_definitions_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:location_storage_definitions,
                   :updated_at,
                   function_name: :location_storage_definitions_set_updated_at,
                   trigger_name: :set_updated_at)

    alter_table(:locations) do
      add_foreign_key :location_storage_definition_id, :location_storage_definitions, null: true, key: [:id]
    end
  end

  down do
    alter_table(:locations) do
      drop_column :location_storage_definition_id
    end

    drop_trigger(:location_storage_definitions, :set_created_at)
    drop_function(:location_storage_definitions_set_created_at)
    drop_trigger(:location_storage_definitions, :set_updated_at)
    drop_function(:location_storage_definitions_set_updated_at)

    drop_table(:location_storage_definitions)
  end
end
