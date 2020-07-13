# frozen_string_literal: true

# Generate a file or print from a Jasper report.
#
# To run: CreateJasperReport.call(report_name: 'abc',
#                                 user: current_user.login_name,
#                                 file: file_name_without_extension_or_path,
#                                 params: hash_of_report_parameters)
#
# If params includes keep_file: true, the script that runs the report will be saved in
# the tmp dir below the root.
#
# The report is generated with the following default parameters which can be overridden (Note the case of the keys is important)):
# - MODE: 'GENERATE'. Generate will create a file, PRINT will send the report directly to the printer.
# - printer: 'no_printer'. In PRINT mode, this MUST be provided.
# - OUT_FILE_TYPE: 'PDF'. This can be PDF, CSV, XLS, RTF. Ignored in PRINT mode.
# - top_level_dir: ''. Use this if the report is stored in a subdir of the report dir.
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
  attr_reader :report_name, :user, :parent_folder, :keep_file, :top_level_dir, :printer, :report_parameters, :debug_mode

  NO_PRINTER = 'no_printer'

  def initialize(report_name:, user:, file:, parent_folder: nil, debug_mode: false, params: {}) # rubocop:disable Metrics/ParameterLists
    params = params.dup
    @report_name = report_name
    @user = user
    @parent_folder = parent_folder
    @debug_mode = debug_mode
    @keep_file = params.delete(:keep_file)
    @return_full_path = params.delete(:return_full_path)
    @top_level_dir = params.delete(:top_level_dir) || ''
    @printer = params.delete(:printer) || NO_PRINTER
    @output_file = add_output_path(file)
    adjust_parent_folder
    make_report_parameters_string(params)
  end

  def call # rubocop:disable Metrics/AbcSize
    result = run_report
    clear_temp_file
    log_report_result(result)

    if result.to_s.include?(error_string_key) && (errors = result.split(error_string_key)).length.positive?
      send_error_mail(result)
      failed_response("Jasper printing error: <br>#{errors[1]}")
    elsif @mode == 'GENERATE'
      success_response('Report has been generated', download_file)
    else
      success_response('Report has been sent to the printer')
    end
  end

  private

  def error_string_key
    @use_older_jasper_engine ? 'JMT Jasper error:' : 'Jasper error:'
  end

  def send_error_mail(result)
    body = <<~STR
      Jasper report "#{report_name}" did not succeed.

      Error  : #{result.split(error_string_key)[1].strip}

      User   : #{user}

      Command: #{command}

      Result : #{result}
    STR
    ErrorMailer.send_error_email(subject: "Jasper error for #{report_name}",
                                 message: body)
  end

  def download_file
    file = "#{@output_file}.#{@file_type.downcase}"
    return file if @return_full_path

    File.relative_path(File.join(ENV['ROOT'], 'public'), file)
  end

  def clear_temp_file
    File.delete(print_command_file_name) unless keep_file
  end

  def connection_string
    "jdbc:postgresql://#{DB.opts[:host]}:#{DB.opts[:port] || 5432}/#{DB.opts[:database]}?user=#{DB.opts[:user]}&password=#{DB.opts[:password]}"
  end

  def print_command_file_name
    @print_command_file_name ||= File.join(ENV['ROOT'], 'tmp', "#{report_name}_#{user}_#{Time.now.strftime('%m_%d_%Y_%H_%M_%S')}.sh")
  end

  def run_report
    log_report_details

    File.open(print_command_file_name, 'w') do |f|
      f.puts "cd #{path}"
      f.puts command
    end

    `sh #{print_command_file_name}`
  end

  def command
    @command ||= "#{debug_switch}java -jar JasperReportPrinter.jar \"#{report_dir}\" #{report_name} \"#{printer}\" \"#{connection_string}\" #{report_parameters}"
  end

  def debug_switch
    return '' unless debug_mode

    'DEBUG=y '
  end

  def log_report_details
    puts "--- JASPER REPORT : #{report_name} :: #{Time.now}"
    puts "USER   : #{user}"
    puts "COMMAND: #{command}"
    puts '-'
  end

  def log_report_result(result)
    puts "RESULT : #{result}"
    puts '---'
  end

  def adjust_parent_folder
    return unless AppConst::CLIENT_CODE

    return unless File.exist?(File.join(AppConst::JASPER_REPORTS_PATH, AppConst::CLIENT_CODE, @top_level_dir, @report_name))

    @parent_folder = AppConst::CLIENT_CODE
  end

  def report_dir
    @report_dir ||= "#{report_definitions_dir}/#{top_level_dir.blank? ? '' : top_level_dir + '/'}#{report_name}"
  end

  def path
    @path ||= ENV['JASPER_REPORTING_ENGINE_PATH']
  end

  # maybe check if dir exists under parent folder or not...
  def report_definitions_dir
    @report_definitions_dir ||= if parent_folder.nil_or_empty?
                                  AppConst::JASPER_REPORTS_PATH
                                else
                                  "#{AppConst::JASPER_REPORTS_PATH}/#{parent_folder}"
                                end
  end

  def add_output_path(file)
    File.join(ENV['ROOT'], 'public', 'downloads', 'jasper', file)
  end

  def make_report_parameters_string(params)
    params[:SUBREPORT_DIR] = "#{File.join(report_definitions_dir, @top_level_dir, @report_name)}/"
    @mode = params.fetch(:MODE, 'GENERATE')
    params[:MODE] ||= @mode
    @file_type = params.fetch(:OUT_FILE_TYPE, 'PDF').upcase
    params[:OUT_FILE_TYPE] = @file_type
    params[:OUT_FILE_NAME] = @output_file
    assert_params_valid!(params)
    @report_parameters = params.map { |k, v| "\"#{k}=#{v}\"" }.join(' ')
  end

  def assert_params_valid!(params)
    raise ArgumentError, "\"#{params[:MODE]}\" is not a valid MODE for Jasper printing (expect GENERATE or PRINT)" unless %w[GENERATE PRINT].include?(params.fetch(:MODE))
    raise ArgumentError, "\"#{params[:OUT_FILE_TYPE]}\" is not a valid OUT_FILE_TYPE for Jasper printing (expect PDF, CSV, XLS or RTF)" unless %w[PDF CSV XLS RTF].include?(params.fetch(:OUT_FILE_TYPE))
    raise ArgumentError, 'In print mode a printer must be included in the parameters' if @printer == NO_PRINTER && params[:MODE] == 'PRINT'
  end
end
