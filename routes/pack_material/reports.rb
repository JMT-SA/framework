# frozen_string_literal: true

class Framework < Roda
  route 'reports', 'pack_material' do |r|
    # MR PURCHASE ORDERS
    # --------------------------------------------------------------------------
    r.on 'goods_returned', Integer do |id|
      res = CreateJasperReport.call(report_name: 'goods_returned_note',
                                    user: current_user.login_name,
                                    file: 'goods_returned_note',
                                    params: { delivery_id: id,
                                              keep_file: true })
      if res.success
        change_window_location_via_json(res.instance, request.path)
      else
        show_error(res.message, fetch?(r))
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
  end
end
