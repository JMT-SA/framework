# frozen_string_literal: true

module MasterfilesApp
  class LocationType < Dry::Struct
    attribute :id, Types::Integer
    attribute :location_type_code, Types::String
  end
end
