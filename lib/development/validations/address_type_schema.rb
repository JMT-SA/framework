# frozen_string_literal: true

AddressTypeSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:address_type).filled(:str?)
  required(:active).maybe(:bool?)
end