# frozen_string_literal: true

module PackMaterialApp
  MatresProductVariantSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:product_variant_id, :int).filled(:int?)
    required(:product_variant_table_name, Types::StrippedString).filled(:str?)
    required(:product_variant_number, :int).filled(:int?)
    required(:old_product_code, Types::StrippedString).maybe(:str?)
    required(:supplier_lead_time, :int).maybe(:int?)
    required(:minimum_stock_level, :int).maybe(:int?)
    required(:re_order_stock_level, :int).maybe(:int?)
  end
end
