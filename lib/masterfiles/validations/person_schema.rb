# frozen_string_literal: true

PersonSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  # required(:party_id).filled(:int?)
  required(:surname).filled(:str?)
  required(:first_name).filled(:str?)
  required(:title).filled(:str?)
  required(:vat_number).maybe(:str?)
  optional(:role_id).maybe(:int?)
  # required(:active).maybe(:bool?)
end
