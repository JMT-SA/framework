# frozen_string_literal: true

ProductTypeSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:packing_material_product_type_id).filled(:int?)
  required(:packing_material_product_sub_type_id).filled(:int?)
end
