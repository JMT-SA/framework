# frozen_string_literal: true

module PackMaterialApp
  MrGoodsReturnedNoteSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:mr_delivery_id, :integer).filled(:int?)
    required(:issue_transaction_id, :integer).maybe(:int?)
    required(:dispatch_location_id, :integer).filled(:int?)
    optional(:created_by, Types::StrippedString).filled(:str?)
    required(:remarks, Types::StrippedString).maybe(:str?)
  end

  NewMrGoodsReturnedNoteSchema = Dry::Validation.Params do
    required(:mr_delivery_id, :integer).filled(:int?)
  end
end
