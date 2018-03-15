# frozen_string_literal: true

class MaterialResourceProductColumn < Dry::Struct
  attribute :id, Types::Int
  attribute :material_resource_domain_id, Types::Int
  attribute :column_name, Types::String
  attribute :group_name, Types::String
  attribute :is_variant_column, Types::Bool
end
