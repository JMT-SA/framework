# frozen_string_literal: true

module PackMaterialApp
  class MatresType < Dry::Struct
    attribute :id, Types::Integer
    attribute :material_resource_domain_id, Types::Integer
    attribute :type_name, Types::String
    attribute :short_code, Types::String
    attribute :description, Types::String
    attribute :domain_name, Types::String
    attribute :internal_seq, Types::Integer
  end
end
