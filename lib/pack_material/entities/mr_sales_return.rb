# frozen_string_literal: true

module PackMaterialApp
  class MrSalesReturn < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_sales_order_id, Types::Integer
    attribute :issue_transaction_id, Types::Integer
    attribute :created_by, Types::String
    attribute :remarks, Types::String
    attribute :sales_return_number, Types::Integer
    attribute :completed, Types::Bool
    attribute :completed_by, Types::String
    attribute :verified, Types::Bool
    attribute :verified_by, Types::String
    attribute :receipt_location_id, Types::Integer
    attribute :integration_error, Types::Bool
  end

  class MrSalesReturnFlat < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_sales_order_id, Types::Integer
    attribute :sales_order_number, Types::Integer
    attribute :erp_customer_number, Types::Integer
    attribute :sales_return_number, Types::Integer
    attribute :issue_transaction_id, Types::Integer
    attribute :created_by, Types::String
    attribute :remarks, Types::String
    attribute :completed, Types::Bool
    attribute :completed_by, Types::String
    attribute :verified, Types::Bool
    attribute :verified_by, Types::String
    attribute :status, Types::String
    attribute :created_at, Types::DateTime
    attribute :updated_at, Types::DateTime
    attribute :receipt_location_id, Types::Integer
    attribute :integration_error, Types::Bool
  end
end
