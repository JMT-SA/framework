# frozen_string_literal: true

module MasterfilesApp
  class AddressInteractor < BaseInteractor
    def create_address(params)
      res = validate_address_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      @address_id = party_repo.create_address(res)
      success_response("Created address #{address.address_line_1}", address)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { address_line_1: ['This address already exists'] }))
    end

    def update_address(id, params)
      @address_id = id
      res = validate_address_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      party_repo.update_address(id, res)
      success_response("Updated address #{address.address_line_1}", address(false))
    end

    def delete_address(id)
      @address_id = id
      name = address.address_line_1
      party_repo.delete_address(id)
      success_response("Deleted address #{name}")
    end

    private

    def party_repo
      @party_repo ||= PartyRepo.new
    end

    def address(cached = true)
      if cached
        @address ||= party_repo.find_address(@address_id)
      else
        @address = party_repo.find_address(@address_id)
      end
    end

    def validate_address_params(params)
      AddressSchema.call(params)
    end
  end
end
