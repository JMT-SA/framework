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
  # required(:non_variant_product_code_column_ids).each(:int?)
  required(:chosen_column_ids).filled { each(:int?) }
  required(:columncodes_sorted_ids).filled { each(:int?) }
  required(:variantcolumncodes_sorted_ids).maybe { each(:int?) }
end

MaterialResourceTypeConfigVariantCodeColumnsSchema = Dry::Validation.Form do
  required(:variant_product_code_column_ids).each(:int?)
end
