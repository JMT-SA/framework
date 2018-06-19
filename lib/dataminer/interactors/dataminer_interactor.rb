# frozen_string_literal: true

module DataminerApp
  class DataminerInteractor < BaseInteractor
    def repo
      @repo ||= ReportRepo.new(@context[:for_grid_queries])
    end

    def report_parameters(id, params)
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

    def run_report(id, params)
      db, = repo.split_db_and_id(id)
      page = OpenStruct.new(id: id, col_defs: [])
      page.report = repo.lookup_report(id)
      page.crosstab_config = repo.lookup_crosstab(id)
      page.json_var = params[:json_var]
      setup_report_with_parameters(page.report, params, page.crosstab_config, db)

      # If just passing parameterised query to url, return page with base64 version of runnable_sql.
      if page.report.external_settings[:render_url]
        db_type = repo.db_connection_for(db).database_type
        page.runnable = Base64.encode64(page.report.runnable_sql_delimited(db_type))
        page.sql_run_url = page.report.external_settings[:render_url]
        return page
      end
      # puts params.inspect
      # {"limit"=>"", "offset"=>"", "crosstab"=>{"row_columns"=>["organization_code", "commodity_code", "fg_code_old"], "column_columns"=>"grade_code", "value_columns"=>"no_pallets"}, "btnSubmit"=>"Run report", "json_var"=>"[]"}
      page.report.ordered_columns.each do |col|
        hs                  = { headerName: col.caption, field: col.name, hide: col.hide, headerTooltip: col.caption }
        hs[:width]          = col.width unless col.width.nil?
        hs[:enableValue]    = true if %i[integer number].include?(col.data_type)
        hs[:enableRowGroup] = true unless hs[:enableValue] && !col.groupable
        hs[:enablePivot]    = true unless hs[:enableValue] && !col.groupable
        hs[:rowGroupIndex]  = col.group_by_seq if col.group_by_seq
        hs[:cellRenderer]   = 'group' if col.group_by_seq
        hs[:cellRendererParams] = { restrictToOneGroup: true } if col.group_by_seq
        hs[:aggFunc]            = 'sum' if col.group_sum
        if %i[integer number].include?(col.data_type)
          hs[:cellClass] = 'grid-number-column'
          hs[:width]     = 100 if col.width.nil? && col.data_type == :integer
          hs[:width]     = 120 if col.width.nil? && col.data_type == :number
        end
        if col.format == :delimited_1000
          hs[:cellRenderer] = 'crossbeamsGridFormatters.numberWithCommas2'
        end
        if col.format == :delimited_1000_4
          hs[:cellRenderer] = 'crossbeamsGridFormatters.numberWithCommas4'
        end
        if col.data_type == :boolean
          hs[:cellRenderer] = 'crossbeamsGridFormatters.booleanFormatter'
          hs[:cellClass]    = 'grid-boolean-column'
          hs[:width]        = 100 if col.width.nil?
        end

        # hs[:cellClassRules] = {"grid-row-red": "x === 'Fred'"} if col.name == 'author'

        page.col_defs << hs
      end
      # p page.report.runnable_sql
      # Use module for BigDecimal change? - register_extension...?
      db_type = repo.db_connection_for(db).database_type
      page.row_defs = repo.db_connection_for(db)[page.report.runnable_sql_delimited(db_type)].to_a.map do |m|
        m.each_key { |k| m[k] = m[k].to_f if m[k].is_a?(BigDecimal) }
        m
      end
      page
    end

    def create_spreadsheet(id, params)
      db, = repo.split_db_and_id(id)
      page = OpenStruct.new(id: id)
      page.report = repo.lookup_report(id)
      page.crosstab_config = repo.lookup_crosstab(id)
      setup_report_with_parameters(page.report, params, page.crosstab_config, db)
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
          puts x_styles.inspect
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

    def admin_report_list_grid(for_grids: false)
      rpt_list = if for_grids
                   repo.list_all_grid_reports
                 else
                   repo.list_all_reports
                 end
      col_defs = Crossbeams::DataGrid::ColumnDefiner.new.make_columns do |mk|
        mk.action_column do |act|
          act.edit_link '/dataminer/admin/$col1$/edit', col1: 'id'
          act.popup_delete_link '/dataminer/admin/$col1$', col1: 'id'
        end
        mk.col 'db', 'Database'
        mk.col 'caption', 'Report caption', width: 300
        mk.col 'file', 'File name', width: 600
        mk.boolean 'crosstab', 'Crosstab?'
        mk.boolean('external', 'External render?', width: 150) unless for_grids
      end
      {
        columnDefs: col_defs,
        rowDefs:    rpt_list.sort_by { |rpt| "#{rpt[:db]}#{rpt[:caption]}" }
      }.to_json
    end

    def report_list_grid
      rpt_list = repo.list_all_reports
      link     = "'/dataminer/reports/report/'+data.id+'|run'"

      col_defs = Crossbeams::DataGrid::ColumnDefiner.new.make_columns do |mk|
        mk.href link, 'edit_link'
        mk.col 'db', 'Database'
        mk.col 'caption', 'Report caption', width: 300
        mk.col 'file', 'File name', width: 600
        mk.boolean 'crosstab', 'Crosstab?'
        mk.boolean 'external', 'External render?', width: 150
      end
      {
        columnDefs: col_defs,
        rowDefs:    rpt_list.sort_by { |rpt| "#{rpt[:db]}#{rpt[:caption]}" }
      }.to_json
    end

    def validate_new_report_params(params)
      NewReportSchema.call(params)
    end

    def create_report(params)
      res = validate_new_report_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      page = OpenStruct.new
      s = params[:filename].strip.downcase.tr(' ', '_').gsub(/_+/, '_').gsub(/[\/:*?"\\<>\|\r\n]/i, '-')
      page.filename = File.basename(s).reverse.sub(File.extname(s).reverse, '').reverse << '.yml'
      page.caption  = params[:caption]
      page.sql      = params[:sql]
      page.database = params[:database]
      err = ''
      repo = ReportRepo.new

      page.rpt = Crossbeams::Dataminer::Report.new(page.caption)
      begin
        page.rpt.sql = page.sql
      rescue StandardError => e
        err = e.message
      end
      # Check for existing file name...
      if File.exist?(File.join(repo.admin_report_path(page.database), page.filename))
        err = 'A file with this name already exists'
      end
      # Write file, rebuild index and go to edit...

      if err.empty?
        # run the report with limit 1 and set up datatypes etc.
        DmCreator.new(repo.db_connection_for(page.database), page.rpt).modify_column_datatypes
        yp = Crossbeams::Dataminer::YamlPersistor.new(File.join(repo.admin_report_path(page.database), page.filename))
        page.rpt.save(yp)
        success_response('Created report', page)
      else
        failed_response(err, page)
      end
    end

    def convert_report(params)
      yml = params[:yml]
      dbname = params[:database]
      hash = YAML.load(yml)
      hash['query'] = params[:sql]
      rpt = DmConverter.new(repo.admin_report_path(dbname)).convert_hash(hash, params[:filename])
      success_response('Converted to a new report', rpt)
    rescue StandardError => e
      failed_response(e.message)
    end

    def edit_report(id)
      page = OpenStruct.new(id: id, report: repo.lookup_report(id, true))

      page.filename = File.basename(repo.lookup_file_name(id, true))

      page.col_defs = Crossbeams::DataGrid::ColumnDefiner.new.make_columns do |mk| # rubocop:disable Metrics/BlockLength
        mk.col 'name', 'Column name', pinned: 'left'
        mk.col 'sequence_no', 'Seq', cellClass: 'grid-number-column', pinned: 'left', width: 80
        mk.col 'caption', nil, editable: true, pinned: 'left'
        mk.col 'namespaced_name'
        mk.col 'data_type', nil, editable: true, cellEditor: 'select', cellEditorParams: {
          values: %w[string boolean integer number date datetime]
        }
        mk.integer 'width', nil, editable: true, cellEditor: 'NumericCellEditor'
        mk.col 'format', nil, editable: true, cellEditor: 'select', cellEditorParams: {
          values: ['', 'delimited_1000', 'delimited_1000_4']
        }
        mk.boolean 'hide', 'Hide?', editable: true, cellEditor: 'select', cellEditorParams: {
          values: [true, false]
        }
        mk.boolean 'groupable', 'Can group by?', editable: true, cellEditor: 'select', cellEditorParams: {
          values: [true, false]
        }
        mk.integer 'group_by_seq', 'Group Seq', tooltip: 'If the grid opens grouped, this is the grouping level', editable: true, cellEditor: 'NumericCellEditor'
        mk.boolean 'group_sum', 'Sum?', editable: true, cellEditor: 'select', cellEditorParams: {
          values: [true, false]
        }
        mk.boolean 'group_avg', 'Avg?', editable: true, cellEditor: 'select', cellEditorParams: {
          values: [true, false]
        }
        mk.boolean 'group_min', 'Min?', editable: true, cellEditor: 'select', cellEditorParams: {
          values: [true, false]
        }
        mk.boolean 'group_max', 'Max?', editable: true, cellEditor: 'select', cellEditorParams: {
          values: [true, false]
        }
      end
      page.row_defs = page.report.ordered_columns.map(&:to_hash)

      page.col_defs_params = Crossbeams::DataGrid::ColumnDefiner.new.make_columns do |mk|
        mk.href_prompt "'/dataminer/admin/#{id}/parameter/delete/' + data.column + '|delete|Are you sure?|delete'", 'delete_link'
        mk.col 'column'
        mk.col 'caption'
        mk.col 'data_type'
        mk.col 'control_type'
        mk.col 'list_def', 'List definition'
        mk.col 'ui_priority'
        mk.col 'default_value'
      end

      page.row_defs_params = []
      page.report.query_parameter_definitions.each do |query_def|
        page.row_defs_params << query_def.to_hash
      end
      page.save_url = "/dataminer/admin/#{id}/save_param_grid_col/"
      page
    end

    def save_report(id, params)
      report = repo.lookup_report(id, true)

      filename = repo.lookup_file_name(id, true)
      report.caption = params[:caption]
      report.limit = params[:limit].empty? ? nil : params[:limit].to_i
      report.offset = params[:offset].empty? ? nil : params[:offset].to_i
      report.external_settings[:render_url] = params[:render_url].empty? ? nil : params[:render_url]
      yp = Crossbeams::Dataminer::YamlPersistor.new(filename)
      report.save(yp)
      success_response('Report saved', report)
    rescue StandardError => e
      failed_response(e.message)
    end

    def delete_report(id)
      filename = repo.lookup_file_name(id, true)
      File.delete(filename)
      success_response('Report has been deleted')
    rescue StandardError => e
      failed_response(e.message)
    end

    def save_report_sql(id, params)
      report = repo.lookup_admin_report(id)
      report.sql = params[:report][:sql]
      filename = repo.lookup_file_name(id, true)
      yp       = Crossbeams::Dataminer::YamlPersistor.new(filename)
      report.save(yp)
      success_response('SQL saved', report)
    rescue StandardError => e
      failed_response(e.message)
    end

    def save_report_column_order(id, params)
      report = repo.lookup_admin_report(id)
      col_order = params[:dm_sorted_ids].split(',')
      col_order.each_with_index do |col, index|
        report.columns[col].sequence_no = index + 1
      end
      filename = repo.lookup_file_name(id, true)
      yp       = Crossbeams::Dataminer::YamlPersistor.new(filename)
      report.save(yp)
      success_response('Columns reordered', report)
    rescue StandardError => e
      failed_response(e.message)
    end

    def save_param_grid_col(id, params)
      report = repo.lookup_admin_report(id)
      col = report.columns[params[:key_val]]
      attrib = params[:col_name]
      value  = params[:col_val]
      value  = nil if value.strip == ''
      # Should validate - width numeric, range... caption cannot be blank...
      # group_sum, avg etc should act as radio grps... --> Create service class to do validation.
      # FIXME: width cannot be 0...
      if %w[format data_type].include?(attrib) && !value.nil?
        col.send("#{attrib}=", value.to_sym)
      else
        value = value.to_i if attrib == 'width' && !value.nil?
        value = value.to_i if attrib == 'group_seq' && !value.nil?
        value = true if value && value == 'true'
        value = false if value && value == 'false'
        col.send("#{attrib}=", value)
      end
      # puts ">>> ATTR: #{attrib} - #{value} #{value.class}"
      if attrib == 'group_sum' && value == 'true' # NOTE string value of bool...
        puts 'CHANGING...'
        col.group_avg = false
        col.group_min = false
        col.group_max = false
        send_changes = true
      else
        send_changes = false
      end

      if value.nil? && attrib == 'caption' # Cannot be nil...
        res = { status: 'error', message: "Caption for #{params[:key_val]} cannot be blank" }
      else
        filename = repo.lookup_file_name(id, true)
        yp = Crossbeams::Dataminer::YamlPersistor.new(filename)
        report.save(yp)
        res = if send_changes
                { status: 'ok', message: "Changed #{attrib} for #{params[:key_val]}",
                  changedFields: { group_avg: false, group_min: false, group_max: false, group_none: 'A TEST' } }
              else
                { status: 'ok', message: "Changed #{attrib} for #{params[:key_val]}" }
              end
      end
      success_response('OK', res)
    end

    def create_parameter(id, params)
      # Validate... also cannot add if col exists as param already
      report = repo.lookup_admin_report(id)

      col_name = params[:column]
      if col_name.nil? || col_name.empty?
        col_name = "#{params[:table]}.#{params[:field]}"
      end
      opts = { control_type: params[:control_type].to_sym,
               data_type: params[:data_type].to_sym, caption: params[:caption] }
      unless params[:list_def].nil? || params[:list_def].empty?
        opts[:list_def] = if params[:list_def].start_with?('[') # Array
                            str_to_array(params[:list_def])
                          else
                            params[:list_def]
                          end
      end

      param = Crossbeams::Dataminer::QueryParameterDefinition.new(col_name, opts)
      report.add_parameter_definition(param)

      filename = repo.lookup_file_name(id, true)
      yp = Crossbeams::Dataminer::YamlPersistor.new(filename)
      report.save(yp)

      success_response('Parameter has been added.', report)
    end

    # Convert a string to an array without using +eval+.
    # If all elements are digits they will be converted to integers.
    # For a 2D array, the second element will be converted to integer
    # if all second elemets are made up of only digits.
    #
    # @param str [String] the string-representation of the array.
    # @return [Array] the String converted to an Array.
    def str_to_array(str)
      ar = str.split(']').map { |a| a.sub('[', '').sub(/\A,/, '').split(',').map(&:strip) }
      return ar if ar.empty?
      ar.flatten! if ar.length == 1 && ar.first.is_a?(Array)
      ar.map!(&:to_i) if !ar.first.is_a?(Array) && ar.all? { |a| a.match?(/\A\d+\Z/) }
      ar.map! { |a, b| [a, b.to_i] } if ar.first.is_a?(Array) && ar.all? { |_, b| b.match?(/\A\d+\Z/) }
      ar
    end

    def delete_parameter(id, param_id)
      report = repo.lookup_admin_report(id)
      report.query_parameter_definitions.delete_if { |p| p.column == param_id }
      filename = repo.lookup_file_name(id, true)
      yp = Crossbeams::Dataminer::YamlPersistor.new(filename)
      report.save(yp)
      success_response('Parameter has been deleted', report)
    rescue StandardError => e
      failed_response(e.message)
    end

    # Apply request parameters to a Report.
    #
    # @param rpt [Crossbeams::Dataminer::Report] the report.
    # @param params [Hash] the request parameters.
    # @param crosstab_hash [Hash] the crosstab config (if applicable).
    # @return [Crossbeams::Dataminer::Report] the modified report.
    def setup_report_with_parameters(rpt, params, crosstab_hash = {}, db)
      # puts params[:json_var].inspect
      # {"col"=>"users.department_id", "op"=>"=", "opText"=>"is", "val"=>"17", "text"=>"Finance", "caption"=>"Department"}
      input_parameters = ::JSON.parse(params[:json_var])
      # logger.info input_parameters.inspect
      parms   = []
      # Check if this should become an IN parmeter (list of equal checks for a column.
      eq_sel  = input_parameters.select { |p| p['op'] == '=' }.group_by { |p| p['col'] }
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

        CrosstabApplier.new(repo.db_connection_for(db), rpt, params, crosstab_hash).convert_report if params[:crosstab]
        rpt
        # rescue StandardError => e
        #   return "ERROR: #{e.message}"
      end
    end

    # ------------------------------------------------------------------------------------------------------
  end
end
