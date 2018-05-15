# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'reports', 'dataminer' do |r|
    interactor = DataminerInteractor.new(current_user, {}, { route_url: request.path }, {})

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
      interactor.report_list_grid
    end

    # PREPARED REPORTS
    # --------------------------------------------------------------------------
    # r.on 'prepared_reports', String do |id|
    #   # interactor = DataminerApp::SecurityPermissionInteractor.new(current_user, {}, { route_url: request.path }, {})
    #
    #   # Check for notfound:
    #   r.on !interactor.exists?(:security_permissions, id) do
    #     handle_not_found(r)
    #   end
    #
    #   r.on 'edit' do   # EDIT
    #     raise Crossbeams::AuthorizationError unless authorised?('reports', 'edit')
    #     show_partial { Dataminer::PreparedReport::SecurityPermission::Edit.call(id) }
    #   end
    #   r.is do
    #     r.get do       # SHOW
    #       raise Crossbeams::AuthorizationError unless authorised?('reports', 'read')
    #       show_partial { Dataminer::PreparedReport::SecurityPermission::Show.call(id) }
    #     end
    #     r.patch do     # UPDATE
    #       return_json_response
    #       res = interactor.update_security_permission(id, params[:security_permission])
    #       if res.success
    #         update_grid_row(id, changes: { security_permission: res.instance[:security_permission] },
    #                             notice: res.message)
    #       else
    #         content = show_partial { Dataminer::PreparedReport::SecurityPermission::Edit.call(id, params[:security_permission], res.errors) }
    #         update_dialog_content(content: content, error: res.message)
    #       end
    #     end
    #     r.delete do    # DELETE
    #       return_json_response
    #       raise Crossbeams::AuthorizationError unless authorised?('reports', 'delete')
    #       # TODO: Only user who created or admin can delete...
    #       res = interactor.delete_security_permission(id)
    #       delete_grid_row(id, notice: res.message)
    #     end
    #   end
    # end

    # r.on 'prepared_reports', Integer do |id|
    r.on 'prepared_reports' do
      r.on 'new', String do |id|    # NEW
        raise Crossbeams::AuthorizationError unless authorised?('reports', 'new')
        show_partial_or_page(r) { Dataminer::Report::PreparedReport::New.call(id, params[:json_var], remote: fetch?(r)) }
      end

      r.post do       # CREATE
        res = interactor.create_prepared_report(params[:prepared_report])
        if res.success
          update_dialog_content(content: 'Webquery URL for this report is abcd... Click to copy to clipboard...', notice: res.message)
          # Show webquery URL
          # flash[:notice] = res.message
          # redirect_to_last_grid(r)
        else
          re_show_form(r, res, url: "/dataminer/reports/prepared_reports/new/#{id}") do
            Dataminer::Report::PreparedReport::New.call(id,
                                                        form_values: params[:security_permission],
                                                        form_errors: res.errors,
                                                        remote: fetch?(r))
          end
        end
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength
