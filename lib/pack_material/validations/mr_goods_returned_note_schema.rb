# frozen_string_literal: true

module PackMaterialApp
  MrGoodsReturnedNoteSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:mr_delivery_id).filled(:integer)
    required(:issue_transaction_id).maybe(:integer)
    required(:dispatch_location_id).filled(:integer)
    optional(:created_by).filled(Types::StrippedString)
    required(:remarks).maybe(Types::StrippedString)
  end

  NewMrGoodsReturnedNoteSchema = Dry::Schema.Params do
    required(:mr_delivery_id).filled(:integer)
  end
end
