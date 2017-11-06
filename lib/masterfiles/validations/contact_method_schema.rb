# frozen_string_literal: true

ContactMethodSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:contact_method_type_id).filled(:int?)
  required(:contact_method_code).filled(:str?)
  required(:active).maybe(:bool?)
end
