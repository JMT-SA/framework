# frozen_string_literal: true

module PackMaterialApp
  class MatresProductVariant < Dry::Struct
    attribute :id, Types::Int
    attribute :product_variant_id, Types::Int
    attribute :product_variant_table_name, Types::String
    attribute :product_variant_number, Types::Int
    attribute :product_variant_code, Types::Int
    attribute :old_product_code, Types::String
    attribute :supplier_lead_time, Types::Int
    attribute :minimum_stock_level, Types::Int
    attribute :re_order_stock_level, Types::Int
  end
end
