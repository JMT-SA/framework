# frozen_string_literal: true

CultivarGroupSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:cultivar_group_code).filled(:str?)
  required(:description).maybe(:str?)
end
