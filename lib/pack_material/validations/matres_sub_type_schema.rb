# frozen_string_literal: true

module PackMaterialApp
  MatresSubTypeSchema = Dry::Validation.Form do
    optional(:id).filled(:int?)
    required(:material_resource_type_id).filled(:int?)
    required(:sub_type_name).filled(:str?)
  end

  MatresSubTypeConfigSchema = Dry::Validation.Form do
    optional(:id).filled(:int?)
    required(:product_code_separator).filled(:str?)
    required(:has_suppliers).filled(:bool?)
    required(:has_marketers).filled(:bool?)
    required(:has_retailer).filled(:bool?)
  end

  MatresSubTypeConfigColumnsSchema = Dry::Validation.Form do
    required(:chosen_column_ids).filled { each(:int?) }
    required(:columncodes_sorted_ids).filled { each(:int?) }
    required(:variantcolumncodes_sorted_ids).maybe { each(:int?) }
  end
end
