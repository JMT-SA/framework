# frozen_string_literal: true

module PackMaterialApp
  class MatresSubTypeInteractor < BaseInteractor
    
		def create_matres_type(params)
		  res = validate_matres_type_params(params)
		  return validation_failed_response(res) unless res.messages.empty?
      @id = repo.create_matres_type(res)
      success_response("Created matres type #{matres_type.type_name}",
                       matres_type)
		rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { type_name: ['This matres type already exists'] }))
		end

		def update_matres_type(id, params)
		  @id = id
      res = validate_matres_type_params(params)
		  return validation_failed_response(res) unless res.messages.empty?
      repo.update_matres_type(id, res)
      success_response("Updated matres type #{matres_type.type_name}",
                       matres_type(false))
		end

		def delete_matres_type(id)
		  @id = id
      name = matres_type.type_name
      repo.delete_matres_type(id)
      success_response("Deleted matres type #{name}")
		end

		private

		def repo
		  @repo ||= PackMaterialRepo.new
		end

    def matres_type(cached = true)
      if cached
        @matres_type ||= repo.find_matres_type(@id)
      else
        @matres_type = repo.find_matres_type(@id)
      end
    end

    def validate_matres_type_params(params)
      MatresTypeSchema.call(params)
    end

    def create_matres_sub_type(params)
      res = validate_matres_sub_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      @id = repo.create_matres_sub_type(res)
      success_response("Created matres sub type #{matres_sub_type.sub_type_name}",
                       matres_sub_type)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { sub_type_name: ['This matres sub type already exists'] }))
    end

    def update_matres_sub_type(id, params)
      @id = id
      res = validate_matres_sub_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.update_matres_sub_type(id, res)
      success_response("Updated matres sub type #{matres_sub_type.sub_type_name}",
                       matres_sub_type(false))
    end

    def delete_matres_sub_type(id)
      @id = id
      name = matres_sub_type.sub_type_name
      repo.delete_matres_sub_type(id)
      success_response("Deleted matres sub type #{name}")
    end

		private

		def repo
      @repo ||= MatresSubTypeRepo.new
    end

    def matres_sub_type(cached = true)
      if cached
        @matres_sub_type ||= repo.find_matres_sub_type(@id)
      else
        @matres_sub_type = repo.find_matres_sub_type(@id)
      end
    end

    def validate_matres_sub_type_params(params)
      MatresSubTypeSchema.call(params)
    end

  end
end
