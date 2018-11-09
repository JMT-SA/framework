require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:registered_mobile_devices, ignore_index_errors: true) do
      primary_key :id
      inet :ip_address, null: false
      foreign_key :start_page_program_function_id, :program_functions, key: [:id]
      TrueClass :active, default: true
      TrueClass :scan_with_camera, default: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:ip_address], name: :registered_mobile_devices_unique_ip, unique: true
    end

    pgt_created_at(:registered_mobile_devices,
                   :created_at,
                   function_name: :registered_mobile_devices_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:registered_mobile_devices,
                   :updated_at,
                   function_name: :registered_mobile_devices_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('registered_mobile_devices', true, true, '{updated_at}'::text[]);"
  end

  down do
    # Drop logging for this table.
    drop_trigger(:registered_mobile_devices, :audit_trigger_row)
    drop_trigger(:registered_mobile_devices, :audit_trigger_stm)

    drop_trigger(:registered_mobile_devices, :set_created_at)
    drop_function(:registered_mobile_devices_set_created_at)
    drop_trigger(:registered_mobile_devices, :set_updated_at)
    drop_function(:registered_mobile_devices_set_updated_at)
    drop_table(:registered_mobile_devices)
  end
end
