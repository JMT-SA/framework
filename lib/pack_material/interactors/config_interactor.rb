# frozen_string_literal: true

module PackMaterialApp
  class ConfigInteractor < BaseInteractor

    def create_matres_type(params)
      res = validate_matres_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      @id = repo.create_matres_type(res)
      success_response("Created type #{matres_type.type_name}", matres_type)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { type_name: ['This type already exists'] }))
    end

    def update_matres_type(id, params)
      @id = id
      res = validate_matres_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.update_matres_type(id, res)
      success_response("Updated type #{matres_type.type_name}", matres_type(false))
    end

    def delete_matres_type(id)
      @id = id
      name = matres_type.type_name
      repo.delete_matres_type(id)
      success_response("Deleted type #{name}")
    end

    def create_matres_sub_type(params)
      res = validate_matres_sub_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      @id = repo.create_matres_sub_type(res)
      success_response("Created sub type #{matres_sub_type.sub_type_name}", matres_sub_type)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { sub_type_name: ['This sub type already exists'] }))
    end

    def update_matres_sub_type(id, params)
      @id = id
      res = validate_matres_sub_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.update_matres_sub_type(id, res)
      success_response("Updated sub type #{matres_sub_type.sub_type_name}", matres_sub_type(false))
    end

    def delete_matres_sub_type(id)
      @id = id
      name = matres_sub_type.sub_type_name
      DB.transaction do
        repo.delete_matres_sub_type(id)
      end
      success_response("Deleted sub type #{name}")
    end

    def link_product_columns(id, col_ids)
      DB.transaction do
        repo.link_product_columns(id, col_ids)
      end

      config = repo.find_matres_config(id)
      sub_type = repo.find_matres_sub_type(config.material_resource_sub_type_id)
      existing_ids = repo.type_product_column_ids(id)
      if existing_ids.eql?(col_ids.sort)
        success_response('Product columns linked successfully', sub_type)
      else
        failed_response('Some product columns were not linked', sub_type)
      end
    end

    private

    def repo
      @repo ||= ConfigRepo.new
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