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
  attribute :non_variant_product_code_column_ids, Types::Array
  attribute :variant_product_code_column_ids, Types::Array
  attribute :for_selected_non_variant_product_code_column_ids, Types::Array
  attribute :for_selected_variant_product_code_column_ids, Types::Array
  # attribute :product_code_columns, Types::Array #Possibly a for_select value here
end
