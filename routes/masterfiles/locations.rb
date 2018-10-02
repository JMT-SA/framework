# frozen_string_literal: true

# rubocop#disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'locations', 'masterfiles' do |r|
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
      r.on 'add_child' do   # NEW CHILD
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
            re_show_form(r, res, url: "/masterfiles/locations/locations/#{id}/add_child") do
              Masterfiles::Locations::Location::New.call(id: id,
                                                         form_values: params[:location],
                                                         form_errors: res.errors,
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
              location_code
              location_description
              has_single_container
              virtual_location
              consumption_area
            ]
            update_grid_row(id, changes: select_attributes(res.instance, row_keys), notice: res.message)
          else
            re_show_form(r, res) { Masterfiles::Locations::Location::Edit.call(id, form_values: params[:location], form_errors: res.errors) }
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
          re_show_form(r, res, url: '/masterfiles/locations/locations/new') do
            Masterfiles::Locations::Location::New.call(form_values: params[:location],
                                                       form_errors: res.errors,
                                                       remote: fetch?(r))
          end
        end
      end
    end
  end
end

# rubocop#enable Metrics/ClassLength
# rubocop:enable Metrics/BlockLength
