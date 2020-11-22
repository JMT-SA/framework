# frozen_string_literal: true

module PackMaterialApp
  NewBulkStockAdjustmentSchema = Dry::Schema.Params do
    optional(:business_process_id).filled(:integer)
    optional(:ref_no).filled(Types::StrippedString)
    optional(:is_stock_take).maybe(:bool)
    optional(:carton_assembly).maybe(:bool)
    optional(:staging_consumption).maybe(:bool)
  end

  ItemAdjustMrBulkStockAdjustmentSchema = Dry::Schema.Params do
    required(:stock_adjustment_number).filled(:integer)
    required(:stock_adjustment_number_scan_field).maybe(Types::StrippedString)
    required(:location).filled(Types::StrippedString)
    required(:location_scan_field).maybe(Types::StrippedString)
    required(:sku_number).filled(:integer)
    required(:sku_number_scan_field).maybe(Types::StrippedString)
    required(:quantity).filled(:decimal)
  end

  MrBulkStockAdjustmentPriceSchema = Dry::Schema.Params do
    required(:column_name).filled(Types::StrippedString)
    required(:column_value).filled(:decimal, gt?: 0)
  end
end
