# frozen_string_literal: true

module LabelApp
  class PrinterInteractor < BaseInteractor
    def repo
      @repo ||= PrinterRepo.new
    end

    def refresh_printers
      mes_repo = MesserverApp::MesserverRepo.new
      res = mes_repo.printer_list
      if res.success
        repo.refresh_and_add_printers(AppConst::LABEL_SERVER_URI, res.instance)
        success_response('Refreshed printers')
      else
        failed_response(res.message)
      end
    end

    def refresh_server_printers(ip_address)
      printer_codes = `lpstat -a | cut -f1 -d ' '`.chomp.split("\n")
      repo.refresh_and_add_server_printers(ip_address, printer_codes)
      success_response('Refreshed printers')
    end

    def printer_application(id)
      repo.find_printer_application(id)
    end

    def validate_printer_application_params(params)
      PrinterApplicationSchema.call(params)
    end

    def create_printer_application(params) # rubocop:disable Metrics/AbcSize
      res = validate_printer_application_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_printer_application(res)
        repo.unset_default_printer(id, res) if res.to_h[:default_printer]
        log_status(:printer_applications, id, 'CREATED')
        log_transaction
      end
      instance = printer_application(id)
      success_response("Created printer application #{instance.application}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { application: ['This printer application already exists'] }))
    end

    def update_printer_application(id, params) # rubocop:disable Metrics/AbcSize
      res = validate_printer_application_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_printer_application(id, res)
        repo.unset_default_printer(id, res) if res.to_h[:default_printer]
        log_transaction
      end
      instance = printer_application(id)
      success_response("Updated printer application #{instance.application}",
                       instance)
    end

    def delete_printer_application(id)
      name = printer_application(id).application
      repo.transaction do
        repo.delete_printer_application(id)
        log_status(:printer_applications, id, 'DELETED')
        log_transaction
      end
      success_response("Deleted printer application #{name}")
    end
  end
end
