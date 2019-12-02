# frozen_string_literal: true

module PackMaterialApp
  class MrGoodsReturnedNoteItem < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_goods_returned_note_id, Types::Integer
    attribute :mr_delivery_item_id, Types::Integer
    attribute :mr_delivery_item_batch_id, Types::Integer
    attribute :remarks, Types::String
    attribute :quantity_returned, Types::Decimal
    attribute? :sku_number, Types::Integer
    attribute? :product_variant_code, Types::String
    attribute? :product_variant_number, Types::Integer
    attribute? :status, Types::String
  end
end
