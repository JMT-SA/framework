# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'rmd', 'security' do |r|
    # REGISTERED MOBILE DEVICES
    # --------------------------------------------------------------------------
    r.on 'registered_mobile_devices', Integer do |id|
      interactor = SecurityApp::RegisteredMobileDeviceInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:registered_mobile_devices, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('rmd', 'edit')
        show_partial { Security::Rmd::RegisteredMobileDevice::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('rmd', 'read')
          show_partial { Security::Rmd::RegisteredMobileDevice::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_registered_mobile_device(id, params[:registered_mobile_device])
          if res.success
            update_grid_row(id, changes: { ip_address: res.instance[:ip_address],
                                           start_page_program_function_program_function_name: res.instance[:program_function_name],
                                           active: res.instance[:active] },
                                notice: res.message)
          else
            re_show_form(r, res) { Security::Rmd::RegisteredMobileDevice::Edit.call(id, form_values: params[:registered_mobile_device], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('rmd', 'delete')
          res = interactor.delete_registered_mobile_device(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    r.on 'registered_mobile_devices' do
      interactor = SecurityApp::RegisteredMobileDeviceInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        check_auth!('rmd', 'new')
        show_partial_or_page(r) { Security::Rmd::RegisteredMobileDevice::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_registered_mobile_device(params[:registered_mobile_device])
        if res.success
          row_keys = %i[
            id
            ip_address
            active
          ]
          add_grid_row(attrs: select_attributes(res.instance, row_keys, start_page_program_function_program_function_name: res.instance[:program_function_name]),
                       notice: res.message)
        else
          re_show_form(r, res, url: '/security/rmd/registered_mobile_devices/new') do
            Security::Rmd::RegisteredMobileDevice::New.call(form_values: params[:registered_mobile_device],
                                                            form_errors: res.errors,
                                                            remote: fetch?(r))
          end
        end
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength
