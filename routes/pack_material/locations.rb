# frozen_string_literal: true

# rubocop#disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'locations', 'pack_material' do |r|
    # LOCATIONS
    # --------------------------------------------------------------------------
    r.on 'locations', Integer do |id|
      interactor = PackMaterialApp::LocationInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:locations, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('locations', 'edit')
        show_partial { PackMaterial::Locations::Location::Edit.call(id) }
      end
      r.on 'add_child' do   # NEW CHILD
        r.get do
          check_auth!('locations', 'edit')
          show_partial { PackMaterial::Locations::Location::New.call(id: id) }
        end
        r.post do
          # return_json_response
          # update_dialog_content(content: "Got here with #{id} ::: #{params.inspect}", error: 'TESTING')
          res = interactor.create_location(id, params[:location])
          if res.success
            flash[:notice] = res.message
            redirect_to_last_grid(r)
          else
            re_show_form(r, res, url: "/pack_material/locations/locations/#{id}/add_child") do
              PackMaterial::Locations::Location::New.call(id: id,
                                                          form_values: params[:location],
                                                          form_errors: res.errors,
                                                          remote: fetch?(r))
            end
          end
        end
      end
      r.on 'link_assignments' do
        r.post do
          return_json_response
          res = interactor.link_assignments(id, multiselect_grid_choices(params))
          if res.success
            flash[:notice] = res.message
            redirect_via_json_to_last_grid
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
      r.on 'link_storage_types' do
        r.post do
          return_json_response
          res = interactor.link_storage_types(id, multiselect_grid_choices(params))
          if res.success
            flash[:notice] = res.message
            redirect_via_json_to_last_grid
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
      r.is do
        r.get do       # SHOW
          check_auth!('locations', 'read')
          show_partial { PackMaterial::Locations::Location::Show.call(id) }
        end
        r.patch do     # UPDATE
          return_json_response
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
            content = show_partial { PackMaterial::Locations::Location::Edit.call(id, form_values: params[:location], form_errors: res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          return_json_response
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
      interactor = PackMaterialApp::LocationInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('locations', 'new')
        show_partial_or_page(r) { PackMaterial::Locations::Location::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_root_location(params[:location])
        if res.success
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        else
          re_show_form(r, res, url: '/pack_material/locations/locations/new') do
            PackMaterial::Locations::Location::New.call(form_values: params[:location],
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
