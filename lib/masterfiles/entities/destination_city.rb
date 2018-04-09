# frozen_string_literal: true

module MasterfilesApp
  class DestinationCity < Dry::Struct
    attribute :id, Types::Int
    attribute :destination_country_id, Types::Int
    attribute :city_name, Types::String
    attribute :country_name, Types::String
    attribute :region_name, Types::String
  end
end
