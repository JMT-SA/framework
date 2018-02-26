# frozen_string_literal: true

class MaterialResourceDomain < Dry::Struct
  attribute :id, Types::Int
  attribute :domain_name, Types::String
  attribute :product_table_name, Types::String
  attribute :variant_table_name, Types::String
end
