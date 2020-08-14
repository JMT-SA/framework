# frozen_string_literal: true

module PackMaterialApp
  MrSalesReturnItemSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:mr_sales_return_id, :integer).filled(:int?)
    required(:mr_sales_order_item_id, :integer).filled(:int?)
    optional(:remarks, Types::StrippedString).maybe(:str?)
    optional(:quantity_returned, %i[nil decimal]).maybe(:decimal?)
  end

  MrSalesReturnItemInlineQuantitySchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:column_name, Types::StrippedString).filled(:str?)
    required(:column_value, :decimal).maybe(:decimal?, gt?: 0)
  end

  MrSalesReturnItemInlineRemarksSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:column_name, Types::StrippedString).filled(:str?)
    required(:column_value, Types::StrippedString).maybe(:str?)
  end
end
