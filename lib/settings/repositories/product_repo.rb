# frozen_string_literal: true

class ProductRepo < RepoBase
  build_for_select :products,
                   label: :variant,
                   value: :id,
                   order_by: :variant
  build_inactive_select :products,
                        label: :variant,
                        value: :id,
                        order_by: :variant

  crud_calls_for :products, name: :product, wrapper: Product
end
