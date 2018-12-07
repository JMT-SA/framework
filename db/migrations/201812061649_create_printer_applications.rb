require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:printer_applications, ignore_index_errors: true) do
      primary_key :id
      foreign_key :printer_id, :printers, null: false
      String :application, size: 255, null: false
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:printer_id, :application], name: :printer_applications_application_unique, unique: true
    end

    pgt_created_at(:printer_applications,
                   :created_at,
                   function_name: :printer_applications_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:printer_applications,
                   :updated_at,
                   function_name: :printer_applications_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('printer_applications', true, true, '{updated_at}'::text[]);"
  end

  down do
    # Drop logging for this table.
    drop_trigger(:printer_applications, :audit_trigger_row)
    drop_trigger(:printer_applications, :audit_trigger_stm)

    drop_trigger(:printer_applications, :set_created_at)
    drop_function(:printer_applications_set_created_at)
    drop_trigger(:printer_applications, :set_updated_at)
    drop_function(:printer_applications_set_updated_at)
    drop_table(:printer_applications)
  end
end
