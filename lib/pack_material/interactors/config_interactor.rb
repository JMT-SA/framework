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

    def update_matres_config(id, params)
      @id = id
      res = validate_matres_sub_type_config_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.update_matres_sub_type(id, res)
      success_response('Updated the config')
    end

    def chosen_product_columns(ids)
      code_items = repo.for_select_material_resource_product_columns(where: { is_variant_column: false }).select { |i| ids.include?(i[1]) }
      var_items = repo.for_select_material_resource_product_columns(where: { is_variant_column: true }).select { |i| ids.include?(i[1]) }
      success_response('got_items', code: code_items, var: var_items)
    end

    def convert_string_params_to_arrays(params)
      params.transform_values { |v| v.is_a?(String) ? v.split(',') : v }
    end

    def prep_params_for_nonvar_pcodes(params)
      { non_variant_product_code_column_ids: [] }.merge(convert_string_params_to_arrays(params))
    end

    def update_product_code_configuration(id, params)
      # TODO: see if we can manage the String => Array conversion in dry-validation...
      res = validate_material_resource_type_config_code_columns_params(prep_params_for_nonvar_pcodes(params))
      return validation_failed_response(res) unless res.messages.empty?

      DB.transaction do
        repo.update_product_code_configuration(id, res)
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

    def validate_matres_sub_type_config_params(params)
      MatresSubTypeConfigSchema.call(params)
    end

    def validate_material_resource_type_config_code_columns_params(params)
      MatresSubTypeConfigColumnsSchema.call(params)
    end
  end
end
