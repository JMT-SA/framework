# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/ClassLength

class Framework < Roda
  # STOCK
  # --------------------------------------------------------------------------
  route 'stock', 'rmd' do |r|
    # MOVE
    # --------------------------------------------------------------------------
    r.on 'moves' do
      interactor = PackMaterialApp::MrInventoryTransactionInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do
        r.get do
          details = retrieve_from_local_store(:stock_move) || {}
          processes = interactor.adhoc_move_business_processes
          form = Crossbeams::RMDForm.new(details,
                                         form_name: :move,
                                         notes: 'Scan current Location & SKU and enter quantity to move',
                                         progress: details[:transaction_item_id] ? details[:last_move] : nil,
                                         scan_with_camera: @rmd_scan_with_camera,
                                         caption: 'Stock move',
                                         step_and_total: [1, 2],
                                         action: '/rmd/stock/moves/new',
                                         button_caption: 'Move')
          form.add_select(:business_process, 'Business process', items: processes, value: processes.first, required: true, prompt: true)
          form.add_field(:from_location, 'From location', scan: 'key248_all', scan_type: :location, lookup: true)
          form.add_field(:sku_number, 'SKU', scan: 'key248_all', scan_type: :sku, lookup: true)
          form.add_field(:quantity, 'Quantity', data_type: 'number')
          form.add_field(:ref_no, 'Reference Number', data_type: 'string')
          form.add_csrf_tag csrf_tag
          view(inline: form.render, layout: :layout_rmd)
        end

        r.post do
          values = params[:move].merge(lookup_values: params[:lookup_values])
          res = interactor.validation_for_adhoc_rmd_move_stock(values)
          if res.success
            store_locally(:stock_move, values.merge(from_location_id: res.instance[:from_location_id],
                                                    business_process_id: res.instance[:business_process_id]))
            r.redirect '/rmd/stock/moves/putaway'
          else
            payload = {
              error_message: res.message,
              errors: res.errors[:business_process_id] ? res.errors.merge(business_process: res.errors[:business_process_id]) : res.errors
            }
            payload.merge!(business_process: values[:business_process],
                           from_location: values[:from_location],
                           from_location_scan_field: values[:from_location_scan_field],
                           sku_number: values[:sku_number],
                           sku_number_scan_field: values[:sku_number_scan_field],
                           quantity: values[:quantity],
                           ref_no: values[:ref_no])
            payload.merge!(lookup_values: params[:lookup_values])
            store_locally(:stock_move, payload)
            r.redirect '/rmd/stock/moves/new'
          end
        end
      end

      r.on 'putaway' do
        r.get do
          details = retrieve_from_local_store(:stock_move) || {}
          store_locally(:stock_move, details)

          form = Crossbeams::RMDForm.new(details,
                                         form_name: :move,
                                         notes: 'Scan TO Location & SKU and enter quantity to move',
                                         scan_with_camera: @rmd_scan_with_camera,
                                         caption: 'Stock move',
                                         step_and_total: [2, 2],
                                         links: [{ caption: 'Cancel', url: '/rmd/stock/moves/cancel', prompt: 'Are you sure?' }],
                                         action: '/rmd/stock/moves/putaway',
                                         button_caption: 'Putaway')
          form.add_label(:business_process, 'Business process', details[:business_process])
          form.add_label(:from_location, 'From location', details[:from_location])
          form.add_label(:sku_number, 'SKU', details[:sku_number])
          form.add_label(:quantity, 'Quantity', details[:quantity])
          form.add_label(:ref_no, 'Reference Number', details[:ref_no])
          form.add_field(:to_location, 'To location', scan: 'key248_all', scan_type: :location, lookup: true)
          form.add_csrf_tag csrf_tag
          view(inline: form.render, layout: :layout_rmd)
        end

        r.post do
          details = retrieve_from_local_store(:stock_move) || {}
          details = details.merge(to_location: params[:move][:to_location],
                                  to_location_scan_field: params[:move][:to_location_scan_field])
          res = interactor.adhoc_rmd_move_stock(details)

          if res.success
            payload = {
              transaction_item_id: res.instance[:transaction_item_id],
              last_move: res.instance[:report]
            }
            store_locally(:stock_move, payload)
            r.redirect '/rmd/stock/moves/new'
          else
            payload = {
              error_message: res.message,
              errors: res.errors
            }
            payload.merge!(business_process: details[:business_process],
                           from_location: details[:from_location],
                           from_location_scan_field: details[:from_location_scan_field],
                           sku_number: details[:sku_number],
                           sku_number_scan_field: details[:sku_number_scan_field],
                           quantity: details[:quantity],
                           ref_no: details[:ref_no],
                           to_location: details[:to_location],
                           to_location_scan_field: details[:to_location_scan_field])
            payload.merge!(lookup_values: params[:lookup_values])
            store_locally(:stock_move, payload)
            r.redirect '/rmd/stock/moves/putaway'
          end
        end
      end

      r.on 'cancel' do
        # Clear local storage
        store_locally(:stock_move, {})
        r.redirect '/rmd/stock/moves/new'
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
# rubocop:enable Metrics/ClassLength
