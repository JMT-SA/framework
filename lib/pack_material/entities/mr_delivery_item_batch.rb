# frozen_string_literal: true

module PackMaterialApp
  class MrDeliveryItemBatch < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_delivery_item_id, Types::Integer
    attribute :client_batch_number, Types::String
    attribute :quantity_on_note, Types::Decimal
    attribute :quantity_received, Types::Decimal
  end
end
