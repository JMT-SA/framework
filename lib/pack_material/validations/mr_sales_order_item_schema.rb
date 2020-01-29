# frozen_string_literal: true

module PackMaterialApp
  MrSalesOrderItemSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:mr_sales_order_id, :integer).filled(:int?)
    required(:mr_product_variant_id, :integer).maybe(:int?)
    required(:quantity_required, :decimal).filled(:decimal?, gt?: 0)
    required(:unit_price, :decimal).filled(:decimal?, gt?: 0)
  end

  MrSalesOrderItemInlineSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:column_name, Types::StrippedString).filled(:str?)
    required(:column_value, :decimal).maybe(:decimal?, gteq?: 0)
  end
end
