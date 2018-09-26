# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

class Framework < Roda
  # Generic grid lists.
  route('list') do |r|
    r.on :id do |id|
      r.is do
        session[:last_grid_url] = "/list/#{id}"
        show_page { render_data_grid_page(id, fit_height: true) }
      end

      r.on 'with_params' do
        # Pass query_string rather than params as it is passed through directly
        # to the grid div's url.
        if fetch?(r)
          show_partial { render_data_grid_page(id, query_string: request.query_string) }
        else
          session[:last_grid_url] = "/list/#{id}/with_params?#{request.query_string}"
          show_page { render_data_grid_page(id, query_string: request.query_string, fit_height: true) }
        end
      end

      r.on 'multi' do
        if fetch?(r)
          show_partial { render_data_grid_page_multiselect(id, params) }
        else
          show_page { render_data_grid_page_multiselect(id, params.merge(fit_height: true)) }
        end
      end

      r.on 'grid' do
        if params && !params.empty?
          render_data_grid_rows(id, ->(function, program, permission) { auth_blocked?(function, program, permission) }, params)
        else
          render_data_grid_rows(id, ->(function, program, permission) { auth_blocked?(function, program, permission) })
        end
      rescue StandardError => e
        show_json_exception(e)
      end

      r.on 'grid_multi', String do |key|
        render_data_grid_multiselect_rows(id, ->(function, program, permission) { auth_blocked?(function, program, permission) }, key, params)
      rescue StandardError => e
        show_json_exception(e)
      end

      r.on 'nested_grid' do
        render_data_grid_nested_rows(id)
      rescue StandardError => e
        show_json_exception(e)
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
        show_page { render_search_grid_page(id, params.merge(fit_height: true)) }
      end

      r.on 'grid' do
        render_search_grid_rows(id, params, ->(function, program, permission) { auth_blocked?(function, program, permission) })
      rescue StandardError => e
        show_json_exception(e)
      end

      r.on 'xls' do
        caption, xls = render_excel_rows(id, params)
        response.headers['content_type'] = 'application/vnd.ms-excel'
        response.headers['Content-Disposition'] = "attachment; filename=\"#{caption.strip.gsub(%r{[/:*?"\\<>\|\r\n]}i, '-') + '.xls'}\""
        response.write(xls) # NOTE: could this use streaming to start downloading quicker?
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength
