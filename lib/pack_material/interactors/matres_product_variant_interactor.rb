# frozen_string_literal: true

module PackMaterialApp
  class MatresProductVariantInteractor < BaseInteractor
    def update_matres_product_variant(id, params)
      params.delete(:product_variant_number)
      res = validate_matres_product_variant_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      DB.transaction do
        repo.update_matres_product_variant(id, res)
        log_transaction
      end
      instance = matres_product_variant(id)
      success_response('Updated inventory', instance)
    end

    def link_alternatives(id, alternative_ids)
      repo.transaction do
        repo.link_alternatives(id, alternative_ids)
      end
      success_response('Alternative product codes linked successfully')
    end

    def link_co_use_product_codes(id, co_use_ids)
      repo.transaction do
        repo.link_co_use_product_codes(id, co_use_ids)
      end
      success_response('Co-use product codes linked successfully')
    end

    private

    def repo
      @repo ||= ConfigRepo.new
    end

    def matres_product_variant(id)
      repo.find_matres_product_variant(id)
    end

    def validate_matres_product_variant_params(params)
      MatresProductVariantSchema.call(params)
    end
  end
end
