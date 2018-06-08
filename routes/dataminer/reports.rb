# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'reports', 'dataminer' do |r|
    interactor = DataminerApp::DataminerInteractor.new(current_user, {}, { route_url: request.path }, {})

    r.on 'iframe' do
      if flash[:iframe_url].nil?
        view(inline: '<h1>Not reloadable</h1><p>This page cannot be reloaded. Please navigate back to the report and re-run it.</p><p>Once the report has run, you may be able to reload by right-clicking in the body and choosing <em>Reload frame</em>.</p>')
      else
        view(inline: %(<iframe src="#{flash[:iframe_url]}" title="test" width="100%" style="height:80vh"></iframe>))
      end
    end

    # Just for testing inside an iframe...
    r.on 'runnable_sql' do
      "<h2>Iframe</h2><h3>Params</h3><p>#{params[:sql]}</p><h3>Base64 decoded:</h3><p>#{Base64.decode64(params[:sql])}</p>"
    end

    r.on 'report', String do |id|
      id = id.gsub('%20', ' ')

      r.get true do
        @page = interactor.report_parameters(id, params)
        view('dataminer/report/parameters')
      end

      r.post 'xls' do
        page = interactor.create_spreadsheet(id, params)
        response.headers['content_type'] = 'application/vnd.ms-excel'
        response.headers['Content-Disposition'] = "attachment; filename=\"#{page.report.caption.strip.gsub(%r{[/:*?"\\<>\|\r\n]}i, '-') + '.xls'}\""
        # NOTE: could this use streaming to start downloading quicker?
        response.write(page.excel_file.to_stream.read)
      rescue Sequel::DatabaseError => e
        view(inline: <<-HTML)
        <p style='color:red;'>There is a problem with the SQL definition of this report:</p>
        <p>Report: <em>#{@page.nil? ? id : @page.report.caption}</em></p>The error message is:
        <pre>#{e.message}</pre>
        <button class="pure-button" onclick="crossbeamsUtils.toggleVisibility('sql_code', this);return false">
          <i class="fa fa-info"></i> Toggle SQL
        </button>
        <pre id="sql_code" style="display:none;">#{@page.nil? ? 'Unknown' : '<%= sql_to_highlight(@page.report.runnable_sql) %>'}</pre>
        HTML
      end

      r.post 'run' do
        @page = interactor.run_report(id, params)
        if @page.sql_run_url
          flash[:iframe_url] = "#{@page.sql_run_url}?sql=#{@page.runnable}"
          r.redirect '/dataminer/reports/iframe'
          # view(inline: "<p>Runnable</p><pre>#{Base64.decode64(@page.runnable)}</p>")
        else
          view('dataminer/report/display')
        end
      rescue Sequel::DatabaseError => e
        view(inline: <<-HTML)
        <p style='color:red;'>There is a problem with the SQL definition of this report:</p>
        <p>Report: <em>#{@page.nil? ? id : @page.report.caption}</em></p>The error message is:
        <pre>#{e.message}</pre>
        <button class="pure-button" onclick="crossbeamsUtils.toggleVisibility('sql_code', this);return false">
          <i class="fa fa-info"></i> Toggle SQL
        </button>
        <pre id="sql_code" style="display:none;">#{@page.nil? ? 'Unknown' : '<%= sql_to_highlight(@page.report.runnable_sql) %>'}</pre>
        HTML
      end
    end

    r.is do
      renderer = Crossbeams::Layout::Renderer::Grid.new('rpt_grid', '/dataminer/reports/grid/', 'Report listing')
      view(inline: renderer.render)
    end

    r.on 'grid' do
      return_json_response
      begin
        interactor.report_list_grid
      rescue StandardError => e
        show_json_exception(e)
      end
    end

    # ****************************************************************************************************************************************
    #
    # TODO: think through system + framework db with same connection, diff reports path, but same prep dir. (do not list same dir twice......)
    #
    # ****************************************************************************************************************************************
    r.on 'prepared_reports' do
      r.on 'new', String do |id|    # NEW
        raise Crossbeams::AuthorizationError unless authorised?('reports', 'new')
        # Show already-saved-reports-for-same_user
        show_partial_or_page(r) { Dataminer::Report::PreparedReport::New.call(id, params[:json_var], current_user, remote: fetch?(r)) }
      end

      r.on 'list' do
        renderer = Crossbeams::Layout::Renderer::Grid.new('rpt_grid', '/dataminer/reports/prepared_reports/grid/', 'Prepared report listing')
        view(inline: renderer.render)
      end

      r.on 'grid' do
        return_json_response
        begin
          interactor.prepared_report_list_grid(true)
        rescue StandardError => e
          show_json_exception(e)
        end
      end

      r.on 'list_all' do
        renderer = Crossbeams::Layout::Renderer::Grid.new('rpt_grid', '/dataminer/reports/prepared_reports/grid_all/', 'Prepared report listing - all reports')
        view(inline: renderer.render)
      end

      r.on 'grid_all' do
        return_json_response
        begin
          interactor.prepared_report_list_grid
        rescue StandardError => e
          show_json_exception(e)
        end
      end

      r.on :id do |id|
        # Make an instance
        instance = interactor.prepared_report_meta(id)
        r.on 'webquery_url' do
          show_partial_or_page(r) { Dataminer::Report::PreparedReport::WebQuery.call(instance, webquery_url_for(id)) }
        end

        r.on 'run' do
          renderer = Crossbeams::Layout::Renderer::Grid.new('rpt_grid', "/dataminer/reports/prepared_reports/#{id}/grid/", instance[:report_description], height: 35)
          view(inline: renderer.render)
        end

        r.on 'xls' do
          page = interactor.create_prepared_report_spreadsheet(id)
          response.headers['content_type'] = 'application/vnd.ms-excel'
          response.headers['Content-Disposition'] = "attachment; filename=\"#{page.report.caption.strip.gsub(%r{[/:*?"\\<>\|\r\n]}i, '-') + '.xls'}\""
          # NOTE: could this use streaming to start downloading quicker?
          response.write(page.excel_file.to_stream.read)
        end

        r.on 'grid' do
          return_json_response
          begin
            interactor.prepared_report_grid(id)
          rescue StandardError => e
            show_json_exception(e)
          end
        end

        r.on 'edit' do
          raise Crossbeams::AuthorizationError unless authorised?('reports', 'edit') # Need to check user == creator, or has all_preps permission...
          show_partial { Dataminer::Report::PreparedReport::Edit.call(id) }
        end

        r.patch do     # UPDATE
          return_json_response
          res = interactor.update_prepared_report(id, params[:prepared_report])
          if res.success
            update_grid_row(id, changes: { caption: res.instance[:report_description] },
                                notice: res.message)
          else
            content = show_partial { Dataminer::Report::PreparedReport::Edit.call(id, form_values: params[:prepared_report], form_errors: res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end

        r.delete do
          return_json_response
          res = interactor.delete_prepared_report(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message)
          end
        end
      end

      r.post do       # CREATE
        res = interactor.create_prepared_report(params[:prepared_report])
        if res.success
          show_page_or_update_dialog(r, res) { Dataminer::Report::PreparedReport::WebQuery.call(res.instance, webquery_url_for(res.instance[:id]), fetch?(r)) }
        else
          id = params[:prepared_report][:id]
          re_show_form(r, res, url: "/dataminer/reports/prepared_reports/new/#{id}") do
            Dataminer::Report::PreparedReport::New.call(id, params[:prepared_report][:json_var], current_user,
                                                        form_values: params[:prepared_report],
                                                        form_errors: res.errors,
                                                        remote: fetch?(r))
          end
        end
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength
