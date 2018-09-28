# frozen_string_literal: true

module MasterfilesApp
  CitySchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    optional(:destination_country_id, :integer).filled(:int?)
    required(:city_name, Types::StrippedString).filled(:str?)
  end
end
