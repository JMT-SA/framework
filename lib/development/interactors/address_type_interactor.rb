# frozen_string_literal: true

module DevelopmentApp
  class AddressTypeInteractor < BaseInteractor
    def repo
      @repo ||= AddressTypeRepo.new
    end

    def address_type(id)
      repo.find_address_type(id)
    end

    def validate_address_type_params(params)
      AddressTypeSchema.call(params)
    end

    def create_address_type(params)
      res = validate_address_type_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_address_type(res)
      end
      instance = address_type(id)
      success_response("Created address type #{instance.address_type}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { address_type: ['This address type already exists'] }))
    end

    def update_address_type(id, params)
      res = validate_address_type_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_address_type(id, res)
      end
      instance = address_type(id)
      success_response("Updated address type #{instance.address_type}", instance)
    end

    def delete_address_type(id)
      name = address_type(id).address_type
      repo.transaction do
        repo.delete_address_type(id)
      end
      success_response("Deleted address type #{name}")
    end
  end
end
