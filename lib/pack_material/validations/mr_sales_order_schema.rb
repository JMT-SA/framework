# frozen_string_literal: true

module PackMaterialApp
  MrSalesOrderSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:customer_party_role_id).filled(:integer)
    required(:dispatch_location_id).filled(:integer)
    optional(:issue_transaction_id).maybe(:integer)
    required(:vat_type_id).filled(:integer)
    required(:account_code_id).filled(:integer)
    optional(:erp_customer_number).filled(Types::StrippedString)
    optional(:created_by).maybe(Types::StrippedString)
    required(:fin_object_code).maybe(Types::StrippedString)
    required(:client_reference_number).maybe(Types::StrippedString)
    optional(:sales_order_number).maybe(:integer)
    optional(:shipped_at).maybe(:date_time)
    optional(:integration_error).maybe(:bool)
    optional(:integration_completed).maybe(:bool)
    optional(:shipped).maybe(:bool)
    optional(:returned).maybe(:bool)
  end

  NewMrSalesOrderSchema = Dry::Schema.Params do
    required(:customer_party_role_id).filled(:integer)
  end
end
