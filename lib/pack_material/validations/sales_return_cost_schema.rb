# frozen_string_literal: true

module PackMaterialApp
  SalesReturnCostSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:mr_sales_return_id, :integer).filled(:int?)
    required(:mr_cost_type_id, :integer).filled(:int?)
    required(:amount, %i[nil decimal]).maybe(:decimal?)
  end
end
