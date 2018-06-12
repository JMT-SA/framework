# frozen_string_literal: true

module PackMaterialApp
  class MatresSubType < Dry::Struct
    attribute :id, Types::Int
    attribute :material_resource_type_id, Types::Int
    attribute :sub_type_name, Types::String
    attribute :short_code, Types::String
    attribute :product_code_separator, Types::String
    attribute :has_suppliers, Types::Bool
    attribute :has_marketers, Types::Bool
    attribute :has_retailers, Types::Bool
    # attribute :active, Types::Bool
    attribute :product_column_ids, Types::Array
    attribute :product_code_ids, Types::Array
  end
end