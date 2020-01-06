require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:mes_modules, ignore_index_errors: true) do
      primary_key :id
      String :module_code, null: false
      String :module_type, null: false
      inet :server_ip, null: false
      inet :ip_address, null: false
      Integer :port, null: false
      String :alias, null: false
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:server_ip, :module_code], name: :mes_modules_unique_ip_code, unique: true
    end

    pgt_created_at(:mes_modules,
                   :created_at,
                   function_name: :mes_modules_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:mes_modules,
                   :updated_at,
                   function_name: :mes_modules_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('mes_modules', true, true, '{updated_at}'::text[]);"
  end

  down do
    # Drop logging for this table.
    drop_trigger(:mes_modules, :audit_trigger_row)
    drop_trigger(:mes_modules, :audit_trigger_stm)

    drop_trigger(:mes_modules, :set_created_at)
    drop_function(:mes_modules_set_created_at)
    drop_trigger(:mes_modules, :set_updated_at)
    drop_function(:mes_modules_set_updated_at)
    drop_table(:mes_modules)
  end
end
