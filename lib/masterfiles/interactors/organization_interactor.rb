# frozen_string_literal: true

# rubocop#:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module MasterfilesApp
  class OrganizationInteractor < BaseInteractor
    def create_organization(params)
      res = validate_organization_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      response = nil
      party_repo.transaction do
        response = party_repo.create_organization(res)
      end
      if response[:id]
        @organization_id = response[:id]
        success_response("Created organization #{organization.party_name}", organization)
      else
        validation_failed_response(OpenStruct.new(messages: response[:error]))
      end
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { short_description: ['This organization already exists'] }))
    end

    def update_organization(id, params)
      @organization_id = id
      res = validate_organization_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      attrs = res.to_h
      role_ids = attrs.delete(:role_ids)
      roles_response = assign_organization_roles(id, role_ids)
      if roles_response.success
        party_repo.transaction do
          party_repo.update_organization(id, attrs)
        end
        success_response("Updated organization #{organization.party_name}, #{roles_response.message}", organization(false))
      else
        validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] }))
      end
    end

    def delete_organization(id)
      @organization_id = id
      name = organization.party_name
      response = nil
      party_repo.transaction do
        response = party_repo.delete_organization(id)
      end
      if response[:success]
        success_response("Deleted organization #{name}")
      else
        validation_failed_response(OpenStruct.new(messages: response[:error]))
      end
    end

    def assign_organization_roles(id, role_ids)
      return validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] })) if role_ids.empty?
      party_repo.transaction do
        party_repo.assign_roles(id, role_ids, 'O')
      end
      success_response('Roles assigned successfully')
    end

    private

    def party_repo
      @party_repo ||= PartyRepo.new
    end

    def organization(cached = true)
      if cached
        @organization ||= party_repo.find_organization(@organization_id)
      else
        @organization = party_repo.find_organization(@organization_id)
      end
    end

    def validate_organization_params(params)
      OrganizationSchema.call(params)
    end
  end
end
# rubocop#:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
