# frozen_string_literal: true

module PackMaterialApp
  class MatresType < Dry::Struct
    attribute :id, Types::Int
    attribute :material_resource_domain_id, Types::Int
    attribute :type_name, Types::String
    attribute :domain_name, Types::String
  end
end
