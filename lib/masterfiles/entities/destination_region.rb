# frozen_string_literal: true

class DestinationRegion < Dry::Struct
  attribute :id, Types::Int
  attribute :destination_region_name, Types::String
end
