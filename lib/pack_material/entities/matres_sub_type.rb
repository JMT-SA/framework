# frozen_string_literal: true

module PackMaterialApp
  class MatresSubType < Dry::Struct
    attribute :id, Types::Integer
    attribute :material_resource_type_id, Types::Integer
    attribute :inventory_uom_id, Types::Integer
    attribute :inventory_uom_code, Types::String.optional
    attribute :sub_type_name, Types::String
    attribute :short_code, Types::String
    attribute :product_code_separator, Types::String
    attribute :has_suppliers, Types::Bool
    attribute :has_marketers, Types::Bool
    attribute :has_retailers, Types::Bool
    attribute :active, Types::Bool
    attribute :product_column_ids, Types::Array
    attribute :product_code_ids, Types::Array
    attribute :product_variant_code_ids, Types::Array
    attribute :optional_product_variant_code_ids, Types::Array
    attribute :internal_seq, Types::Integer
  end
end
