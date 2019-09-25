# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
#- rubocop:disable Metrics/ClassLength

class Framework < Roda
  # Vehicles
  # --------------------------------------------------------------------------
  route 'vehicles', 'rmd' do |r|
    r.on 'load' do # rubocop:disable Metrics/BlockLength
      interactor = PackMaterialApp::VehicleJobInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do
        details = retrieve_from_local_store(:vehicle_unit_load) || {}
        form = Crossbeams::RMDForm.new(details,
                                       form_name: :load_unit,
                                       progress: details[:vehicle_job_id] ? details[:progress] : nil,
                                       notes: 'Please scan the Tripsheet number and the SKU number, then scan the Location and enter the quantity to be loaded.',
                                       scan_with_camera: @rmd_scan_with_camera,
                                       caption: 'Vehicle Unit Load',
                                       action: '/rmd/vehicles/load',
                                       button_caption: 'Load Unit')
        form.add_field(:tripsheet_number, 'Tripsheet', scan: 'key248_all', scan_type: :tripsheet)
        form.add_field(:sku_number, 'SKU', scan: 'key248_all', scan_type: :sku, lookup: true)
        form.add_field(:location, 'Location', scan: 'key248_all', scan_type: :location, lookup: true)
        form.add_field(:quantity, 'Quantity to Load', data_type: 'number', allow_decimals: true)
        form.add_csrf_tag csrf_tag
        view(inline: form.render, layout: :layout_rmd)
      end

      r.post do
        res = interactor.load_vehicle_unit(params[:load_unit])
        payload = { progress: nil }
        if res.success
          payload[:vehicle_job_id] = res.instance[:vehicle_job_id]
          payload[:tripsheet_number] = params[:load_unit][:tripsheet_number]
          payload[:tripsheet_number_scan_field] = params[:load_unit][:tripsheet_number_scan_field]
          payload[:progress] = res.instance[:report]
        else
          these_params = params[:load_unit]
          payload[:error_message] = res.message
          payload[:errors] = res.errors
          payload.merge!(location: these_params[:location],
                         location_scan_field: these_params[:location_scan_field],
                         sku_number: these_params[:sku_number],
                         sku_number_scan_field: these_params[:sku_number_scan_field],
                         tripsheet_number: these_params[:tripsheet_number],
                         tripsheet_number_scan_field: these_params[:tripsheet_number_scan_field],
                         quantity: these_params[:quantity])
          payload.merge!(lookup_values: params[:lookup_values])
        end

        store_locally(:vehicle_unit_load, payload)
        r.redirect '/rmd/vehicles/load/new'
      end
    end

    # r.on 'offload' do
    # end
    #
    # r.on 'putaways' do #- rubocop:disable Metrics/BlockLength
    #   r.on 'new' do    # NEW
    #     details = retrieve_from_local_store(:delivery_putaway) || {}
    #     form = Crossbeams::RMDForm.new(details,
    #                                    form_name: :putaway,
    #                                    progress: details[:delivery_id] ? details[:progress] : nil, # 'Delivery 123: 3 of 5 items complete' : nil,
    #                                    notes: 'Please scan the Delivery number and the SKU number, then scan the Location and enter the quantity to be putaway.',
    #                                    scan_with_camera: @rmd_scan_with_camera,
    #                                    caption: 'Delivery putaway',
    #                                    action: '/rmd/deliveries/putaways',
    #                                    button_caption: 'Putaway')
    #     form.add_field(:delivery_number, 'Delivery', scan: 'key248_all', scan_type: :delivery)
    #     form.add_field(:sku_number, 'SKU', scan: 'key248_all', scan_type: :sku, lookup: true)
    #     form.add_field(:quantity, 'Quantity', data_type: 'number')
    #     form.add_field(:location, 'Location', scan: 'key248_all', scan_type: :location, lookup: true)
    #     form.add_csrf_tag csrf_tag
    #     view(inline: form.render, layout: :layout_rmd)
    #   end
    #
    #   r.post do        # CREATE
    #     interactor = PackMaterialApp::MrDeliveryInteractor.new(current_user, {}, { route_url: request.path }, {})
    #     res = interactor.putaway_delivery(params[:putaway])
    #     payload = { progress: nil }
    #     if res.success
    #       payload[:delivery_id] = res.instance[:delivery_id]
    #       payload[:progress] = res.instance[:report]
    #     else
    #       these_params = params[:putaway]
    #       payload[:error_message] = res.message
    #       payload[:errors] = res.errors
    #       payload.merge!(location: these_params[:location],
    #                      location_scan_field: these_params[:location_scan_field],
    #                      sku_number: these_params[:sku_number],
    #                      sku_number_scan_field: these_params[:sku_number_scan_field],
    #                      delivery_number: these_params[:delivery_number],
    #                      delivery_number_scan_field: these_params[:delivery_number_scan_field],
    #                      quantity: these_params[:quantity])
    #       payload.merge!(lookup_values: params[:lookup_values])
    #     end
    #
    #     store_locally(:delivery_putaway, payload)
    #     r.redirect '/rmd/deliveries/putaways/new'
    #   end
    # end
  end
end
# rubocop:enable Metrics/BlockLength
#- rubocop:enable Metrics/ClassLength
