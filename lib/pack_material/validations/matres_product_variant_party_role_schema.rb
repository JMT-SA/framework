# frozen_string_literal: true

module PackMaterialApp
  NewMatresProductVariantPartyRoleSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:material_resource_product_variant_id, :int).filled(:int?)
    optional(:supplier_id, :int).filled(:int?)
    optional(:customer_id, :int).filled(:int?)
    required(:party_stock_code, Types::StrippedString).filled(:str?)
    optional(:supplier_lead_time, :int).filled(:int?)
    optional(:is_preferred_supplier, :bool).filled(:bool?)
  end

  UpdateMatresProductVariantPartyRoleSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:material_resource_product_variant_id, :int).filled(:int?)
    optional(:supplier_id, :int).maybe(:int?)
    optional(:customer_id, :int).maybe(:int?)
    required(:party_stock_code, Types::StrippedString).filled(:str?)
    optional(:supplier_lead_time, :int).maybe(:int?)
    optional(:is_preferred_supplier, :bool).filled(:bool?)
  end
end
