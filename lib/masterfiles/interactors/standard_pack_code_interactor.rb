# frozen_string_literal: true

module MasterfilesApp
  class StandardPackCodeInteractor < BaseInteractor
    def fruit_size_repo
      @fruit_size_repo ||= FruitSizeRepo.new
    end

    def standard_pack_code(cached = true)
      if cached
        @standard_pack_code ||= fruit_size_repo.find_standard_pack_code(@id)
      else
        @standard_pack_code = fruit_size_repo.find_standard_pack_code(@id)
      end
    end

    def validate_standard_pack_code_params(params)
      StandardPackCodeSchema.call(params)
    end

    def create_standard_pack_code(params)
      res = validate_standard_pack_code_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      @id = fruit_size_repo.create_standard_pack_code(res)
      success_response("Created standard pack code #{standard_pack_code.standard_pack_code}", standard_pack_code)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { standard_pack_code: ['This standard pack code already exists'] }))
    end

    def update_standard_pack_code(id, params)
      @id = id
      res = validate_standard_pack_code_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      fruit_size_repo.update_standard_pack_code(id, res)
      success_response("Updated standard pack code #{standard_pack_code.standard_pack_code}", standard_pack_code(false))
    end

    def delete_standard_pack_code(id)
      @id = id
      name = standard_pack_code.standard_pack_code
      fruit_size_repo.delete_standard_pack_code(id)
      success_response("Deleted standard pack code #{name}")
    end
  end
end
