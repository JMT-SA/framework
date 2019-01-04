# frozen_string_literal: true

module PackMaterialApp
  class MatresProductVariant < Dry::Struct
    attribute :id, Types::Integer
    attribute :product_variant_id, Types::Integer
    attribute :product_variant_table_name, Types::String
    attribute :product_variant_number, Types::Integer
    attribute :product_variant_code, Types::Integer
    attribute :old_product_code, Types::String
    attribute :supplier_lead_time, Types::Integer
    attribute :minimum_stock_level, Types::Integer
    attribute :re_order_stock_level, Types::Integer
    attribute :use_fixed_batch_number, Types::Bool
    attribute :internal_batch_number, Types::Integer
    attribute :mr_internal_batch_number_id, Types::Integer
  end
end
