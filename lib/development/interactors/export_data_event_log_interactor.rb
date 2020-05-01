# frozen_string_literal: true

module DevelopmentApp
  class ExportDataEventLogInteractor < BaseInteractor
    def repo
      @repo ||= ExportDataEventLogRepo.new
    end

    def export_data_event_log(id)
      repo.find_export_data_event_log(id)
    end
  end
end
