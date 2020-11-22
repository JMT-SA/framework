# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop#:disable Metrics/AbcSize

module PackMaterialApp
  class PmProductInteractor < BaseInteractor
    def create_pm_product(params)
      res = validate_pm_product_params(params)
      return validation_failed_response(res) if res.failure?

      pm_product_create(res)
    end

    def clone_pm_product(params)
      res = validate_clone_pm_product_params(params)
      return validation_failed_response(res) if res.failure?

      pm_product_create(res)
    end

    def update_pm_product(id, params)
      res = validate_pm_product_params(params)
      return validation_failed_response(res) if res.failure?

      resp = nil
      repo.transaction do
        resp = repo.update_pm_product(id, res)
      end
      if resp.success
        instance = pm_product(id)
        success_response("Updated product #{instance.product_code}", instance)
      else
        resp
      end
    end

    def delete_pm_product(id)
      name = pm_product(id).product_code
      res = nil
      repo.transaction do
        res = repo.delete_pm_product(id)
      end
      res.success ? success_response("Deleted product #{name}") : res
    end

    def create_pm_product_variant(parent_id, params)
      params[:pack_material_product_id] = parent_id
      return parent_id_missing unless parent_id

      res = validate_pm_product_variant_params(params)
      return validation_failed_response(res) if res.failure?

      pm_product_variant_create(res)
    end

    def clone_pm_product_variant(parent_id, params)
      params[:pack_material_product_id] = parent_id
      return parent_id_missing unless parent_id

      res = validate_clone_pm_product_variant_params(params)
      return validation_failed_response(res) if res.failure?

      pm_product_variant_create(res)
    end

    def pm_product_variant_create(res)
      result = nil
      repo.transaction do
        result = repo.create_pm_product_variant(res)
      end
      if result.success
        variant = pm_product_variant(result.instance)
        success_response('Created product variant', variant)
      else
        result
      end
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { base: ['This product variant already exists'] }))
    end

    def update_pm_product_variant(id, params)
      res = validate_pm_product_variant_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_pm_product_variant(id, res)
      end
      instance = pm_product_variant(id)
      success_response("Updated pack material product variant #{instance.product_variant_number}", instance)
    end

    def delete_pm_product_variant(id)
      name = pm_product_variant(id).product_variant_number
      repo.transaction do
        repo.delete_pm_product_variant(id)
      end
      success_response("Deleted pack material product variant #{name}")
    end

    private

    def repo
      @repo ||= PmProductRepo.new
    end

    def pm_product(id)
      repo.find_pm_product(id)
    end

    def pm_product_variant(id)
      repo.find_pm_product_variant(id)
    end

    def pm_product_create(res)
      id = nil
      repo.transaction do
        id = repo.create_pm_product(res)
      end
      instance = pm_product(id)
      success_response('Created product', instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { product_number: ['This product already exists'] }))
    end

    def validate_pm_product_params(params)
      PmProductSchema.call(params)
    end

    def validate_clone_pm_product_params(params)
      ClonePmProductSchema.call(params)
    end

    def validate_completed_pm_product_params(params)
      CompletedPmProductSchema.call(params)
    end

    def validate_pm_product_variant_params(params)
      PmProductVariantSchema.call(params)
    end

    def validate_clone_pm_product_variant_params(params)
      ClonePmProductVariantSchema.call(params)
    end

    def validate_completed_pm_product_variant_params(params)
      CompletedPmProductVariantSchema.call(params)
    end

    def parent_id_missing
      validation_failed_response(OpenStruct.new(messages: { pack_material_product_id: ['is missing'] }))
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop#:enable Metrics/AbcSize
