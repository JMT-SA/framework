# frozen_string_literal: true

module PackMaterialApp
  MrPurchaseOrderItemSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:mr_purchase_order_id).maybe(:integer)
    required(:mr_product_variant_id).maybe(:integer)
    required(:inventory_uom_id).maybe(:integer)
    required(:quantity_required).maybe(:decimal)
    required(:unit_price).maybe(:decimal)
  end
end
