# frozen_string_literal: true

module PackMaterialApp
  class PmProductRepo < BaseRepo
    build_for_select :pack_material_products,
                     label: :description,
                     value: :id,
                     order_by: :description
    build_inactive_select :pack_material_products,
                          label: :description,
                          value: :id,
                          order_by: :description

    crud_calls_for :pack_material_products, name: :pm_product, wrapper: PmProduct
  end
end
