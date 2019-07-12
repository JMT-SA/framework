# frozen_string_literal: true

module MasterfilesApp
  class StandardPackCodeInteractor < BaseInteractor
    def repo
      @repo ||= FruitSizeRepo.new
    end

    def standard_pack_code(id)
      repo.find_standard_pack_code(id)
    end

    def validate_standard_pack_code_params(params)
      StandardPackCodeSchema.call(params)
    end

    def create_standard_pack_code(params)
      res = validate_standard_pack_code_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      id = repo.create_standard_pack_code(res)
      instance = standard_pack_code(id)
      success_response("Created standard pack code #{instance.standard_pack_code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { standard_pack_code: ['This standard pack code already exists'] }))
    end

    def update_standard_pack_code(id, params)
      res = validate_standard_pack_code_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.update_standard_pack_code(id, res)
      instance = standard_pack_code(id)
      success_response("Updated standard pack code #{instance.standard_pack_code}", instance)
    end

    def delete_standard_pack_code(id)
      name = standard_pack_code(id).standard_pack_code
      res = {}
      repo.transaction do
        res = repo.delete_standard_pack_code(id)
      end
      if res[:error]
        failed_response(res[:error])
      else
        success_response("Deleted standard pack code #{name}")
      end
    end
  end
end
