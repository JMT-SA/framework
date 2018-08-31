require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    # LOCATION TYPES
    # --------------
    create_table(:location_types, ignore_index_errors: true) do
      primary_key :id
      String :location_type_code, size: 255, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:location_type_code], name: :location_types_unique_code, unique: true
    end

    pgt_created_at(:location_types,
                   :created_at,
                   function_name: :location_types_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:location_types,
                   :updated_at,
                   function_name: :location_types_set_updated_at,
                   trigger_name: :set_updated_at)

    # LOCATION ASSIGNMENTS
    # --------------------
    create_table(:location_assignments, ignore_index_errors: true) do
      primary_key :id
      String :assignment_code, size: 255, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:assignment_code], name: :location_assignments_unique_code, unique: true
    end

    pgt_created_at(:location_assignments,
                   :created_at,
                   function_name: :location_assignments_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:location_assignments,
                   :updated_at,
                   function_name: :location_assignments_set_updated_at,
                   trigger_name: :set_updated_at)

    # LOCATION STORAGE TYPES
    # ----------------------
    create_table(:location_storage_types, ignore_index_errors: true) do
      primary_key :id
      String :storage_type_code, size: 255, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:storage_type_code], name: :location_storage_types_unique_code, unique: true
    end

    pgt_created_at(:location_storage_types,
                   :created_at,
                   function_name: :location_storage_types_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:location_storage_types,
                   :updated_at,
                   function_name: :location_storage_types_set_updated_at,
                   trigger_name: :set_updated_at)

    # LOCATIONS
    # ---------
    create_table(:locations, ignore_index_errors: true) do
      primary_key :id
      foreign_key :primary_storage_type_id, :location_storage_types, type: :integer, null: false
      foreign_key :location_type_id, :location_types, type: :integer, null: false
      foreign_key :primary_assignment_id, :location_assignments, type: :integer, null: false
      String :location_code, size: 255, null: false
      String :location_description, size: 255, null: false
      TrueClass :active, default: true
      TrueClass :has_single_container, default: false
      TrueClass :virtual_location, default: false
      TrueClass :consumption_area, default: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:location_code], name: :locations_unique_code, unique: true
    end

    pgt_created_at(:locations,
                   :created_at,
                   function_name: :locations_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:locations,
                   :updated_at,
                   function_name: :locations_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('locations', true, true, '{updated_at}'::text[]);"

    # LOCATION ASSIGNMENTS LOCATIONS
    # ------------------------------
    create_table(:location_assignments_locations, ignore_index_errors: true) do
      foreign_key :location_assignment_id, :location_assignments, null: false, key: [:id]
      foreign_key :location_id, :locations, null: false, key: [:id]
      
      primary_key [:location_assignment_id, :location_id], name: :location_assignments_locations_pk
    end

    # LOCATION STORAGE TYPES LOCATIONS
    # --------------------------------
    create_table(:location_storage_types_locations, ignore_index_errors: true) do
      foreign_key :location_storage_type_id, :location_storage_types, null: false, key: [:id]
      foreign_key :location_id, :locations, null: false, key: [:id]
      
      primary_key [:location_storage_type_id, :location_id], name: :location_storage_types_locations_pk
    end

    # TREE LOCATIONS
    # --------------
    create_table(:tree_locations, ignore_index_errors: true) do
      foreign_key :ancestor_location_id, :locations, null: false, key: [:id]
      foreign_key :descendant_location_id, :locations, null: false, key: [:id]
      Integer :path_length
      
      primary_key [:ancestor_location_id, :descendant_location_id], name: :tree_locations_pk
    end
  end

  down do
    drop_table(:tree_locations)

    drop_table(:location_assignments_locations)

    drop_table(:location_storage_types_locations)

    # Drop logging for this table.
    drop_trigger(:locations, :audit_trigger_row)
    drop_trigger(:locations, :audit_trigger_stm)

    drop_trigger(:locations, :set_created_at)
    drop_function(:locations_set_created_at)
    drop_trigger(:locations, :set_updated_at)
    drop_function(:locations_set_updated_at)
    drop_table(:locations)

    drop_trigger(:location_types, :set_created_at)
    drop_function(:location_types_set_created_at)
    drop_trigger(:location_types, :set_updated_at)
    drop_function(:location_types_set_updated_at)
    drop_table(:location_types)

    drop_trigger(:location_storage_types, :set_created_at)
    drop_function(:location_storage_types_set_created_at)
    drop_trigger(:location_storage_types, :set_updated_at)
    drop_function(:location_storage_types_set_updated_at)
    drop_table(:location_storage_types)

    drop_trigger(:location_assignments, :set_created_at)
    drop_function(:location_assignments_set_created_at)
    drop_trigger(:location_assignments, :set_updated_at)
    drop_function(:location_assignments_set_updated_at)
    drop_table(:location_assignments)
  end
end
