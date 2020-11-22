# frozen_string_literal: true

module MasterfilesApp
  class AddressInteractor < BaseInteractor
    def create_address(params)
      res = validate_address_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_address(res)
      instance = address(id)
      success_response("Created address #{instance.address_line_1}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { address_line_1: ['This address already exists'] }))
    end

    def update_address(id, params)
      @address_id = id
      res = validate_address_params(params)
      return validation_failed_response(res) if res.failure?

      repo.update_address(id, res)
      instance = address(id)
      success_response("Updated address #{instance.address_line_1}", instance)
    end

    def delete_address(id)
      name = address(id).address_line_1
      repo.delete_address(id)
      success_response("Deleted address #{name}")
    end

    private

    def repo
      @repo ||= PartyRepo.new
    end

    def address(id)
      repo.find_address(id)
    end

    def validate_address_params(params)
      AddressSchema.call(params)
    end
  end
end
