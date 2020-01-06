# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'reports', 'dataminer' do |r|
    interactor = DataminerApp::DataminerInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

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
        @page = page
        view(inline: <<-HTML)
        <div>
          <p style='color:red;'>There is a problem with the SQL definition of this report:</p>
          <p>Report: <em>#{@page.nil? ? id : @page.report.caption}</em></p>The error message is:
          <pre>#{e.message}</pre>
          <button class="crossbeams-button f6 link dim br2 ph3 pv2 dib white bg-silver" onclick="crossbeamsUtils.toggleVisibility('sql_code');return false">
            #{Crossbeams::Layout::Icon.render(:info)} Toggle SQL
          </button>
          <pre id="sql_code" hidden>#{@page.nil? ? 'Unknown' : '<%= sql_to_highlight(@page.report.runnable_sql) %>'}</pre>
        </div>
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
        <div>
          <p style='color:red;'>There is a problem with the SQL definition of this report:</p>
          <p>Report: <em>#{@page.nil? ? id : @page.report.caption}</em></p>The error message is:
          <pre>#{e.message}</pre>
          <button class="crossbeams-button f6 link dim br2 ph3 pv2 dib white bg-silver" onclick="crossbeamsUtils.toggleVisibility('sql_code');return false">
            #{Crossbeams::Layout::Icon.render(:info)} Toggle SQL
          </button>
          <pre id="sql_code" hidden>#{@page.nil? ? 'Unknown' : '<%= sql_to_highlight(@page.report.runnable_sql) %>'}</pre>
        </div>
        HTML
      end
    end

    r.is do
      show_page { DM::Report::Report::GridPage.call('/dataminer/reports/grid/', 'Report listing') }
    end

    r.on 'grid' do
      interactor.report_list_grid
    rescue StandardError => e
      show_json_exception(e)
    end
  end
end

# rubocop:enable Metrics/BlockLength
