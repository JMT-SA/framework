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

  MrSalesReturnItemPrintSKUBarcodeSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:mr_sales_return_item_id, :integer).filled(:int?)
    required(:sales_return_number, :integer).filled(:int?)
    required(:sku_id, :integer).filled(:int?)
    required(:sku_number, :integer).filled(:int?)
    required(:product_variant_code, Types::StrippedString).maybe(:str?)
    required(:product_variant_number, Types::StrippedString).maybe(:str?)
    required(:batch_number, Types::StrippedString).maybe(:str?)
    required(:printer, :integer).filled(:int?)
    required(:no_of_prints, :integer).filled(:int?, gt?: 0)
  end
end
