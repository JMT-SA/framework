# frozen_string_literal: true

module PackMaterialApp
  class MrDelivery < Dry::Struct
    attribute :id, Types::Integer
    attribute :receipt_transaction_id, Types::Integer
    attribute :putaway_transaction_id, Types::Integer
    attribute :transporter_party_role_id, Types::Integer
    attribute :transporter, Types::String
    attribute :driver_name, Types::String
    attribute :client_delivery_ref_number, Types::String
    attribute :delivery_number, Types::Integer
    attribute :vehicle_registration, Types::String
    attribute :supplier_invoice_ref_number, Types::String
    attribute :verified, Types::Bool
  end
end
