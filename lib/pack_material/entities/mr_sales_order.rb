# frozen_string_literal: true

module PackMaterialApp
  class MrSalesOrder < Dry::Struct
    attribute :id, Types::Integer
    attribute :customer_party_role_id, Types::Integer
    attribute :dispatch_location_id, Types::Integer
    attribute :issue_transaction_id, Types::Integer
    attribute :vehicle_job_id, Types::Integer
    attribute :vat_type_id, Types::Integer
    attribute :account_code_id, Types::Integer
    attribute :account_code, Types::String
    attribute :erp_customer_number, Types::String
    attribute :erp_invoice_number, Types::String
    attribute :created_by, Types::String
    attribute :fin_object_code, Types::String
    attribute :sales_order_number, Types::Integer
    attribute :shipped_at, Types::DateTime
    attribute :integration_error, Types::Bool
    attribute :integration_completed, Types::Bool
    attribute :shipped, Types::Bool
    attribute :status, Types::Bool
  end
end
