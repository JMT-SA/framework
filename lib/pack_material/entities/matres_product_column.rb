# frozen_string_literal: true

module PackMaterialApp
  class MatresProductColumn < Dry::Struct
    attribute :id, Types::Int
    attribute :material_resource_domain_id, Types::Int
    attribute :column_name, Types::String
    attribute :short_code, Types::String
    attribute :description, Types::String
  end
end
