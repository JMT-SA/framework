# frozen_string_literal: true

class MaterialResourceSubType < Dry::Struct
  attribute :id, Types::Int
  attribute :material_resource_type_id, Types::Int
  attribute :sub_type_name, Types::String
end
