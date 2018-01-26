# frozen_string_literal: true

class PackingMaterialProductType < Dry::Struct
  attribute :id, Types::Int
  attribute :packing_material_type_name, Types::String
end
