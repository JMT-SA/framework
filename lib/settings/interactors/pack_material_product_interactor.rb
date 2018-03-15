# frozen_string_literal: true

class PackMaterialProductInteractor < BaseInteractor
  def validate_pack_material_product_params(params)
    PackMaterialProductSchema.call(params)
  end

  def create_pack_material_product(params)
    res = validate_pack_material_product_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @id = repo.create_pack_material_product(res)
    success_response("Created pack material product #{pack_material_product.description}",
                     pack_material_product)
  rescue Sequel::UniqueConstraintViolation
    validation_failed_response(OpenStruct.new(messages: { description: ['This pack material product already exists'] }))
  end

  def update_pack_material_product(id, params)
    @id = id
    res = validate_pack_material_product_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    repo.update_pack_material_product(id, res)
    success_response("Updated pack material product #{pack_material_product.description}",
                     pack_material_product(false))
  end

  def delete_pack_material_product(id)
    @id = id
    name = pack_material_product.description
    repo.delete_pack_material_product(id)
    success_response("Deleted pack material product #{name}")
  end

  private

  def repo
    @repo ||= PackMaterialProductRepo.new
  end

  def pack_material_product(cached = true)
    if cached
      @pack_material_product ||= repo.find_pack_material_product(@id)
    else
      @pack_material_product = repo.find_pack_material_product(@id)
    end
  end

end
