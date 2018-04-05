# frozen_string_literal: true

DestinationRegionSchema = Dry::Validation.Form do
  configure { config.type_specs = true }

  optional(:id, :int).filled(:int?)
  required(:destination_region_name, Types::StrippedString).filled(:str?)
end
