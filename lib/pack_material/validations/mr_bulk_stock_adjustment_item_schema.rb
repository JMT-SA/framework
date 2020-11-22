# frozen_string_literal: true

module PackMaterialApp
  NewMrBulkStockAdjustmentItemSchema = Dry::Schema.Params do
    required(:mr_bulk_stock_adjustment_id).filled(:integer)
    required(:mr_sku_id).filled(:integer)
    required(:location_id).filled(:integer)
  end

  UpdateMrBulkStockAdjustmentItemSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:product_variant_number).maybe(:integer)
    required(:mr_type_name).filled(Types::StrippedString)
    required(:mr_sub_type_name).filled(Types::StrippedString)
    required(:product_variant_code).filled(Types::StrippedString)
    required(:location_long_code).maybe(Types::StrippedString)
    # required(:scan_to_location_long_code).maybe(Types::StrippedString)
    required(:inventory_uom_code).maybe(Types::StrippedString)
    required(:system_quantity).maybe(:decimal)
    required(:actual_quantity).maybe(:decimal)
    required(:stock_take_complete).maybe(:bool)
  end

  MrBulkStockAdjustmentItemInlineSchema = Dry::Schema.Params do
    required(:column_name).filled(Types::StrippedString)
    required(:column_value).maybe(:decimal, gteq?: 0)
  end
end
