# frozen_string_literal: true

module PackMaterialApp
  class MrGoodsReturnedNoteItemContract < Dry::Validation::Contract
    params do
      optional(:id).filled(:integer)
      required(:mr_goods_returned_note_id).filled(:integer)
      # required(:delivery_item).maybe(:hash)
      optional(:mr_delivery_item_id).maybe(:integer)
      optional(:mr_delivery_item_batch_id).maybe(:integer)
      optional(:remarks).maybe(Types::StrippedString)
      optional(:quantity_returned).maybe(:decimal)
    end

    rule(:mr_delivery_item_batch_id, :mr_delivery_item_id) do
      base.failure('One of delivery item or batch item must be present') unless values[:mr_delivery_item_batch_id] || values[:mr_delivery_item_id]
    end
  end
  # MrGoodsReturnedNoteItemSchema = Dry::Schema.Params do
  #   optional(:id, :integer).filled(:int?)
  #   required(:mr_goods_returned_note_id, :integer).filled(:int?)
  #   # required(:delivery_item, :hash).maybe(:int?)
  #   optional(:mr_delivery_item_id, :integer).maybe(:int?)
  #   optional(:mr_delivery_item_batch_id, :integer).maybe(:int?)
  #   optional(:remarks, Types::StrippedString).maybe(:str?)
  #   optional(:quantity_returned, :decimal).maybe(:decimal?)
  #
  #   validate(delivery_item: %i[mr_delivery_item_id mr_delivery_item_batch_id]) do |item_id, item_batch_id|
  #     item_id || item_batch_id
  #   end
  # end

  MrGoodsReturnedNoteItemInlineQuantitySchema = Dry::Schema.Params do
    required(:column_name).filled(Types::StrippedString)
    required(:column_value).maybe(:decimal, gt?: 0)
  end

  MrGoodsReturnedNoteItemInlineRemarksSchema = Dry::Schema.Params do
    required(:column_name).filled(Types::StrippedString)
    required(:column_value).maybe(Types::StrippedString)
  end
end
