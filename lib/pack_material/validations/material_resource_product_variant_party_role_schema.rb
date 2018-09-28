# frozen_string_literal: true

module PackMaterialApp
  MaterialResourceProductVariantPartyRoleSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:material_resource_product_variant_id, :integer).filled(:int?)
    required(:supplier_id, :integer).maybe(:int?)
    required(:customer_id, :integer).maybe(:int?)
    required(:party_stock_code, Types::StrippedString).maybe(:str?)
    required(:supplier_lead_time, :integer).maybe(:int?)
    required(:is_preferred_supplier, :bool).maybe(:bool?)
  end
end
