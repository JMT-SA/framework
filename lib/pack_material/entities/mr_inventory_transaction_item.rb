# frozen_string_literal: true

module PackMaterialApp
  class MrInventoryTransactionItem < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_sku_id, Types::Integer
    attribute :inventory_uom_id, Types::Integer
    attribute :inventory_uom_code, Types::String.optional
    attribute :from_location_id, Types::Integer
    attribute :mr_inventory_transaction_id, Types::Integer
    attribute :quantity, Types::Decimal
  end
end
