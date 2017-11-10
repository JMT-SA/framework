require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:contact_method_types, ignore_index_errors: true) do
      primary_key :id
      String :contact_method_type, size: 255, null:false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:contact_method_type], name: :contact_method_types_unique_code, unique: true
    end

    pgt_created_at(:contact_method_types,
                   :created_at,
                   function_name: :contact_method_types_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:contact_method_types,
                   :updated_at,
                   function_name: :contact_method_types_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:contact_methods, ignore_index_errors: true) do
      primary_key :id
      foreign_key :contact_method_type_id, :contact_method_types, type: :integer, null: false
      String :contact_method_code, size: 255, null:false
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:contact_method_type_id, :contact_method_code], name: :contact_methods_unique_code, unique: true
    end

    pgt_created_at(:contact_methods,
                   :created_at,
                   function_name: :contact_methods_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:contact_methods,
                   :updated_at,
                   function_name: :contact_methods_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:party_contact_methods, ignore_index_errors: true) do
      primary_key :id
      foreign_key :contact_method_id, :contact_methods, type: :integer, null: false
      foreign_key :party_id, :parties, type: :integer, null: false
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:contact_method_id], name: :fki_party_contact_methods_contact_method_id
      index [:party_id], name: :fki_party_contact_methods_party_id
    end

    pgt_created_at(:party_contact_methods,
                   :created_at,
                   function_name: :party_contact_methods_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:party_contact_methods,
                   :updated_at,
                   function_name: :party_contact_methods_set_updated_at,
                   trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:party_contact_methods, :set_created_at)
    drop_function(:party_contact_methods_set_created_at)
    drop_trigger(:party_contact_methods, :set_updated_at)
    drop_function(:party_contact_methods_set_updated_at)
    drop_table(:party_contact_methods)

    drop_trigger(:contact_methods, :set_created_at)
    drop_function(:contact_methods_set_created_at)
    drop_trigger(:contact_methods, :set_updated_at)
    drop_function(:contact_methods_set_updated_at)
    drop_table(:contact_methods)

    drop_trigger(:contact_method_types, :set_created_at)
    drop_function(:contact_method_types_set_created_at)
    drop_trigger(:contact_method_types, :set_updated_at)
    drop_function(:contact_method_types_set_updated_at)
    drop_table(:contact_method_types)
  end
end
