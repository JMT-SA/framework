# frozen_string_literal: true

module DevelopmentApp
  class ExportDataEventLogRepo < BaseRepo
    crud_calls_for :export_data_event_logs,
                   name: :export_data_event_log,
                   wrapper: ExportDataEventLog,
                   exclude: %i[update delete]

    def update_export_data_event_log(id, changeset)
      str = get(:export_data_event_logs, id, :event_log)
      changeset[:event_log] = "#{str}\n#{wrap_log_time(changeset[:event_log])}"
      update(:export_data_event_logs, id, changeset)
    end

    def wrap_log_time(msg)
      "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}: #{msg}"
    end

    def run_report(sql)
      DB[sql].all
    end
  end
end
