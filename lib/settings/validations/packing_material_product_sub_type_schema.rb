# frozen_string_literal: true

PackingMaterialProductSubTypeSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:packing_material_product_type_id).filled(:int?)
  required(:packing_material_sub_type_name).filled(:str?)
end
