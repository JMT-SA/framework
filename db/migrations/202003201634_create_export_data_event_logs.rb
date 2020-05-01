require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:export_data_event_logs, ignore_index_errors: true) do
      primary_key :id
      String :export_key, null: false
      DateTime :started_at, null: false
      String :event_log, text: true
      TrueClass :complete, default: false
      DateTime :completed_at
      TrueClass :failed, default: false
      String :error_message
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end

    pgt_created_at(:export_data_event_logs,
                   :created_at,
                   function_name: :export_data_event_logs_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:export_data_event_logs,
                   :updated_at,
                   function_name: :export_data_event_logs_set_updated_at,
                   trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:export_data_event_logs, :set_created_at)
    drop_function(:export_data_event_logs_set_created_at)
    drop_trigger(:export_data_event_logs, :set_updated_at)
    drop_function(:export_data_event_logs_set_updated_at)
    drop_table(:export_data_event_logs)
  end
end
