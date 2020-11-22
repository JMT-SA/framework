# frozen_string_literal: true

module PackMaterialApp
  MrPurchaseOrderSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:mr_delivery_term_id).maybe(:integer)
    required(:account_code_id).maybe(:integer)
    required(:supplier_party_role_id).maybe(:integer)
    required(:mr_vat_type_id).maybe(:integer)
    required(:delivery_address_id).maybe(:integer)
    required(:fin_object_code).maybe(Types::StrippedString)
    required(:is_consignment_stock).maybe(:bool)
    required(:valid_until).maybe(:date_time)
    # required(:purchase_order_number).maybe(:integer)
    required(:remarks).maybe(Types::StrippedString)
  end
end
