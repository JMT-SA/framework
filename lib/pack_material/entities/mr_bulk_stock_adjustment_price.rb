# frozen_string_literal: true

module PackMaterialApp
  class MrBulkStockAdjustmentPrice < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_bulk_stock_adjustment_id, Types::Integer
    attribute :mr_product_variant_id, Types::Integer
    attribute :stock_adj_price, Types::Decimal
  end
end
