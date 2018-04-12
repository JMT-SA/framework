# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'parties', 'masterfiles' do |r|
    r.on 'organizations', Integer do |id|
      interactor = MasterfilesApp::OrganizationInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:organizations, id) do
        handle_not_found(r)
      end

      r.on 'edit' do
        if authorised?('parties', 'edit')
          show_partial { Masterfiles::Parties::Organization::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.on 'addresses' do
        r.post do
          response['Content-Type'] = 'application/json'
          res = interactor.assign_addresses(id, params[:organization])
          if res.success
            update_grid_row(id,
                            changes: { addresses: res.instance.address_list },
                            notice: res.message)
          else
            content = show_partial { Masterfiles::Parties::Organization::Addresses.call(id, params[:organization], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end

        show_partial { Masterfiles::Parties::Organization::Addresses.call(id) }
      end
      r.on 'contact_methods' do
        r.post do
          response['Content-Type'] = 'application/json'
          res = interactor.assign_contact_methods(id, params[:organization])
          if res.success
            update_grid_row(id,
                            changes: { contact_methods: res.instance.contact_method_list },
                            notice: res.message)
          else
            content = show_partial { Masterfiles::Parties::Organization::ContactMethods.call(id, params[:organization], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end

        show_partial { Masterfiles::Parties::Organization::ContactMethods.call(id) }
      end
      r.is do
        r.get do
          if authorised?('parties', 'read')
            show_partial { Masterfiles::Parties::Organization::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_organization(id, params[:organization])
          if res.success
            update_grid_row(id, changes: { party_id: res.instance[:party_id],
                                           parent: res.instance[:parent_organization],
                                           short_description: res.instance[:short_description],
                                           medium_description: res.instance[:medium_description],
                                           long_description: res.instance[:long_description],
                                           vat_number: res.instance[:vat_number],
                                           variants: res.instance[:variants],
                                           active: res.instance[:active] },
                                notice: res.message)
          else
            content = show_partial { Masterfiles::Parties::Organization::Edit.call(id, params[:organization], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_organization(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'organizations' do
      interactor = MasterfilesApp::OrganizationInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do
        if authorised?('parties', 'new')
          page = stashed_page
          if page
            show_page { page }
          else
            show_partial_or_page(fetch?(r)) { Masterfiles::Parties::Organization::New.call(remote: fetch?(r)) }
          end
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_organization(params[:organization])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Masterfiles::Parties::Organization::New.call(form_values: params[:organization],
                                                         form_errors: res.errors,
                                                         remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          stash_page(Masterfiles::Parties::Organization::New.call(form_values: params[:organization],
                                                                  form_errors: res.errors,
                                                                  remote: false))
          r.redirect '/masterfiles/parties/organizations/new'
        end
      end
    end

    r.on 'people', Integer do |id|
      interactor = MasterfilesApp::PersonInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:people, id) do
        handle_not_found(r)
      end

      r.on 'edit' do
        if authorised?('parties', 'edit')
          show_partial { Masterfiles::Parties::Person::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.on 'addresses' do
        r.post do
          response['Content-Type'] = 'application/json'
          res = interactor.assign_addresses(id, params[:person])
          if res.success
            update_grid_row(id,
                            changes: { addresses: res.instance.address_list },
                            notice: res.message)
          else
            content = show_partial { Masterfiles::Parties::Person::Addresses.call(id, params[:person], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        show_partial { Masterfiles::Parties::Person::Addresses.call(id) }
      end
      r.on 'contact_methods' do
        r.post do
          response['Content-Type'] = 'application/json'
          res = interactor.assign_contact_methods(id, params[:person])
          if res.success
            update_grid_row(id,
                            changes: { contact_methods: res.instance.contact_method_list },
                            notice: res.message)
          else
            content = show_partial { Masterfiles::Parties::Person::ContactMethods.call(id, params[:person], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        show_partial { Masterfiles::Parties::Person::ContactMethods.call(id) }
      end
      r.is do
        r.get do
          if authorised?('parties', 'read')
            show_partial { Masterfiles::Parties::Person::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do
          response['Content-Type'] = 'application/json'
          res = interactor.update_person(id, params[:person])
          if res.success
            update_grid_row(id,
                            changes: { title: res.instance[:title],
                                       first_name: res.instance[:first_name],
                                       surname: res.instance[:surname],
                                       vat_number: res.instance[:vat_number] },
                            notice: res.message)
          else
            content = show_partial { Masterfiles::Parties::Person::Edit.call(id, params[:person], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do
          response['Content-Type'] = 'application/json'
          res = interactor.delete_person(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'people' do
      interactor = MasterfilesApp::PersonInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do
        if authorised?('parties', 'new')
          page = stashed_page
          if page
            show_page { page }
          else
            show_partial_or_page(fetch?(r)) { Masterfiles::Parties::Person::New.call(remote: fetch?(r)) }
          end
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do
        res = interactor.create_person(params[:person])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Masterfiles::Parties::Person::New.call(form_values: params[:person],
                                                   form_errors: res.errors,
                                                   remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          stash_page(Masterfiles::Parties::Person::New.call(form_values: params[:person],
                                                            form_errors: res.errors,
                                                            remote: false))
          r.redirect '/masterfiles/parties/people/new'
        end
      end
    end

    r.on 'addresses', Integer do |id|
      interactor = MasterfilesApp::AddressInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:addresses, id) do
        handle_not_found(r)
      end

      r.on 'edit' do
        if authorised?('parties', 'edit')
          show_partial { Masterfiles::Parties::Address::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do
          if authorised?('parties', 'read')
            show_partial { Masterfiles::Parties::Address::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do
          response['Content-Type'] = 'application/json'
          res = interactor.update_address(id, params[:address])
          if res.success
            update_grid_row(id,
                            changes: { address_type_id: res.instance[:address_type_id],
                                       address_line_1: res.instance[:address_line_1],
                                       address_line_2: res.instance[:address_line_2],
                                       address_line_3: res.instance[:address_line_3],
                                       city: res.instance[:city],
                                       postal_code: res.instance[:postal_code],
                                       country: res.instance[:country],
                                       active: res.instance[:active] },
                            notice: res.message)
          else
            content = show_partial { Masterfiles::Parties::Address::Edit.call(id, params[:address], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do
          response['Content-Type'] = 'application/json'
          res = interactor.delete_address(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'addresses' do
      interactor = MasterfilesApp::AddressInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do
        if authorised?('parties', 'new')
          show_partial_or_page(fetch?(r)) { Masterfiles::Parties::Address::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do
        res = interactor.create_address(params[:address])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Masterfiles::Parties::Address::New.call(form_values: params[:address],
                                                    form_errors: res.errors,
                                                    remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Masterfiles::Parties::Address::New.call(form_values: params[:address],
                                                    form_errors: res.errors,
                                                    remote: false)
          end
        end
      end
    end

    r.on 'contact_methods', Integer do |id|
      interactor = MasterfilesApp::ContactMethodInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:contact_methods, id) do
        handle_not_found(r)
      end

      r.on 'edit' do
        if authorised?('parties', 'edit')
          show_partial { Masterfiles::Parties::ContactMethod::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do
          if authorised?('parties', 'read')
            show_partial { Masterfiles::Parties::ContactMethod::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do
          response['Content-Type'] = 'application/json'
          res = interactor.update_contact_method(id, params[:contact_method])
          if res.success
            update_grid_row(id,
                            changes: { contact_method_type_id: res.instance[:contact_method_type_id],
                                       contact_method_code: res.instance[:contact_method_code],
                                       active: res.instance[:active] },
                            notice: res.message)
          else
            content = show_partial { Masterfiles::Parties::ContactMethod::Edit.call(id, params[:contact_method], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do
          response['Content-Type'] = 'application/json'
          res = interactor.delete_contact_method(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'contact_methods' do
      interactor = MasterfilesApp::ContactMethodInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do
        if authorised?('parties', 'new')
          show_partial_or_page(fetch?(r)) { Masterfiles::Parties::ContactMethod::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do
        res = interactor.create_contact_method(params[:contact_method])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Masterfiles::Parties::ContactMethod::New.call(form_values: params[:contact_method],
                                                          form_errors: res.errors,
                                                          remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Masterfiles::Parties::ContactMethod::New.call(form_values: params[:contact_method],
                                                          form_errors: res.errors,
                                                          remote: false)
          end
        end
      end
    end

    r.on 'link_addresses', Integer do |id|
      r.post do
        interactor = MasterfilesApp::PartyInteractor.new(current_user, {}, { route_url: request.path }, {})

        res = interactor.link_addresses(id, multiselect_grid_choices(params))
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_last_grid(r)
      end
    end
    r.on 'link_contact_methods', Integer do |id|
      r.post do
        interactor = MasterfilesApp::PartyInteractor.new(current_user, {}, { route_url: request.path }, {})

        res = interactor.link_contact_methods(id, multiselect_grid_choices(params))
        if res.success
          flash[:notice] = res.message
        else
          flash[:error] = res.message
        end
        redirect_to_last_grid(r)
      end
    end
  end
end
