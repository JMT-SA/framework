# frozen_string_literal: true

module PackMaterialApp
  MrSalesOrderSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:customer_party_role_id, :integer).filled(:int?)
    required(:dispatch_location_id, :integer).filled(:int?)
    optional(:issue_transaction_id, :integer).maybe(:int?)
    required(:vat_type_id, :integer).filled(:int?)
    required(:account_code_id, :integer).filled(:int?)
    optional(:erp_customer_number, Types::StrippedString).filled(:str?)
    optional(:created_by, Types::StrippedString).maybe(:str?)
    required(:fin_object_code, Types::StrippedString).maybe(:str?)
    required(:client_reference_number, Types::StrippedString).maybe(:str?)
    optional(:sales_order_number, :integer).maybe(:int?)
    optional(:shipped_at, :date_time).maybe(:date_time?)
    optional(:integration_error, :bool).maybe(:bool?)
    optional(:integration_completed, :bool).maybe(:bool?)
    optional(:shipped, :bool).maybe(:bool?)
    required(:returned, :bool).maybe(:bool?)
  end

  NewMrSalesOrderSchema = Dry::Validation.Params do
    required(:customer_party_role_id, :integer).filled(:int?)
  end
end
