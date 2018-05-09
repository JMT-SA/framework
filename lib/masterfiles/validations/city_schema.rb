# frozen_string_literal: true

module MasterfilesApp
  CitySchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    optional(:destination_country_id, :int).filled(:int?)
    required(:city_name, Types::StrippedString).filled(:str?)
  end
end
