# frozen_string_literal: true

class Framework < Roda # rubocop:disable Metrics/ClassLength
  # RMD USER MENU PAGE
  # --------------------------------------------------------------------------
  route 'home', 'rmd' do # |r|
    @no_menu = true
    show_rmd_page { Rmd::Home::Show.call(rmd_menu_items(self.class.name, as_hash: true)) }
  end

  # RMD BARCODE CHECK PAGE
  # --------------------------------------------------------------------------
  route 'check_barcode', 'rmd' do |r| # rubocop:disable Metrics/BlockLength
    r.get do
      form = Crossbeams::RMDForm.new({},
                                     form_name: :barcodes,
                                     notes: 'Scan one or more barcodes to see their raw text',
                                     scan_with_camera: @rmd_scan_with_camera,
                                     caption: 'Barcode check',
                                     action: '/rmd/check_barcode',
                                     button_caption: 'Show')
      form.add_field(:barcode_1, 'Barcode one', scan: 'key248_all', required: false)
      form.add_field(:barcode_2, 'Barcode two', scan: 'key248_all', required: false)
      form.add_field(:barcode_3, 'Barcode three', scan: 'key248_all', required: false)
      form.add_field(:barcode_4, 'Barcode four', scan: 'key248_all', required: false)
      form.add_field(:barcode_5, 'Barcode five', scan: 'key248_all', required: false)
      form.add_csrf_tag csrf_tag
      @bypass_rules = true
      view(inline: form.render, layout: :layout_rmd)
    end
    r.post do
      tr_cls = 'striped--light-gray'
      td_cls = 'pv2 ph3'
      res = <<~HTML
        <table class="collapse ba br2 b--black-10 pv2 ph3">
        <tbody>
          <tr class="#{tr_cls}"><td class="#{td_cls}">Barcode one</td><td class="#{td_cls}">#{params[:barcodes][:barcode_1]}</td></tr>
          <tr class="#{tr_cls}"><td class="#{td_cls}">Barcode two</td><td class="#{td_cls}">#{params[:barcodes][:barcode_2]}</td></tr>
          <tr class="#{tr_cls}"><td class="#{td_cls}">Barcode three</td><td class="#{td_cls}">#{params[:barcodes][:barcode_3]}</td></tr>
          <tr class="#{tr_cls}"><td class="#{td_cls}">Barcode four</td><td class="#{td_cls}">#{params[:barcodes][:barcode_4]}</td></tr>
          <tr class="#{tr_cls}"><td class="#{td_cls}">Barcode five</td><td class="#{td_cls}">#{params[:barcodes][:barcode_5]}</td></tr>
        </tbody>
        </table>
        <p class="mt4">
          <a href="/rmd/check_barcode" class="link dim br2 pa3 bn white bg-blue">Scan again</a>
        </p>
      HTML
      view(inline: "<h2>Scanned barcodes</h2><p>#{res}</p>", layout: :layout_rmd)
    end
  end

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
        form.add_field(:sku_number, 'SKU', scan: 'key248_all', scan_type: :sku)
        form.add_field(:location, 'Location', scan: 'key248_all', scan_type: :location)
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
end
