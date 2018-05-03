# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

class Framework < Roda
  # Generic grid lists.
  route('list') do |r|
    r.on :id do |id|
      r.is do
        session[:last_grid_url] = "/list/#{id}"
        show_page { render_data_grid_page(id) }
      end

      r.on 'with_params' do
        if fetch?(r)
          show_partial { render_data_grid_page(id, query_string: request.query_string) }
        else
          session[:last_grid_url] = "/list/#{id}/with_params?#{request.query_string}"
          show_page { render_data_grid_page(id, query_string: request.query_string) }
        end
      end

      r.on 'multi' do
        if fetch?(r)
          show_partial { render_data_grid_page_multiselect(id, params) }
        else
          show_page { render_data_grid_page_multiselect(id, params) }
        end
      end

      r.on 'grid' do
        return_json_response
        begin
          if params && !params.empty?
            render_data_grid_rows(id, ->(program, permission) { auth_blocked?(program, permission) }, params)
          else
            render_data_grid_rows(id, ->(program, permission) { auth_blocked?(program, permission) })
          end
        rescue StandardError => e
          show_json_exception(e)
        end
      end

      r.on 'grid_multi', String do |key|
        return_json_response
        begin
          render_data_grid_multiselect_rows(id, ->(program, permission) { auth_blocked?(program, permission) }, key, params)
        rescue StandardError => e
          show_json_exception(e)
        end
      end

      r.on 'nested_grid' do
        return_json_response
        begin
          render_data_grid_nested_rows(id)
        rescue StandardError => e
          show_json_exception(e)
        end
      end
    end
  end

  route('print_grid') do
    @layout = Crossbeams::Layout::Page.build(grid_url: params[:grid_url]) do |page, _|
      page.add_grid('crossbeamsPrintGrid', params[:grid_url], caption: 'Print', for_print: true)
    end
    view('crossbeams_layout_page', layout: 'print_layout')
  end

  # Generic code for grid searches.
  route('search') do |r|
    r.on :id do |id|
      r.is do
        render_search_filter(id, params)
      end

      r.on 'run' do
        session[:last_grid_url] = "/search/#{id}?rerun=y"
        show_page { render_search_grid_page(id, params) }
      end

      r.on 'grid' do
        return_json_response
        render_search_grid_rows(id, params, ->(program, permission) { auth_blocked?(program, permission) })
      end

      r.on 'xls' do
        caption, xls = render_excel_rows(id, params)
        response.headers['content_type'] = 'application/vnd.ms-excel'
        response.headers['Content-Disposition'] = "attachment; filename=\"#{caption.strip.gsub(%r{[/:*?"\\<>\|\r\n]}i, '-') + '.xls'}\""
        response.write(xls) # NOTE: could this use streaming to start downloading quicker?
      rescue Sequel::DatabaseError => e
        view(inline: <<-HTML)
        <p style='color:red;'>There is a problem with the SQL definition of this report:</p>
        <p>Report: <em>#{caption}</em></p>The error message is:
        <pre>#{e.message}</pre>
        <button class="pure-button" onclick="crossbeamsUtils.toggleVisibility('sql_code', this);return false">
          <i class="fa fa-info"></i> Toggle SQL
        </button>
        <pre id="sql_code" style="display:none;"><%= sql_to_highlight(@rpt.runnable_sql) %></pre>
        HTML
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength
