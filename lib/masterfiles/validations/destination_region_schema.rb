# frozen_string_literal: true

DestinationRegionSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:destination_region_name).filled(:str?)
end
