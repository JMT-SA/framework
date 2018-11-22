# frozen_string_literal: true

module PackMaterialApp
  class MrSku < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_product_variant_id, Types::Integer
    attribute :owner_party_role_id, Types::Integer
    attribute :mr_delivery_item_batch_id, Types::Integer
    attribute :batch_number, Types::String
    attribute :is_consignment_stock, Types::Bool
    attribute :initial_quantity, Types::Decimal
    attribute :sku_number, Types::Integer
  end
end
