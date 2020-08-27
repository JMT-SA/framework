# frozen_string_literal: true

module PackMaterialApp
  class SalesReturnCost < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_sales_return_id, Types::Integer
    attribute :mr_cost_type_id, Types::Integer
    attribute :amount, Types::Decimal
  end

  class SalesReturnCostFlat < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_sales_return_id, Types::Integer
    attribute :mr_cost_type_id, Types::Integer
    attribute :amount, Types::Decimal
    attribute :cost_type_code, Types::String
  end
end
