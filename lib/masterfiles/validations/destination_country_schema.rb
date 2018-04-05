# frozen_string_literal: true

DestinationCountrySchema = Dry::Validation.Form do
  optional(:id, :int).filled(:int?)
  required(:destination_region_id, :int).filled(:int?)
  required(:country_name, Types::StrippedString).filled(:str?)
end
