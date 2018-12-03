# frozen_string_literal: true

module PackMaterialApp
  PurchaseOrderSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:mr_delivery_term_id, :integer).maybe(:int?)
    required(:supplier_party_role_id, :integer).maybe(:int?)
    required(:mr_vat_type_id, :integer).maybe(:int?)
    required(:delivery_address_id, :integer).maybe(:int?)
    required(:purchase_account_code, Types::StrippedString).maybe(:str?)
    required(:fin_object_code, Types::StrippedString).maybe(:str?)
    required(:valid_until, :date_time).maybe(:date_time?)
  end
end
