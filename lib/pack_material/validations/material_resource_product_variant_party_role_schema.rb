# frozen_string_literal: true

module PackMaterialApp
  MaterialResourceProductVariantPartyRoleSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:material_resource_product_variant_id, :int).filled(:int?)
    required(:supplier_id, :int).maybe(:int?)
    required(:customer_id, :int).maybe(:int?)
    required(:party_stock_code, Types::StrippedString).maybe(:str?)
    required(:supplier_lead_time, :int).maybe(:int?)
    required(:is_preferred_supplier, :bool).maybe(:bool?)
  end
end
