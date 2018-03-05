# frozen_string_literal: true

module PackMaterialApp
  class MaterialResourceInteractor < BaseInteractor

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
    #
    # def create_material_resource_sub_type(params)
    #   res = validate_material_resource_sub_type_params(params)
    #   return validation_failed_response(res) unless res.messages.empty?
    #   @id = repo.create_material_resource_sub_type(res)
    #   success_response("Created material resource sub type #{material_resource_sub_type.sub_type_name}",
    #                    material_resource_sub_type)
    # rescue Sequel::UniqueConstraintViolation
    #   validation_failed_response(OpenStruct.new(messages: { sub_type_name: ['This material resource sub type already exists'] }))
    # end
    #
    # def update_material_resource_sub_type(id, params)
    #   @id = id
    #   res = validate_material_resource_sub_type_params(params)
    #   return validation_failed_response(res) unless res.messages.empty?
    #   repo.update_material_resource_sub_type(id, res)
    #   success_response("Updated material resource sub type #{material_resource_sub_type.sub_type_name}",
    #                    material_resource_sub_type(false))
    # end
    #
    # def delete_material_resource_sub_type(id)
    #   @id = id
    #   name = material_resource_sub_type.sub_type_name
    #   DB.transaction do
    #     repo.delete_material_resource_sub_type(id)
    #   end
    #   success_response("Deleted material resource sub type #{name}")
    # end
    #
    # def update_material_resource_type_config(id, params)
    #   @id = id
    #   res = validate_material_resource_type_config_params(params)
    #   return validation_failed_response(res) unless res.messages.empty?
    #   repo.update_material_resource_type_config(id, res)
    #   success_response("Updated config successfully", material_resource_type_config(false))
    # end
    #
    # def link_mr_product_columns(id, product_column_ids)
    #   DB.transaction do
    #     repo.link_mr_product_columns(id, product_column_ids)
    #   end
    #
    #   config = repo.find_material_resource_type_config(id)
    #   sub_type = repo.find_material_resource_sub_type(config.material_resource_sub_type_id)
    #   p "SUB TYPE in interactor"
    #   existing_ids = repo.mr_type_mr_product_column_ids(id)
    #   if existing_ids.eql?(product_column_ids.sort)
    #     success_response('Product columns linked successfully', sub_type)
    #   else
    #     failed_response('Some product columns were not linked', sub_type)
    #   end
    # end
    #
    # def link_mr_product_code_columns(id, product_code_column_ids)
    #   DB.transaction do
    #     repo.link_mr_product_code_columns(id, product_code_column_ids)
    #   end
    #
    #   config = repo.find_material_resource_type_config(id)
    #   sub_type = repo.find_material_resource_sub_type(config.material_resource_sub_type_id)
    #   p "SUB TYPE in interactor"
    #   existing_ids = repo.mr_type_mr_product_code_column_ids(id)
    #   if existing_ids.eql?(product_code_column_ids.sort)
    #     success_response('Product code columns linked successfully', sub_type)
    #   else
    #     failed_response('Some product code columns were not linked', sub_type)
    #   end
    # end
    #
    # def reorder_product_code_columns(id, sorted_product_code_column_ids)
    #   DB.transaction do
    #     repo.reorder_product_code_columns(id, sorted_product_code_column_ids)
    #   end
    #   success_response('Product code columns reordered')
    # end

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

    # def material_resource_sub_type(cached = true)
    #   if cached
    #     @material_resource_sub_type ||= repo.find_material_resource_sub_type(@id)
    #   else
    #     @material_resource_sub_type = repo.find_material_resource_sub_type(@id)
    #   end
    # end
    #
    # def validate_material_resource_sub_type_params(params)
    #   MaterialResourceSubTypeSchema.call(params)
    # end
    #
    # def material_resource_type_config(cached = true)
    #   if cached
    #     @material_resource_type_config ||= repo.find_material_resource_type_config(@id)
    #   else
    #     @material_resource_type_config = repo.find_material_resource_type_config(@id)
    #   end
    # end
    #
    # def validate_material_resource_type_config_params(params)
    #   MaterialResourceTypeConfigSchema.call(params)
    # end

  end
end