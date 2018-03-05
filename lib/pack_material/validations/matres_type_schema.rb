# frozen_string_literal: true

module PackMaterialApp
  MatresTypeSchema = Dry::Validation.Form do
    optional(:id).filled(:int?)
    required(:material_resource_domain_id).filled(:int?)
    required(:type_name).filled(:str?)
  end
end
