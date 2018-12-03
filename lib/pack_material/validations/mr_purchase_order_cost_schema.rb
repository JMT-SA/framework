# frozen_string_literal: true

module PackMaterialApp
  MrPurchaseOrderCostSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:mr_cost_type_id, :integer).maybe(:int?)
    required(:mr_purchase_order_id, :integer).maybe(:int?)
    required(:amount, :decimal).maybe(:decimal?)
  end
end
