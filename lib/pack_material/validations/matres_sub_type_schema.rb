# frozen_string_literal: true

module PackMaterialApp
  MatresSubTypeSchema = Dry::Validation.Form do
    optional(:id).filled(:int?)
    required(:material_resource_type_id).filled(:int?)
    required(:sub_type_name).filled(:str?)
  end
end
