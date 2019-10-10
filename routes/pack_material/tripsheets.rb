# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/ClassLength

class Framework < Roda
  route 'tripsheets', 'pack_material' do |r|
    # VEHICLE TYPES
    # --------------------------------------------------------------------------
    r.on 'vehicle_types', Integer do |id|
      interactor = PackMaterialApp::VehicleTypeInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:vehicle_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('tripsheets', 'edit')
        interactor.assert_permission!(:edit, id)
        show_partial { PackMaterial::Tripsheets::VehicleType::Edit.call(id) }
      end

      r.is do
        r.get do       # SHOW
          check_auth!('tripsheets', 'read')
          show_partial { PackMaterial::Tripsheets::VehicleType::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_vehicle_type(id, params[:vehicle_type])
          if res.success
            update_grid_row(id, changes: { type_code: res.instance[:type_code] },
                                notice: res.message)
          else
            re_show_form(r, res) { PackMaterial::Tripsheets::VehicleType::Edit.call(id, form_values: params[:vehicle_type], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('tripsheets', 'delete')
          interactor.assert_permission!(:delete, id)
          res = interactor.delete_vehicle_type(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end
    r.on 'vehicle_types' do
      interactor = PackMaterialApp::VehicleTypeInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('tripsheets', 'new')
        set_last_grid_url('/list/vehicle_types', r)
        show_partial_or_page(r) { PackMaterial::Tripsheets::VehicleType::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_vehicle_type(params[:vehicle_type])
        if res.success
          if fetch?(r)
            row_keys = %i[
              id
              type_code
            ]
            add_grid_row(attrs: select_attributes(res.instance, row_keys),
                         notice: res.message)
          else
            flash[:notice] = res.message
            redirect_to_last_grid(r)
          end
        else
          re_show_form(r, res, url: '/pack_material/tripsheets/vehicle_types/new') do
            PackMaterial::Tripsheets::VehicleType::New.call(form_values: params[:vehicle_type],
                                                            form_errors: res.errors,
                                                            remote: fetch?(r))
          end
        end
      end
    end

    # VEHICLES
    # --------------------------------------------------------------------------
    r.on 'vehicles', Integer do |id|
      interactor = PackMaterialApp::VehicleInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:vehicles, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('tripsheets', 'edit')
        show_partial { PackMaterial::Tripsheets::Vehicle::Edit.call(id) }
      end

      r.is do
        r.get do       # SHOW
          check_auth!('tripsheets', 'read')
          show_partial { PackMaterial::Tripsheets::Vehicle::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_vehicle(id, params[:vehicle])
          if res.success
            update_grid_row(id,
                            changes: {
                              vehicle_type_id: res.instance[:vehicle_type_id],
                              type_code: res.instance[:type_code],
                              vehicle_code: res.instance[:vehicle_code]
                            },
                            notice: res.message)
          else
            re_show_form(r, res) { PackMaterial::Tripsheets::Vehicle::Edit.call(id, form_values: params[:vehicle], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('tripsheets', 'delete')
          res = interactor.delete_vehicle(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end
    r.on 'vehicles' do
      interactor = PackMaterialApp::VehicleInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('tripsheets', 'new')
        show_partial_or_page(r) { PackMaterial::Tripsheets::Vehicle::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_vehicle(params[:vehicle])
        if res.success
          row_keys = %i[
            id
            vehicle_type_id
            type_code
            vehicle_code
          ]
          add_grid_row(attrs: select_attributes(res.instance, row_keys),
                       notice: res.message)
        else
          re_show_form(r, res, url: '/pack_material/tripsheets/vehicles/new') do
            PackMaterial::Tripsheets::Vehicle::New.call(form_values: params[:vehicle],
                                                        form_errors: res.errors,
                                                        remote: fetch?(r))
          end
        end
      end
    end

    # VEHICLE JOBS
    # --------------------------------------------------------------------------
    r.on 'vehicle_jobs', Integer do |id|
      interactor = PackMaterialApp::VehicleJobInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:vehicle_jobs, id) do
        handle_not_found(r)
      end

      r.on 'mark_as_loaded' do
        check_auth!('transactions', 'edit')
        store_last_referer_url(:vehicle_job_load)
        res = interactor.load_vehicle_job(id)
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_stored_referer(r, :vehicle_job_load)
      end
      r.on 'confirm_arrival' do
        check_auth!('transactions', 'edit')
        store_last_referer_url(:vehicle_job_confirm_arrival)
        res = interactor.vehicle_job_confirm_arrival(id)
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_stored_referer(r, :vehicle_job_confirm_arrival)
      end
      r.on 'edit' do   # EDIT
        check_auth!('tripsheets', 'edit')
        interactor.assert_permission!(:edit, id)
        show_page { PackMaterial::Tripsheets::VehicleJob::Edit.call(id, interactor) }
      end
      r.patch do     # UPDATE
        res = if params[:vehicle_job][:vehicle_id]
                interactor.update_vehicle_job(id, params[:vehicle_job])
              else
                interactor.update_planned_location(id, params[:vehicle_job])
              end
        if res.success
          flash[:notice] = res.message
          r.redirect("/pack_material/tripsheets/vehicle_jobs/#{id}/edit")
        else
          re_show_form(r, res, url: "/pack_material/tripsheets/vehicle_jobs/#{id}/edit") do
            PackMaterial::Tripsheets::VehicleJob::Edit.call(id, interactor, form_values: params[:vehicle_job], form_errors: res.errors)
          end
        end
      end
      r.on 'vehicle_job_units' do
        interactor = PackMaterialApp::VehicleJobUnitInteractor.new(current_user, {}, { route_url: request.path }, {})
        r.on 'new' do    # NEW
          check_auth!('tripsheets', 'new')
          show_partial_or_page(r) { PackMaterial::Tripsheets::VehicleJobUnit::New.call(id, remote: fetch?(r)) }
        end
        r.post do        # CREATE
          res = interactor.create_vehicle_job_unit(id, params[:vehicle_job_unit])
          if res.success
            row_keys = %i[
              id
              vehicle_job_id
              quantity_to_move
              when_loaded
              when_offloaded
              when_offloading
              quantity_loaded
              quantity_offloaded
              when_loading
              mr_sku_id
              sku_number
              location_id
              status
              from_location_short_code
            ]
            add_grid_row(attrs: select_attributes(res.instance, row_keys),
                         notice: res.message)
          else
            form_errors = move_validation_errors_to_base(res.errors, :valid_quantity)
            re_show_form(r, res, url: "/pack_material/tripsheets/vehicle_jobs/#{id}/vehicle_job_units/new") do
              PackMaterial::Tripsheets::VehicleJobUnit::New.call(id,
                                                                 form_values: params[:vehicle_job_unit],
                                                                 form_errors: form_errors,
                                                                 remote: fetch?(r))
            end
          end
        end
      end

      r.is do
        r.get do       # SHOW
          check_auth!('tripsheets', 'read')
          show_partial { PackMaterial::Tripsheets::VehicleJob::Show.call(id) }
        end
        r.delete do    # DELETE
          check_auth!('tripsheets', 'delete')
          interactor.assert_permission!(:delete, id)
          res = interactor.delete_vehicle_job(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end
    r.on 'vehicle_jobs' do
      interactor = PackMaterialApp::VehicleJobInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'sku_location_lookup_result', Integer do |sku_location_id|
        result_hash = interactor.get_sku_location_info_ids(sku_location_id)
        json_actions([OpenStruct.new(type: :change_select_value,
                                     dom_id: 'vehicle_job_unit_mr_sku_id',
                                     value: result_hash[:sku_id]),
                      OpenStruct.new(type: :change_select_value,
                                     dom_id: 'vehicle_job_unit_sku_number',
                                     value: result_hash[:sku_number]),
                      OpenStruct.new(type: :replace_input_value,
                                     dom_id: 'vehicle_job_unit_available_quantity',
                                     value: result_hash[:available_quantity]),
                      OpenStruct.new(type: :replace_input_value,
                                     dom_id: 'vehicle_job_unit_show_available_quantity',
                                     value: UtilityFunctions.delimited_number(result_hash[:available_quantity])),
                      OpenStruct.new(type: :change_select_value,
                                     dom_id: 'vehicle_job_unit_location_code',
                                     value: result_hash[:location_code]),
                      OpenStruct.new(type: :change_select_value,
                                     dom_id: 'vehicle_job_unit_location_id',
                                     value: result_hash[:location_id])],
                     'Selected a SKU Location')
      end
      r.on 'link_mr_skus', Integer do |id|
        r.post do
          res = interactor.link_mr_skus(id, multiselect_grid_choices(params))
          if res.success
            update_grid_row(id,
                            changes: { has_skus: res.instance[:has_skus] },
                            notice: res.message)
          else
            show_json_error(res.message)
          end
        end
      end
      r.on 'link_locations', Integer do |id|
        r.post do
          res = interactor.link_locations(id, multiselect_grid_choices(params))
          if res.success
            update_grid_row(id,
                            changes: { has_locations: res.instance[:has_locations] },
                            notice: res.message)
          else
            show_json_error(res.message)
          end
        end
      end
      r.on 'new' do    # NEW
        check_auth!('tripsheets', 'new')
        show_partial_or_page(r) { PackMaterial::Tripsheets::VehicleJob::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_vehicle_job(params[:vehicle_job])
        if res.success
          row_keys = %i[
            id
            business_process_id
            vehicle_id
            departure_location_id
            tripsheet_number
            planned_location_id
            virtual_location_id
            when_loaded
            when_offloaded
            loaded
            offloaded
            load_transaction_id
            offload_transaction_id
            status
            process
            vehicle_code
            departure_location_long_code
            virtual_location_long_code
            planned_location_long_code
          ]
          add_grid_row(attrs: select_attributes(res.instance, row_keys),
                       notice: res.message)
        else
          re_show_form(r, res, url: '/pack_material/tripsheets/vehicle_jobs/new') do
            PackMaterial::Tripsheets::VehicleJob::New.call(form_values: params[:vehicle_job],
                                                           form_errors: res.errors,
                                                           remote: fetch?(r))
          end
        end
      end
    end

    # VEHICLE JOB UNITS
    # --------------------------------------------------------------------------
    r.on 'vehicle_job_units', Integer do |id|
      interactor = PackMaterialApp::VehicleJobUnitInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:vehicle_job_units, id) do
        handle_not_found(r)
      end

      r.on 'inline_save' do
        check_auth!('tripsheets', 'edit')
        res = interactor.inline_update(id, params)
        if res.success
          show_json_notice(res.message)
          button_permissions = interactor.check_button_permissions(id)
          json_actions([OpenStruct.new(type: button_permissions[:can_mark_as_loaded] ? :show_element : :hide_element,
                                       dom_id: 'vehicle_job_mark_as_loaded'),
                        OpenStruct.new(type: button_permissions[:can_confirm_arrival] ? :show_element : :hide_element,
                                       dom_id: 'vehicle_job_confirm_arrival')],
                       res.message)
        else
          show_json_error(res.message, status: 200)
        end
      end
      r.is do
        r.get do       # SHOW
          check_auth!('tripsheets', 'read')
          show_partial { PackMaterial::Tripsheets::VehicleJobUnit::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_vehicle_job_unit(id, params[:vehicle_job_unit])
          if res.success
            row_keys = %i[
              vehicle_job_id
              quantity_to_move
              when_loaded
              when_offloaded
              when_offloading
              quantity_loaded
              quantity_offloaded
              when_loading
              mr_sku_id
              sku_number
              location_id
              status
              from_location_short_code
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res) { PackMaterial::Tripsheets::VehicleJobUnit::Edit.call(id, form_values: params[:vehicle_job_unit], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('tripsheets', 'delete')
          interactor.assert_permission!(:delete, id)
          res = interactor.delete_vehicle_job_unit(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
# rubocop:enable Metrics/ClassLength
