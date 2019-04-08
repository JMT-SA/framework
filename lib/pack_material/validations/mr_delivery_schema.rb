# frozen_string_literal: true

module PackMaterialApp
  MrDeliverySchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    optional(:receipt_transaction_id, :integer).maybe(:int?)
    optional(:putaway_transaction_id, :integer).maybe(:int?)
    required(:transporter_party_role_id, :integer).maybe(:int?)
    required(:receipt_location_id, :integer).filled(:int?)
    required(:driver_name, Types::StrippedString).filled(:str?)
    required(:client_delivery_ref_number, Types::StrippedString).filled(:str?)
    optional(:delivery_number, :integer).filled(:int?)
    required(:vehicle_registration, Types::StrippedString).filled(:str?)
    required(:supplier_invoice_ref_number, Types::StrippedString).maybe(:str?)
  end

  MrDeliveryPutawaySchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:delivery_number, :integer).filled(:int?)
    required(:delivery_number_scan_field, Types::StrippedString).maybe(:str?)
    required(:location, Types::StrippedString).filled(:str?)
    required(:location_scan_field, Types::StrippedString).maybe(:str?)
    required(:sku_number, :integer).filled(:int?)
    required(:sku_number_scan_field, Types::StrippedString).maybe(:str?)
    required(:quantity, :integer).filled(:int?)
  end
end
