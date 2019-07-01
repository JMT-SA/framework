# frozen_string_literal: true

module PackMaterialApp
  MrInventoryTransactionSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:mr_inventory_transaction_type_id, :integer).maybe(:int?)
    required(:to_location_id, :integer).maybe(:int?)
    required(:business_process_id, :integer).maybe(:int?)
    required(:created_by, Types::StrippedString).filled(:str?)
    required(:ref_no, Types::StrippedString).maybe(:str?)
    required(:is_adhoc, :bool).maybe(:bool?)
  end

  AdhocTransactionSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:sku_number, :integer).maybe(:int?)
    required(:business_process_id, :integer).maybe(:int?)
    required(:to_location_id, :integer).maybe(:int?)
    optional(:vehicle_id, :integer).maybe(:int?)
    required(:quantity, :decimal).maybe(:decimal?, gt?: 0)
    required(:ref_no, Types::StrippedString).maybe(:str?)
    required(:is_adhoc, :bool).maybe(:bool?)
  end
end
