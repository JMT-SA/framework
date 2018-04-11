# frozen_string_literal: true

module MasterfilesApp
  DestinationRegionSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:destination_region_name, Types::StrippedString).filled(:str?)
  end
end
