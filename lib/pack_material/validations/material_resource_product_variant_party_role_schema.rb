# frozen_string_literal: true

module PackMaterialApp
  MaterialResourceProductVariantPartyRoleSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:material_resource_product_variant_id).filled(:integer)
    required(:supplier_id).maybe(:integer)
    required(:customer_id).maybe(:integer)
    required(:party_stock_code).maybe(Types::StrippedString)
    required(:supplier_lead_time).maybe(:integer)
    required(:is_preferred_supplier).maybe(:bool)
  end
end
