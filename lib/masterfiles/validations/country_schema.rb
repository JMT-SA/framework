# frozen_string_literal: true

module MasterfilesApp
  CountrySchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    optional(:destination_region_id, :integer).filled(:int?)
    required(:country_name, Types::StrippedString).filled(:str?)
    required(:iso_country_code, Types::StrippedString).filled(:str?)
  end
end
