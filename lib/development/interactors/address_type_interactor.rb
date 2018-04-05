# frozen_string_literal: true

module DevelopmentApp
  class AddressTypeInteractor < BaseInteractor
    def repo
      @repo ||= AddressTypeRepo.new
    end

    def address_type(cached = true)
      if cached
        @address_type ||= repo.find_address_type(@id)
      else
        @address_type = repo.find_address_type(@id)
      end
    end

    def validate_address_type_params(params)
      AddressTypeSchema.call(params)
    end

    def create_address_type(params)
      res = validate_address_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      @id = repo.create_address_type(res)
      success_response("Created address type #{address_type.address_type}",
                       address_type)
    end

    def update_address_type(id, params)
      @id = id
      res = validate_address_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.update_address_type(id, res)
      success_response("Updated address type #{address_type.address_type}",
                       address_type(false))
    end

    def delete_address_type(id)
      @id = id
      name = address_type.address_type
      repo.delete_address_type(id)
      success_response("Deleted address type #{name}")
    end
  end
end
