# frozen_string_literal: true

module PackMaterialApp
  NewBulkStockAdjustmentSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    optional(:business_process_id, :integer).filled(:int?)
    optional(:ref_no, Types::StrippedString).filled(:str?)
    required(:is_stock_take, :bool).maybe(:bool?)
  end

  ItemAdjustMrBulkStockAdjustmentSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:stock_adjustment_number, :integer).filled(:int?)
    required(:stock_adjustment_number_scan_field, Types::StrippedString).maybe(:str?)
    required(:location, Types::StrippedString).filled(:str?)
    required(:location_scan_field, Types::StrippedString).maybe(:str?)
    required(:sku_number, :integer).filled(:int?)
    required(:sku_number_scan_field, Types::StrippedString).maybe(:str?)
    required(:quantity, :integer).filled(:int?)
  end
end
