# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'masterfiles', 'development' do |r|
    # ROLES
    # --------------------------------------------------------------------------
    r.on 'roles', Integer do |id|
      interactor = DevelopmentApp::RoleInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

      # Check for notfound:
      r.on !interactor.exists?(:roles, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('masterfiles', 'edit')
        show_partial { Development::Masterfiles::Role::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('masterfiles', 'read')
          show_partial { Development::Masterfiles::Role::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_role(id, params[:role])
          if res.success
            update_grid_row(id, changes: { name: res.instance[:name] }, notice: res.message)
          else
            re_show_form(r, res) { Development::Masterfiles::Role::Edit.call(id, params[:role], res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('masterfiles', 'delete')
          res = interactor.delete_role(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end

    r.on 'roles' do
      interactor = DevelopmentApp::RoleInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
      r.on 'new' do    # NEW
        check_auth!('masterfiles', 'new')
        show_partial_or_page(r) { Development::Masterfiles::Role::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_role(params[:role])
        if res.success
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        else
          re_show_form(r, res, url: '/development/masterfiles/roles/new') do
            Development::Masterfiles::Role::New.call(form_values: params[:role],
                                                     form_errors: res.errors,
                                                     remote: fetch?(r))
          end
        end
      end
    end
    # ADDRESS TYPES
    # --------------------------------------------------------------------------
    r.on 'address_types', Integer do |id|
      interactor = DevelopmentApp::AddressTypeInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

      # Check for notfound:
      r.on !interactor.exists?(:address_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('masterfiles', 'edit')
        show_partial { Development::Masterfiles::AddressType::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('masterfiles', 'read')
          show_partial { Development::Masterfiles::AddressType::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_address_type(id, params[:address_type])
          if res.success
            update_grid_row(id, changes: { address_type: res.instance[:address_type] }, notice: res.message)
          else
            re_show_form(r, res) { Development::Masterfiles::AddressType::Edit.call(id, params[:address_type], res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('masterfiles', 'delete')
          res = interactor.delete_address_type(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end

    r.on 'address_types' do
      interactor = DevelopmentApp::AddressTypeInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
      r.on 'new' do    # NEW
        check_auth!('masterfiles', 'new')
        show_partial_or_page(r) { Development::Masterfiles::AddressType::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_address_type(params[:address_type])
        if res.success
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        else
          re_show_form(r, res, url: '/development/masterfiles/address_types/new') do
            Development::Masterfiles::AddressType::New.call(form_values: params[:address_type],
                                                            form_errors: res.errors,
                                                            remote: fetch?(r))
          end
        end
      end
    end
    # CONTACT METHOD TYPES
    # --------------------------------------------------------------------------
    r.on 'contact_method_types', Integer do |id|
      interactor = DevelopmentApp::ContactMethodTypeInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

      # Check for notfound:
      r.on !interactor.exists?(:contact_method_types, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('masterfiles', 'edit')
        show_partial { Development::Masterfiles::ContactMethodType::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('masterfiles', 'read')
          show_partial { Development::Masterfiles::ContactMethodType::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_contact_method_type(id, params[:contact_method_type])
          if res.success
            update_grid_row(id, changes: { contact_method_type: res.instance[:contact_method_type] }, notice: res.message)
          else
            re_show_form(r, res) { Development::Masterfiles::ContactMethodType::Edit.call(id, params[:contact_method_type], res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('masterfiles', 'delete')
          res = interactor.delete_contact_method_type(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end

    r.on 'contact_method_types' do
      interactor = DevelopmentApp::ContactMethodTypeInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
      r.on 'new' do    # NEW
        check_auth!('masterfiles', 'new')
        show_partial_or_page(r) { Development::Masterfiles::ContactMethodType::New.call(remote: fetch?(r)) }
      end
      r.post do        # CREATE
        res = interactor.create_contact_method_type(params[:contact_method_type])
        if res.success
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        else
          re_show_form(r, res, url: '/development/masterfiles/contact_method_types/new') do
            Development::Masterfiles::ContactMethodType::New.call(form_values: params[:contact_method_type],
                                                                  form_errors: res.errors,
                                                                  remote: fetch?(r))
          end
        end
      end
    end

    # USERS
    # --------------------------------------------------------------------------
    r.on 'users', Integer do |id|
      interactor = DevelopmentApp::UserInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

      # Check for notfound:
      r.on !interactor.exists?(:users, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('masterfiles', 'user_maintenance')
        show_partial { Development::Masterfiles::User::Edit.call(id) }
      end

      r.on 'act_as_user' do
        act_as_user(id)
        r.redirect '/'
      end

      r.on 'permission_tree' do
        check_auth!('masterfiles', 'user_maintenance')
        r.get do
          show_partial { Development::Masterfiles::User::PermissionTree.call(id) }
        end
        r.patch do
          res = interactor.change_user_permissions(id, params[:user]) # apply params to tree & save hash to JSON permission_tree
          if res.success
            show_json_notice res.message
          else
            re_show_form(r, res) do
              Development::Masterfiles::User::PermissionTree.call(id,
                                                                  form_values: params[:permission_tree],
                                                                  form_errors: res.errors)
            end
          end
        end
      end

      r.on 'details' do
        r.get do
          show_partial { Development::Masterfiles::User::Details.call(id) }
        end
        r.patch do
          # User updates own password
          res = interactor.change_user_password(id, params[:user])
          if res.success
            show_json_notice res.message
          else
            re_show_form(r, res, url: "/development/masterfiles/users/#{id}/details") do
              Development::Masterfiles::User::Details.call(id,
                                                           form_values: {}, # Do not re-show password values...
                                                           form_errors: res.errors)
            end
          end
        end
      end
      r.on 'change_password' do
        r.get do
          check_auth!('masterfiles', 'user_maintenance')
          show_partial { Development::Masterfiles::User::ChangePassword.call(id) }
        end
        r.patch do
          res = interactor.set_user_password(id, params[:user])
          if res.success
            show_json_notice res.message
          else
            re_show_form(r, res, url: "/development/masterfiles/users/#{id}/change_password") do
              Development::Masterfiles::User::ChangePassword.call(id,
                                                                  form_values: {}, # Do not re-show password values...
                                                                  form_errors: res.errors)
            end
          end
        end
      end
      r.is do
        r.get do       # SHOW
          check_auth!('masterfiles', 'read')
          show_partial { Development::Masterfiles::User::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_user(id, params[:user])
          if res.success
            update_grid_row(id,
                            changes: { login_name: res.instance[:login_name],
                                       user_name: res.instance[:user_name],
                                       password_hash: res.instance[:password_hash],
                                       email: res.instance[:email] },
                            notice: res.message)
          else
            re_show_form(r, res) { Development::Masterfiles::User::Edit.call(id, params[:user], res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('masterfiles', 'user_maintenance')
          res = interactor.delete_user(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'users' do
      interactor = DevelopmentApp::UserInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
      r.on 'new' do    # NEW
        check_auth!('masterfiles', 'user_maintenance')
        show_partial_or_page(r) { Development::Masterfiles::User::New.call(remote: fetch?(r)) }
      end

      r.on 'set_permissions', Integer do |id|
        r.get do
          check_auth!('masterfiles', 'user_permissions')
          ids = multiselect_grid_choices(params)
          show_partial { Development::Masterfiles::User::ApplySecurityGroupToProgram.call(id, ids) }
        end
        r.patch do
          ids = multiselect_grid_choices(params[:permission])
          res = interactor.set_user_permissions(id, ids, params[:permission])
          if res.success
            update_grid_row(ids,
                            changes: { security_group_name: res.instance[:security_group_name],
                                       permissions: res.instance[:permissions] },
                            notice: res.message)
          else
            re_show_form(r, res, url: "/development/masterfiles/users/set_permissions/#{id}") do
              Development::Masterfiles::User::ApplySecurityGroupToProgram.call(id,
                                                                               ids,
                                                                               form_values: params[:permission],
                                                                               form_errors: res.errors)
            end
          end
        end
      end
      r.post do        # CREATE
        res = interactor.create_user(params[:user])
        if res.success
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        else
          re_show_form(r, res, url: '/development/masterfiles/users/new') do
            Development::Masterfiles::User::New.call(form_values: params[:user],
                                                     form_errors: res.errors,
                                                     remote: fetch?(r))
          end
        end
      end
    end

    # USER EMAIL GROUPS
    # --------------------------------------------------------------------------
    r.on 'user_email_groups', Integer do |id|
      interactor = DevelopmentApp::UserEmailGroupInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})

      # Check for notfound:
      r.on !interactor.exists?(:user_email_groups, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        check_auth!('masterfiles', 'edit')
        show_partial { Development::Masterfiles::UserEmailGroup::Edit.call(id) }
      end
      r.is do
        r.get do       # SHOW
          check_auth!('masterfiles', 'read')
          show_partial { Development::Masterfiles::UserEmailGroup::Show.call(id) }
        end
        r.patch do     # UPDATE
          res = interactor.update_user_email_group(id, params[:user_email_group])
          if res.success
            update_grid_row(id, changes: { mail_group: res.instance[:mail_group] },
                                notice: res.message)
          else
            re_show_form(r, res) { Development::Masterfiles::UserEmailGroup::Edit.call(id, form_values: params[:user_email_group], form_errors: res.errors) }
          end
        end
        r.delete do    # DELETE
          check_auth!('masterfiles', 'delete')
          res = interactor.delete_user_email_group(id)
          if res.success
            delete_grid_row(id, notice: res.message)
          else
            show_json_error(res.message, status: 200)
          end
        end
      end
    end

    r.on 'user_email_groups' do
      interactor = DevelopmentApp::UserEmailGroupInteractor.new(current_user, {}, { route_url: request.path, request_ip: request.ip }, {})
      r.on 'new' do    # NEW
        check_auth!('masterfiles', 'new')
        show_partial_or_page(r) { Development::Masterfiles::UserEmailGroup::New.call(remote: fetch?(r)) }
      end
      r.on 'link_users', Integer do |id|
        r.post do
          res = interactor.link_users(id, multiselect_grid_choices(params))
          if fetch?(r)
            show_json_notice(res.message)
          else
            flash[:notice] = res.message
            r.redirect '/list/user_email_groups'
          end
        end
      end
      r.post do        # CREATE
        res = interactor.create_user_email_group(params[:user_email_group])
        if res.success
          row_keys = %i[
            id
            mail_group
          ]
          add_grid_row(attrs: select_attributes(res.instance, row_keys),
                       notice: res.message)
        else
          re_show_form(r, res, url: '/development/masterfiles/user_email_groups/new') do
            Development::Masterfiles::UserEmailGroup::New.call(form_values: params[:user_email_group],
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
