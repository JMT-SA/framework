# frozen_string_literal: true

module PackMaterialApp
  class MatresProductVariant < Dry::Struct
    attribute :id, Types::Integer
    attribute :product_variant_id, Types::Integer
    attribute :product_variant_table_name, Types::String
    attribute :product_variant_number, Types::Integer
    attribute :product_variant_code, Types::String
    attribute :old_product_code, Types::String
    attribute :supplier_lead_time, Types::Integer
    attribute :minimum_stock_level, Types::Decimal
    attribute :re_order_stock_level, Types::Decimal
    attribute :use_fixed_batch_number, Types::Bool
    attribute :internal_batch_number, Types::Integer
    attribute :mr_internal_batch_number_id, Types::Integer
    attribute :current_price, Types::Decimal
    attribute :stock_adj_price, Types::Decimal
  end
end
