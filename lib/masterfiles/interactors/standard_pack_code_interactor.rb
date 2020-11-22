# frozen_string_literal: true

module MasterfilesApp
  class StandardPackCodeInteractor < BaseInteractor
    def create_standard_pack_code(params)
      res = validate_standard_pack_code_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_standard_pack_code(res)
      end
      instance = standard_pack_code(id)
      success_response("Created standard pack code #{instance.standard_pack_code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { standard_pack_code: ['This standard pack code already exists'] }))
    end

    def update_standard_pack_code(id, params)
      res = validate_standard_pack_code_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_standard_pack_code(id, res)
      end
      instance = standard_pack_code(id)
      success_response("Updated standard pack code #{instance.standard_pack_code}", instance)
    end

    def delete_standard_pack_code(id)
      name = standard_pack_code(id).standard_pack_code
      res = nil
      repo.transaction do
        res = repo.delete_standard_pack_code(id)
      end
      if res.success
        success_response("Deleted standard pack code #{name}")
      else
        failed_response(res.message)
      end
    end

    private

    def repo
      @repo ||= FruitSizeRepo.new
    end

    def standard_pack_code(id)
      repo.find_standard_pack_code_flat(id)
    end

    def validate_standard_pack_code_params(params)
      # StandardPackCodeSchema.call(params)
      contract = StandardPackCodeContract.new
      contract.call(params)
    end
  end
end
