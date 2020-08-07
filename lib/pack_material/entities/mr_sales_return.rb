# frozen_string_literal: true

module PackMaterialApp
  class MrSalesReturn < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_sales_order_id, Types::Integer
    attribute :issue_transaction_id, Types::Integer
    attribute :created_by, Types::String
    attribute :remarks, Types::String
    attribute :sales_return_number, Types::Integer
  end
end
