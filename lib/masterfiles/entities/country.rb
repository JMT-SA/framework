# frozen_string_literal: true

module MasterfilesApp
  class Country < Dry::Struct
    attribute :id, Types::Integer
    attribute :destination_region_id, Types::Integer
    attribute :country_name, Types::String
    attribute :region_name, Types::String
    attribute :iso_country_code, Types::String
    attribute? :active, Types::Bool
  end
end
