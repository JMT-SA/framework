# frozen_string_literal: true

class ProductTypeInteractor < BaseInteractor
  def repo
    @repo ||= ProductTypeRepo.new
  end

  def product_type(cached = true)
    if cached
      @product_type ||= repo.find_product_type(@id)
    else
      @product_type = repo.find_product_type(@id)
    end
  end

  def validate_product_type_params(params)
    ProductTypeSchema.call(params)
  end

  def create_product_type(params)
    res = validate_product_type_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @id = repo.create_product_type(res)
    success_response("Created product type #{'product_type.name'}", # TODO - Create a combined product type name
                     product_type)
  rescue Sequel::UniqueConstraintViolation
    validation_failed_response(OpenStruct.new(messages: { product_type_name: ['This product type already exists'] }))
  end

  def update_product_type(id, params)
    @id = id
    res = validate_product_type_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    repo.update_product_type(id, res)
    success_response("Updated product type #{'product_type.name'}",
                     product_type(false))
  end

  def delete_product_type(id)
    @id = id
    # name = product_type.product_columns_options
    repo.delete_product_type(id)
    success_response("Deleted product type #{'name'}")
  end

  def packing_material_product_type(cached = true)
    if cached
      @packing_material_product_type ||= repo.find_packing_material_product_type(@id)
    else
      @packing_material_product_type = repo.find_packing_material_product_type(@id)
    end
  end

  def validate_packing_material_product_type_params(params)
    PackingMaterialProductTypeSchema.call(params)
  end

  def create_packing_material_product_type(params)
    res = validate_packing_material_product_type_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @id = repo.create_packing_material_product_type(res)
    success_response("Created packing material product type #{packing_material_product_type.packing_material_type_name}",
                     packing_material_product_type)
  rescue Sequel::UniqueConstraintViolation
    validation_failed_response(OpenStruct.new(messages: { packing_material_type_name: ['This packing material product type already exists'] }))
  end

  def update_packing_material_product_type(id, params)
    @id = id
    res = validate_packing_material_product_type_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    repo.update_packing_material_product_type(id, res)
    success_response("Updated packing material product type #{packing_material_product_type.packing_material_type_name}",
                     packing_material_product_type(false))
  end

  def delete_packing_material_product_type(id)
    @id = id
    name = packing_material_product_type.packing_material_type_name
    repo.delete_packing_material_product_type(id)
    success_response("Deleted packing material product type #{name}")
  end

  def packing_material_product_sub_type(cached = true)
    if cached
      @packing_material_product_sub_type ||= repo.find_packing_material_product_sub_type(@id)
    else
      @packing_material_product_sub_type = repo.find_packing_material_product_sub_type(@id)
    end
  end

  def validate_packing_material_product_sub_type_params(params)
    PackingMaterialProductSubTypeSchema.call(params)
  end

  def create_packing_material_product_sub_type(params)
    res = validate_packing_material_product_sub_type_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @id = repo.create_packing_material_product_sub_type(res)
    success_response("Created packing material product sub type #{packing_material_product_sub_type.packing_material_sub_type_name}",
                     packing_material_product_sub_type)
  rescue Sequel::UniqueConstraintViolation
    validation_failed_response(OpenStruct.new(messages: { packing_material_sub_type_name: ['This packing material product sub type already exists'] }))
  end

  def update_packing_material_product_sub_type(id, params)
    @id = id
    res = validate_packing_material_product_sub_type_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    repo.update_packing_material_product_sub_type(id, res)
    success_response("Updated packing material product sub type #{packing_material_product_sub_type.packing_material_sub_type_name}",
                     packing_material_product_sub_type(false))
  end

  def delete_packing_material_product_sub_type(id)
    @id = id
    name = packing_material_product_sub_type.packing_material_sub_type_name
    repo.delete_packing_material_product_sub_type(id)
    success_response("Deleted packing material product sub type #{name}")
  end

  def link_product_column_names(id, product_column_name_ids)
    DB.transaction do
      repo.link_product_column_names(id, product_column_name_ids)
    end

    # product_type = repo.find_product_type(id)
    existing_ids = repo.product_type_product_column_name_ids(id)
    if existing_ids.eql?(product_column_name_ids.sort)
      success_response('Product columns linked successfully')#, product_type)
    else
      failed_response('Some product columns were not linked')#, product_type)
    end
  end

  def link_product_code_column_names(id, product_code_column_name_ids)
    # In here we just need to also check that they already exist in product column name links above
    DB.transaction do
      repo.link_product_code_column_names(id, product_code_column_name_ids)
    end

    # product_type = repo.find_product_type(id)
    existing_ids = repo.product_type_product_code_column_name_ids(id)
    if existing_ids.eql?(product_code_column_name_ids.sort)
      success_response('Code columns linked successfully')#, product_type)
    else
      failed_response('Some code columns were not linked')#, product_type)
    end
  end

  def product(cached = true)
    if cached
      @product ||= repo.find_product(@id)
    else
      @product = repo.find_product(@id)
    end
  end

  def validate_product_params(params)
    ProductSchema.call(params)
  end

  def create_product(params)
    res = validate_product_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @id = repo.create_product(res)
    success_response("Created product #{product.variant}",
                     product)
  rescue Sequel::UniqueConstraintViolation
    validation_failed_response(OpenStruct.new(messages: { variant: ['This product already exists'] }))
  end

  def update_product(id, params)
    @id = id
    res = validate_product_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    repo.update_product(id, res)
    success_response("Updated product #{product.variant}",
                     product(false))
  end

  def delete_product(id)
    @id = id
    name = product.variant
    repo.delete_product(id)
    success_response("Deleted product #{name}")
  end

  def reorder_product_code_column_names(id, column_codes_sorted_ids)
    if repo.store_product_code_column_ordering(id, column_codes_sorted_ids)
      success_response("Product code column ordering has been updated")
    else
      failed_response("Something went wrong")
    end
  end
end
