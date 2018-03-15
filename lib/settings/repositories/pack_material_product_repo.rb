# frozen_string_literal: true

class PackMaterialProductRepo < RepoBase
  build_for_select :pack_material_products,
                   label: :description,
                   value: :id,
                   order_by: :description
  build_inactive_select :pack_material_products,
                        label: :description,
                        value: :id,
                        order_by: :description

  crud_calls_for :pack_material_products, name: :product, wrapper: PackMaterialProduct
end