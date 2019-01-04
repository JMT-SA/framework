# frozen_string_literal: true

module PackMaterialApp
  MrDeliveryItemBatchSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:mr_delivery_item_id, :integer).filled(:int?)
    required(:client_batch_number, Types::StrippedString).maybe(:str?)
    required(:quantity_on_note, :decimal).maybe(:decimal?)
    required(:quantity_received, :decimal).maybe(:decimal?)
  end
end
