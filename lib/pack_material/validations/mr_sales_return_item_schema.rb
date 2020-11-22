# frozen_string_literal: true

module PackMaterialApp
  MrSalesReturnItemSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:mr_sales_return_id).filled(:integer)
    required(:mr_sales_order_item_id).filled(:integer)
    optional(:remarks).maybe(Types::StrippedString)
    # optional(:quantity_returned).maybe(%i[nil decimal])
    optional(:quantity_returned).maybe(:decimal)
  end

  MrSalesReturnItemInlineQuantitySchema = Dry::Schema.Params do
    required(:column_name).filled(Types::StrippedString)
    required(:column_value).maybe(:decimal, gt?: 0)
  end

  MrSalesReturnItemInlineRemarksSchema = Dry::Schema.Params do
    required(:column_name).filled(Types::StrippedString)
    required(:column_value).maybe(Types::StrippedString)
  end

  MrSalesReturnItemPrintSKUBarcodeSchema = Dry::Schema.Params do
    required(:mr_sales_return_item_id).filled(:integer)
    required(:sales_return_number).filled(:integer)
    required(:sku_id).filled(:integer)
    required(:sku_number).filled(:integer)
    required(:product_variant_code).maybe(Types::StrippedString)
    required(:product_variant_number).maybe(Types::StrippedString)
    required(:batch_number).maybe(Types::StrippedString)
    required(:printer).filled(:integer)
    required(:no_of_prints).filled(:integer, gt?: 0)
  end
end
