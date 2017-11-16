# frozen_string_literal: true

DestinationCountrySchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:destination_region_id).filled(:int?)
  required(:country_name).filled(:str?)
end
