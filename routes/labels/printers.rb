# frozen_string_literal: true

class Framework < Roda
  route 'printers', 'labels' do |r| # rubocop:disable Metrics/BlockLength
    # PRINTERS
    # --------------------------------------------------------------------------
    r.on 'printers', Integer do |id|
      interactor = LabelApp::PrinterInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

      # Check for notfound:
      r.on !interactor.exists?(:printers, id) do
        handle_not_found(r)
      end

      r.get do       # SHOW
        show_partial { Labels::Printers::Printer::Show.call(id) }
      end
    end

    r.on 'printers' do
      interactor = LabelApp::PrinterInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
      r.on 'refresh' do
        res = interactor.refresh_printers
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_last_grid(r)
      end
    end

    # PRINTER APPLICATIONS
    # --------------------------------------------------------------------------
    r.on 'printer_applications', Integer do |id| # rubocop:disable Metrics/BlockLength
      interactor = LabelApp::PrinterInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

      # Check for notfound:
      r.on !interactor.exists?(:printer_applications, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('designs', 'edit')
        show_partial { Labels::Printers::PrinterApplication::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('designs', 'read')
          show_partial { Labels::Printers::PrinterApplication::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_printer_application(id, params[:printer_application])
          if res.success
            redirect_to_last_grid(r)
          else
            re_show_form(r, res) { Labels::Printers::PrinterApplication::Edit.call(id, form_values: params[:printer_application], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('designs', 'delete')
          res = interactor.delete_printer_application(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    r.on 'printer_applications' do
      interactor = LabelApp::PrinterInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
      r.on 'new' do    # NEW
        check_auth!('designs', 'new')
        show_partial_or_page(r) { Labels::Printers::PrinterApplication::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_printer_application(params[:printer_application])
        if res.success
          redirect_to_last_grid(r)
        else
          re_show_form(r, res, url: '/labels/printers/printer_applications/new') do
            Labels::Printers::PrinterApplication::New.call(form_values: params[:printer_application],
                                                           form_errors: res.errors,
                                                           remote: fetch?(r))
          end
        end
      end
    end
  end
end
