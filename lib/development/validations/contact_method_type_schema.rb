# frozen_string_literal: true

ContactMethodTypeSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:contact_method_type).filled(:str?)
end
