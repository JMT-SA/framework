# frozen_string_literal: true

module Crossbeams
  # Export data to file using configuration settings
  # defined in config/export_data_config.yml
  #
  # Run using a valid key form the config file:
  # Crossbeams::ExportData.run('keyname')
  class ExportData # rubocop:disable Metrics/ClassLength
    attr_reader :key, :report, :recs

    class << self
      def run(*args)
        new(*args).run
      end
    end

    def initialize(key)
      @key = key
      @current_column = nil
      @log_id = nil
    end

    def run # rubocop:disable Metrics/AbcSize
      log('Starting export', start: true)

      validate
      set_defaults
      prepare
      run_report
      write_csv_file if for_csv?
      write_xls_file if for_xls?

      make_zip if config['zip_for_mail']
      send_mail if config['email']

      log('Export completed', complete: true)
    rescue StandardError => e
      handle_error(e)
    end

    def to_s
      "Key: #{key}, #{config.map { |k, v| "#{k} => #{v.inspect}" }}"
    end

    private

    def for_csv?
      @output_format == 'csv'
    end

    def for_xls?
      @output_format == 'xls'
    end

    def handle_error(err)
      message = if @current_column
                  "Failure in export of #{key} - column #{@current_column}"
                else
                  "Failure in export of #{key}"
                end
      ErrorMailer.send_exception_email(err, subject: "ExportData (#{key}) failed: #{err.message}", message: message)
      log('Export failed', failed: true, error_message: "#{message} - #{err.message}")
      puts err.message
    end

    def repo
      @repo ||= DevelopmentApp::ExportDataEventLogRepo.new
    end

    def validate
      raise ArgumentError, "#{key} is not a valid ExportData key" unless valid_key?
      raise ArgumentError, 'ExportData must have "out_dir"' unless valid_dir?
    end

    def log(msg, start: false, complete: false, failed: false, error_message: nil)
      if start
        @log_id = repo.create_export_data_event_log(event_log: repo.wrap_log_time(msg), export_key: key, started_at: Time.now)
      else
        changeset = { event_log: msg }
        if complete || failed
          changeset[:complete] = true
          changeset[:completed_at] = Time.now
        end
        changeset[:failed] = true if failed
        changeset[:error_message] = error_message if error_message
        repo.update_export_data_event_log(@log_id, changeset)
      end
    end

    def set_defaults # rubocop:disable Metrics/AbcSize
      @export_hidden_fields = config['export_hidden_fields'] == true
      @prefix_long_numbers_with_quote = config['prefix_long_numbers_with_quote'].nil? ? true : config['prefix_long_numbers_with_quote']
      @boolean_as_yn = config['boolean_as_yn'].nil? ? true : config['boolean_as_yn']
      @output_format = (config['output_format'] || 'csv').strip
    end

    def send_mail
      log('Send mail job starting')
      fn = config['zip_for_mail'] ? "#{output_file}.zip" : output_file
      email = config['email']

      DevelopmentApp::SendMailJob.enqueue(to: email['to'],
                                          subject: email['subject'],
                                          body: "Data extracted at #{Time.now.strftime('%Y-%m-%d %H:%M')}.\n#{email['body']}",
                                          attachments: [{ path: fn }])
    end

    def run_report
      log('Running query')
      apply_where_conditions
      @recs = repo.run_report(report.runnable_sql)
    end

    def write_csv_file # rubocop:disable Metrics/AbcSize
      log('Writing to file')
      CSV.open(output_file, 'w', headers: ordered_headers, write_headers: true) do |csv|
        recs.each do |rec|
          csv << report.ordered_columns.map do |col|
            @current_column = col.name
            format_column(col, rec[col.name.to_sym])
          end.compact
        end
      end
      @current_column = nil
    end

    def write_xls_file # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      xls_possible_types = { string: :string, integer: :integer, date: :string,
                             datetime: :time, time: :time, boolean: :string, number: :float }
      heads = []
      fields = []
      xls_types = []
      x_styles = []
      Axlsx::Package.new do |p| # rubocop:disable Metrics/BlockLength
        p.workbook do |wb| # rubocop:disable Metrics/BlockLength
          styles = wb.styles
          styles.fonts.first.sz = 10
          tbl_header = styles.add_style b: true, font_name: 'arial', alignment: { horizontal: :center }, sz: 10
          delim4 = styles.add_style(format_code: '#,##0.0000;[Red]-#,##0.0000', sz: 10)
          delim2 = styles.add_style(format_code: '#,##0.00;[Red]-#,##0.00', sz: 10)
          bool = styles.add_style alignment: { horizontal: :center }, sz: 10
          and_styles = { delimited_1000_4: delim4, delimited_1000: delim2, boolean: bool }
          report.ordered_columns.each do |col|
            next if col.hide && !@export_hidden_fields

            xls_types << xls_possible_types[col.data_type] || :string
            heads << col.caption
            fields << col.name
            x_styles << if col.format
                          and_styles[col.format]
                        else
                          and_styles[col.data_type]
                        end
          end

          wb.add_worksheet do |sheet|
            sheet.add_row heads, style: tbl_header
            recs.each do |row|
              values = fields.map do |f|
                v = row[f.to_sym]
                # v.is_a?(BigDecimal) ? v.to_f : v
                case v
                when BigDecimal
                  v.to_f
                when TrueClass
                  'Y'
                when FalseClass
                  'N'
                else
                  v
                end
              end
              sheet.add_row(values, types: xls_types, style: x_styles)
            end
          end
        end
        p.serialize(output_file)
      end
    end

    def apply_where_conditions
      return unless config['conditions']

      # TODO: IN clause...
      params = []
      config['conditions'].each do |condition|
        params << Crossbeams::Dataminer::QueryParameter.new(condition['col'], Crossbeams::Dataminer::OperatorValue.new(condition['op'], condition['val']))
      end
      report.replace_where(params)
    end

    def make_zip
      log('Creating zip file')
      `zip -j #{output_file}.zip #{output_file}`
    end

    def format_column(col, val) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return nil if col.hide && !@export_hidden_fields
      return '' if val.nil?
      return boolean_value(val) if col.data_type == :boolean

      if @prefix_long_numbers_with_quote && col.data_type == :string && val.is_a?(String) && val.length > 12 && val.match?(/\A\d+\Z/)
        "'#{val}"
      elsif col.format == :delimited_1000
        UtilityFunctions.delimited_number(val, delimiter: '')
      elsif col.format == :delimited_1000_4
        UtilityFunctions.delimited_number(val, delimiter: '', no_decimals: 4)
      elsif col.data_type == :datetime
        val.to_s.gsub(/:\d\d \+\d\d\d\d$/, '')
      else
        val
      end
    end

    def boolean_value(val)
      if @boolean_as_yn
        val ? 'Y' : 'N'
      else
        val
      end
    end

    def output_file
      @output_file ||= File.join(config['out_dir'], "#{key}.#{@output_format}")
    end

    def ordered_headers
      report.ordered_columns.map do |col|
        if col.hide && !@export_hidden_fields
          nil
        else
          col.caption
        end
      end.compact
    end

    def prepare
      fn = nil
      fn = File.join('grid_definitions/dataminer_queries', "#{config['grid']}.yml") if config['grid']
      fn = File.join('reports', "#{config['report']}.yml") if config['report']
      raise Crossbeams::FrameworkError, "Export config for #{key} does not have a valid grid or report setting" if fn.nil?

      load_report(fn)
    end

    def load_report(file)
      persistor = Crossbeams::Dataminer::YamlPersistor.new(file)
      @report = Crossbeams::Dataminer::Report.load(persistor)
    end

    def valid_key?
      !config.nil?
    end

    def valid_dir?
      !config['out_dir'].nil?
    end

    def config
      @config || load_config
    end

    def load_config
      raise Crossbeams::FrameworkError, 'There is no export config file named "config/export_data_config.yml"' unless File.exist?('config/export_data_config.yml')

      YAML.load_file('config/export_data_config.yml')[key]
    end
  end
end
