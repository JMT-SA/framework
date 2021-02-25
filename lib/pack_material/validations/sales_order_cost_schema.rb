# frozen_string_literal: true

module PackMaterialApp
  SalesOrderCostSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:mr_sales_order_id).filled(:integer)
    required(:mr_cost_type_id).filled(:integer)
    required(:amount).maybe(:decimal)
  end
end
