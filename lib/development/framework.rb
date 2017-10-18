# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'masterfiles', 'development' do |r|
    # ROLES
    # --------------------------------------------------------------------------
    r.on 'roles', Integer do |id|
      repo = RoleRepo.new
      role = repo.find(id)

      # Check for notfound:
      r.on role.nil? do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        begin
          if authorised?('masterfiles', 'edit')
            show_partial { Development::Masterfiles::Role::Edit.call(id) }
          else
            dialog_permission_error
          end
        rescue StandardError => e
          dialog_error(e)
        end
      end
      r.is do
        r.get do       # SHOW
          if authorised?('masterfiles', 'read')
            show_partial { Development::Masterfiles::Role::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          begin
            response['Content-Type'] = 'application/json'
            res = RoleSchema.call(params[:role])
            errors = res.messages
            if errors.empty?
              repo = RoleRepo.new
              repo.update(id, res)
              update_grid_row(id, changes: { name: res[:name], active: res[:active] },
                              notice:  "Updated #{res[:name]}")
            else
              content = show_partial { Development::Masterfiles::Role::Edit.call(id, params[:role], errors) }
              update_dialog_content(content: content, error: 'Validation error')
            end
          rescue StandardError => e
            handle_json_error(e)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          repo = RoleRepo.new
          repo.delete(id)
          delete_grid_row(id, notice: 'Deleted')
        end
      end
    end
    r.on 'roles' do
      r.on 'new' do    # NEW
        begin
          if authorised?('masterfiles', 'new')
            show_partial { Development::Masterfiles::Role::New.call }
          else
            dialog_permission_error
          end
        rescue StandardError => e
          dialog_error(e)
        end
      end
      r.post do        # CREATE
        res = RoleSchema.call(params[:role])
        errors = res.messages
        if errors.empty?
          repo = RoleRepo.new
          repo.create(res)
          flash[:notice] = 'Created'
          redirect_via_json_to_last_grid
        else
          content = show_partial { Development::Masterfiles::Role::New.call(params[:role], errors) }
          update_dialog_content(content: content, error: 'Validation error')
        end
      end
    end
  end
end