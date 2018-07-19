# frozen_string_literal: true

module PackMaterialApp
  class PmProductRepo < BaseRepo
    build_for_select :pack_material_products,
                     label: :product_code,
                     value: :id,
                     order_by: :product_code
    build_inactive_select :pack_material_products,
                          label: :product_code,
                          value: :id,
                          order_by: :product_code

    crud_calls_for :pack_material_products, name: :pm_product, wrapper: PmProduct
    crud_calls_for :pack_material_product_variants, name: :pm_product_variant, wrapper: PmProductVariant
  end
end

