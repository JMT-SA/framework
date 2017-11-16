# frozen_string_literal: true

CultivarSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:commodity_id).filled(:int?)
  required(:cultivar_group_id).maybe(:int?)
  required(:cultivar_name).filled(:str?)
  required(:description).maybe(:str?)
end
