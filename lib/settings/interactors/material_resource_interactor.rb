# frozen_string_literal: true

class MaterialResourceInteractor < BaseInteractor

  def create_material_resource_type(params)
    res = validate_material_resource_type_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @id = repo.create_material_resource_type(res)
    success_response("Created material resource type #{material_resource_type.type_name}",
                     material_resource_type)
  rescue Sequel::UniqueConstraintViolation
    validation_failed_response(OpenStruct.new(messages: { type_name: ['This material resource type already exists'] }))
  end

  def update_material_resource_type(id, params)
    @id = id
    res = validate_material_resource_type_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    repo.update_material_resource_type(id, res)
    success_response("Updated material resource type #{material_resource_type.type_name}",
                     material_resource_type(false))
  end

  def delete_material_resource_type(id)
    @id = id
    name = material_resource_type.type_name
    repo.delete_material_resource_type(id)
    success_response("Deleted material resource type #{name}")
  end

  def create_material_resource_sub_type(params)
    res = validate_material_resource_sub_type_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @id = repo.create_material_resource_sub_type(res)
    success_response("Created material resource sub type #{material_resource_sub_type.sub_type_name}",
                     material_resource_sub_type)
  rescue Sequel::UniqueConstraintViolation
    validation_failed_response(OpenStruct.new(messages: { sub_type_name: ['This material resource sub type already exists'] }))
  end

  def update_material_resource_sub_type(id, params)
    @id = id
    res = validate_material_resource_sub_type_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    repo.update_material_resource_sub_type(id, res)
    success_response("Updated material resource sub type #{material_resource_sub_type.sub_type_name}",
                     material_resource_sub_type(false))
  end

  def delete_material_resource_sub_type(id)
    @id = id
    name = material_resource_sub_type.sub_type_name
    DB.transaction do
      repo.delete_material_resource_sub_type(id)
    end
    success_response("Deleted material resource sub type #{name}")
  end

  def update_material_resource_type_config(id, params)
    @id = id
    res = validate_material_resource_type_config_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    repo.update_material_resource_type_config(id, res)
    success_response("Updated config successfully", material_resource_type_config(false))
  end

  def link_mr_product_columns(id, product_column_ids)
    DB.transaction do
      repo.link_mr_product_columns(id, product_column_ids)
    end

    config = repo.find_material_resource_type_config(id)
    sub_type = repo.find_material_resource_sub_type(config.material_resource_sub_type_id)
    # existing_ids = repo.mr_type_mr_product_column_ids(id)
    # if existing_ids.eql?(product_column_ids.sort)
      success_response('Product columns linked successfully', sub_type)
    # else
    #   failed_response('Some product columns were not linked', sub_type)
    # end
  end

  def chosen_product_columns(ids)
    code_items = repo.for_select_material_resource_product_columns(where: { is_variant_column: false }).select { |i| ids.include?(i[1]) }
    var_items = repo.for_select_material_resource_product_columns(where: { is_variant_column: true }).select { |i| ids.include?(i[1]) }
    # items = repo.for_select_material_resource_product_columns.select { |i| ids.include?(i[1]) }
    success_response('got_items', code: code_items, var: var_items)
  end

  def link_mr_product_code_columns(id, product_code_column_ids)
    DB.transaction do
      repo.link_mr_product_code_columns(id, product_code_column_ids)
    end

    config = repo.find_material_resource_type_config(id)
    sub_type = repo.find_material_resource_sub_type(config.material_resource_sub_type_id)
    existing_ids = repo.mr_type_mr_product_code_column_ids(id)
    if existing_ids.eql?(product_code_column_ids.sort)
      success_response('Product code columns linked successfully', sub_type)
    else
      failed_response('Some product code columns were not linked', sub_type)
    end
  end

  def convert_string_params_to_arrays(params)
    params.transform_values { |v| v.is_a?(String) ? v.split(',') : v }
  end

  def prep_params_for_nonvar_pcodes(params)
    { non_variant_product_code_column_ids: [] }.merge(convert_string_params_to_arrays(params))
  end

  def assign_non_variant_product_code_columns(id, params)
    # store 3x id sets...
    # res = validate_material_resource_type_config_code_columns_params(params || { non_variant_product_code_column_ids: [] })

    # TODO: see if we can manage the String => Array conversion in DryValidation...
    res = validate_material_resource_type_config_code_columns_params(prep_params_for_nonvar_pcodes(params))
    return validation_failed_response(res) unless res.messages.empty?

    # required(:chosen_column_ids).filled { each(:int?) }
    # required(:columncodes_sorted_ids).filled { each(:int?) }
    # required(:variantcolumncodes_sorted_ids).maybe { each(:int?) }
    # non_variant_col_ids = res[:non_variant_product_code_column_ids]
    DB.transaction do
      # repo.assign_non_variant_product_code_columns(id, non_variant_col_ids)
      repo.assign_non_variant_product_code_columns(id, res)
    end
    # existing_ids = repo.non_variant_product_code_column_ids(id)
    # if existing_ids.eql?(non_variant_col_ids.sort)
    #   success_response('Code columns assigned successfully')
    # else
    #   validation_failed_response(OpenStruct.new(messages: { product_code_columns: ['You did not choose any product code columns'] }))
    # end
  end

  def assign_variant_product_code_columns(id, params)
    res = validate_material_resource_type_config_variant_code_columns_params(params || { variant_product_code_column_ids: [] })
    return validation_failed_response(res) unless res.messages.empty?

    variant_col_ids = res[:variant_product_code_column_ids]
    DB.transaction do
      repo.assign_variant_product_code_columns(id, variant_col_ids)
    end
    existing_ids = repo.variant_product_code_column_ids(id)
    if existing_ids.eql?(variant_col_ids.sort)
      success_response('Variant code columns assigned successfully')
    else
      validation_failed_response(OpenStruct.new(messages: { variant_product_code_columns: ['You did not choose any variant product code columns'] }))
    end
  end

  def reorder_product_code_columns(id, sorted_product_code_column_ids)
    DB.transaction do
      repo.reorder_product_code_columns(id, sorted_product_code_column_ids)
    end
    success_response('Product code columns reordered')
  end

  private

  def repo
    @repo ||= PackMaterialRepo.new
  end

  def material_resource_type(cached = true)
    if cached
      @material_resource_type ||= repo.find_material_resource_type(@id)
    else
      @material_resource_type = repo.find_material_resource_type(@id)
    end
  end

  def validate_material_resource_type_params(params)
    MaterialResourceTypeSchema.call(params)
  end

  def material_resource_sub_type(cached = true)
    if cached
      @material_resource_sub_type ||= repo.find_material_resource_sub_type(@id)
    else
      @material_resource_sub_type = repo.find_material_resource_sub_type(@id)
    end
  end

  def validate_material_resource_sub_type_params(params)
    MaterialResourceSubTypeSchema.call(params)
  end

  def material_resource_type_config(cached = true)
    if cached
      @material_resource_type_config ||= repo.find_material_resource_type_config(@id)
    else
      @material_resource_type_config = repo.find_material_resource_type_config(@id)
    end
  end

  def validate_material_resource_type_config_params(params)
    MaterialResourceTypeConfigSchema.call(params)
  end

  def validate_material_resource_type_config_code_columns_params(params)
    MaterialResourceTypeConfigCodeColumnsSchema.call(params)
  end

  def validate_material_resource_type_config_variant_code_columns_params(params)
    MaterialResourceTypeConfigVariantCodeColumnsSchema.call(params)
  end
end
