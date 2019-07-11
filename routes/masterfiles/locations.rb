# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'locations', 'masterfiles' do |r|
    # LOCATION TYPES
    # --------------------------------------------------------------------------
    r.on 'location_types', Integer do |id|
      interactor = MasterfilesApp::LocationInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:location_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('locations', 'edit')
        show_partial { Masterfiles::Locations::LocationType::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('locations', 'read')
          show_partial { Masterfiles::Locations::LocationType::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_location_type(id, params[:location_type])
          if res.success
            row_keys = %i[
              location_type_code
              short_code
              can_be_moved
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res) { Masterfiles::Locations::LocationType::Edit.call(id, form_values: params[:location_type], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('locations', 'delete')
          res = interactor.delete_location_type(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end
    r.on 'location_types' do
      interactor = MasterfilesApp::LocationInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('locations', 'new')
        show_partial_or_page(r) { Masterfiles::Locations::LocationType::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_location_type(params[:location_type])
        if res.success
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        else
          re_show_form(r, res, url: '/masterfiles/locations/location_types/new') do
            Masterfiles::Locations::LocationType::New.call(form_values: params[:location_type],
                                                           form_errors: res.errors,
                                                           remote: fetch?(r))
          end
        end
      end
    end
    # LOCATIONS
    # --------------------------------------------------------------------------
    r.on 'locations', Integer do |id|
      interactor = MasterfilesApp::LocationInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:locations, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('locations', 'edit')
        show_partial { Masterfiles::Locations::Location::Edit.call(id) }
      end

      r.on 'print_barcode' do # BARCODE
        r.get do
          show_partial { Masterfiles::Locations::Location::PrintBarcode.call(id) }
        end
        r.patch do
          res = interactor.print_location_barcode(id, params[:location])
          if res.success
            show_json_notice(res.message)
          else
            re_show_form(r, res) { Masterfiles::Locations::Location::PrintBarcode.call(id, form_values: params[:location], form_errors: res.errors) }
          end
        end
      end

      r.on 'primary_storage_type_changed' do
        res = interactor.location_short_code_suggestion(params[:changed_value])
        json_replace_input_value('location_location_short_code', res.success ? res.instance : nil)
      end

      r.on 'add_child' do   # NEW CHILD
        r.on 'location_type_changed' do
          res = interactor.location_long_code_suggestion(id, params[:changed_value])
          json_replace_input_value('location_location_long_code', res.instance)
        end
        r.get do
          check_auth!('locations', 'edit')
          show_partial { Masterfiles::Locations::Location::New.call(id: id) }
        end
        r.post do
          res = interactor.create_location(id, params[:location])
          if res.success
            flash[:notice] = res.message
            redirect_to_last_grid(r)
          else
            form_errors = move_validation_errors_to_base(res.errors,
                                                         %i[location_long_code receiving_bay_type_location],
                                                         highlights: { location_long_code: %i[location_long_code location_short_code],
                                                                       receiving_bay_type_location: %i[location_type_id can_store_stock] })
            re_show_form(r, res, url: "/masterfiles/locations/locations/#{id}/add_child") do
              Masterfiles::Locations::Location::New.call(id: id,
                                                         form_values: params[:location],
                                                         form_errors: form_errors,
                                                         remote: fetch?(r))
            end
          end
        end
      end
      r.on 'link_assignments' do
        r.post do
          res = interactor.link_assignments(id, multiselect_grid_choices(params))
          if res.success
            flash[:notice] = res.message
            redirect_to_last_grid(r)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
      r.on 'link_storage_types' do
        r.post do
          res = interactor.link_storage_types(id, multiselect_grid_choices(params))
          if res.success
            flash[:notice] = res.message
            redirect_to_last_grid(r)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
      r.is do
        r.get do       # SHOW
          check_auth!('locations', 'read')
          show_partial { Masterfiles::Locations::Location::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_location(id, params[:location])
          if res.success
            row_keys = %i[
              storage_type_code
              location_type_code
              assignment_code
              location_long_code
              location_description
              location_short_code
              has_single_container
              virtual_location
              can_be_moved
              can_store_stock
              consumption_area
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            form_errors = move_validation_errors_to_base(res.errors, :receiving_bay_type_location, highlights: { receiving_bay_type_location: %i[location_type_id can_store_stock] })
            re_show_form(r, res) { Masterfiles::Locations::Location::Edit.call(id, form_values: params[:location], form_errors: form_errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('locations', 'delete')
          # Only delete a leaf - return an error if there are children.
          res = interactor.delete_location(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end
    r.on 'locations' do
      interactor = MasterfilesApp::LocationInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('locations', 'new')
        show_partial_or_page(r) { Masterfiles::Locations::Location::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_root_location(params[:location])
        if res.success
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        else
          form_errors = move_validation_errors_to_base(res.errors,
                                                       %i[location_long_code receiving_bay_type_location],
                                                       highlights: { location_long_code: %i[location_long_code location_short_code],
                                                                     receiving_bay_type_location: %i[location_type_id can_store_stock] })
          re_show_form(r, res, url: '/masterfiles/locations/locations/new') do
            Masterfiles::Locations::Location::New.call(form_values: params[:location],
                                                       form_errors: form_errors,
                                                       remote: fetch?(r))
          end
        end
      end
    end
    # LOCATION ASSIGNMENTS
    # --------------------------------------------------------------------------
    r.on 'location_assignments', Integer do |id|
      interactor = MasterfilesApp::LocationInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:location_assignments, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('locations', 'edit')
        show_partial { Masterfiles::Locations::LocationAssignment::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('locations', 'read')
          show_partial { Masterfiles::Locations::LocationAssignment::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_location_assignment(id, params[:location_assignment])
          if res.success
            update_grid_row(id,
                            changes: { assignment_code: res.instance[:assignment_code] },
                            notice: res.message)
          else
            re_show_form(r, res) { Masterfiles::Locations::LocationAssignment::Edit.call(id, form_values: params[:location_assignment], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('locations', 'delete')
          res = interactor.delete_location_assignment(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end
    r.on 'location_assignments' do
      interactor = MasterfilesApp::LocationInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('locations', 'new')
        show_partial_or_page(r) { Masterfiles::Locations::LocationAssignment::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_location_assignment(params[:location_assignment])
        if res.success
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        else
          re_show_form(r, res, url: '/masterfiles/locations/location_assignments/new') do
            Masterfiles::Locations::LocationAssignment::New.call(form_values: params[:location_assignment],
                                                                 form_errors: res.errors, remote: fetch?(r))
          end
        end
      end
    end
    # LOCATION STORAGE TYPES
    # --------------------------------------------------------------------------
    r.on 'location_storage_types', Integer do |id|
      interactor = MasterfilesApp::LocationInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:location_storage_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('locations', 'edit')
        show_partial { Masterfiles::Locations::LocationStorageType::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('locations', 'read')
          show_partial { Masterfiles::Locations::LocationStorageType::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_location_storage_type(id, params[:location_storage_type])
          if res.success
            update_grid_row(id,
                            changes: { storage_type_code: res.instance[:storage_type_code],
                                       location_short_code_prefix: res.instance[:location_short_code_prefix] },
                            notice: res.message)
          else
            re_show_form(r, res) { Masterfiles::Locations::LocationStorageType::Edit.call(id, form_values: params[:location_storage_type], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('locations', 'delete')
          res = interactor.delete_location_storage_type(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end
    r.on 'location_storage_types' do
      interactor = MasterfilesApp::LocationInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('locations', 'new')
        show_partial_or_page(r) { Masterfiles::Locations::LocationStorageType::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_location_storage_type(params[:location_storage_type])
        if res.success
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        else
          re_show_form(r, res, url: '/masterfiles/locations/location_storage_types/new') do
            Masterfiles::Locations::LocationStorageType::New.call(form_values: params[:location_storage_type],
                                                                  form_errors: res.errors,
                                                                  remote: fetch?(r))
          end
        end
      end
    end

    # LOCATION STORAGE DEFINITIONS
    # --------------------------------------------------------------------------
    r.on 'location_storage_definitions', Integer do |id|
      interactor = MasterfilesApp::LocationStorageDefinitionInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:location_storage_definitions, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('locations', 'edit')
        show_partial { Masterfiles::Locations::LocationStorageDefinition::Edit.call(id) }
      end

      r.is do
        r.get do       # SHOW
          check_auth!('locations', 'read')
          show_partial { Masterfiles::Locations::LocationStorageDefinition::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_location_storage_definition(id, params[:location_storage_definition])
          if res.success
            update_grid_row(id,
                            changes: {
                              storage_definition_code: res.instance[:storage_definition_code],
                              storage_definition_format: res.instance[:storage_definition_format],
                              storage_definition_description: res.instance[:storage_definition_description],
                              active: res.instance[:active]
                            },
                            notice: res.message)
          else
            re_show_form(r, res) { Masterfiles::Locations::LocationStorageDefinition::Edit.call(id, form_values: params[:location_storage_definition], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('locations', 'delete')
          res = interactor.delete_location_storage_definition(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    r.on 'location_storage_definitions' do
      interactor = MasterfilesApp::LocationStorageDefinitionInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('locations', 'new')
        show_partial_or_page(r) { Masterfiles::Locations::LocationStorageDefinition::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_location_storage_definition(params[:location_storage_definition])
        if res.success
          row_keys = %i[
            id
            storage_definition_code
            storage_definition_format
            storage_definition_description
            active
          ]
          add_grid_row(attrs: select_attributes(res.instance, row_keys),
                       notice: res.message)
        else
          re_show_form(r, res, url: '/masterfiles/locations/location_storage_definitions/new') do
            Masterfiles::Locations::LocationStorageDefinition::New.call(form_values: params[:location_storage_definition],
                                                                        form_errors: res.errors,
                                                                        remote: fetch?(r))
          end
        end
      end
    end
  end
end

# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/BlockLength
