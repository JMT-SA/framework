# frozen_string_literal: true

module MasterfilesApp
  CountrySchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    optional(:destination_region_id).filled(:integer)
    required(:country_name).filled(Types::StrippedString)
    required(:iso_country_code).filled(Types::StrippedString)
  end
end
