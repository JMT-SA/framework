# frozen_string_literal: true

module PackMaterialApp
  MrDeliverySchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    optional(:receipt_transaction_id, :integer).maybe(:int?)
    optional(:putaway_transaction_id, :integer).maybe(:int?)
    required(:transporter_party_role_id, :integer).maybe(:int?)
    required(:driver_name, Types::StrippedString).filled(:str?)
    required(:client_delivery_ref_number, Types::StrippedString).filled(:str?)
    optional(:delivery_number, :integer).filled(:int?)
    required(:vehicle_registration, Types::StrippedString).filled(:str?)
    required(:supplier_invoice_ref_number, Types::StrippedString).maybe(:str?)
  end
end
