# frozen_string_literal: true

DestinationCitySchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:destination_country_id).filled(:int?)
  required(:city_name).filled(:str?)
end
