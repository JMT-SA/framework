# frozen_string_literal: true

module MasterfilesApp
  class BasicPackCodeInteractor < BaseInteractor
    def repo
      @repo ||= FruitSizeRepo.new
    end

    def basic_pack_code(id)
      repo.find_basic_pack_code(id)
    end

    def validate_basic_pack_code_params(params)
      BasicPackCodeSchema.call(params)
    end

    def create_basic_pack_code(params)
      res = validate_basic_pack_code_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      id = repo.create_basic_pack_code(res)
      instance = basic_pack_code(id)
      success_response("Created basic pack code #{instance.basic_pack_code}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { basic_pack_code: ['This basic pack code already exists'] }))
    end

    def update_basic_pack_code(id, params)
      @id = id
      res = validate_basic_pack_code_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.update_basic_pack_code(id, res)
      instance = basic_pack_code(id)
      success_response("Updated basic pack code #{instance.basic_pack_code}",
                       instance)
    end

    def delete_basic_pack_code(id)
      name = basic_pack_code(id).basic_pack_code
      res = {}
      repo.transaction do
        res = repo.delete_basic_pack_code(id)
      end
      if res[:error]
        failed_response(res[:error])
      else
        success_response("Deleted basic pack code #{name}")
      end
    end
  end
end
