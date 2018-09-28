# frozen_string_literal: true

module MasterfilesApp
  class Country < Dry::Struct
    attribute :id, Types::Integer
    attribute :destination_region_id, Types::Integer
    attribute :country_name, Types::String
    attribute :region_name, Types::String
  end
end
