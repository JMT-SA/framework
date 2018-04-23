# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'masterfiles', 'development' do |r|
    # ROLES
    # --------------------------------------------------------------------------
    r.on 'roles', Integer do |id|
      interactor = DevelopmentApp::RoleInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:roles, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        raise Crossbeams::AuthorizationError unless authorised?('masterfiles', 'edit')
        show_partial { Development::Masterfiles::Role::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          raise Crossbeams::AuthorizationError unless authorised?('masterfiles', 'read')
          show_partial { Development::Masterfiles::Role::Show.call(id) }
        end
        r.patch do     # UPDATE
          return_json_response
          res = interactor.update_role(id, params[:role])
          if res.success
            update_grid_row(id,
                            changes: { name: res.instance[:name],
                                       active: res.instance[:active] },
                            notice: res.message)
          else
            content = show_partial { Development::Masterfiles::Role::Edit.call(id, params[:role], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          return_json_response
          res = interactor.delete_role(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'roles' do
      interactor = DevelopmentApp::RoleInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        raise Crossbeams::AuthorizationError unless authorised?('masterfiles', 'new')
        show_partial_or_page(fetch?(r)) { Development::Masterfiles::Role::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_role(params[:role])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Development::Masterfiles::Role::New.call(form_values: params[:role],
                                                     form_errors: res.errors,
                                                     remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Development::Masterfiles::Role::New.call(form_values: params[:role],
                                                     form_errors: res.errors,
                                                     remote: false)
          end
        end
      end
    end
    # ADDRESS TYPES
    # --------------------------------------------------------------------------
    r.on 'address_types', Integer do |id|
      interactor = DevelopmentApp::AddressTypeInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:address_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        raise Crossbeams::AuthorizationError unless authorised?('masterfiles', 'edit')
        show_partial { Development::Masterfiles::AddressType::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          raise Crossbeams::AuthorizationError unless authorised?('masterfiles', 'read')
          show_partial { Development::Masterfiles::AddressType::Show.call(id) }
        end
        r.patch do     # UPDATE
          return_json_response
          res = interactor.update_address_type(id, params[:address_type])
          if res.success
            update_grid_row(id,
                            changes: { address_type: res.instance[:address_type],
                                       active: res.instance[:active] },
                            notice: res.message)
          else
            content = show_partial { Development::Masterfiles::AddressType::Edit.call(id, params[:address_type], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          return_json_response
          res = interactor.delete_address_type(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'address_types' do
      interactor = DevelopmentApp::AddressTypeInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        raise Crossbeams::AuthorizationError unless authorised?('masterfiles', 'new')
        show_partial_or_page(fetch?(r)) { Development::Masterfiles::AddressType::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_address_type(params[:address_type])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Development::Masterfiles::AddressType::New.call(form_values: params[:address_type],
                                                            form_errors: res.errors,
                                                            remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Development::Masterfiles::AddressType::New.call(form_values: params[:address_type],
                                                            form_errors: res.errors,
                                                            remote: false)
          end
        end
      end
    end
    # CONTACT METHOD TYPES
    # --------------------------------------------------------------------------
    r.on 'contact_method_types', Integer do |id|
      interactor = DevelopmentApp::ContactMethodTypeInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:contact_method_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        raise Crossbeams::AuthorizationError unless authorised?('masterfiles', 'edit')
        show_partial { Development::Masterfiles::ContactMethodType::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          raise Crossbeams::AuthorizationError unless authorised?('masterfiles', 'read')
          show_partial { Development::Masterfiles::ContactMethodType::Show.call(id) }
        end
        r.patch do     # UPDATE
          return_json_response
          res = interactor.update_contact_method_type(id, params[:contact_method_type])
          if res.success
            update_grid_row(id,
                            changes: { contact_method_type: res.instance[:contact_method_type] },
                            notice: res.message)
          else
            content = show_partial { Development::Masterfiles::ContactMethodType::Edit.call(id, params[:contact_method_type], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          return_json_response
          res = interactor.delete_contact_method_type(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'contact_method_types' do
      interactor = DevelopmentApp::ContactMethodTypeInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        raise Crossbeams::AuthorizationError unless authorised?('masterfiles', 'new')
        show_partial_or_page(fetch?(r)) { Development::Masterfiles::ContactMethodType::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_contact_method_type(params[:contact_method_type])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Development::Masterfiles::ContactMethodType::New.call(form_values: params[:contact_method_type],
                                                                  form_errors: res.errors,
                                                                  remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Development::Masterfiles::ContactMethodType::New.call(form_values: params[:contact_method_type],
                                                                  form_errors: res.errors,
                                                                  remote: false)
          end
        end
      end
    end
    # USERS
    # --------------------------------------------------------------------------
    r.on 'users', Integer do |id|
      interactor = DevelopmentApp::UserInteractor.new(current_user, {}, { route_url: request.path }, {})

      # Check for notfound:
      r.on !interactor.exists?(:users, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        raise Crossbeams::AuthorizationError unless authorised?('masterfiles', 'edit')
        show_partial { Development::Masterfiles::User::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          raise Crossbeams::AuthorizationError unless authorised?('masterfiles', 'read')
          show_partial { Development::Masterfiles::User::Show.call(id) }
        end
        r.patch do     # UPDATE
          return_json_response
          res = interactor.update_user(id, params[:user])
          if res.success
            update_grid_row(id,
                            changes: { login_name: res.instance[:login_name],
                                       user_name: res.instance[:user_name],
                                       password_hash: res.instance[:password_hash],
                                       email: res.instance[:email],
                                       active: res.instance[:active] },
                            notice: res.message)
          else
            content = show_partial { Development::Masterfiles::User::Edit.call(id, params[:user], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          return_json_response
          res = interactor.delete_user(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'users' do
      interactor = DevelopmentApp::UserInteractor.new(current_user, {}, { route_url: request.path }, {})
      r.on 'new' do    # NEW
        raise Crossbeams::AuthorizationError unless authorised?('masterfiles', 'new')
        show_partial_or_page(fetch?(r)) { Development::Masterfiles::User::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_user(params[:user])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Development::Masterfiles::User::New.call(form_values: params[:user],
                                                     form_errors: res.errors,
                                                     remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Development::Masterfiles::User::New.call(form_values: params[:security_group],
                                                     form_errors: res.errors,
                                                     remote: false)
          end
        end
      end
    end
  end
end

# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/BlockLength
