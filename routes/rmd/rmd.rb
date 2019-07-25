# frozen_string_literal: true

class Framework < Roda # rubocop:disable Metrics/ClassLength
  # DELIVERIES
  # --------------------------------------------------------------------------
  route 'deliveries', 'rmd' do |r| # rubocop:disable Metrics/BlockLength
    # PUTAWAYS
    # --------------------------------------------------------------------------
    r.on 'putaways' do # rubocop:disable Metrics/BlockLength
      # Interactor
      r.on 'new' do    # NEW
        # check auth...
        details = retrieve_from_local_store(:delivery_putaway) || {}
        form = Crossbeams::RMDForm.new(details,
                                       form_name: :putaway,
                                       progress: details[:delivery_id] ? details[:progress] : nil, # 'Delivery 123: 3 of 5 items complete' : nil,
                                       notes: 'Please scan the Delivery number and the SKU number, then scan the Location and enter the quantity to be putaway.',
                                       scan_with_camera: @rmd_scan_with_camera,
                                       caption: 'Delivery putaway',
                                       action: '/rmd/deliveries/putaways',
                                       button_caption: 'Putaway')
        form.add_field(:delivery_number, 'Delivery', scan: 'key248_all', scan_type: :delivery)
        form.add_field(:sku_number, 'SKU', scan: 'key248_all', scan_type: :sku, lookup: true)
        form.add_field(:location, 'Location', scan: 'key248_all', scan_type: :location, lookup: true)
        form.add_field(:quantity, 'Quantity', data_type: 'number')
        form.add_csrf_tag csrf_tag
        view(inline: form.render, layout: :layout_rmd)
      end

      r.post do        # CREATE
        interactor = PackMaterialApp::MrDeliveryInteractor.new(current_user, {}, { route_url: request.path }, {})
        res = interactor.putaway_delivery(params[:putaway])
        payload = { progress: nil }
        if res.success
          payload[:delivery_id] = res.instance[:delivery_id]
          payload[:progress] = res.instance[:report]
        else
          these_params = params[:putaway]
          payload[:error_message] = res.message
          payload[:errors] = res.errors
          payload.merge!(location: these_params[:location],
                         location_scan_field: these_params[:location_scan_field],
                         sku_number: these_params[:sku_number],
                         sku_number_scan_field: these_params[:sku_number_scan_field],
                         delivery_number: these_params[:delivery_number],
                         delivery_number_scan_field: these_params[:delivery_number_scan_field],
                         quantity: these_params[:quantity])
        end

        store_locally(:delivery_putaway, payload)
        r.redirect '/rmd/deliveries/putaways/new'
      end
    end

    r.on 'status' do
      view(inline: '<h2>Just a dummy page this...</h2><p>Nothing to see here, keep moving along...</p>', layout: :layout_rmd)
    end
  end

  # Bulk Stock Adjustments
  # --------------------------------------------------------------------------
  route 'stock_adjustments', 'rmd' do |r| # rubocop:disable Metrics/BlockLength
    # ADJUST ITEM
    # --------------------------------------------------------------------------
    r.on 'adjust_item' do # rubocop:disable Metrics/BlockLength
      interactor = PackMaterialApp::MrBulkStockAdjustmentInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do
        details = retrieve_from_local_store(:stock_item_adjustment) || {}
        form = Crossbeams::RMDForm.new(details,
                                       form_name: :adjust_item,
                                       progress: details[:bulk_stock_adjustment_id] ? details[:progress] : nil,
                                       notes: 'Please scan the Stock Adjustment number and the SKU number, then scan the Location and enter the actual quantity to adjust the item.',
                                       scan_with_camera: @rmd_scan_with_camera,
                                       caption: 'Stock Item Adjustment',
                                       action: '/rmd/stock_adjustments/adjust_item',
                                       button_caption: 'Adjust Item')
        form.add_field(:stock_adjustment_number, 'Stock Adjustment', scan: 'key248_all', scan_type: :stock_adjustment)
        form.add_field(:sku_number, 'SKU', scan: 'key248_all', scan_type: :sku)
        form.add_field(:location, 'Location', scan: 'key248_all', scan_type: :location)
        form.add_field(:quantity, 'Actual Quantity', data_type: 'number')
        form.add_csrf_tag csrf_tag
        view(inline: form.render, layout: :layout_rmd)
      end

      r.post do
        res = interactor.stock_item_adjust(params[:adjust_item])
        payload = { progress: nil }
        if res.success
          payload[:bulk_stock_adjustment_id] = res.instance[:bulk_stock_adjustment_id]
          payload[:stock_adjustment_number] = params[:adjust_item][:stock_adjustment_number]
          payload[:stock_adjustment_number_scan_field] = params[:adjust_item][:stock_adjustment_number_scan_field]
          payload[:progress] = res.instance[:report]
        else
          these_params = params[:adjust_item]
          payload[:error_message] = res.message
          payload[:errors] = res.errors
          payload.merge!(location: these_params[:location],
                         location_scan_field: these_params[:location_scan_field],
                         sku_number: these_params[:sku_number],
                         sku_number_scan_field: these_params[:sku_number_scan_field],
                         stock_adjustment_number: these_params[:stock_adjustment_number],
                         stock_adjustment_number_scan_field: these_params[:stock_adjustment_number_scan_field],
                         quantity: these_params[:quantity])
        end

        store_locally(:stock_item_adjustment, payload)
        r.redirect '/rmd/stock_adjustments/adjust_item/new'
      end
    end
  end

  # Printing
  # --------------------------------------------------------------------------
  route 'printing', 'rmd' do |r| # rubocop:disable Metrics/BlockLength
    # PRINT SKU LABEL
    # --------------------------------------------------------------------------
    r.on 'sku_label' do # rubocop:disable Metrics/BlockLength
      interactor = PackMaterialApp::MrDeliveryItemBatchInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do
        @print_repo = LabelApp::PrinterRepo.new
        printers    = @print_repo.select_printers_for_application(AppConst::PRINT_APP_MR_SKU_BARCODE)
        details     = retrieve_from_local_store(:print_rmd_sku_label_options) || {}
        form        = Crossbeams::RMDForm.new(details,
                                              form_name: :print_rmd_sku_label,
                                              progress: details[:progress],
                                              notes: 'Please scan the SKU number, then enter the quantity to be printed.',
                                              scan_with_camera: @rmd_scan_with_camera,
                                              caption: 'Print SKU Label',
                                              action: '/rmd/printing/sku_label',
                                              button_caption: 'Print')
        form.add_select(:printer, 'Printer', items: printers, value: printers.first, required: true, prompt: true)
        form.add_field(:sku_number, 'SKU', scan: 'key248_all', scan_type: :sku)
        form.add_field(:no_of_prints, 'No of Prints', data_type: 'number')
        form.add_csrf_tag csrf_tag
        view(inline: form.render, layout: :layout_rmd)
      end

      r.post do
        res     = interactor.print_sku_barcode(params[:print_rmd_sku_label], rmd: true)
        payload = { progress: nil }
        if res.success
          payload[:printer]  = res.instance[:printer]
          payload[:progress] = res.message
        else
          these_params            = params[:print_rmd_sku_label]
          payload[:error_message] = res.message
          payload[:errors]        = res.errors
          payload.merge!(printer: these_params[:printer],
                         sku_number: these_params[:sku_number],
                         sku_number_scan_field: these_params[:sku_number_scan_field],
                         no_of_prints: these_params[:no_of_prints])
        end

        store_locally(:print_rmd_sku_label_options, payload)
        r.redirect '/rmd/printing/sku_label/new'
      end
    end
  end
end
