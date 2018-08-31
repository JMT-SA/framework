# frozen_string_literal: true

module PackMaterialApp
  class Location < Dry::Struct
    attribute :id, Types::Int
    attribute :primary_storage_type_id, Types::Int
    attribute :location_type_id, Types::Int
    attribute :primary_assignment_id, Types::Int
    attribute :location_code, Types::String
    attribute :location_description, Types::String
    attribute :has_single_container, Types::Bool
    attribute :virtual_location, Types::Bool
    attribute :consumption_area, Types::Bool
    attribute :assignment_code, Types::String
    attribute :storage_type_code, Types::String
    attribute :location_type_code, Types::String
  end
end
