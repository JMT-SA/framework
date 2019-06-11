# frozen_string_literal: true

module PackMaterialApp
  MrDeliveryItemSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:mr_delivery_id, :integer).maybe(:int?)
    required(:mr_purchase_order_item_id, :integer).filled(:int?)
    required(:mr_product_variant_id, :integer).maybe(:int?)
    required(:quantity_on_note, :decimal).maybe(:decimal?)
    required(:quantity_over_supplied, :decimal).maybe(:decimal?)
    required(:quantity_under_supplied, :decimal).maybe(:decimal?)
    required(:quantity_received, :decimal).maybe(:decimal?)
    optional(:invoiced_unit_price, :decimal).maybe(:decimal?)
    required(:remarks, Types::StrippedString).maybe(:str?)
  end
end
