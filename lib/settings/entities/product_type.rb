# frozen_string_literal: true

class ProductType < Dry::Struct
  attribute :id, Types::Int
  attribute :packing_material_product_type_id, Types::Int
  attribute :packing_material_product_sub_type_id, Types::Int
end
