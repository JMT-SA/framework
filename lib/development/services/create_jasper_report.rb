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
class CreateJasperReport < BaseService
  attr_reader :report_name, :user, :keep_file, :top_level_dir, :printer, :report_parameters

  NO_PRINTER = 'no_printer'

  def initialize(report_name:, user:, file:, params: {})
    @report_name = report_name
    @user = user
    @keep_file = params.delete(:keep_file)
    @top_level_dir = params.delete(:top_level_dir) || ''
    @printer = params.delete(:printer) || NO_PRINTER
    @output_file = add_output_path(file)
    make_report_parameters_string(params)
  end

  def call
    result = run_report
    clear_temp_file
    log_report_result(result)

    if result.to_s.include?('JMT Jasper error:') && (errors = result.split('JMT Jasper error:')).length.positive?
      failed_response("Jasper printing error: <BR> #{errors[1]}")
    elsif @mode == 'GENERATE'
      success_response('Report has been generated', download_file)
    else
      success_response('Report has been sent to the printer')
    end
  end

  private

  def download_file
    File.relative_path(File.join(ENV['ROOT'], 'public'), "#{@output_file}.#{@file_type.downcase}")
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
    @command ||= "java -jar JasperReportPrinter.jar \"#{report_dir}\" #{report_name} \"#{printer}\" \"#{connection_string}\" #{report_parameters}"
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

  def report_dir
    @report_dir ||= "#{report_definitions_dir}/#{top_level_dir.blank? ? '' : top_level_dir + '/'}#{report_name}"
  end

  def path
    @path ||= ENV['JASPER_REPORTING_ENGINE_PATH']
  end

  def report_definitions_dir
    @report_definitions_dir ||= ENV['JASPER_REPORTS_PATH']
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
