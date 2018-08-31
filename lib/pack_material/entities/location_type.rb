# frozen_string_literal: true

module PackMaterialApp
  class LocationType < Dry::Struct
    attribute :id, Types::Int
    attribute :location_type_code, Types::String
  end
end
