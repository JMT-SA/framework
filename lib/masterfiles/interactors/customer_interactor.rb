# frozen_string_literal: true

# rubocop#:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module MasterfilesApp
  class CustomerInteractor < BaseInteractor
    def create_customer(params)
      res = validate_new_customer_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      result = nil
      repo.transaction do
        result = repo.create_customer(res)
        log_transaction
      end
      if result[:success]
        instance = customer(result[:id])
        success_response("Created customer #{instance.party_name}", instance)
      else
        validation_failed_response(OpenStruct.new(messages: result[:error]))
      end
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { erp_customer_number: ['This customer already exists'] }))
    end

    def update_customer(id, params)
      res = validate_edit_customer_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      result = nil
      repo.transaction do
        result = repo.update_customer(id, res)
        log_transaction
      end
      if result[:success]
        instance = customer(result[:id])
        success_response("Updated customer #{instance.party_name}", instance)
      else
        validation_failed_response(OpenStruct.new(messages: result[:error]))
      end
    end

    def delete_customer(id)
      name = customer(id).party_name
      repo.transaction do
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
# rubocop#:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
