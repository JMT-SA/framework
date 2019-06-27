# frozen_string_literal: true

# rubocop#:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module MasterfilesApp
  class SupplierInteractor < BaseInteractor
    def create_supplier(params)
      res = validate_new_supplier_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      result = nil
      DB.transaction do
        result = repo.create_supplier(res)
        log_transaction
      end
      if result[:success]
        instance = supplier(result[:id])
        success_response("Created supplier #{instance.party_name}", instance)
      else
        validation_failed_response(OpenStruct.new(messages: result[:error]))
      end
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { erp_supplier_number: ['This supplier already exists'] }))
    end

    def update_supplier(id, params)
      res = validate_edit_supplier_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      result = nil
      DB.transaction do
        result = repo.update_supplier(id, res)
        log_transaction
      end
      if result[:success]
        instance = supplier(result[:id])
        success_response("Updated supplier #{instance.party_name}", instance)
      else
        validation_failed_response(OpenStruct.new(messages: result[:error]))
      end
    end

    def delete_supplier(id)
      name = supplier(id).party_name
      DB.transaction do
        repo.delete_supplier(id)
        log_transaction
      end
      success_response("Deleted supplier #{name}")
    end

    private

    def repo
      @repo ||= PartyRepo.new
    end

    def supplier(id)
      repo.find_supplier(id)
    end

    def validate_new_supplier_params(params)
      NewSupplierSchema.call(params)
    end

    def validate_edit_supplier_params(params)
      EditSupplierSchema.call(params)
    end
  end
end
# rubocop#:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
