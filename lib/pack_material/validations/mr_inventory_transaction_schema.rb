# frozen_string_literal: true

module PackMaterialApp
  MrInventoryTransactionSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:mr_inventory_transaction_type_id).maybe(:integer)
    required(:to_location_id).maybe(:integer)
    required(:business_process_id).maybe(:integer)
    required(:created_by).filled(Types::StrippedString)
    required(:ref_no).maybe(Types::StrippedString)
    required(:is_adhoc).maybe(:bool)
  end

  AdhocTransactionSchema = Dry::Schema.Params do
    required(:sku_number).maybe(:integer)
    required(:business_process_id).maybe(:integer)
    required(:to_location_id).maybe(:integer)
    optional(:vehicle_id).maybe(:integer)
    required(:quantity).maybe(:decimal, gt?: 0)
    required(:ref_no).filled(Types::StrippedString)
    required(:is_adhoc).maybe(:bool)
  end

  AdhocRmdMoveStockSchema = Dry::Schema.Params do
    required(:sku_number).filled(:integer)
    required(:business_process_id).filled(:integer)
    optional(:to_location_id).filled(:integer)
    required(:from_location_id).filled(:integer)
    required(:quantity).filled(:decimal, gt?: 0)
    required(:ref_no).filled(Types::StrippedString)
  end

  FinalAdhocRmdMoveStockSchema = Dry::Schema.Params do
    required(:sku_ids).filled(:array).each(:integer)
    required(:business_process_id).filled(:integer)
    required(:to_location_id).filled(:integer)
    required(:quantity).filled(:decimal, gt?: 0)
    required(:ref_no).filled(Types::StrippedString)
    required(:user_name).filled(Types::StrippedString)
    required(:location_id).filled(:integer)
  end
end
