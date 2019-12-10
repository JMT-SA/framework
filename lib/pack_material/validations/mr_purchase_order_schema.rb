# frozen_string_literal: true

module PackMaterialApp
  MrPurchaseOrderSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:mr_delivery_term_id, :integer).maybe(:int?)
    required(:account_code_id, :integer).maybe(:int?)
    required(:supplier_party_role_id, :integer).maybe(:int?)
    required(:mr_vat_type_id, :integer).maybe(:int?)
    required(:delivery_address_id, :integer).maybe(:int?)
    required(:fin_object_code, Types::StrippedString).maybe(:str?)
    required(:is_consignment_stock, :bool).maybe(:bool?)
    required(:valid_until, :date_time).maybe(:date_time?)
    # required(:purchase_order_number, :integer).maybe(:int?)
    required(:remarks, Types::StrippedString).maybe(:str?)
  end
end
