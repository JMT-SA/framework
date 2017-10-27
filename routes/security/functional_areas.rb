# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

Dir['./lib/security/functional_areas/**/*.rb'].each { |f| require f }
Dir['./lib/security/programs/**/*.rb'].each { |f| require f }
Dir['./lib/security/program_functions/**/*.rb'].each { |f| require f }
class Framework < Roda
  route 'functional_areas', 'security' do |r|
    # --- see empty root plugin...
    # puts ">>>> URL: #{request.url}"
    # puts ">>>> SCHEME: #{request.scheme}"
    # puts ">>>> TYPE: #{request.content_type}"
    # puts ">>>> MEDIA: #{request.media_type}"
    # puts ">>>> XHR? #{request.xhr?}"
    # puts ">>>> GET? #{request.get?}"
    # puts ">>>> METHOD #{request.request_method}"
    r.on 'functional_areas' do
      # r.root do
      #   render(inline: '<h2>functional_areas</h2>')
      # end
      r.on 'new' do
        begin
          if authorised?('menu', 'new')
            show_partial { Security::FunctionalAreas::FunctionalAreas::New.call }
          else
            dialog_permission_error
          end
        rescue StandardError => e
          dialog_error(e)
        end
      end
      r.on 'create' do
        res = FunctionalAreaSchema.call(params[:functional_area])
        errors = res.messages
        if errors.empty?
          repo = FunctionalAreaRepo.new
          repo.create(res)
          flash[:notice] = 'Created'
          redirect_to_last_grid(r)
        else
          flash.now[:error] = 'Unable to create functional area'
          show_page { Security::FunctionalAreas::FunctionalAreas::New.call(params[:functional_area], errors) }
        end
      end
      r.on :id do |id|
        r.on 'edit' do
          begin
            if authorised?('menu', 'edit')
              show_partial { Security::FunctionalAreas::FunctionalAreas::Edit.call(id) }
            else
              dialog_permission_error
            end
          rescue StandardError => e
            dialog_error(e)
          end
        end
        # define a routes result object:
        # - success?
        # - flash_message - or should the action do this?
        # - errors
        # - result
        r.post do
          r.on 'update' do
            begin
              response['Content-Type'] = 'application/json'
              res = FunctionalAreaSchema.call(params[:functional_area])
              errors = res.messages
              if errors.empty?
                repo = FunctionalAreaRepo.new
                repo.update(id, res)
                flash[:notice] = 'Updated'
                redirect_via_json_to_last_grid
                # flash[:notice] = 'Updated'
                # redirect_to_last_grid(r)
                # update_grid_row(id, changes: res.to_h,
                #                     notice: "Updated #{res[:functional_area_name]}")
              else
                # flash.now[:error] = 'Unable to update functional area'
                # show_page { Security::FunctionalAreas::FunctionalAreas::Edit.call(id, params[:functional_area], errors) }
                content = show_partial { Security::FunctionalAreas::FunctionalAreas::Edit.call(id, params[:functional_area], errors) }
                update_dialog_content(content: content, error: 'Validation error')
              end
            rescue StandardError => e
              handle_json_error(e)
            end
          end
        end
        r.delete do
          repo = FunctionalAreaRepo.new
          repo.delete(id)
          flash[:notice] = 'Deleted'
          redirect_to_last_grid(r)
        end
      end
    end

    r.on 'programs' do
      r.on 'create' do
        res = ProgramSchema.call(params[:program])
        errors = res.messages
        # schema = Dry::Validation.Schema do
        #   required(:program_name).filled(:str?)
        # end
        # errors = schema.call(params[:program]).messages
        if errors.empty?
          repo = ProgramRepo.new
          # changeset = repo.changeset(NewChangeset).data(params[:program])
          repo.create(res)
          flash[:notice] = 'Created'
          r.redirect '/list/menu_definitions'
        else
          flash.now[:error] = 'Unable to create program'
          show_page { Security::FunctionalAreas::Programs::New.call(params[:program][:functional_area_id], params[:program], errors) }
        end
      end
      r.on :id do |id|
        r.on 'new' do
          show_page { Security::FunctionalAreas::Programs::New.call(id) }
        end
        r.on 'edit' do
          show_page { Security::FunctionalAreas::Programs::Edit.call(id) }
        end
        r.post do
          r.on 'update' do
            res = ProgramSchema.call(params[:program])
            errors = res.messages
            # schema = Dry::Validation.Schema do
            #   required(:program_name).filled(:str?)
            # end
            # errors = schema.call(params[:program]).messages
            if errors.empty?
              repo = ProgramRepo.new
              # changeset = repo.changeset(id, params[:program]).map(:touch)
              repo.update(id, res)
              flash[:notice] = 'Updated'
              redirect_to_last_grid(r)
            else
              flash.now[:error] = 'Unable to update program'
              show_page { Security::FunctionalAreas::Programs::Edit.call(id, params[:program], errors) }
            end
          end
          r.on 'save_reorder' do
            repo = ProgramRepo.new
            # FIXME: ... Should this be in the repo? or in objects sent to the repo to update?
            repo.re_order_program_functions(params[:pf_sorted_ids])
            flash[:notice] = 'Re-ordered'
            redirect_via_json_to_last_grid
          end
        end
        r.delete do
          repo = ProgramRepo.new
          repo.delete(id)
          flash[:notice] = 'Deleted'
          redirect_to_last_grid(r)
        end

        r.on 'reorder' do
          show_partial { Security::FunctionalAreas::Programs::Reorder.call(id) }
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
          repo.create(res)
          flash[:notice] = 'Created'
          r.redirect '/list/menu_definitions'
        else
          # TODO: might work better with a redirect?
          flash.now[:error] = 'Unable to create program function'
          show_page do
            Security::FunctionalAreas::ProgramFunctions::New.call(params[:program_function][:program_id],
                                                                  params[:program_function], errors)
          end
        end
      end
      r.on :id do |id|
        r.on 'new' do
          show_page { Security::FunctionalAreas::ProgramFunctions::New.call(id) }
        end
        r.on 'edit' do
          show_page { Security::FunctionalAreas::ProgramFunctions::Edit.call(id) }
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
              repo.update(id, res)
              flash[:notice] = 'Updated'
              redirect_to_last_grid(r)
            else
              flash.now[:error] = 'Unable to create program function'
              show_page do
                Security::FunctionalAreas::ProgramFunctions::Edit.call(id,
                                                                       params[:program_function], errors)
              end
            end
          end
        end
        r.delete do
          repo = ProgramFunctionRepo.new
          repo.delete(id)
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
          show_partial { interactor.edit_security_group_layout(id) }
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
            content = show_partial { interactor.security_group_permissions_layout(id, params[:security_group], res.errors) }
            update_dialog_content(content: content, error: res.message)
          end
        end

        show_partial { interactor.security_group_permissions_layout(id) }
      end
      r.is do
        r.get do       # SHOW
          if authorised?('menu', 'read')
            show_partial { interactor.show_security_group_layout(id) }
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
            content = show_partial { interactor.edit_security_group_layout(id, params[:security_group], res.errors) }
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
          show_partial { interactor.new_security_group_layout }
        else
          dialog_permission_error
        end
      end
      r.post do        # CREATE
        res = interactor.create_security_group(params[:security_group])
        if res.success
          flash[:notice] = res.message
          redirect_via_json_to_last_grid
        else
          content = show_partial { interactor.new_security_group_layout(params[:security_group], res.errors) }
          update_dialog_content(content: content, error: res.message)
        end
      end
    end

    # SECURITY PERMISSIONS
    # --------------------------------------------------------------------------
    r.on 'security_permissions', Integer do |id|
      repo                = SecurityPermissionRepo.new
      security_permission = repo.find(id)

      # Check for notfound:
      r.on security_permission.nil? do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        begin
          if authorised?('menu', 'edit')
            show_partial { Security::FunctionalAreas::SecurityPermissions::Edit.call(id) }
          else
            dialog_permission_error
          end
        rescue StandardError => e
          dialog_error(e)
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('menu', 'read')
            show_partial { Security::FunctionalAreas::SecurityPermissions::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          begin
            response['Content-Type'] = 'application/json'
            res = SecurityPermissionSchema.call(params[:security_permission])
            errors = res.messages
            if errors.empty?
              repo = SecurityPermissionRepo.new
              repo.update(id, res)
              # flash[:notice] = 'Updated'
              # redirect_via_json_to_last_grid
              update_grid_row(id, changes: { security_permission: res[:security_permission] },
                                  notice:  "Updated #{res[:security_permission]}")
            else
              content = show_partial { Security::FunctionalAreas::SecurityPermissions::Edit.call(id, params[:security_permission], errors) }
              update_dialog_content(content: content, error: 'Validation error')
            end
          rescue StandardError => e
            handle_json_error(e)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          repo = SecurityPermissionRepo.new
          repo.delete(id)
          # flash[:notice] = 'Deleted'
          # redirect_to_last_grid(r)
          delete_grid_row(id, notice: 'Deleted')
        end
      end
    end
    r.on 'security_permissions' do
      r.on 'new' do    # NEW
        begin
          if authorised?('menu', 'new')
            # show_page { Security::FunctionalAreas::SecurityPermissions::New.call }
            show_partial { Security::FunctionalAreas::SecurityPermissions::New.call }
          else
            dialog_permission_error
            # show_unauthorised
          end
        rescue StandardError => e
          dialog_error(e)
        end
      end
      r.post do        # CREATE
        res = SecurityPermissionSchema.call(params[:security_permission])
        errors = res.messages
        if errors.empty?
          repo = SecurityPermissionRepo.new
          repo.create(res)
          flash[:notice] = 'Created'
          redirect_via_json_to_last_grid
        else
          content = show_partial { Security::FunctionalAreas::SecurityPermissions::New.call(params[:security_permission], errors) }
          update_dialog_content(content: content, error: 'Validation error')
        end
      end
    end
  end
end
