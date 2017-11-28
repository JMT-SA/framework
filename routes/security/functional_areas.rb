# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'functional_areas', 'security' do |r|
    # FUNCTIONAL AREAS
    # --------------------------------------------------------------------------
    r.on 'functional_areas', Integer do |id|
      interactor = FunctionalAreaInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:functional_areas, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('menu', 'edit')
          show_partial { Security::FunctionalAreas::FunctionalArea::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('menu', 'read')
            show_partial { Security::FunctionalAreas::FunctionalArea::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_functional_area(id, params[:functional_area])
          if res.success
            flash[:notice] = res.message
            redirect_via_json_to_last_grid
          else
            content = show_partial { Security::FunctionalAreas::FunctionalArea::Edit.call(id, params[:functional_area], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_functional_area(id)
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        end
      end
    end

    r.on 'functional_areas' do
      interactor = FunctionalAreaInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('menu', 'new')
          show_partial_or_page(fetch?(r)) { Security::FunctionalAreas::FunctionalArea::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_functional_area(params[:functional_area])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Security::FunctionalAreas::FunctionalArea::New.call(form_values: params[:functional_area],
                                                                form_errors: res.errors,
                                                                remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Security::FunctionalAreas::FunctionalArea::New.call(form_values: params[:functional_area],
                                                                form_errors: res.errors,
                                                                remote: false)
          end
        end
      end
    end

    # PROGRAMS
    # --------------------------------------------------------------------------
    r.on 'programs', Integer do |id|
      interactor = ProgramInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:programs, id) do
        handle_not_found(r)
      end

      r.on 'new' do    # NEW
        if authorised?('menu', 'new')
          show_partial_or_page(fetch?(r)) { Security::FunctionalAreas::Program::New.call(id, remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end

      r.on 'edit' do   # EDIT
        if authorised?('menu', 'edit')
          show_partial { Security::FunctionalAreas::Program::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        p 'IS'
        r.get do       # SHOW
          if authorised?('menu', 'read')
            show_partial { Security::FunctionalAreas::Program::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_program(id, params[:program])
          if res.success
            flash[:notice] = res.message
            redirect_via_json_to_last_grid
          else
            content = show_partial { Security::FunctionalAreas::Program::Edit.call(id, params[:program], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_program(id)
          flash[:notice] = res.message
          redirect_to_last_grid(r)
        end
      end

      r.on 'reorder' do
        show_partial { Security::FunctionalAreas::Program::Reorder.call(id) }
      end

      r.on 'save_reorder' do
        res = interactor.reorder_program_functions(params[:pf_sorted_ids])
        flash[:notice] = res.message
        redirect_via_json_to_last_grid
      end
    end

    r.on 'programs' do
      interactor = ProgramInteractor.new(current_user, {}, {}, {})

      r.on 'link_users', Integer do |id|
        r.post do
          res = interactor.link_user(id, multiselect_grid_choices(params))
          flash[:notice] = res.message
          r.redirect '/list/users'
        end
      end

      r.post do        # CREATE
        res = interactor.create_program(params[:program])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do # params[:program][:functional_area_id]
            Security::FunctionalAreas::Program::New.call(res.functional_area_id,
                                                         form_values: params[:program],
                                                         form_errors: res.errors,
                                                         remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Security::FunctionalAreas::Program::New.call(res.functional_area_id,
                                                         form_values: params[:program],
                                                         form_errors: res.errors,
                                                         remote: false)
          end
        end
      end
    end

    r.on 'program_functions' do
      r.on 'create' do
        res = ProgramFunctionCreateSchema.call(params[:program_function])
        errors = res.messages
        # schema = Dry::Validation.Form do
        #   required(:program_function_name).filled(:str?)
        #   required(:url).filled(:str?)
        #   required(:program_function_sequence).filled(:int?)
        #   required(:program_id).filled(:int?) # Hidden parameter
        #   required(:group_name).maybe(:str?)
        #   required(:restricted_user_access).filled(:bool?)
        #   required(:active).filled(:bool?)
        # end
        # result = schema.call(params[:program_function])
        # errors = result.messages
        if errors.empty?
          repo = ProgramFunctionRepo.new
          # changeset = repo.changeset(params[:functional_area]).map(:add_timestamps)
          # changeset = repo.changeset(NewChangeset).data(result.to_h) # + hidden params...
          repo.create(:program_functions, res)
          flash[:notice] = 'Created'
          r.redirect '/list/menu_definitions'
        else
          # TODO: might work better with a redirect?
          flash.now[:error] = 'Unable to create program function'
          show_page do
            Security::FunctionalAreas::ProgramFunction::New.call(params[:program_function][:program_id],
                                                                 params[:program_function], errors)
          end
        end
      end
      r.on :id do |id|
        r.on 'new' do
          show_page { Security::FunctionalAreas::ProgramFunction::New.call(id) }
        end
        r.on 'edit' do
          show_page { Security::FunctionalAreas::ProgramFunction::Edit.call(id) }
        end
        r.post do
          r.on 'update' do
            res = ProgramFunctionSchema.call(params[:program_function])
            errors = res.messages
            # schema = Dry::Validation.Form do
            #   required(:program_function_name).filled(:str?)
            #   required(:url).filled(:str?)
            #   required(:program_function_sequence).filled(:int?)
            #   required(:group_name).maybe(:str?)
            #   required(:restricted_user_access).filled(:bool?)
            #   required(:active).filled(:bool?)
            # end
            # result = schema.call(params[:program_function])
            # errors = result.messages
            if errors.empty?
              repo = ProgramFunctionRepo.new
              # changeset = repo.changeset(id, result.to_h).map(:touch)
              # changeset = repo.changeset(id, UpdateChangeset).data(result.to_h)
              repo.update(:program_functions, id, res)
              flash[:notice] = 'Updated'
              redirect_to_last_grid(r)
            else
              flash.now[:error] = 'Unable to create program function'
              show_page do
                Security::FunctionalAreas::ProgramFunction::Edit.call(id,
                                                                      params[:program_function], errors)
              end
            end
          end
        end
        r.delete do
          repo = ProgramFunctionRepo.new
          repo.delete(:program_functions, id)
          flash[:notice] = 'Deleted'
          redirect_to_last_grid(r)
        end
      end
    end

    # SECURITY GROUPS
    # --------------------------------------------------------------------------
    r.on 'security_groups', Integer do |id|
      interactor = SecurityGroupInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:security_groups, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('menu', 'edit')
          show_partial { Security::FunctionalAreas::SecurityGroup::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.on 'permissions' do
        r.post do
          response['Content-Type'] = 'application/json'
          res = interactor.assign_security_permissions(id, params[:security_group])
          if res.success
            update_grid_row(id, changes: { permissions: res.instance.permission_list },
                                notice:  res.message)
          else
            content = show_partial { Security::FunctionalAreas::SecurityGroup::Permissions.call(id, params[:security_group], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end

        show_partial { Security::FunctionalAreas::SecurityGroup::Permissions.call(id) }
      end
      r.is do
        r.get do       # SHOW
          if authorised?('menu', 'read')
            show_partial { Security::FunctionalAreas::SecurityGroup::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_security_group(id, params[:security_group])
          if res.success
            update_grid_row(id, changes: { security_group_name: res.instance[:security_group_name] },
                                notice:  res.message)
          else
            content = show_partial { Security::FunctionalAreas::SecurityGroup::Edit.call(id, params[:security_group], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_security_group(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end
    r.on 'security_groups' do
      interactor = SecurityGroupInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('menu', 'new')
          show_partial_or_page(fetch?(r)) { Security::FunctionalAreas::SecurityGroup::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_security_group(params[:security_group])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Security::FunctionalAreas::SecurityGroup::New.call(form_values: params[:security_group],
                                                               form_errors: res.errors,
                                                               remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Security::FunctionalAreas::SecurityGroup::New.call(form_values: params[:security_group],
                                                               form_errors: res.errors,
                                                               remote: false)
          end
        end
      end
    end

    # SECURITY PERMISSIONS
    # --------------------------------------------------------------------------
    r.on 'security_permissions', Integer do |id|
      interactor = SecurityPermissionInteractor.new(current_user, {}, {}, {})

      # Check for notfound:
      r.on !interactor.exists?(:security_permissions, id) do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        if authorised?('menu', 'edit')
          show_partial { Security::FunctionalAreas::SecurityPermission::Edit.call(id) }
        else
          dialog_permission_error
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('menu', 'read')
            show_partial { Security::FunctionalAreas::SecurityPermission::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          response['Content-Type'] = 'application/json'
          res = interactor.update_security_permission(id, params[:security_permission])
          if res.success
            update_grid_row(id, changes: { security_permission: res.instance[:security_permission] },
                                notice:  res.message)
          else
            content = show_partial { Security::FunctionalAreas::SecurityPermission::Edit.call(id, params[:security_permission], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          res = interactor.delete_security_permission(id)
          delete_grid_row(id, notice: res.message)
        end
      end
    end

    r.on 'security_permissions' do
      interactor = SecurityPermissionInteractor.new(current_user, {}, {}, {})
      r.on 'new' do    # NEW
        if authorised?('menu', 'new')
          show_partial_or_page(fetch?(r)) { Security::FunctionalAreas::SecurityPermission::New.call(remote: fetch?(r)) }
        else
          fetch?(r) ? dialog_permission_error : show_unauthorised
        end
      end
      r.post do        # CREATE
        res = interactor.create_security_permission(params[:security_permission])
        if res.success
          flash[:notice] = res.message
          if fetch?(r)
            redirect_via_json_to_last_grid
          else
            redirect_to_last_grid(r)
          end
        elsif fetch?(r)
          content = show_partial do
            Security::FunctionalAreas::SecurityPermission::New.call(form_values: params[:security_permission],
                                                                    form_errors: res.errors,
                                                                    remote: true)
          end
          update_dialog_content(content: content, error: res.message)
        else
          flash[:error] = res.message
          show_page do
            Security::FunctionalAreas::SecurityPermission::New.call(form_values: params[:security_permission],
                                                                    form_errors: res.errors,
                                                                    remote: false)
          end
        end
      end
    end
    # # SECURITY PERMISSIONS
    # # --------------------------------------------------------------------------
    # r.on 'security_permissions', Integer do |id|
    #   repo                = SecurityGroupRepo.new
    #   security_permission = repo.find(:security_permissions, SecurityPermission, id)
    #
    #   # Check for notfound:
    #   r.on security_permission.nil? do
    #     handle_not_found(r)
    #   end
    #
    #   r.on 'edit' do   # EDIT
    #     begin
    #       if authorised?('menu', 'edit')
    #         show_partial { Security::FunctionalAreas::SecurityPermission::Edit.call(id) }
    #       else
    #         dialog_permission_error
    #       end
    #     rescue StandardError => e
    #       dialog_error(e)
    #     end
    #   end
    #   r.is do
    #     r.get do       # SHOW
    #       if authorised?('menu', 'read')
    #         show_partial { Security::FunctionalAreas::SecurityPermission::Show.call(id) }
    #       else
    #         dialog_permission_error
    #       end
    #     end
    #     r.patch do     # UPDATE
    #       begin
    #         response['Content-Type'] = 'application/json'
    #         res = SecurityPermissionSchema.call(params[:security_permission])
    #         errors = res.messages
    #         if errors.empty?
    #           repo = SecurityGroupRepo.new
    #           repo.update(:security_permissions, id, res)
    #           # flash[:notice] = 'Updated'
    #           # redirect_via_json_to_last_grid
    #           update_grid_row(id, changes: { security_permission: res[:security_permission] },
    #                               notice:  "Updated #{res[:security_permission]}")
    #         else
    #           content = show_partial { Security::FunctionalAreas::SecurityPermission::Edit.call(id, params[:security_permission], errors) }
    #           update_dialog_content(content: content, error: 'Validation error')
    #         end
    #       rescue StandardError => e
    #         handle_json_error(e)
    #       end
    #     end
    #     r.delete do    # DELETE
    #       response['Content-Type'] = 'application/json'
    #       repo = SecurityGroupRepo.new
    #       repo.delete(:security_permissions, id)
    #       # flash[:notice] = 'Deleted'
    #       # redirect_to_last_grid(r)
    #       delete_grid_row(id, notice: 'Deleted')
    #     end
    #   end
    # end
    # r.on 'security_permissions' do
    #   r.on 'new' do    # NEW
    #     begin
    #       if authorised?('menu', 'new')
    #         # show_page { Security::FunctionalAreas::SecurityPermission::New.call }
    #         show_partial { Security::FunctionalAreas::SecurityPermission::New.call }
    #       else
    #         dialog_permission_error
    #         # show_unauthorised
    #       end
    #     rescue StandardError => e
    #       dialog_error(e)
    #     end
    #   end
    #   r.post do        # CREATE
    #     res = SecurityPermissionSchema.call(params[:security_permission])
    #     errors = res.messages
    #     if errors.empty?
    #       repo = SecurityGroupRepo.new
    #       repo.create(:security_permissions, res)
    #       flash[:notice] = 'Created'
    #       redirect_via_json_to_last_grid
    #     else
    #       content = show_partial { Security::FunctionalAreas::SecurityPermission::New.call(params[:security_permission], errors) }
    #       update_dialog_content(content: content, error: 'Validation error')
    #     end
    #   end
    # end
  end
end
