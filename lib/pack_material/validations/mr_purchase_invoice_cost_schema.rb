# frozen_string_literal: true

module PackMaterialApp
  MrPurchaseInvoiceCostSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:mr_cost_type_id, :integer).maybe(:int?)
    required(:mr_delivery_id, :integer).maybe(:int?)
    required(:amount, :decimal).maybe(:decimal?)
  end
end
