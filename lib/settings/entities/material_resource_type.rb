# frozen_string_literal: true

class MaterialResourceType < Dry::Struct
  attribute :id, Types::Int
  attribute :material_resource_domain_id, Types::Int
  attribute :type_name, Types::String
end
