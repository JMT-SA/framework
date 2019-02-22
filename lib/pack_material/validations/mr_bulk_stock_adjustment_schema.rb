# frozen_string_literal: true

module PackMaterialApp
  NewBulkStockAdjustmentSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    optional(:business_process_id, :integer).filled(:int?)
    optional(:ref_no, Types::StrippedString).filled(:str?)
    required(:is_stock_take, :bool).maybe(:bool?)
  end
end
