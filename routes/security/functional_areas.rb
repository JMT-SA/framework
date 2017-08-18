# frozen_string_literal: true

Dir['./lib/security/functional_areas/**/*.rb'].each { |f| require f }
Dir['./lib/security/programs/**/*.rb'].each { |f| require f }
Dir['./lib/security/program_functions/**/*.rb'].each { |f| require f }
class Framework < Roda
  route 'functional_areas', 'security' do |r|
    # --- see empty root plugin...
    r.on 'functional_areas' do
      # r.root do
      #   render(inline: '<h2>functional_areas</h2>')
      # end
      r.on 'new' do
        show_page { Security::FunctionalAreas::FunctionalAreas::New.call }
      end
      r.on 'create' do
        res = FunctionalAreaSchema.(params[:functional_area])
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
          # show_page { Security::FunctionalAreas::FunctionalAreas::Edit.call(id) }
          show_partial { Security::FunctionalAreas::FunctionalAreas::Edit.call(id) }
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
              res = FunctionalAreaSchema.(params[:functional_area])
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
            rescue => e
              handle_json_error(e)
            end
          end
        end
        r.delete do
          repo = FunctionalAreaRepo.new(DB.db)
          repo.delete(id)
          flash[:notice] = 'Deleted'
          redirect_to_last_grid(r)
        end
      end
    end

    r.on 'programs' do
      r.on 'create' do
        res = ProgramSchema.(params[:program])
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
            res = ProgramSchema.(params[:program])
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
            # FIXME:... Should this be in the repo? or in objects sent to the repo to update?
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
        res = ProgramFunctionCreateSchema.(params[:program_function])
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
          show_page { Security::FunctionalAreas::ProgramFunctions::New.call(params[:program_function][:program_id],
                                                                            params[:program_function], errors) }
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
            res = ProgramFunctionSchema.(params[:program_function])
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
              show_page { Security::FunctionalAreas::ProgramFunctions::Edit.call(id,
                                                                                params[:program_function], errors) }
            end
          end
        end
        r.delete do
          repo = ProgramFunctionRepo.new(DB.db)
          repo.delete(id)
          flash[:notice] = 'Deleted'
          redirect_to_last_grid(r)
        end
      end
    end
  end
end

