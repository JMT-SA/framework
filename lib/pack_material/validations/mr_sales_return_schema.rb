# frozen_string_literal: true

module PackMaterialApp
  MrSalesReturnSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:mr_sales_order_id).filled(:integer)
    required(:issue_transaction_id).maybe(:integer)
    required(:remarks).maybe(Types::StrippedString)
    required(:sales_return_number).maybe(:integer)
    required(:receipt_location_id).filled(:integer)
  end

  NewMrSalesReturnSchema = Dry::Schema.Params do
    required(:mr_sales_order_id).filled(:integer)
  end
end
