# frozen_string_literal: true

RoleSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:name).maybe(:str?)
  required(:active).maybe(:bool?)
end