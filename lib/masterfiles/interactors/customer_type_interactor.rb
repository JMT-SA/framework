# frozen_string_literal: true

module MasterfilesApp
  class CustomerTypeInteractor < BaseInteractor
    def create_customer_type(params)
      res = validate_customer_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      DB.transaction do
        id = repo.create_customer_type(res)
      end
      instance = customer_type(id)
      success_response("Created customer type #{instance.type_code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { type_code: ['This customer type already exists'] }))
    end

    def update_customer_type(id, params)
      res = validate_customer_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      DB.transaction do
        repo.update_customer_type(id, res)
      end
      instance = customer_type(id)
      success_response("Updated customer type #{instance.type_code}", instance)
    end

    def delete_customer_type(id)
      name = customer_type(id).type_code
      DB.transaction do
        repo.delete_customer_type(id)
      end
      success_response("Deleted customer type #{name}")
    end

    private

    def repo
      @repo ||= PartyRepo.new
    end

    def customer_type(id)
      repo.find_customer_type(id)
    end

    def validate_customer_type_params(params)
      CustomerTypeSchema.call(params)
    end
  end
end
