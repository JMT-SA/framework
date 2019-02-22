# frozen_string_literal: true

module PackMaterialApp
  class MrBulkStockAdjustment < Dry::Struct
    attribute :id, Types::Integer
    attribute :stock_adjustment_number, Types::Integer
    attribute :mr_inventory_transaction_id, Types::Integer
    attribute :sku_numbers, Types::Array
    attribute :location_ids, Types::String
    attribute :is_stock_take, Types::Bool
    attribute :completed, Types::DateTime
    attribute :approved, Types::Bool
    attribute :active, Types::Bool
  end
end
