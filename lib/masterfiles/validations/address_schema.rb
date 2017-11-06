# frozen_string_literal: true

AddressSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:address_type_id).filled(:int?)
  required(:address_line_1).filled(:str?)
  required(:address_line_2).maybe(:str?)
  required(:address_line_3).maybe(:str?)
  required(:city).maybe(:str?)
  required(:postal_code).maybe(:str?)
  required(:country).maybe(:str?)
  required(:active).maybe(:bool?)
end
