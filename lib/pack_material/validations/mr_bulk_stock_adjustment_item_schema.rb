# frozen_string_literal: true

module PackMaterialApp
  MrBulkStockAdjustmentItemSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:mr_bulk_stock_adjustment_id, :integer).filled(:int?)
    required(:mr_sku_location_id, :integer).filled(:int?)
    required(:sku_number, :integer).filled(:int?)
    required(:product_variant_number, :integer).maybe(:int?)
    required(:product_number, :integer).maybe(:int?)
    required(:mr_type_name, Types::StrippedString).filled(:str?)
    required(:mr_sub_type_name, Types::StrippedString).filled(:str?)
    required(:product_variant_code, Types::StrippedString).filled(:str?)
    required(:product_code, Types::StrippedString).filled(:str?)
    required(:location_long_code, Types::StrippedString).maybe(:str?)
    required(:inventory_uom_code, Types::StrippedString).maybe(:str?)
    required(:scan_to_location_long_code, Types::StrippedString).maybe(:str?)
    required(:system_quantity, :decimal).maybe(:decimal?)
    required(:actual_quantity, :decimal).maybe(:decimal?)
    required(:stock_take_complete, :bool).maybe(:bool?)
  end
end
