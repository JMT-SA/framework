# frozen_string_literal: true

module PackMaterialApp
  MatresSubTypeSchema = Dry::Validation.Params do
    optional(:id).filled(:int?)
    required(:material_resource_type_id).filled(:int?)
    required(:sub_type_name).filled(:str?)
    required(:short_code, Types::StrippedString).filled(:str?)
    optional(:product_code_separator).filled(:str?)
    optional(:has_suppliers).filled(:bool?)
    optional(:has_marketers).filled(:bool?)
    optional(:has_retailers).filled(:bool?)
  end

  MatresSubTypeConfigColumnsSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:chosen_column_ids, Types::ArrayFromString).filled { each(:int?) }
    required(:columncodes_sorted_ids, Types::ArrayFromString).filled(:array?) { each(:int?) }
    required(:variant_product_code_column_ids, Types::Array).filled(:array?)
  end
end
