# frozen_string_literal: true

module PackMaterialApp
  NewMatresProductVariantPartyRoleSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:material_resource_product_variant_id, :integer).filled(:int?)
    optional(:supplier_id, :integer).filled(:int?)
    optional(:customer_id, :integer).filled(:int?)
    required(:party_stock_code, Types::StrippedString).filled(:str?)
    optional(:supplier_lead_time, :integer).filled(:int?)
    optional(:is_preferred_supplier, :bool).filled(:bool?)
  end

  UpdateMatresProductVariantPartyRoleSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:material_resource_product_variant_id, :integer).filled(:int?)
    optional(:supplier_id, :integer).maybe(:int?)
    optional(:customer_id, :integer).maybe(:int?)
    required(:party_stock_code, Types::StrippedString).filled(:str?)
    optional(:supplier_lead_time, :integer).maybe(:int?)
    optional(:is_preferred_supplier, :bool).filled(:bool?)
  end
end
