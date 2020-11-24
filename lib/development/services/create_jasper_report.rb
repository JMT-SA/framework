# frozen_string_literal: true

require 'drb/drb'

# Generate a file or print from a Jasper report.
#
# To run:
#     jasper_params = JasperParams.new('adc', current_user.login_name, param1: 'val', param2: 123)
#     CreateJasperReport.call(jasper_params)
#
# The report is generated with the following default parameters which can be overridden (e.g. jasper_param.mode = :xls)
# - mode: :pdf. Can be :rtf, :xls, :csv or :print.
# - file_name: Same as report_name. This is the name of the output file without extension.
# - printer: nil. In :print mode, this MUST be provided.
#
# A note about report variants...
# -------------------------------
# A report dir in the JAPSER_REPORTS_PATH will be available for all installations.
# A report dir in a sub dir named by the RPT_INDUSTRY will be specific to the current installation's industry.
# A report dir in a sub dir named by the CLIENT_CODE will be specific to the current implementation (client) only.
#
# This service will check to see if there is a client-specific report and use it if present by overwriting the parent_folder value.
#
class CreateJasperReport < BaseService # rubocop:disable Metrics/ClassLength
  attr_reader :jasper_params, :parent_folder, :repo

  FILE_TYPES = {
    pdf: 'pdf',
    xls: 'xlsx',
    rtf: 'rtf',
    csv: 'csv'
  }.freeze

  def initialize(jasper_params)
    @repo = DevelopmentApp::JasperReportRepo.new
    @jasper_params = jasper_params
    @parent_folder = jasper_params.parent_folder
    @output_file = add_output_path
    @file_type = FILE_TYPES[jasper_params.mode]
    adjust_parent_folder
  end

  def call
    log_report_details
    output = if jasper_params.mode == :print
               print_report
             else
               generate_report
             end

    if output[:success]
      handle_success(output)
    else
      handle_failure(output)
    end
  end

  private

  def handle_success(output)
    log_report_result(output)
    if jasper_params.mode == :print
      success_response("Report has been sent to #{jasper_params.printer} for printing")
    else
      save_file(output)
      success_response('Report has been generated', download_file)
    end
  end

  def handle_failure(output)
    send_error_mail(output)
    log_report_result(output)
    failed_response("Jasper printing error: <br>#{output[:msg]}")
  end

  def print_report
    repo.print_report(jasper_params.user_name,
                      jasper_params.report_name,
                      report_dir,
                      jasper_params.printer,
                      jasper_params.params)
  end

  def generate_report
    repo.generate_report_string(jasper_params.user_name,
                                jasper_params.report_name,
                                report_dir,
                                jasper_params.mode,
                                jasper_params.params)
  end

  def save_file(output)
    file = "#{@output_file}.#{@file_type}"
    File.open(file, 'w') { |f| f << output[:doc] }
  end

  def send_error_mail(result) # rubocop:disable Metrics/AbcSize
    e_type = result[:error_type] ? "#{result[:error_type]}: " : ''
    trace = result[:backtrace] ? "\n\n#{result[:backtrace].join("\n")}" : ''
    body = <<~STR
      Jasper report "#{jasper_params.report_name}" did not succeed.

      Error  : #{e_type}#{result[:msg]}

      User   : #{jasper_params.user_name}

      Mode   : #{show_mode}

      Params : #{jasper_params.params.inspect}

      Result : #{result}
      #{trace}
    STR
    ErrorMailer.send_error_email(subject: "Jasper error for #{jasper_params.report_name}",
                                 message: body)
  end

  def download_file
    file = "#{@output_file}.#{@file_type.downcase}"
    return file if jasper_params.return_full_path

    File.relative_path(File.join(ENV['ROOT'], 'public'), file)
  end

  def log_report_details
    puts "--- JASPER REPORT : #{jasper_params.report_name} :: #{Time.now}"
    puts "USER   : #{jasper_params.user_name}"
    puts "MODE   : #{show_mode}"
    puts "PARAMS : #{jasper_params.params.inspect}"
    puts '-'
  end

  def show_mode
    if jasper_params.mode == :print
      "Print to #{jasper_params.printer}"
    else
      jasper_params.mode
    end
  end

  def log_report_result(result)
    puts "RESULT : #{result[:msg]}"
    puts '---'
  end

  def adjust_parent_folder
    return unless AppConst::CLIENT_CODE

    return unless File.exist?(File.join(AppConst::JASPER_REPORTS_PATH, AppConst::CLIENT_CODE, jasper_params.report_name))

    @parent_folder = AppConst::CLIENT_CODE
  end

  def report_dir
    @report_dir ||= if parent_folder.nil_or_empty?
                      AppConst::JASPER_REPORTS_PATH
                    else
                      "#{AppConst::JASPER_REPORTS_PATH}/#{parent_folder}"
                    end
  end

  def add_output_path
    File.join(ENV['ROOT'], 'public', 'downloads', 'jasper', jasper_params.file_name)
  end
end
