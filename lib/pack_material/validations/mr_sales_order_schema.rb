# frozen_string_literal: true

module PackMaterialApp
  MrSalesOrderSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:customer_party_role_id, :integer).maybe(:int?)
    required(:dispatch_location_id, :integer).maybe(:int?)
    required(:issue_transaction_id, :integer).maybe(:int?)
    required(:vat_type_id, :integer).maybe(:int?)
    required(:account_code_id, :integer).maybe(:int?)
    required(:erp_customer_number, Types::StrippedString).maybe(:str?)
    required(:created_by, Types::StrippedString).maybe(:str?)
    required(:fin_object_code, Types::StrippedString).maybe(:str?)
    required(:sales_order_number, :integer).maybe(:int?)
    required(:valid_until, :date_time).maybe(:date_time?)
    required(:shipped_at, :date_time).maybe(:date_time?)
    required(:integration_error, :bool).maybe(:bool?)
    required(:integration_completed, :bool).maybe(:bool?)
    required(:shipped, :bool).maybe(:bool?)
  end
end
