# frozen_string_literal: true

module PackMaterialApp
  class PmProductInteractor < BaseInteractor
    def repo
      @repo ||= PmProductRepo.new
    end

    def pm_product(cached = true)
      if cached
        @pm_product ||= repo.find_pm_product(@id)
      else
        @pm_product = repo.find_pm_product(@id)
      end
    end

    def validate_pm_product_params(params)
      PmProductSchema.call(params)
    end

    def create_pm_product(params)
      res = validate_pm_product_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      @id = repo.create_pm_product(res)
      success_response("Created pm product #{pm_product.description}",
                       pm_product)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { description: ['This pm product already exists'] }))
    end

    def update_pm_product(id, params)
      @id = id
      res = validate_pm_product_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.update_pm_product(id, res)
      success_response("Updated pm product #{pm_product.description}",
                       pm_product(false))
    end

    def delete_pm_product(id)
      @id = id
      name = pm_product.description
      repo.delete_pm_product(id)
      success_response("Deleted pm product #{name}")
    end
  end
end
