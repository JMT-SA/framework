# frozen_string_literal: true

module PackMaterialApp
  class ConfigInteractor < BaseInteractor
    def create_matres_type(params)
      res = validate_matres_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      @matres_type_id = repo.create_matres_type(res)
      success_response("Created type #{matres_type.type_name}", matres_type)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { type_name: ['This type already exists'] }))
    end

    def update_matres_type(id, params)
      @matres_type_id = id
      res = validate_matres_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.update_matres_type(id, res)
      success_response("Updated type #{matres_type.type_name}", matres_type(false))
    end

    def delete_matres_type(id)
      @matres_type_id = id
      name = matres_type.type_name
      repo.delete_matres_type(id)
      success_response("Deleted type #{name}")
    end

    def add_a_matres_unit(id, params)
      if params && params[:unit_of_measure] == 'other'
        create_matres_unit(id, params)
      else
        add_matres_unit(id, params)
      end
    end

    def create_matres_unit(matres_type_id, params)
      params[:unit_of_measure] = params[:other]
      res = validate_matres_unit_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.create_matres_type_unit(matres_type_id, res[:unit_of_measure])
      success_response("Created unit #{res[:unit_of_measure]}")
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { other: ['This unit already exists'] }))
    end

    def add_matres_unit(matres_type_id, params)
      repo.add_matres_type_unit(matres_type_id, params[:unit_of_measure])
      @matres_type_id = matres_type_id
      success_response("Unit was added to #{matres_type.type_name}", matres_type(false))
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { unit_of_measure: ['This unit is already assigned'] }))
    end

    def create_matres_sub_type(params)
      res = validate_matres_sub_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      @matres_sub_type_id = repo.create_matres_sub_type(res)
      success_response("Created sub type #{matres_sub_type.sub_type_name}", matres_sub_type)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { sub_type_name: ['This sub type already exists'] }))
    end

    def update_matres_sub_type(id, params)
      @matres_sub_type_id = id
      res = validate_matres_sub_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.update_matres_sub_type(id, res)
      success_response("Updated sub type #{matres_sub_type.sub_type_name}", matres_sub_type(false))
    end

    def delete_matres_sub_type(id)
      @matres_sub_type_id = id
      name = matres_sub_type.sub_type_name
      res = nil
      DB.transaction do
        res = repo.delete_matres_sub_type(id)
      end
      res.success ? success_response("Deleted sub type #{name}") : res
    end

    def update_matres_config(id, params)
      @matres_sub_type_id = id
      res = validate_matres_sub_type_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.update_matres_sub_type(id, res)
      success_response('Updated the config')
    end

    def chosen_product_columns(ids)
      code_items = repo.product_code_column_subset(ids)
      success_response('got_items', code: code_items)
    end

    def update_product_code_configuration(id, params)
      res = validate_material_resource_type_config_code_columns_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      DB.transaction do
        repo.update_product_code_configuration(id, res)
      end
      success_response('Saved configuration')
    end

    def create_matres_master_list_item(sub_type_id, params)
      res = validate_matres_master_list_item_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      DB.transaction do
        id = repo.create_matres_sub_type_master_list_item(sub_type_id, res)
      end
      instance = matres_master_list_item(id)
      success_response("Created list item #{instance.short_code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { short_code: ['This list item already exists'] }))
    end

    def update_matres_master_list_item(id, params)
      res = validate_matres_master_list_item_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      DB.transaction do
        repo.update_matres_master_list_item(id, res)
      end
      instance = matres_master_list_item(id)
      success_response("Updated list item #{instance.short_code}", instance)
    end

    private

    def repo
      @repo ||= ConfigRepo.new
    end

    def matres_type(cached = true)
      if cached
        @matres_type ||= repo.find_matres_type(@matres_type_id)
      else
        @matres_type = repo.find_matres_type(@matres_type_id)
      end
    end

    def validate_matres_type_params(params)
      MatresTypeSchema.call(params)
    end

    def validate_matres_unit_params(params)
      MatresTypeUnitSchema.call(params)
    end

    def matres_sub_type(cached = true)
      if cached
        @matres_sub_type ||= repo.find_matres_sub_type(@matres_sub_type_id)
      else
        @matres_sub_type = repo.find_matres_sub_type(@matres_sub_type_id)
      end
    end

    def validate_matres_sub_type_params(params)
      MatresSubTypeSchema.call(params)
    end

    def validate_material_resource_type_config_code_columns_params(params)
      MatresSubTypeConfigColumnsSchema.call(params)
    end

    def matres_master_list_item(id)
      repo.find_matres_master_list_item(id)
    end

    def validate_matres_master_list_item_params(params)
      MatresMasterListItemSchema.call(params)
    end
  end
end
