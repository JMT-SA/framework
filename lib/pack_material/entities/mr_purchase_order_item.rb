# frozen_string_literal: true

module PackMaterialApp
  class MrPurchaseOrderItem < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_purchase_order_id, Types::Integer
    attribute :mr_product_variant_id, Types::Integer
    attribute :product_variant_code, Types::String
    attribute :purchasing_uom_id, Types::Integer
    attribute :purchasing_uom_code, Types::String
    attribute :inventory_uom_id, Types::Integer
    attribute :inventory_uom_code, Types::String
    attribute :quantity_required, Types::Decimal
    attribute :unit_price, Types::Decimal
  end
end
