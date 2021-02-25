# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop#disable Metrics/AbcSize

module PackMaterialApp
  class ConfigInteractor < BaseInteractor
    def create_matres_type(params)
      res = validate_matres_type_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_matres_type(res)
      instance = matres_type(id)
      success_response("Created type #{instance.type_name}", instance)
    rescue Sequel::UniqueConstraintViolation
      # TODO: How do we respond with a double unique constraint?
      # I suspect we need to add 'This type already exists' to the form base error
      # And then type name:'must be unique'
      validation_failed_response(OpenStruct.new(messages: { type_name: ['This type already exists'], short_code: ['must be unique'] }))
    end

    def update_matres_type(id, params)
      res = validate_matres_type_params(params)
      return validation_failed_response(res) if res.failure?

      response = repo.update_matres_type(id, res)
      extra = response[:message] ? (', ' + response[:message]) : ''
      instance = matres_type(id)
      success_response("Updated type #{instance.type_name}#{extra}", instance)
    end

    def delete_matres_type(id)
      name = matres_type(id).type_name
      repo.delete_matres_type(id)
      success_response("Deleted type #{name}")
    end

    def create_matres_sub_type(params)
      res = validate_matres_sub_type_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_matres_sub_type(res)
      instance = matres_sub_type(id)
      success_response("Created sub type #{instance.sub_type_name}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { sub_type_name: ['This sub type already exists'], short_code: ['must be unique'] }))
    end

    def update_matres_sub_type(id, params)
      res = validate_matres_sub_type_params(params)
      return validation_failed_response(res) if res.failure?

      result = repo.update_matres_sub_type(id, res)
      if result.success
        instance = matres_sub_type(id)
        success_response("Updated sub type #{instance.sub_type_name}", instance)
      else
        result
      end
    end

    def delete_matres_sub_type(id)
      name = matres_sub_type(id).sub_type_name
      res = nil
      repo.transaction do
        res = repo.delete_matres_sub_type(id)
      end
      res.success ? success_response("Deleted sub type #{name}") : res
    end

    def update_matres_config(id, params)
      res = validate_matres_sub_type_params(params)
      return validation_failed_response(res) if res.failure?

      repo.update_matres_sub_type(id, res)
      success_response('Updated the config')
    end

    def chosen_product_columns(sub_type_id, ids)
      code_items, var_items = repo.product_code_column_options(sub_type_id, ids)
      success_response('got_items', code: code_items, variant: var_items)
    end

    def link_product_columns(sub_type_id, ids)
      repo.update_product_column_ids(sub_type_id, ids)
      chosen_product_columns(sub_type_id, [])
    end

    def update_product_code_configuration(id, params)
      res = validate_material_resource_type_config_code_columns_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_product_code_configuration(id, res)
      end
      success_response('Saved configuration')
    end

    def create_matres_master_list_item(sub_type_id, params)
      res = validate_matres_master_list_item_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_matres_sub_type_master_list_item(sub_type_id, res)
      end
      instance = matres_master_list_item(id)
      success_response("Created list item #{instance.short_code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { short_code: ['This list item already exists'] }))
    end

    def matres_sub_type_master_list_items(sub_type_id, product_column_id)
      items = repo.matres_sub_type_master_list_items(sub_type_id, product_column_id)
      items.map { |r| "#{r[:short_code]} #{r[:long_name] ? '- ' + r[:long_name] : ''}" }
    end

    def update_matres_master_list_item(id, params)
      res = validate_matres_master_list_item_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_matres_master_list_item(id, res)
      end
      instance = matres_master_list_item(id)
      success_response("Updated list item #{instance.short_code}", instance)
    end

    def delete_matres_master_list_item(sub_type_id, id)
      assert_permission!(:delete_master_list_item, sub_type_id)
      name = matres_master_list_item(id).short_code
      repo.delete_matres_master_list_item(id)
      success_response("Deleted master list item #{name}")
    rescue Crossbeams::TaskNotPermittedError => e
      failed_response(e.message)
    end

    def matres_sub_types_product_column_ids(sub_type_id)
      product_column_ids = repo.find_matres_sub_type(sub_type_id).product_column_ids || []
      if product_column_ids.any?
        success_response('Success', product_column_ids)
      else
        failed_response('No product columns selected, please see config.')
      end
    end

    private

    def repo
      @repo ||= ConfigRepo.new
    end

    def matres_type(id)
      repo.find_matres_type(id)
    end

    def validate_matres_type_params(params)
      MatresTypeSchema.call(params)
    end

    def matres_sub_type(id)
      repo.find_matres_sub_type(id)
    end

    def validate_matres_sub_type_params(params)
      MatresSubTypeSchema.call(params)
    end

    def validate_material_resource_type_config_code_columns_params(params)
      contract = MatresSubTypeConfigColumnsContract.new
      contract.call(params)
    end

    def matres_master_list_item(id)
      repo.find_matres_master_list_item(id)
    end

    def validate_matres_master_list_item_params(params)
      MatresMasterListItemSchema.call(params)
    end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::MatresSubType.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop#enable Metrics/AbcSize
