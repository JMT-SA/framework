# frozen_string_literal: true

module PackMaterialApp
  MrDeliverySchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    optional(:receipt_transaction_id).maybe(:integer)
    optional(:putaway_transaction_id).maybe(:integer)
    required(:transporter_party_role_id).maybe(:integer)
    required(:receipt_location_id).filled(:integer)
    required(:driver_name).filled(Types::StrippedString)
    required(:client_delivery_ref_number).filled(Types::StrippedString)
    optional(:delivery_number).filled(:integer)
    required(:vehicle_registration).filled(Types::StrippedString)
    optional(:mr_purchase_order_id).maybe(:integer)
  end

  MrDeliveryPurchaseInvoiceSchema = Dry::Schema.Params do
    required(:supplier_invoice_ref_number).filled(Types::StrippedString)
    required(:supplier_invoice_date).filled(Types::DateTime)
  end

  MrDeliveryPutawaySchema = Dry::Schema.Params do
    required(:delivery_number).filled(:integer)
    required(:delivery_number_scan_field).maybe(Types::StrippedString)
    required(:location).filled(Types::StrippedString)
    required(:location_scan_field).maybe(Types::StrippedString)
    required(:sku_number).filled(:integer)
    required(:sku_number_scan_field).maybe(Types::StrippedString)
    required(:quantity).filled(:integer)
  end
end
