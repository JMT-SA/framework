# frozen_string_literal: true

module MasterfilesApp
  CountrySchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    optional(:destination_region_id, :int).filled(:int?)
    required(:country_name, Types::StrippedString).filled(:str?)
  end
end
