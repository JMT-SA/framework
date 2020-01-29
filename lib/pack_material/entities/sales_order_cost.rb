# frozen_string_literal: true

module PackMaterialApp
  class SalesOrderCost < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_sales_order_id, Types::Integer
    attribute :mr_cost_type_id, Types::Integer
    attribute :amount, Types::Decimal
    attribute :cost_type_code, Types::String
  end
end
