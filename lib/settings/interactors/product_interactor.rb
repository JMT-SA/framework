# frozen_string_literal: true

class ProductInteractor < BaseInteractor
  def repo
    @repo ||= ProductRepo.new
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
end
