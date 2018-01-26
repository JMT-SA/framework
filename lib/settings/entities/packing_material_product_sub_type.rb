# frozen_string_literal: true

class PackingMaterialProductSubType < Dry::Struct
  attribute :id, Types::Int
  attribute :packing_material_product_type_id, Types::Int
  attribute :packing_material_sub_type_name, Types::String
end
