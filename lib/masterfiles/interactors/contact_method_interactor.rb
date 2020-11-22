# frozen_string_literal: true

module MasterfilesApp
  class ContactMethodInteractor < BaseInteractor
    def create_contact_method(params)
      res = validate_contact_method_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_contact_method(res)
      instance = contact_method(id)
      success_response("Created contact method #{instance.contact_method_code}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { contact_method_code: ['This contact method already exists'] }))
    end

    def update_contact_method(id, params)
      res = validate_contact_method_params(params)
      return validation_failed_response(res) if res.failure?

      repo.update_contact_method(id, res)
      instance = contact_method(id)
      success_response("Updated contact method #{instance.contact_method_code}",
                       instance)
    end

    def delete_contact_method(id)
      name = contact_method(id).contact_method_code
      repo.delete_contact_method(id)
      success_response("Deleted contact method #{name}")
    end

    private

    def repo
      @repo ||= PartyRepo.new
    end

    def contact_method(id)
      repo.find_contact_method(id)
    end

    def validate_contact_method_params(params)
      ContactMethodSchema.call(params)
    end
  end
end
