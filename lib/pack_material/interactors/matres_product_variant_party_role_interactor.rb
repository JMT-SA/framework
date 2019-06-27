# frozen_string_literal: true

# rubocop#disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module PackMaterialApp
  class MatresProductVariantPartyRoleInteractor < BaseInteractor
    def create_matres_product_variant_party_role(parent_id, params)
      params[:material_resource_product_variant_id] = parent_id
      res = validate_matres_product_variant_party_role_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      result = nil
      DB.transaction do
        result = repo.create_matres_product_variant_party_role(res)
        log_transaction
      end
      if result.success
        instance = matres_product_variant_party_role(result.instance)
        success_response("Created #{link_name(instance)}", instance)
      else
        validation_failed_response(OpenStruct.new(messages: result.errors))
      end
    end

    def update_matres_product_variant_party_role(id, params)
      res = validate_update_matres_product_variant_party_role_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      DB.transaction do
        repo.update_matres_product_variant_party_role(id, res)
        log_transaction
      end
      instance = matres_product_variant_party_role(id)
      success_response("Updated #{link_name(instance)}", instance)
    end

    def delete_matres_product_variant_party_role(id)
      name = link_name(matres_product_variant_party_role(id))
      DB.transaction do
        repo.delete_matres_product_variant_party_role(id)
        log_transaction
      end
      success_response("Deleted #{name} link")
    end

    def link_name(instance)
      "#{instance.supplier? ? 'supplier' : 'customer'}, #{instance.party_name}"
    end

    private

    def repo
      @repo ||= ConfigRepo.new
    end

    def matres_product_variant_party_role(id)
      repo.find_product_variant_party_role(id)
    end

    def validate_matres_product_variant_party_role_params(params)
      NewMatresProductVariantPartyRoleSchema.call(params)
    end

    def validate_update_matres_product_variant_party_role_params(params)
      UpdateMatresProductVariantPartyRoleSchema.call(params)
    end
  end
end
# rubocop#enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
