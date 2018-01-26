# frozen_string_literal: true

PackingMaterialProductTypeSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:packing_material_type_name).filled(:str?)
end
