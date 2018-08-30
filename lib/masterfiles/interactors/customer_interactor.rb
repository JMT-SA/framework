# frozen_string_literal: true

module MasterfilesApp
  class CustomerInteractor < BaseInteractor
    def create_customer(params)
      res = validate_new_customer_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      DB.transaction do
        id = repo.create_customer(res)
        log_transaction
      end
      instance = customer(id)
      success_response("Created customer #{instance.erp_customer_number}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { erp_customer_number: ['This customer already exists'] }))
    end

    def update_customer(id, params)
      res = validate_edit_customer_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      DB.transaction do
        repo.update_customer(id, res)
        log_transaction
      end
      instance = customer(id)
      success_response("Updated customer #{instance.erp_customer_number}",
                       instance)
    end

    def delete_customer(id)
      name = customer(id).erp_customer_number
      DB.transaction do
        repo.delete_customer(id)
        log_transaction
      end
      success_response("Deleted customer #{name}")
    end

    private

    def repo
      @repo ||= PartyRepo.new
    end

    def customer(id)
      repo.find_customer(id)
    end

    def validate_new_customer_params(params)
      NewCustomerSchema.call(params)
    end

    def validate_edit_customer_params(params)
      EditCustomerSchema.call(params)
    end
  end
end
