# frozen_string_literal: true

class Framework < Roda # rubocop:disable Metrics/ClassLength
  route 'reports', 'pack_material' do |r| # rubocop:disable Metrics/BlockLength
    # MR PURCHASE ORDERS
    # --------------------------------------------------------------------------
    r.on 'print_purchase_order', Integer do |id|
      res = CreateJasperReport.call(report_name: 'print_purchase_order',
                                    user: current_user.login_name,
                                    file: 'print_purchase_order',
                                    params: { mr_purchase_order_id: id,
                                              keep_file: true })
      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end

    r.on 'email_purchase_order', Integer do |id|
      r.get do
        interactor = PackMaterialApp::MrPurchaseOrderInteractor.new(current_user, {}, { route_url: request.path }, {})
        show_partial_or_page(r) do
          Development::Generators::General::Email.call(remote: true,
                                                       email_options: interactor.email_puchase_order_defaults(id, current_user),
                                                       action: "/pack_material/reports/email_purchase_order/#{id}")
        end
      end
      r.post do
        opts = {
          email_settings: params[:mail],
          user: current_user.login_name,
          reports: [
            {
              report_name: 'print_purchase_order',
              file: 'purchase_order',
              report_params: { mr_purchase_order_id: id,
                               keep_file: true }
            }
          ]
        }
        DevelopmentApp::EmailJasperReport.enqueue(opts)
        show_json_notice('Report queued to be generated and sent')
      end
    end

    r.on 'delivery_received', Integer do |id|
      res = CreateJasperReport.call(report_name: 'delivery_received_note',
                                    user: current_user.login_name,
                                    file: 'delivery_received_note',
                                    params: { delivery_id: id,
                                              keep_file: true })
      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end

    r.on 'waybill_note', Integer do |id|
      res = CreateJasperReport.call(report_name: 'waybill_note',
                                    user: current_user.login_name,
                                    file: 'waybill_note',
                                    params: { delivery_id: id,
                                              keep_file: true })
      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end

    r.on 'delivery_purchase_invoice', Integer do |id|
      res = CreateJasperReport.call(report_name: 'delivery_purchase_invoice',
                                    user: current_user.login_name,
                                    file: 'delivery_purchase_invoice',
                                    params: { delivery_id: id,
                                              keep_file: true })
      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end

    # BULK STOCK ADJUSTMENTS
    # --------------------------------------------------------------------------
    r.on 'stock_adjustment_sheet', Integer do |id|
      res = CreateJasperReport.call(report_name: 'stock_adjustment_sheet',
                                    user: current_user.login_name,
                                    file: 'stock_adjustment_sheet',
                                    params: { mr_bulk_stock_adjustment_id: id,
                                              keep_file: true })
      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end

    r.on 'signed_off_report', Integer do |id|
      res = CreateJasperReport.call(report_name: 'signed_off_report',
                                    user: current_user.login_name,
                                    file: 'signed_off_report',
                                    params: { mr_bulk_stock_adjustment_id: id,
                                              keep_file: true })
      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end

    r.on 'preliminary_report', Integer do |id|
      res = CreateJasperReport.call(report_name: 'preliminary_report',
                                    user: current_user.login_name,
                                    file: 'preliminary_report',
                                    params: { mr_bulk_stock_adjustment_id: id,
                                              keep_file: true })
      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end
  end
end
