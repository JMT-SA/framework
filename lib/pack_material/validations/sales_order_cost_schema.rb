# frozen_string_literal: true

module PackMaterialApp
  SalesOrderCostSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:mr_sales_order_id, :integer).filled(:int?)
    required(:mr_cost_type_id, :integer).filled(:int?)
    required(:amount, :decimal).maybe(:decimal?)
  end
end
