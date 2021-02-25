# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
module DataminerApp
  class PreparedReportInteractor < BaseInteractor # rubocop:disable Metrics/ClassLength
    def repo
      @repo ||= PreparedReportRepo.new
    end

    # FIXME: This is a dup of method in DataminerInteractor...

    # Apply request parameters to a Report.
    #
    # @param rpt [Crossbeams::Dataminer::Report] the report.
    # @param params [Hash] the request parameters.
    # @param crosstab_hash [Hash] the crosstab config (if applicable).
    # @return [Crossbeams::Dataminer::Report] the modified report.
    def setup_report_with_parameters(rpt, params, db_name, crosstab_hash = {}) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      # {"col"=>"users.department_id", "op"=>"=", "opText"=>"is", "val"=>"17", "text"=>"Finance", "caption"=>"Department"}
      input_parameters = ::JSON.parse(params[:json_var])
      # logger.info input_parameters.inspect
      parms = []
      # Check if this should become an IN parmeter (list of equal checks for a column.
      eq_sel = input_parameters.select { |p| p['op'] == '=' }.group_by { |p| p['col'] }
      in_sets = {}
      in_keys = []
      eq_sel.each do |col, qp|
        in_keys << col if qp.length > 1
      end

      input_parameters.each do |in_param|
        col = in_param['col']
        if in_keys.include?(col)
          in_sets[col] ||= []
          in_sets[col] << in_param['val']
          next
        end
        param_def = rpt.parameter_definition(col)
        parms << if in_param['op'] == 'between'
                   Crossbeams::Dataminer::QueryParameter.new(col, Crossbeams::Dataminer::OperatorValue.new(in_param['op'], [in_param['val'], in_param['valTo']], param_def.data_type))
                 else
                   Crossbeams::Dataminer::QueryParameter.new(col, Crossbeams::Dataminer::OperatorValue.new(in_param['op'], in_param['val'], param_def.data_type))
                 end
      end
      in_sets.each do |col, vals|
        param_def = rpt.parameter_definition(col)
        parms << Crossbeams::Dataminer::QueryParameter.new(col, Crossbeams::Dataminer::OperatorValue.new('in', vals, param_def.data_type))
      end

      rpt.limit  = params[:limit].to_i  if params[:limit] != ''
      rpt.offset = params[:offset].to_i if params[:offset] != ''
      begin
        rpt.apply_params(parms)

        CrosstabApplier.new(repo.db_connection_for(db_name), rpt, params, crosstab_hash).convert_report if params[:crosstab]
        rpt
      end
    end

    def report_parameters(id, params)
      # TODO: apply chosen params (as defaults?)
      db, = repo.split_db_and_id(id)
      page = OpenStruct.new(id: id,
                            load_params: params[:back] && params[:back] == 'y',
                            report_action: "/dataminer/reports/report/#{id}/run",
                            excel_action: "/dataminer/reports/report/#{id}/xls",
                            prepared_action: "/dataminer/prepared_reports/new/#{id}")
      page.report = repo.lookup_report(id)
      page.connection = repo.db_connection_for(db)
      page.crosstab_config = repo.lookup_crosstab(id)
      page
    end

    def prepared_report_list_grid(for_user = false) # rubocop:disable Metrics/AbcSize
      rpt_list = if for_user
                   PreparedReportRepo.new.list_all_reports_for_user(@user)
                 else
                   PreparedReportRepo.new.list_all_reports(@user)
                 end

      col_defs = Crossbeams::DataGrid::ColumnDefiner.new.make_columns do |mk| # rubocop:disable Metrics/BlockLength
        mk.action_column do |act| # rubocop:disable Metrics/BlockLength
          act.popup_link 'properties', '/dataminer/prepared_reports/$col1$/properties',
                         col1: 'id',
                         icon: 'book-reference',
                         title: 'Prepared report properties'
          act.separator
          act.popup_link 'webquery link', '/dataminer/prepared_reports/$col1$/webquery_url',
                         col1: 'id',
                         icon: 'link',
                         title_field: 'caption'
          act.link 'run', '/dataminer/prepared_reports/$col1$/run',
                   col1: 'id',
                   icon: 'play'
          act.link 'Excel download', '/dataminer/prepared_reports/$col1$/xls',
                   col1: 'id',
                   icon: 'excel'
          act.separator
          act.popup_edit_link '/dataminer/prepared_reports/$col1$/edit',
                              col1: 'id',
                              hide_if_false: for_user ? 'owner' : nil
          act.popup_link 'change columns', '/dataminer/prepared_reports/$col1$/change_columns',
                         col1: 'id',
                         icon: 'view-columns',
                         hide_if_false: for_user ? 'owner' : nil
          act.popup_delete_link '/dataminer/prepared_reports/$col1$',
                                col1: 'id',
                                hide_if_false: for_user ? 'owner' : nil
        end
        mk.col 'db', 'Database'
        mk.col 'caption', 'Report caption', width: 300
        mk.col 'report_name'
        mk.col 'file', 'File name', width: 600
        mk.boolean 'crosstab', 'Crosstab?'
        mk.boolean 'owner', 'Owner?'
      end
      {
        columnDefs: col_defs,
        rowDefs: rpt_list.sort_by { |rpt| "#{rpt[:db]}#{rpt[:caption]}" }
      }.to_json
    end

    def prepared_report_grid(id)
      db, = repo.split_db_and_id(id)
      report = PreparedReportRepo.new.lookup_report(id)
      params = { json_var: report.external_settings[:prepared_report][:json_var] }
      setup_report_with_parameters(report, params, db) # Need to include crosstab_hash if required...

      col_defs = Crossbeams::DataGrid::ColumnDefiner.new.make_columns do |mk|
        report.ordered_columns.each do |col|
          mk.column_from_dataminer col
        end
      end
      # Use module for BigDecimal change? - register_extension...?
      db_type = repo.db_connection_for(db).database_type
      row_defs = repo.db_connection_for(db)[report.runnable_sql_delimited(db_type)].to_a.map do |m|
        m.each_key { |k| m[k] = m[k].to_f if m[k].is_a?(BigDecimal) }
        m
      end
      {
        columnDefs: col_defs,
        rowDefs: row_defs
      }.to_json
    end

    def create_prepared_report_spreadsheet(id)
      db, = repo.split_db_and_id(id)
      page = OpenStruct.new(id: id)
      # page.crosstab_config = prep_repo.lookup_crosstab(id)
      # ....
      page.report = PreparedReportRepo.new.lookup_report(id)
      params = { json_var: page.report.external_settings[:prepared_report][:json_var] }
      setup_report_with_parameters(page.report, params, db) # Need to include crosstab_hash if required...
      xls_possible_types = { string: :string, integer: :integer, date: :string,
                             datetime: :time, time: :time, boolean: :boolean, number: :float }
      heads = []
      fields = []
      xls_types = []
      x_styles = []
      page.excel_file = Axlsx::Package.new do |p|
        p.workbook do |wb|
          styles     = wb.styles
          tbl_header = styles.add_style b: true, font_name: 'arial', alignment: { horizontal: :center }
          # red_negative = styles.add_style :num_fmt => 8
          delim4 = styles.add_style(format_code: '#,##0.0000;[Red]-#,##0.0000')
          delim2 = styles.add_style(format_code: '#,##0.00;[Red]-#,##0.00')
          and_styles = { delimited_1000_4: delim4, delimited_1000: delim2 }
          page.report.ordered_columns.each do |col|
            xls_types << xls_possible_types[col.data_type] || :string # BOOLEAN == 0,1 ... need to change this to Y/N...or use format TRUE|FALSE...
            heads << col.caption
            fields << col.name
            # x_styles << (col.format == :delimited_1000_4 ? delim4 : :delimited_1000 ? delim2 : nil) # :num_fmt => Axlsx::NUM_FMT_YYYYMMDDHHMMSS / Axlsx::NUM_FMT_PERCENT
            x_styles << and_styles[col.format]
          end

          wb.add_worksheet do |sheet|
            sheet.add_row heads, style: tbl_header
            db_type = repo.db_connection_for(db).database_type
            repo.db_connection_for(db)[page.report.runnable_sql_delimited(db_type)].each do |row|
              values = fields.map do |f|
                v = row[f.to_sym]
                v.is_a?(BigDecimal) ? v.to_f : v
              end
              sheet.add_row(values, types: xls_types, style: x_styles)
            end
          end
        end
      end
      page
    end

    def create_prepared_report(params)
      res = validate_prepared_report_params(params)
      return validation_failed_response(res) if res.failure?

      # NB. Validate the report description - must be unique. (unless we are replacing an existing prep rpt.)

      json_var = if params[:json_var].start_with?('[')
                   params[:json_var]
                 else
                   Base64.decode64(params[:json_var])
                 end
      prep_rep_id = PreparedReportRepo.new.create_prepared_report(@user, params[:id], params[:report_description], json_var, params[:existing_report])
      param_texts = json_var_as_text(::JSON.parse(json_var))
      success_response('Prepared report was successfully created', id: prep_rep_id, report_description: params[:report_description], param_texts: param_texts)
    end

    def validate_prepared_report_params(params)
      PreparedReportSchema.call(params)
    end

    def update_prepared_report(id, params)
      res = validate_prepared_report_params(params)
      return validation_failed_response(res) if res.failure?

      PreparedReportRepo.new.save_prepared_report(id, params)
      success_response('Report has been updated', report_description: params[:report_description])
    end

    def change_columns(id, params)
      PreparedReportRepo.new.change_columns(id, params[:co_sorted_ids].split(','), params[:hc_sorted_ids].split(','))
    end

    def delete_prepared_report(id)
      # Should ideally validate user is owner or has all reports permission...
      filename = PreparedReportRepo.new.lookup_file_name(id)
      File.delete(filename)
      success_response('Report has been deleted')
    end

    def prepared_report(id)
      PreparedReportRepo.new.lookup_report(id)
    end

    def prepared_report_meta(id)
      rpt = prepared_report(id)
      json_var = ::JSON.parse(rpt.external_settings[:prepared_report][:json_var])
      param_texts = json_var_as_text(json_var)

      { id: id, report_description: rpt.caption, param_texts: param_texts }
    end

    def json_var_as_text(json_var)
      json_var.map do |param|
        if param['op'] == 'between'
          "#{param['caption']} #{param['opText']} #{param['text']} AND #{param['textTo']}"
        elsif param['op'] == 'is_null' || param['op'] == 'notnull'
          "#{param['caption']} #{param['opText']}"
        else
          "#{param['caption']} #{param['opText']} #{param['text']}"
        end
      end
    end

    def prepared_report_as_html(id)
      db, = repo.split_db_and_id(id)
      rpt = PreparedReportRepo.new.lookup_report(id)
      params = { json_var: rpt.external_settings[:prepared_report][:json_var] }
      setup_report_with_parameters(rpt, params, db) # Need to include crosstab_hash if required...

      db_type = repo.db_connection_for(db).database_type
      row_defs = repo.db_connection_for(db)[rpt.runnable_sql_delimited(db_type)].to_a.map do |m|
        m.each_key { |k| m[k] = m[k].to_f if m[k].is_a?(BigDecimal) }
        m
      end

      s = +"<table><tr><th>#{rpt.ordered_columns.map(&:caption).join('</th><th>')}</th></tr>"
      row_defs.each do |record|
        s << '<tr>'
        rpt.ordered_columns.each do |k|
          s << "<td>#{format_for_spreadsheet(record[k.name.to_sym].to_s)}</td>"
        end
        s << '</tr>'
      end
      s << '</table>'
    end

    def prepared_report_as_xml(id)
      db, = repo.split_db_and_id(id)
      rpt = PreparedReportRepo.new.lookup_report(id)
      params = { json_var: rpt.external_settings[:prepared_report][:json_var] }
      setup_report_with_parameters(rpt, params, db) # Need to include crosstab_hash if required...

      db_type = repo.db_connection_for(db).database_type
      row_defs = repo.db_connection_for(db)[rpt.runnable_sql_delimited(db_type)].to_a.map do |m|
        m.each_key { |k| m[k] = m[k].to_f if m[k].is_a?(BigDecimal) }
        m
      end

      s = +<<~STR
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <data-set xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      STR
      row_defs.each do |record|
        s << '<record>'
        rpt.ordered_columns.each do |k|
          # ... could use properties of column for format, datatype etc. in a schema?
          s << "<#{k.caption.split(' ').map(&:capitalize).join}>#{record[k.name.to_sym]}</#{k.caption.split(' ').map(&:capitalize).join}>"
        end
        s << '</record>'
      end
      s << '</data-set>'
    end

    # When a spreadsheet loads this data, any numbers starting with 0 need to have "'" prefix.
    # Also if a number is too long, the spreadsheet will convert to scientific notation,
    # so we prefix long numbers with "'" too.
    def format_for_spreadsheet(str)
      if str =~ /^\d+$/ && str.length > 1
        return "'#{str}" if str.start_with?('0') || str.length > 10
      end
      str
    end
  end
end
# rubocop:enable Metrics/AbcSize
