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
            show_partial { Masterfiles::Parties::Role::Edit.call(id) }
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
            show_partial { Masterfiles::Parties::Role::Show.call(id) }
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
              content = show_partial { Masterfiles::Parties::Role::Edit.call(id, params[:role], errors) }
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
        # begin
          if authorised?('masterfiles', 'new')
            show_partial { Masterfiles::Parties::Role::New.call }
          else
            dialog_permission_error
          end
        # rescue StandardError => e
        #   dialog_error(e)
        # end
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
          content = show_partial { Masterfiles::Parties::Role::New.call(params[:role], errors) }
          update_dialog_content(content: content, error: 'Validation error')
        end
      end
    end
    # ADDRESS TYPES
    # --------------------------------------------------------------------------
    r.on 'address_types', Integer do |id|
      repo = AddressTypeRepo.new
      address_type = repo.find(id)

      # Check for notfound:
      r.on address_type.nil? do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        begin
          if authorised?('masterfiles', 'edit')
            show_partial { Development::Masterfiles::AddressType::Edit.call(id) }
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
            show_partial { Development::Masterfiles::AddressType::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          begin
            response['Content-Type'] = 'application/json'
            res = AddressTypeSchema.call(params[:address_type])
            errors = res.messages
            if errors.empty?
              repo = AddressTypeRepo.new
              repo.update(id, res)
              update_grid_row(id, changes: { address_type: res[:address_type], active: res[:active] },
                              notice:  "Updated #{res[:address_type]}")
            else
              content = show_partial { Development::Masterfiles::AddressType::Edit.call(id, params[:address_type], errors) }
              update_dialog_content(content: content, error: 'Validation error')
            end
          rescue StandardError => e
            handle_json_error(e)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          repo = AddressTypeRepo.new
          repo.delete(id)
          delete_grid_row(id, notice: 'Deleted')
        end
      end
    end
    r.on 'address_types' do
      r.on 'new' do    # NEW
        begin
          if authorised?('masterfiles', 'new')
            show_partial { Development::Masterfiles::AddressType::New.call }
          else
            dialog_permission_error
          end
        rescue StandardError => e
          dialog_error(e)
        end
      end
      r.post do        # CREATE
        res = AddressTypeSchema.call(params[:address_type])
        errors = res.messages
        if errors.empty?
          repo = AddressTypeRepo.new
          repo.create(res)
          flash[:notice] = 'Created'
          redirect_via_json_to_last_grid
        else
          content = show_partial { Development::Masterfiles::AddressType::New.call(params[:address_type], errors) }
          update_dialog_content(content: content, error: 'Validation error')
        end
      end
    end
    # CONTACT METHOD TYPES
    # --------------------------------------------------------------------------
    r.on 'contact_method_types', Integer do |id|
      repo = ContactMethodTypeRepo.new
      contact_method_type = repo.find(id)

      # Check for notfound:
      r.on contact_method_type.nil? do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        begin
          if authorised?('masterfiles', 'edit')
            show_partial { Development::Masterfiles::ContactMethodType::Edit.call(id) }
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
            show_partial { Development::Masterfiles::ContactMethodType::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          begin
            response['Content-Type'] = 'application/json'
            res = ContactMethodTypeSchema.call(params[:contact_method_type])
            errors = res.messages
            if errors.empty?
              repo = ContactMethodTypeRepo.new
              repo.update(id, res)
              update_grid_row(id, changes: { contact_method_code: res[:contact_method_code] },
                              notice:  "Updated #{res[:contact_method_code]}")
            else
              content = show_partial { Development::Masterfiles::ContactMethodType::Edit.call(id, params[:contact_method_type], errors) }
              update_dialog_content(content: content, error: 'Validation error')
            end
          rescue StandardError => e
            handle_json_error(e)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          repo = ContactMethodTypeRepo.new
          repo.delete(id)
          delete_grid_row(id, notice: 'Deleted')
        end
      end
    end
    r.on 'contact_method_types' do
      r.on 'new' do    # NEW
        begin
          if authorised?('masterfiles', 'new')
            show_partial { Development::Masterfiles::ContactMethodType::New.call }
          else
            dialog_permission_error
          end
        rescue StandardError => e
          dialog_error(e)
        end
      end
      r.post do        # CREATE
        res = ContactMethodTypeSchema.call(params[:contact_method_type])
        errors = res.messages
        if errors.empty?
          repo = ContactMethodTypeRepo.new
          repo.create(res)
          flash[:notice] = 'Created'
          redirect_via_json_to_last_grid
        else
          content = show_partial { Development::Masterfiles::ContactMethodType::New.call(params[:contact_method_type], errors) }
          update_dialog_content(content: content, error: 'Validation error')
        end
      end
    end
  end
end
