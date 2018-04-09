# frozen_string_literal: true

module MasterfilesApp
  class DestinationRegion < Dry::Struct
    attribute :id, Types::Int
    attribute :destination_region_name, Types::String
  end
end
