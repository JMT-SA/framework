# frozen_string_literal: true

module PackMaterialApp
  class MrBulkStockAdjustmentItem < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_bulk_stock_adjustment_id, Types::Integer
    attribute :mr_sku_location_id, Types::Integer
    attribute :sku_number, Types::Integer
    attribute :product_variant_number, Types::Integer
    attribute :product_number, Types::Integer
    attribute :mr_type_name, Types::String
    attribute :mr_sub_type_name, Types::String
    attribute :product_variant_code, Types::String
    attribute :product_code, Types::String
    attribute :location_long_code, Types::String
    attribute :inventory_uom_code, Types::String
    attribute :scan_to_location_long_code, Types::String
    attribute :system_quantity, Types::Decimal
    attribute :actual_quantity, Types::Decimal
    attribute :stock_take_complete, Types::Bool
    # attribute? :active, Types::Bool
  end
end
