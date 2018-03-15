# frozen_string_literal: true

MaterialResourceProductColumnSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:material_resource_domain_id).filled(:int?)
  required(:column_name).filled(:str?)
  required(:group_name).filled(:str?)
  required(:is_variant_column).filled(:bool?)
end
