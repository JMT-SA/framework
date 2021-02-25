# frozen_string_literal: true

module PackMaterialApp
  MrSalesOrderItemSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:mr_sales_order_id).filled(:integer)
    required(:mr_product_variant_id).maybe(:integer)
    required(:quantity_required).filled(:decimal, gt?: 0)
    required(:unit_price).filled(:decimal, gt?: 0)
    optional(:returned).maybe(:bool)
  end

  MrSalesOrderItemInlineSchema = Dry::Schema.Params do
    required(:column_name).filled(Types::StrippedString)
    required(:column_value).maybe(:decimal, gteq?: 0)
  end
end
