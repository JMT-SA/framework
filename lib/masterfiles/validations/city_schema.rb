# frozen_string_literal: true

module MasterfilesApp
  CitySchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    optional(:destination_country_id).filled(:integer)
    required(:city_name).filled(Types::StrippedString)
  end
end
