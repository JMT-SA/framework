# frozen_string_literal: true

module PackMaterialApp
  class MrDelivery < Dry::Struct
    attribute :id, Types::Integer
    attribute :receipt_transaction_id, Types::Integer
    attribute :putaway_transaction_id, Types::Integer
    attribute :transporter_party_role_id, Types::Integer
    attribute :receipt_location_id, Types::Integer
    attribute :transporter, Types::String
    attribute :driver_name, Types::String
    attribute :client_delivery_ref_number, Types::String
    attribute :delivery_number, Types::Integer
    attribute :waybill_number, Types::Integer
    attribute :vehicle_registration, Types::String
    attribute :supplier_invoice_ref_number, Types::String
    attribute :verified, Types::Bool
    attribute :accepted_over_supply, Types::Bool
    attribute :accepted_qty_difference, Types::Bool
    attribute :reviewed, Types::Bool
    attribute :putaway_completed, Types::Bool
    attribute :status, Types::String
    attribute :supplier_invoice_date, Types::Date
    attribute :invoice_completed, Types::Bool
    attribute? :erp_purchase_order_number, Types::String.optional
    attribute? :erp_purchase_invoice_number, Types::String.optional
    attribute? :purchase_order_numbers, Types::String.optional
  end
end
