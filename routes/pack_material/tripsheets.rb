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

      r.on 'edit' do   # EDIT
        check_auth!('tripsheets', 'edit')
        interactor.assert_permission!(:edit, id)
        # show_partial { PackMaterial::Tripsheets::VehicleJob::Edit.call(id) }
        show_page { PackMaterial::Tripsheets::VehicleJob::Edit.call(id, interactor) }
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
          mr_sku_location_from_id
          mr_inventory_transaction_item_id
          vehicle_job_id
          quantity_to_move
          when_loaded
          when_offloaded
          when_offloading
          quantity_moved
          when_loading
        ]
            add_grid_row(attrs: select_attributes(res.instance, row_keys),
                         notice: res.message)
          else
            re_show_form(r, res, url: "/pack_material/tripsheets/vehicle_jobs/#{id}/vehicle_job_units/new") do
              PackMaterial::Tripsheets::VehicleJobUnit::New.call(id,
                                                                 form_values: params[:vehicle_job_unit],
                                                                 form_errors: res.errors,
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
        r.patch do     # UPDATE
          res = interactor.update_vehicle_job(id, params[:vehicle_job])
          if res.success
            row_keys = %i[
              business_process_id
              vehicle_id
              departure_location_id
              tripsheet_number
              planned_location_id
              when_loaded
              when_offloaded
              loaded
              offloaded
              load_transaction_id
              putaway_transaction_id
              offload_transaction_id
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res) { PackMaterial::Tripsheets::VehicleJob::Edit.call(id, form_values: params[:vehicle_job], form_errors: res.errors) }
          end
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
            when_loaded
            when_offloaded
            loaded
            offloaded
            load_transaction_id
            putaway_transaction_id
            offload_transaction_id
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

      r.on 'edit' do   # EDIT
        check_auth!('tripsheets', 'edit')
        interactor.assert_permission!(:edit, id)
        show_partial { PackMaterial::Tripsheets::VehicleJobUnit::Edit.call(id) }
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
              mr_sku_location_from_id
              mr_inventory_transaction_item_id
              vehicle_job_id
              quantity_to_move
              when_loaded
              when_offloaded
              when_offloading
              quantity_moved
              when_loading
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
