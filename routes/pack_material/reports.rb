# frozen_string_literal: true

class Framework < Roda # rubocop:disable Metrics/ClassLength
  route 'reports', 'pack_material' do |r| # rubocop:disable Metrics/BlockLength
    # MR PURCHASE ORDERS
    # --------------------------------------------------------------------------
    r.on 'print_purchase_order', Integer do |id|
      jasper_params = JasperParams.new('print_purchase_order',
                                       current_user.login_name,
                                       mr_purchase_order_id: id)
      res = CreateJasperReport.call(jasper_params)

      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end

    r.on 'email_purchase_order', Integer do |id|
      r.get do
        interactor = PackMaterialApp::MrPurchaseOrderInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
        show_partial_or_page(r) do
          Development::Generators::General::Email.call(remote: true,
                                                       email_options: interactor.email_purchase_order_defaults(id, current_user),
                                                       action: "/pack_material/reports/email_purchase_order/#{id}")
        end
      end
      r.post do
        opts = {
          email_settings: params[:mail],
          user_name: current_user.user_name,
          reports: [
            {
              report_name: 'print_purchase_order',
              file: 'purchase_order',
              report_params: { mr_purchase_order_id: id }
            }
          ]
        }
        DevelopmentApp::EmailJasperReport.enqueue(opts)
        show_json_notice('Report queued to be generated and sent')
      end
    end

    r.on 'delivery_received', Integer do |id|
      jasper_params = JasperParams.new('delivery_received_note',
                                       current_user.login_name,
                                       delivery_id: id)
      res = CreateJasperReport.call(jasper_params)

      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end

    r.on 'waybill_note', Integer do |id|
      jasper_params = JasperParams.new('waybill_note',
                                       current_user.login_name,
                                       delivery_id: id)
      res = CreateJasperReport.call(jasper_params)

      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end

    r.on 'delivery_purchase_invoice', Integer do |id|
      jasper_params = JasperParams.new('delivery_purchase_invoice',
                                       current_user.login_name,
                                       delivery_id: id)
      res = CreateJasperReport.call(jasper_params)

      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end

    # BULK STOCK ADJUSTMENTS
    # --------------------------------------------------------------------------
    r.on 'stock_adjustment_sheet', Integer do |id|
      jasper_params = JasperParams.new('stock_adjustment_sheet',
                                       current_user.login_name,
                                       mr_bulk_stock_adjustment_id: id)
      res = CreateJasperReport.call(jasper_params)

      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end

    r.on 'signed_off_report', Integer do |id|
      jasper_params = JasperParams.new('signed_off_report',
                                       current_user.login_name,
                                       mr_bulk_stock_adjustment_id: id)
      res = CreateJasperReport.call(jasper_params)

      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end

    r.on 'consumption_report', Integer do |id|
      jasper_params = JasperParams.new('consumption_report',
                                       current_user.login_name,
                                       mr_bulk_stock_adjustment_id: id)
      res = CreateJasperReport.call(jasper_params)

      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end

    r.on 'preliminary_report', Integer do |id|
      jasper_params = JasperParams.new('preliminary_report',
                                       current_user.login_name,
                                       mr_bulk_stock_adjustment_id: id)
      res = CreateJasperReport.call(jasper_params)

      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end

    # TRIPSHEETS
    # ---------------------------------------------------------------------------
    r.on 'tripsheet', Integer do |id|
      jasper_params = JasperParams.new('tripsheet',
                                       current_user.login_name,
                                       vehicle_job_id: id)
      res = CreateJasperReport.call(jasper_params)

      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end

    # GOODS RETURNED NOTE
    # ---------------------------------------------------------------------------
    r.on 'print_credit_note', Integer do |id|
      jasper_params = JasperParams.new('credit_note',
                                       current_user.login_name,
                                       mr_goods_returned_note_id: id)
      res = CreateJasperReport.call(jasper_params)

      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end

    r.on 'email_credit_note', Integer do |id|
      r.get do
        interactor = PackMaterialApp::MrGoodsReturnedNoteInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
        show_partial_or_page(r) do
          Development::Generators::General::Email.call(remote: true,
                                                       email_options: interactor.email_credit_note_defaults(id, current_user),
                                                       action: "/pack_material/reports/email_credit_note/#{id}")
        end
      end
      r.post do
        opts = {
          email_settings: params[:mail],
          user_name: current_user.user_name,
          reports: [{
            report_name: 'print_credit_note',
            file: 'credit_note',
            report_params: { mr_goods_returned_note_id: id }
          }]
        }
        DevelopmentApp::EmailJasperReport.enqueue(opts)
        show_json_notice('Report queued to be generated and sent')
      end
    end

    # SALES ORDER
    # ---------------------------------------------------------------------------
    r.on 'print_sales_order', Integer do |id|
      jasper_params = JasperParams.new('sales_order',
                                       current_user.login_name,
                                       mr_sales_order_id: id)
      res = CreateJasperReport.call(jasper_params)

      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end
    r.on 'print_so_waybill', Integer do |id|
      jasper_params = JasperParams.new('sales_order_waybill',
                                       current_user.login_name,
                                       mr_sales_order_id: id)
      res = CreateJasperReport.call(jasper_params)

      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end
    r.on 'email_sales_order', Integer do |id|
      r.get do
        interactor = PackMaterialApp::MrSalesOrderInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
        show_partial_or_page(r) do
          Development::Generators::General::Email.call(remote: true,
                                                       email_options: interactor.email_sales_order_defaults(id, current_user),
                                                       action: "/pack_material/reports/email_sales_order/#{id}")
        end
      end
      r.post do
        opts = {
          email_settings: params[:mail],
          user_name: current_user.user_name,
          reports: [{
            report_name: 'sales_order',
            file: 'sales_order',
            report_params: { mr_sales_order_id: id }
          }]
        }
        DevelopmentApp::EmailJasperReport.enqueue(opts)
        show_json_notice('Report queued to be generated and sent')
      end
    end

    # SALES RETURNS
    # ---------------------------------------------------------------------------
    r.on 'print_sales_return', Integer do |id|
      jasper_params = JasperParams.new('sales_return',
                                       current_user.login_name,
                                       mr_sales_return_id: id)
      res = CreateJasperReport.call(jasper_params)

      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
      end
    end

    r.on 'email_sales_return', Integer do |id|
      r.get do
        interactor = PackMaterialApp::MrSalesReturnInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
        show_partial_or_page(r) do
          Development::Generators::General::Email.call(remote: true,
                                                       email_options: interactor.email_sales_return_defaults(id, current_user),
                                                       action: "/pack_material/reports/email_sales_return/#{id}")
        end
      end
      r.post do
        opts = {
          email_settings: params[:mail],
          user_name: current_user.user_name,
          reports: [{
            report_name: 'print_sales_return',
            file: 'sales_return',
            report_params: { mr_sales_return_id: id }
          }]
        }
        DevelopmentApp::EmailJasperReport.enqueue(opts)
        show_json_notice('Report queued to be generated and sent')
      end
    end
  end
end
