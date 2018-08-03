require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:program_functions, ignore_index_errors: true) do
      primary_key :id
      foreign_key :program_id, :programs, null: false, key: [:id]
      String :program_function_name, size: 255, null: false
      String :group_name, size: 255
      String :url, size: 255, null: false
      Integer :program_function_sequence, default: 0, null: false
      TrueClass :restricted_user_access, default: false
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:program_id], name: :fki_program_functions_program
    end

    pgt_created_at(:program_functions,
                   :created_at,
                   function_name: :program_functions_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:program_functions,
                   :updated_at,
                   function_name: :program_functions_set_updated_at,
                   trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:program_functions, :set_created_at)
    drop_function(:program_functions_set_created_at)
    drop_trigger(:program_functions, :set_updated_at)
    drop_function(:program_functions_set_updated_at)
    drop_table(:program_functions)
  end
end
