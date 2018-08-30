# frozen_string_literal: true

module MasterfilesApp
  class SupplierInteractor < BaseInteractor
    def create_supplier(params)
      res = validate_new_supplier_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      DB.transaction do
        id = repo.create_supplier(res)
        log_transaction
      end
      instance = supplier(id)
      success_response("Created supplier #{instance.erp_supplier_number}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { erp_supplier_number: ['This supplier already exists'] }))
    end

    def update_supplier(id, params)
      res = validate_edit_supplier_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      DB.transaction do
        repo.update_supplier(id, res)
        log_transaction
      end
      instance = supplier(id)
      success_response("Updated supplier #{instance.erp_supplier_number}", instance)
    end

    def delete_supplier(id)
      name = supplier(id).erp_supplier_number
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
