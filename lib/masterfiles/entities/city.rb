# frozen_string_literal: true

module MasterfilesApp
  class City < Dry::Struct
    attribute :id, Types::Integer
    attribute :destination_country_id, Types::Integer
    attribute :city_name, Types::String
    attribute :country_name, Types::String
    attribute :region_name, Types::String
  end
end
