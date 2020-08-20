# frozen_string_literal: true

module PackMaterialApp
  MrSalesReturnSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:mr_sales_order_id, :integer).filled(:int?)
    required(:issue_transaction_id, :integer).maybe(:int?)
    required(:remarks, Types::StrippedString).maybe(:str?)
    required(:sales_return_number, :integer).maybe(:int?)
    required(:receipt_location_id, :integer).filled(:int?)
  end

  NewMrSalesReturnSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:mr_sales_order_id, :integer).filled(:int?)
  end
end
