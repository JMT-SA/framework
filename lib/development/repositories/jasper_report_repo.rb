# frozen_string_literal: true

require 'drb/drb'

module DevelopmentApp
  class JasperReportRepo
    include Crossbeams::Responses

    JASPER_DB_OPTIONS = DB.opts.select { |k, _| %i[user password port host database].include?(k) }

    def generate_report_string(user, report, path, mode, params)
      DRb.start_service
      remote_object = DRbObject.new_with_uri("druby://#{AppConst::JRUBY_JASPER_HOST_PORT}")
      res = remote_object.make_jasper_report(user,
                                             report,
                                             path,
                                             mode,
                                             JASPER_DB_OPTIONS,
                                             params || {})

      DRb.stop_service
      res
    rescue DRb::DRbConnError => e
      DRb.stop_service # as ensure?
      msg = if e.cause
              e.cause.message
            else
              e.message
            end
      raise Crossbeams::FrameworkError, "The Jasper service is not reachable at #{AppConst::JRUBY_JASPER_HOST_PORT} : #{msg}"
    end

    def print_report(user, report, path, printer, params)
      DRb.start_service
      remote_object = DRbObject.new_with_uri("druby://#{AppConst::JRUBY_JASPER_HOST_PORT}")
      mod_params = (params || {}).merge(_printer_name: printer)
      res = remote_object.make_jasper_report(user,
                                             report,
                                             path,
                                             :print,
                                             JASPER_DB_OPTIONS,
                                             mod_params)

      DRb.stop_service
      res
    rescue DRb::DRbConnError => e
      DRb.stop_service
      msg = if e.cause
              e.cause.message
            else
              e.message
            end
      raise Crossbeams::FrameworkError, "The Jasper service is not reachable at #{AppConst::JRUBY_JASPER_HOST_PORT} : #{msg}"
    end
  end
end
