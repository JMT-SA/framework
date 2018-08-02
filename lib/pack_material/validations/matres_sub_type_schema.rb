# frozen_string_literal: true

module PackMaterialApp
  MatresSubTypeSchema = Dry::Validation.Form do
    optional(:id).filled(:int?)
    required(:material_resource_type_id).filled(:int?)
    required(:sub_type_name).filled(:str?)
    required(:short_code, Types::StrippedString).filled(:str?)
    required(:product_code_separator).filled(:str?)
    required(:has_suppliers).filled(:bool?)
    required(:has_marketers).filled(:bool?)
    required(:has_retailers).filled(:bool?)
  end

  MatresSubTypeConfigColumnsSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    required(:chosen_column_ids, Types::ArrayFromString).filled { each(:int?) }
    required(:columncodes_sorted_ids, Types::ArrayFromString).filled(:array?) { each(:int?) }
  end
end
