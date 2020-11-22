# frozen_string_literal: true

module DevelopmentApp
  class ContactMethodTypeInteractor < BaseInteractor
    def repo
      @repo ||= ContactMethodTypeRepo.new
    end

    def contact_method_type(id)
      repo.find_contact_method_type(id)
    end

    def validate_contact_method_type_params(params)
      ContactMethodTypeSchema.call(params)
    end

    def create_contact_method_type(params)
      res = validate_contact_method_type_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_contact_method_type(res)
      end
      instance = contact_method_type(id)
      success_response("Created contact method type #{instance.contact_method_type}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { contact_method_type: ['This contact method type already exists'] }))
    end

    def update_contact_method_type(id, params)
      res = validate_contact_method_type_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_contact_method_type(id, res)
      end
      instance = contact_method_type(id)
      success_response("Updated contact method type #{instance.contact_method_type}", instance)
    end

    def delete_contact_method_type(id)
      name = contact_method_type(id).contact_method_type
      repo.transaction do
        repo.delete_contact_method_type(id)
      end
      success_response("Deleted contact method type #{name}")
    end
  end
end
