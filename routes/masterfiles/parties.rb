# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength

class Framework < Roda
  route 'parties', 'masterfiles' do |r|
    # ORGANIZATIONS
    # --------------------------------------------------------------------------
    r.on 'organizations', Integer do |id|
      repo = OrganizationRepo.new
      organization = repo.find(id)

      # Check for notfound:
      r.on organization.nil? do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        begin
          if authorised?('masterfiles', 'edit')
            show_partial { Masterfiles::Parties::Organization::Edit.call(id) }
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
            show_partial { Masterfiles::Parties::Organization::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          begin
            response['Content-Type'] = 'application/json'
            res = OrganizationSchema.call(params[:organization])
            errors = res.messages
            if errors.empty?
              repo = OrganizationRepo.new
              repo.update(id, res)
              update_grid_row(id, changes: { party_id: res[:party_id], parent_id: res[:parent_id], short_description: res[:short_description], medium_description: res[:medium_description], long_description: res[:long_description], vat_number: res[:vat_number], variants: res[:variants], active: res[:active] },
                              notice:  "Updated #{res[:short_description]}")
            else
              content = show_partial { Masterfiles::Parties::Organization::Edit.call(id, params[:organization], errors) }
              update_dialog_content(content: content, error: 'Validation error')
            end
          rescue StandardError => e
            handle_json_error(e)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          repo = OrganizationRepo.new
          repo.delete(id)
          delete_grid_row(id, notice: 'Deleted')
        end
      end
    end
    r.on 'organizations' do
      r.on 'new' do    # NEW
        begin
          if authorised?('masterfiles', 'new')
            show_partial { Masterfiles::Parties::Organization::New.call }
          else
            dialog_permission_error
          end
        rescue StandardError => e
          dialog_error(e)
        end
      end
      r.post do        # CREATE
        res = OrganizationSchema.call(params[:organization])
        errors = res.messages
        # errors[:short_description] = []
        if OrganizationRepo.new.exists?(short_description: res[:short_description])
          errors[:short_description] ||= []
          errors[:short_description] << 'Dup'
        end
        if errors.empty?

          repo = OrganizationRepo.new
          repo.create_organization(res)
          flash[:notice] = 'Created'
          redirect_via_json_to_last_grid
        else
          content = show_partial { Masterfiles::Parties::Organization::New.call(params[:organization], errors) }
          update_dialog_content(content: content, error: 'Validation error')
        end
      end
    end
    # PARTIES
    # --------------------------------------------------------------------------
    r.on 'parties', Integer do |id|
      repo = PartyRepo.new
      party = repo.find(id)

      # Check for notfound:
      r.on party.nil? do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        begin
          if authorised?('masterfiles', 'edit')
            show_partial { Masterfiles::Parties::Party::Edit.call(id) }
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
            show_partial { Masterfiles::Parties::Party::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          begin
            response['Content-Type'] = 'application/json'
            res = PartySchema.call(params[:party])
            errors = res.messages
            if errors.empty?
              repo = PartyRepo.new
              repo.update(id, res)
              update_grid_row(id, changes: { party_type: res[:party_type], active: res[:active] },
                              notice:  "Updated #{res[:party_type]}")
            else
              content = show_partial { Masterfiles::Parties::Party::Edit.call(id, params[:party], errors) }
              update_dialog_content(content: content, error: 'Validation error')
            end
          rescue StandardError => e
            handle_json_error(e)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          repo = PartyRepo.new
          repo.delete(id)
          delete_grid_row(id, notice: 'Deleted')
        end
      end
    end
    r.on 'parties' do
      r.on 'new' do    # NEW
        begin
          if authorised?('masterfiles', 'new')
            show_partial { Masterfiles::Parties::Party::New.call }
          else
            dialog_permission_error
          end
        rescue StandardError => e
          dialog_error(e)
        end
      end
      r.post do        # CREATE
        res = PartySchema.call(params[:party])
        errors = res.messages
        if errors.empty?
          repo = PartyRepo.new
          repo.create(res)
          flash[:notice] = 'Created'
          redirect_via_json_to_last_grid
        else
          content = show_partial { Masterfiles::Parties::Party::New.call(params[:party], errors) }
          update_dialog_content(content: content, error: 'Validation error')
        end
      end
    end
    # PARTY ROLES
    # --------------------------------------------------------------------------
    r.on 'party_roles', Integer do |id|
      repo = PartyRoleRepo.new
      party_role = repo.find(id)

      # Check for notfound:
      r.on party_role.nil? do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        begin
          if authorised?('masterfiles', 'edit')
            show_partial { Masterfiles::Parties::PartyRole::Edit.call(id) }
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
            show_partial { Masterfiles::Parties::PartyRole::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          begin
            response['Content-Type'] = 'application/json'
            res = PartyRoleSchema.call(params[:party_role])
            errors = res.messages
            if errors.empty?
              repo = PartyRoleRepo.new
              repo.update(id, res)
              update_grid_row(id, changes: { party_id: res[:party_id], role_id: res[:role_id], organization_id: res[:organization_id], person_id: res[:person_id], active: res[:active] },
                              notice:  "Updated #{res[:id]}")
            else
              content = show_partial { Masterfiles::Parties::PartyRole::Edit.call(id, params[:party_role], errors) }
              update_dialog_content(content: content, error: 'Validation error')
            end
          rescue StandardError => e
            handle_json_error(e)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          repo = PartyRoleRepo.new
          repo.delete(id)
          delete_grid_row(id, notice: 'Deleted')
        end
      end
    end
    r.on 'party_roles' do
      r.on 'new' do    # NEW
        begin
          if authorised?('masterfiles', 'new')
            show_partial { Masterfiles::Parties::PartyRole::New.call }
          else
            dialog_permission_error
          end
        rescue StandardError => e
          dialog_error(e)
        end
      end
      r.post do        # CREATE
        res = PartyRoleSchema.call(params[:party_role])
        errors = res.messages
        if errors.empty?
          repo = PartyRoleRepo.new
          repo.create(res)
          flash[:notice] = 'Created'
          redirect_via_json_to_last_grid
        else
          content = show_partial { Masterfiles::Parties::PartyRole::New.call(params[:party_role], errors) }
          update_dialog_content(content: content, error: 'Validation error')
        end
      end
    end
    # PEOPLE
    # --------------------------------------------------------------------------
    r.on 'people', Integer do |id|
      repo = PersonRepo.new
      person = repo.find(id)

      # Check for notfound:
      r.on person.nil? do
        handle_not_found(r)
      end

      r.on 'edit' do   # EDIT
        begin
          if authorised?('masterfiles', 'edit')
            show_partial { Masterfiles::Parties::Person::Edit.call(id) }
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
            show_partial { Masterfiles::Parties::Person::Show.call(id) }
          else
            dialog_permission_error
          end
        end
        r.patch do     # UPDATE
          begin
            response['Content-Type'] = 'application/json'
            res = PersonSchema.call(params[:person])
            errors = res.messages
            if errors.empty?
              repo = PersonRepo.new
              repo.update(id, res)
              update_grid_row(id, changes: { party_id: res[:party_id], surname: res[:surname], first_name: res[:first_name], title: res[:title], vat_number: res[:vat_number], active: res[:active] },
                              notice:  "Updated #{res[:surname]}")
            else
              content = show_partial { Masterfiles::Parties::Person::Edit.call(id, params[:person], errors) }
              update_dialog_content(content: content, error: 'Validation error')
            end
          rescue StandardError => e
            handle_json_error(e)
          end
        end
        r.delete do    # DELETE
          response['Content-Type'] = 'application/json'
          repo = PersonRepo.new
          repo.delete(id)
          delete_grid_row(id, notice: 'Deleted')
        end
      end
    end
    r.on 'people' do
      r.on 'new' do    # NEW
        begin
          if authorised?('masterfiles', 'new')
            show_partial { Masterfiles::Parties::Person::New.call }
          else
            dialog_permission_error
          end
        rescue StandardError => e
          dialog_error(e)
        end
      end
      r.post do        # CREATE
        res = PersonSchema.call(params[:person])
        # update_dialog_content(content: 'AAAARGH')
        errors = res.messages
        if errors.empty?
          repo = PersonRepo.new
          repo.create(res)
          flash[:notice] = 'Created'
          redirect_via_json_to_last_grid
        else
          content = show_partial { Masterfiles::Parties::Person::New.call(params[:person], errors) }
          update_dialog_content(content: content, error: 'Validation error')
        end
      end
    end
  end
end
