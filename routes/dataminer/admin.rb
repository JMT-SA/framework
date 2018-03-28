# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'admin', 'dataminer' do |r|
    context = { for_grid_queries: session[:dm_admin_path] == :grids }
    interactor = DataminerInteractor.new(current_user, {}, context, {})

    r.is do
      show_page { DM::Admin::Index.call(context) }
    end

    r.on 'reports_grid' do
      response['Content-Type'] = 'application/json'
      interactor.admin_report_list_grid
    end

    r.on 'grids_grid' do
      response['Content-Type'] = 'application/json'
      interactor.admin_report_list_grid(for_grids: true)
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
          <h1>Converted</h1>
          <p>New YAML code:</p>
          <pre>#{yml_to_highlight(res.instance.to_hash.to_yaml)}</pre>
          HTML
        else
          view(inline: <<-HTML)
          <h1>Conversion failed</h1>
          <p>#{res.message}</p>
          HTML
        end
      end
    end

    r.on :id do |id|
      r.on 'edit' do
        @page = interactor.edit_report(id)
        view('dataminer/admin/edit')
      end

      r.delete do
        response['Content-Type'] = 'application/json'
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
          r.redirect("/dataminer/admin/#{id}/edit/")
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
          r.redirect("/dataminer/admin/#{id}/edit/")
        end
      end
      r.on 'reorder_columns' do
        show_page { DM::Admin::ReorderColumns.call(id) }
      end
      r.on 'save_reordered_columns' do
        r.patch do
          res = interactor.save_report_column_order(id, params)
          if res.success
            flash[:notice] = "Report's column order has been changed."
          else
            flash[:error] = res.message
          end
          r.redirect("/dataminer/admin/#{id}/edit/")
        end
      end
      r.on 'save_param_grid_col' do # JSON
        res = interactor.save_param_grid_col(id, params)
        res.instance.to_json
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
            r.redirect("/dataminer/admin/#{id}/edit/")
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
            r.redirect("/dataminer/admin/#{id}/edit/")
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
