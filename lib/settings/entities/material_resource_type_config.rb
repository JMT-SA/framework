# frozen_string_literal: true

class MaterialResourceTypeConfig < Dry::Struct
  attribute :id, Types::Int
  attribute :material_resource_sub_type_id, Types::Int
  attribute :product_code_separator, Types::String
  attribute :has_suppliers, Types::Bool
  attribute :has_marketers, Types::Bool
  attribute :has_retailer, Types::Bool
  attribute :active, Types::Bool
  attribute :domain_name, Types::String
  attribute :type_name, Types::String
  attribute :sub_type_name, Types::String
end
