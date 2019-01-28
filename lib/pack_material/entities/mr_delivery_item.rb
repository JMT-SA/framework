# frozen_string_literal: true

module PackMaterialApp
  class MrDeliveryItem < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_delivery_id, Types::Integer
    attribute :mr_purchase_order_item_id, Types::Integer
    attribute :mr_product_variant_id, Types::Integer
    attribute :quantity_on_note, Types::Decimal
    attribute :quantity_over_supplied, Types::Decimal
    attribute :quantity_under_supplied, Types::Decimal
    attribute :quantity_received, Types::Decimal
    attribute :invoiced_unit_price, Types::Decimal
    attribute :remarks, Types::String
    attribute :putaway_completed, Types::Bool
  end
end
