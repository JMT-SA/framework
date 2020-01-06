# frozen_string_literal: true

module LabelApp
  class MesModuleInteractor < BaseInteractor
    def refresh_mes_modules
      mes_repo = MesserverApp::MesserverRepo.new
      res = mes_repo.mes_module_list
      if res.success
        repo.refresh_and_add_mes_modules(AppConst::LABEL_SERVER_URI, res.instance)
        success_response('Refreshed printers')
      else
        failed_response(res.message)
      end
    end

    private

    def repo
      @repo ||= PrinterRepo.new
    end

    def mes_module(id)
      repo.find_mes_module(id)
    end

    def validate_mes_module_params(params)
      MesModuleSchema.call(params)
    end
  end
end
