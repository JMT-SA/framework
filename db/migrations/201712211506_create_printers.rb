require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:printers, ignore_index_errors: true) do
      primary_key :id
      String :printer_code, size: 255, null: false
      String :printer_name, size: 255
      String :printer_type, size: 255
      Integer :pixels_per_mm
      String :printer_language, size: 255
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:printer_code], name: :printers_unique_code, unique: true
    end

    pgt_created_at(:printers,
                   :created_at,
                   function_name: :printers_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:printers,
                   :updated_at,
                   function_name: :printers_set_updated_at,
                   trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:printers, :set_created_at)
    drop_function(:printers_set_created_at)
    drop_trigger(:printers, :set_updated_at)
    drop_function(:printers_set_updated_at)
    drop_table(:printers)
  end
end
