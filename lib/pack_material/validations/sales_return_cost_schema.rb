# frozen_string_literal: true

module PackMaterialApp
  SalesReturnCostSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:mr_sales_return_id).filled(:integer)
    required(:mr_cost_type_id).filled(:integer)
    required(:amount).maybe(%i[nil decimal])
  end
end
