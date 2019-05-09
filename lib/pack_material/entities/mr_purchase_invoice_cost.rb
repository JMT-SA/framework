# frozen_string_literal: true

module PackMaterialApp
  class MrPurchaseInvoiceCost < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_cost_type_id, Types::Integer
    attribute :mr_delivery_id, Types::Integer
    attribute :amount, Types::Decimal
    attribute :cost_type, Types::String
  end
end
