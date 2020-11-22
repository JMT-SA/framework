# frozen_string_literal: true

# rubocop#:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module MasterfilesApp
  class OrganizationInteractor < BaseInteractor
    def create_organization(params)
      res = validate_organization_params(params)
      return validation_failed_response(res) if res.failure?

      response = nil
      repo.transaction do
        response = repo.create_organization(res)
      end
      if response[:id]
        id = response[:id]
        instance = organization(id)
        success_response("Created organization #{instance.party_name}", instance)
      else
        validation_failed_response(OpenStruct.new(messages: response[:error]))
      end
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { short_description: ['This organization already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_organization(id, params)
      res = validate_organization_params(params)
      return validation_failed_response(res) if res.failure?

      attrs = res.to_h
      role_ids = attrs.delete(:role_ids)
      roles_response = assign_organization_roles(id, role_ids)
      if roles_response.success
        repo.transaction do
          repo.update_organization(id, attrs)
        end
        instance = organization(id)
        success_response("Updated organization #{instance.party_name}, #{roles_response.message}", instance)
      else
        validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] }))
      end
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_organization(id)
      name = organization(id).party_name
      response = nil
      repo.transaction do
        response = repo.delete_organization(id)
      end
      if response[:success]
        success_response("Deleted organization #{name}")
      else
        validation_failed_response(OpenStruct.new(messages: response[:error]))
      end
    rescue Sequel::ForeignKeyConstraintViolation => e
      failed_response("Unable to delete organization. Still referenced #{e.message.partition('referenced').last}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def assign_organization_roles(id, role_ids)
      return validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] })) if role_ids.empty?

      repo.transaction do
        repo.assign_roles(id, role_ids, 'O')
      end
      success_response('Roles assigned successfully')
    end

    private

    def repo
      @repo ||= PartyRepo.new
    end

    def organization(id)
      repo.find_organization(id)
    end

    def validate_organization_params(params)
      OrganizationSchema.call(params)
    end
  end
end
# rubocop#:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
