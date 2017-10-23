# frozen_string_literal: true

ContactMethodTypeSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:contact_method_code).filled(:str?)
end
