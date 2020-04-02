# frozen_string_literal: true

module PackMaterialApp
  NewBulkStockAdjustmentSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:business_process_id, :integer).filled(:int?)
    optional(:ref_no, Types::StrippedString).filled(:str?)
    optional(:is_stock_take, :bool).maybe(:bool?)
    optional(:carton_assembly, :bool).maybe(:bool?)
    optional(:staging_consumption, :bool).maybe(:bool?)
  end

  ItemAdjustMrBulkStockAdjustmentSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:stock_adjustment_number, :integer).filled(:int?)
    required(:stock_adjustment_number_scan_field, Types::StrippedString).maybe(:str?)
    required(:location, Types::StrippedString).filled(:str?)
    required(:location_scan_field, Types::StrippedString).maybe(:str?)
    required(:sku_number, :integer).filled(:int?)
    required(:sku_number_scan_field, Types::StrippedString).maybe(:str?)
    required(:quantity, :decimal).filled(:decimal?)
  end

  MrBulkStockAdjustmentPriceSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:column_name, Types::StrippedString).filled(:str?)
    required(:column_value, :decimal).filled(:decimal?, gt?: 0)
  end
end
