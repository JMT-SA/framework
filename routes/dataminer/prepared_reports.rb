# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

# ****************************************************************************************************************************************
#
# TODO: think through system + framework db with same connection, diff reports path, but same prep dir. (do not list same dir twice......)
#
# ****************************************************************************************************************************************

class Framework < Roda
  route 'prepared_reports', 'dataminer' do |r|
    interactor = DataminerApp::PreparedReportInteractor.new(current_user, {}, { route_url: request.path }, {})

    r.on 'new', String do |id|    # NEW
      check_auth!('reports', 'new')
      # Show already-saved-reports-for-same_user
      show_partial_or_page(r) { DM::Report::PreparedReport::New.call(id, params[:json_var], current_user, remote: fetch?(r)) }
    end

    r.on 'list' do
      show_page { DM::Report::Report::GridPage.call('/dataminer/prepared_reports/grid/', 'Prepared report listing') }
    end

    r.on 'grid' do
      interactor.prepared_report_list_grid(true)
    rescue StandardError => e
      show_json_exception(e)
    end

    r.on 'list_all' do
      show_page { DM::Report::Report::GridPage.call('/dataminer/prepared_reports/grid_all/', 'Prepared report listing - all reports') }
    end

    r.on 'grid_all' do
      interactor.prepared_report_list_grid
    rescue StandardError => e
      show_json_exception(e)
    end

    r.on :id do |id|
      id = id.gsub('%20', ' ')

      # Make an instance
      instance = interactor.prepared_report_meta(id)
      r.on 'webquery_url' do
        show_partial_or_page(r) { DM::Report::PreparedReport::WebQuery.call(instance, webquery_url_for(id)) }
      end

      r.on 'properties' do
        show_partial_or_page(r) { DM::Report::PreparedReport::Properties.call(instance, webquery_url_for(id)) }
      end

      r.on 'change_columns' do
        show_partial_or_page(r) { DM::Report::PreparedReport::ChangeColumns.call(id, instance, interactor.prepared_report(id)) }
      end

      r.on 'save_columns' do
        r.patch do
          res = interactor.change_columns(id, params[:prepared_report])
          show_json_notice(res.message)
        end
      end

      r.on 'run' do
        show_page { DM::Report::Report::GridPage.call("/dataminer/prepared_reports/#{id}/grid", instance[:report_description]) }
      end

      r.on 'run_with_parameters' do
        # params.erb
        # @page = interactor.report_parameters(id, params)
        # view('dataminer/report/parameters')
      end

      r.on 'xls' do
        page = interactor.create_prepared_report_spreadsheet(id)
        response.headers['content_type'] = 'application/vnd.ms-excel'
        response.headers['Content-Disposition'] = "attachment; filename=\"#{page.report.caption.strip.gsub(%r{[/:*?"\\<>\|\r\n]}i, '-') + '.xls'}\""
        # NOTE: could this use streaming to start downloading quicker?
        response.write(page.excel_file.to_stream.read)
      end

      r.on 'grid' do
        interactor.prepared_report_grid(id)
      rescue StandardError => e
        show_json_exception(e)
      end

      r.on 'edit' do
        check_auth!('reports', 'edit') # Need to check user == creator, or has all_preps permission...
        show_partial { DM::Report::PreparedReport::Edit.call(id) }
      end

      r.patch do     # UPDATE
        res = interactor.update_prepared_report(id, params[:prepared_report])
        if res.success
          update_grid_row(id, changes: { caption: res.instance[:report_description] },
                              notice: res.message)
        else
          re_show_form(r, res) { DM::Report::PreparedReport::Edit.call(id, form_values: params[:prepared_report], form_errors: res.errors) }
        end
      end

      r.delete do
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
        show_page_or_update_dialog(r, res) { DM::Report::PreparedReport::WebQuery.call(res.instance, webquery_url_for(res.instance[:id]), fetch?(r)) }
      else
        id = params[:prepared_report][:id]
        re_show_form(r, res, url: "/dataminer/prepared_reports/new/#{id}") do
          DM::Report::PreparedReport::New.call(id,
                                               params[:prepared_report][:json_var], current_user,
                                               form_values: params[:prepared_report],
                                               form_errors: res.errors,
                                               remote: fetch?(r))
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
