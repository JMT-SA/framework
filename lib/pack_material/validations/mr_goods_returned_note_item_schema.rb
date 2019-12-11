# frozen_string_literal: true

module PackMaterialApp
  MrGoodsReturnedNoteItemSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:mr_goods_returned_note_id, :integer).filled(:int?)
    # required(:delivery_item, :hash).maybe(:int?)
    optional(:mr_delivery_item_id, :integer).maybe(:int?)
    optional(:mr_delivery_item_batch_id, :integer).maybe(:int?)
    optional(:remarks, Types::StrippedString).maybe(:str?)
    optional(:quantity_returned, :decimal).maybe(:decimal?)

    validate(delivery_item: %i[mr_delivery_item_id mr_delivery_item_batch_id]) do |item_id, item_batch_id|
      item_id || item_batch_id
    end
  end

  MrGoodsReturnedNoteItemInlineQuantitySchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:column_name, Types::StrippedString).filled(:str?)
    required(:column_value, :decimal).maybe(:decimal?, gt?: 0)
  end

  MrGoodsReturnedNoteItemInlineRemarksSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:column_name, Types::StrippedString).filled(:str?)
    required(:column_value, Types::StrippedString).maybe(:str?)
  end
end
