# frozen_string_literal: true

module PackMaterialApp
  MatresProductVariantSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:product_variant_id, :integer).filled(:int?)
    required(:product_variant_table_name, Types::StrippedString).filled(:str?)
    required(:product_variant_number, :integer).filled(:int?)
    required(:old_product_code, Types::StrippedString).maybe(:str?)
    required(:supplier_lead_time, :integer).maybe(:int?)
    required(:minimum_stock_level, :integer).maybe(:int?)
    required(:re_order_stock_level, :integer).maybe(:int?)
    required(:use_fixed_batch_number, :bool).maybe(:bool?)
    required(:mr_internal_batch_number_id, :integer).maybe(:int?)
  end
end
