# frozen_string_literal: true

module PackMaterialApp
  class MrSalesOrderItem < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_sales_order_id, Types::Integer
    attribute :mr_product_variant_id, Types::Integer
    attribute :remarks, Types::String
    attribute :quantity_required, Types::Decimal
    attribute :unit_price, Types::Decimal
    attribute :product_variant_number, Types::Integer
    attribute :product_variant_code, Types::String
    attribute :status, Types::String
    attribute :returned, Types::Bool
  end
end
