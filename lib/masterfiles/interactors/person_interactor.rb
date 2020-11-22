# frozen_string_literal: true

module MasterfilesApp
  class PersonInteractor < BaseInteractor
    def create_person(params) # rubocop:disable Metrics/AbcSize
      res = validate_person_params(params)
      return validation_failed_response(res) if res.failure?

      response = nil
      repo.transaction do
        response = repo.create_person(res)
      end
      if response[:id]
        instance = person(response[:id])
        success_response("Created person #{instance.party_name}", instance)
      else
        validation_failed_response(OpenStruct.new(messages: response[:error]))
      end
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { person: ['This person already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_person(id, params) # rubocop:disable Metrics/AbcSize
      res = validate_person_params(params)
      return validation_failed_response(res) if res.failure?

      attrs = res.to_h
      role_ids = attrs.delete(:role_ids)
      roles_response = assign_person_roles(id, role_ids)
      if roles_response.success
        repo.transaction do
          repo.update_person(id, attrs)
        end
        instance = person(id)
        success_response("Updated person #{instance.party_name}, #{roles_response.message}", instance)
      else
        validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] }))
      end
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_person(id)
      name = person(id).party_name
      repo.transaction do
        repo.delete_person(id)
      end
      success_response("Deleted person #{name}")
    end

    def assign_person_roles(id, role_ids)
      return validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] })) if role_ids.empty?

      repo.transaction do
        repo.assign_roles(id, role_ids, 'P')
      end
      success_response('Roles assigned successfully')
    end

    private

    def repo
      @repo ||= PartyRepo.new
    end

    def person(id)
      repo.find_person(id)
    end

    def validate_person_params(params)
      PersonSchema.call(params)
    end
  end
end
