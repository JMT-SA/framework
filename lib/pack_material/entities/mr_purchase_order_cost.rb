# frozen_string_literal: true

module PackMaterialApp
  class MrPurchaseOrderCost < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_cost_type_id, Types::Integer
    attribute :mr_purchase_order_id, Types::Integer
    attribute :amount, Types::Decimal
  end
end
