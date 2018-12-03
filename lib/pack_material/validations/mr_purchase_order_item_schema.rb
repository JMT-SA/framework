# frozen_string_literal: true

module PackMaterialApp
  MrPurchaseOrderItemSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:mr_purchase_order_id, :integer).maybe(:int?)
    required(:mr_product_variant_id, :integer).maybe(:int?)
    required(:purchasing_uom_id, :integer).maybe(:int?)
    required(:inventory_uom_id, :integer).maybe(:int?)
    required(:quantity_required, :decimal).maybe(:decimal?)
    required(:unit_price, :decimal).maybe(:decimal?)
  end
end
