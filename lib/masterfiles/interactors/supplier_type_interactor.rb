# frozen_string_literal: true

module MasterfilesApp
  class SupplierTypeInteractor < BaseInteractor
    def create_supplier_type(params)
      res = validate_supplier_type_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_supplier_type(res)
      end
      instance = supplier_type(id)
      success_response("Created supplier type #{instance.type_code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { type_code: ['This supplier type already exists'] }))
    end

    def update_supplier_type(id, params)
      res = validate_supplier_type_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_supplier_type(id, res)
      end
      instance = supplier_type(id)
      success_response("Updated supplier type #{instance.type_code}", instance)
    end

    def delete_supplier_type(id)
      name = supplier_type(id).type_code
      repo.transaction do
        repo.delete_supplier_type(id)
      end
      success_response("Deleted supplier type #{name}")
    end

    private

    def repo
      @repo ||= PartyRepo.new
    end

    def supplier_type(id)
      repo.find_supplier_type(id)
    end

    def validate_supplier_type_params(params)
      SupplierTypeSchema.call(params)
    end
  end
end
