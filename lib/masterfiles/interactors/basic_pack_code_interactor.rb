# frozen_string_literal: true

module MasterfilesApp
  class BasicPackCodeInteractor < BaseInteractor
    def fruit_size_repo
      @fruit_size_repo ||= FruitSizeRepo.new
    end

    def basic_pack_code(cached = true)
      if cached
        @basic_pack_code ||= fruit_size_repo.find_basic_pack_code(@id)
      else
        @basic_pack_code = fruit_size_repo.find_basic_pack_code(@id)
      end
    end

    def validate_basic_pack_code_params(params)
      BasicPackCodeSchema.call(params)
    end

    def create_basic_pack_code(params)
      res = validate_basic_pack_code_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      @id = fruit_size_repo.create_basic_pack_code(res)
      success_response("Created basic pack code #{basic_pack_code.basic_pack_code}",
                       basic_pack_code)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { basic_pack_code: ['This basic pack code already exists'] }))
    end

    def update_basic_pack_code(id, params)
      @id = id
      res = validate_basic_pack_code_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      fruit_size_repo.update_basic_pack_code(id, res)
      success_response("Updated basic pack code #{basic_pack_code.basic_pack_code}",
                       basic_pack_code(false))
    end

    def delete_basic_pack_code(id)
      @id = id
      name = basic_pack_code.basic_pack_code
      fruit_size_repo.delete_basic_pack_code(id)
      success_response("Deleted basic pack code #{name}")
    end
  end
end
