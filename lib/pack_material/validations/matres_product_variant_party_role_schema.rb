# frozen_string_literal: true

module PackMaterialApp
  NewMatresProductVariantPartyRoleSchema = Dry::Validation.Params do
    configure do
      config.type_specs = true

      def self.messages
        super.merge(en: { errors: { customer_or_supplier: 'must provide either customer or supplier' } })
      end
    end

    optional(:id, :integer).filled(:int?)
    required(:material_resource_product_variant_id, :integer).filled(:int?)
    optional(:supplier_id, :integer).maybe(:int?)
    optional(:customer_id, :integer).maybe(:int?)
    required(:party_stock_code, Types::StrippedString).filled(:str?)
    optional(:supplier_lead_time, :integer).filled(:int?)
    optional(:is_preferred_supplier, :bool).filled(:bool?)

    validate(customer_or_supplier: %i[customer_id supplier_id]) do |customer_id, supplier_id|
      customer_id || supplier_id
    end
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
