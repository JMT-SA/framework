# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

class Framework < Roda
  # STOCK
  # --------------------------------------------------------------------------
  route 'stock', 'rmd' do |r|
    # MOVE
    # --------------------------------------------------------------------------
    r.on 'moves' do
      # Interactor
      r.on 'new' do
        r.get do
          details = retrieve_from_local_store(:stock_move) || {}
          processes = DB[:business_processes].select_map(:process) # get from interactor
          form = Crossbeams::RMDForm.new(details,
                                         form_name: :move,
                                         notes: 'Scan current Location & SKU and enter quantity to move',
                                         progress: details[:last_move],
                                         scan_with_camera: @rmd_scan_with_camera,
                                         caption: 'Stock move',
                                         step_and_total: [1, 2],
                                         action: '/rmd/stock/moves/new',
                                         button_caption: 'Move')
          form.add_select(:business_process, 'Business process', items: processes, value: processes.first, required: true, prompt: true)
          form.add_field(:from_location, 'From location', scan: 'key248_all', scan_type: :location, lookup: true)
          form.add_field(:sku_number, 'SKU', scan: 'key248_all', scan_type: :sku, lookup: true)
          form.add_field(:quantity, 'Quantity', data_type: 'number')
          form.add_csrf_tag csrf_tag
          view(inline: form.render, layout: :layout_rmd)
        end

        r.post do
          # Validate into StockMoveStep1 entity
          res = OpenStruct.new(success: true, message: 'whatever')
          store_locally(:stock_move, params[:move].merge(lookup_values: params[:lookup_values]))
          if res.success
            r.redirect '/rmd/stock/moves/putaway'
          else
            # store errors
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
          form.add_label(:from_location, 'From location', details[:lookup_values][:from_location])
          form.add_label(:sku_number, 'SKU', details[:lookup_values][:sku_number])
          form.add_label(:quantity, 'Quantity', details[:quantity])
          form.add_field(:to_location, 'To location', scan: 'key248_all', scan_type: :location, lookup: true)
          form.add_csrf_tag csrf_tag
          view(inline: form.render, layout: :layout_rmd)
        end

        r.post do
          interactor = PackMaterialApp::MrInventoryTransactionInteractor.new(current_user, {}, { route_url: request.path }, {})
          # Validate & update via interactor
          res = OpenStruct.new(success: true, message: 'whatever')
          if res.success
            # Clear local storage
            store_locally(:stock_move, last_move: 'Moved 20bags - or whatever...')
            r.redirect '/rmd/stock/moves/new'
          else
            # store errors
            details = retrieve_from_local_store(:stock_move) || {}
            details[:lookup_values][:to_location] = params[:lookup_values][:to_location]
            store_locally(:stock_move, details.merge(params[:move]))
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
