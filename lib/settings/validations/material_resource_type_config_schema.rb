# frozen_string_literal: true

MaterialResourceTypeConfigSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:material_resource_sub_type_id).filled(:int?)
  required(:product_code_separator).filled(:str?)
  required(:has_suppliers).filled(:bool?)
  required(:has_marketers).filled(:bool?)
  required(:has_retailer).filled(:bool?)
end

MaterialResourceTypeConfigCodeColumnsSchema = Dry::Validation.Form do
  required(:non_variant_product_code_column_ids).each(:int?)
end

MaterialResourceTypeConfigVariantCodeColumnsSchema = Dry::Validation.Form do
  required(:variant_product_code_column_ids).each(:int?)
end
