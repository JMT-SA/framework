# frozen_string_literal: true

module PackMaterialApp
  MrPurchaseInvoiceCostSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:mr_cost_type_id).maybe(:integer)
    required(:mr_delivery_id).maybe(:integer)
    required(:amount).maybe(:decimal)
  end
end
