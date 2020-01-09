# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
#- rubocop:disable Metrics/ClassLength

class Framework < Roda
  # Vehicles
  # --------------------------------------------------------------------------
  route 'vehicles', 'rmd' do |r|
    r.on 'load' do # rubocop:disable Metrics/BlockLength
      interactor = PackMaterialApp::VehicleJobInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
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
        form.add_field(:sku_number, 'SKU', scan: 'key248_all', scan_type: :sku, lookup: true, data_type: 'number')
        form.add_field(:location, 'From Location', scan: 'key248_all', scan_type: :location, lookup: true, force_uppercase: true)
        form.add_field(:quantity, 'Quantity to Load', data_type: 'number', allow_decimals: true)
        form.add_select(:force_load, 'Force Load this item', items: [['no', false], ['yes', true]], value: false, required: true)
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
                         quantity: these_params[:quantity],
                         force_load: these_params[:force_load])
          payload.merge!(lookup_values: params[:lookup_values])
        end

        store_locally(:vehicle_unit_load, payload)
        r.redirect '/rmd/vehicles/load/new'
      end
    end

    r.on 'offload' do
      interactor = PackMaterialApp::VehicleJobInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
      r.on 'new' do
        details = retrieve_from_local_store(:vehicle_unit_offload) || {}
        form = Crossbeams::RMDForm.new(details,
                                       form_name: :offload_unit,
                                       progress: details[:vehicle_job_id] ? details[:progress] : nil,
                                       notes: 'Please scan the Tripsheet number and the SKU number, then scan the Location and enter the quantity to be offloaded.',
                                       scan_with_camera: @rmd_scan_with_camera,
                                       caption: 'Vehicle Unit Offload',
                                       action: '/rmd/vehicles/offload',
                                       button_caption: 'Offload Unit')
        form.add_field(:tripsheet_number, 'Tripsheet', scan: 'key248_all', scan_type: :tripsheet)
        form.add_field(:sku_number, 'SKU', scan: 'key248_all', scan_type: :sku, lookup: true, data_type: 'number')
        form.add_field(:location, 'To Location', scan: 'key248_all', scan_type: :location, lookup: true, force_uppercase: true)
        form.add_field(:quantity, 'Quantity to Offload', data_type: 'number', allow_decimals: true)
        form.add_csrf_tag csrf_tag
        view(inline: form.render, layout: :layout_rmd)
      end

      r.post do
        res = interactor.offload_vehicle_unit(params[:offload_unit])
        payload = { progress: nil }
        if res.success
          payload[:vehicle_job_id] = res.instance[:vehicle_job_id]
          payload[:tripsheet_number] = params[:offload_unit][:tripsheet_number]
          payload[:tripsheet_number_scan_field] = params[:offload_unit][:tripsheet_number_scan_field]
          payload[:progress] = res.instance[:report]
        else
          these_params = params[:offload_unit]
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

        store_locally(:vehicle_unit_offload, payload)
        r.redirect '/rmd/vehicles/offload/new'
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
#- rubocop:enable Metrics/ClassLength
