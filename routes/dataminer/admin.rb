# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

class Framework < Roda # rubocop:disable Metrics/ClassLength
  route 'admin', 'dataminer' do |r|
    context = { for_grid_queries: session[:dm_admin_path] == :grids, route_url: request.path }
    interactor = DataminerApp::DataminerInteractor.new(current_user, {}, context, {})

    r.is do
      show_page { DM::Admin::Index.call(context) }
    end

    r.on 'reports_grid' do
      interactor.admin_report_list_grid
    rescue StandardError => e
      show_json_exception(e)
    end

    r.on 'grids_grid' do
      interactor.admin_report_list_grid(for_grids: true)
    rescue StandardError => e
      show_json_exception(e)
    end

    r.on 'reports' do
      session[:dm_admin_path] = :reports
      r.redirect('/dataminer/admin')
    end

    r.on 'grids' do
      session[:dm_admin_path] = :grids
      r.redirect('/dataminer/admin')
    end

    r.on 'new' do
      if flash[:stashed_page]
        show_page { flash[:stashed_page] }
      else
        show_page { DM::Admin::New.call(for_grid_queries: context[:for_grid_queries]) }
      end
    end

    r.on 'create' do
      r.post do
        res = interactor.create_report(params[:report])
        if res.success
          flash[:notice] = res.message
          r.redirect('/dataminer/admin')
        else
          flash[:error] = res.message
          flash[:stashed_page] = DM::Admin::New.call(for_grid_queries: context[:for_grid_queries], form_values: params[:report],
                                                     form_errors: res.errors)
          r.redirect '/dataminer/admin/new/'
        end
      end
    end

    r.on 'convert' do
      r.post do
        unless params[:convert] && params[:convert][:file] &&
               (tempfile = params[:convert][:file][:tempfile]) &&
               (filename = params[:convert][:file][:filename])
          flash[:error] = 'No file selected to convert'
          r.redirect('/dataminer/admin')
        end
        show_page { DM::Admin::Convert.call(tempfile, filename) }
      end
    end

    r.on 'save_conversion' do
      r.post do
        res = interactor.convert_report(params[:report])
        if res.success
          view(inline: <<-HTML)
          <div class="crossbeams-success-note"><p><strong>Converted</strong></p></div>
          <p>New YAML code:</p>
          <pre>#{yml_to_highlight(res.instance.to_hash.to_yaml)}</pre>
          HTML
        else
          show_page_error "Conversion failed: #{res.message}"
        end
      end
    end

    r.on :id do |id|
      id = id.gsub('%20', ' ')

      r.on 'edit' do
        r.is do
          @page = interactor.edit_report(id)
          store_locally(:dm_admin_page, @page)
          view('dataminer/admin/edit')
        end

        r.on 'colour_grid' do
          @page = retrieve_from_local_store(:dm_admin_page)
          store_locally(:dm_admin_page, @page)
          rows = []
          @page.report.external_settings[:colour_key].each do |k, v|
            rows << { id: k, description: v, colour_rule: k }
          end

          cols = Crossbeams::DataGrid::ColumnDefiner.new.make_columns do |mk|
            mk.col 'id', nil, hide: true
            mk.col 'description', nil, editable: true, width: 500
            mk.col 'colour_rule'
          end

          {
            extraContext: { keyColumn: 'id' },
            multiselect_ids: [],
            fieldUpdateUrl: "/dataminer/admin/#{id}/save_colour_key_desc",
            tree: nil,
            columnDefs: cols,
            rowDefs: rows
          }.to_json
        end

        r.on 'columns_grid' do
          @page = retrieve_from_local_store(:dm_admin_page)
          store_locally(:dm_admin_page, @page)

          {
            extraContext: { keyColumn: 'name' },
            multiselect_ids: [],
            fieldUpdateUrl: @page.save_url,
            tree: nil,
            columnDefs: @page.col_defs,
            rowDefs: @page.row_defs
          }.to_json
        end

        r.on 'params_grid' do
          # NOTE: This relies on the fact that the params_grid url comes after the
          #       columns grid url in the page, so it'll be loaded last.
          #       If that ever changes, the retrieve+store in columns_grid above
          #       will not work properly!
          @page = retrieve_from_local_store(:dm_admin_page)

          {
            multiselect_ids: [],
            fieldUpdateUrl: nil,
            tree: nil,
            columnDefs: @page.col_defs_params,
            rowDefs: @page.row_defs_params
          }.to_json
        end
      end

      r.delete do
        res = interactor.delete_report(id)
        if res.success
          delete_grid_row(id, notice: res.message)
        else
          show_json_error(res.message)
        end
      end

      r.on 'save' do
        r.post do
          res = interactor.save_report(id, params)
          if res.success
            flash[:notice] = "Report's header has been changed."
          else
            flash[:error] = res.message
          end
          r.redirect("/dataminer/admin/#{id}/edit")
        end
      end
      r.on 'change_sql' do
        show_page { DM::Admin::ChangeSql.call(id) }
      end
      r.on 'save_new_sql' do
        r.patch do
          res = interactor.save_report_sql(id, params)
          if res.success
            flash[:notice] = "Report's SQL has been changed."
          else
            flash[:error] = res.message
          end
          r.redirect("/dataminer/admin/#{id}/edit")
        end
      end
      r.on 'reorder_columns' do
        show_page { DM::Admin::ReorderColumns.call(id) }
      end
      r.on 'save_reordered_columns' do
        r.patch do
          res = interactor.save_report_column_order(id, params[:report])
          if res.success
            flash[:notice] = "Report's column order has been changed."
          else
            flash[:error] = res.message
          end
          r.redirect("/dataminer/admin/#{id}/edit")
        end
      end
      r.on 'save_param_grid_col' do # JSON
        res = interactor.save_param_grid_col(id, params)
        if res.success
          if res.instance.nil?
            show_json_notice(res.instance)
          else
            update_grid_row(id, changes: res.instance, notice: res.message)
          end
        else
          undo_grid_inline_edit(message: res.message, message_type: :warn)
        end
      end
      r.on 'save_colour_key_desc' do # JSON
        res = interactor.save_colour_key_desc(id, params)
        if res.success
          show_json_notice(res.message)
        else
          undo_grid_inline_edit(message: res.message, message_type: :warn)
        end
      end
      r.on 'parameter' do
        r.on 'new' do
          show_page { DM::Admin::NewParameter.call(id) }
        end

        r.on 'create' do
          r.post do
            res = interactor.create_parameter(id, params[:report])
            if res.success
              flash[:notice] = res.message
            else
              flash[:error] = res.message
            end
            r.redirect("/dataminer/admin/#{id}/edit")
          end
        end
        r.on 'delete' do
          r.on :param_id do |param_id|
            res = interactor.delete_parameter(id, param_id)
            if res.success
              flash[:notice] = res.message
            else
              flash[:error] = res.message
            end
            r.redirect("/dataminer/admin/#{id}/edit")
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
