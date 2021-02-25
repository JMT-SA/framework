# frozen_string_literal: true

module PackMaterialApp
  MrDeliveryItemBatchSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:mr_delivery_item_id).filled(:integer)
    required(:client_batch_number).filled(Types::StrippedString)
    required(:quantity_on_note).maybe(:decimal)
    required(:quantity_received).maybe(:decimal)
  end

  PrintSKUBarcodeSchema = Dry::Schema.Params do
    optional(:mr_internal_batch_number_id).filled(:int?)
    optional(:mr_delivery_item_batch_id).filled(:int?)
    optional(:mr_sku_id).filled(:int?)
  end
end
