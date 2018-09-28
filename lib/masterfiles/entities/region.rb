# frozen_string_literal: true

module MasterfilesApp
  class Region < Dry::Struct
    attribute :id, Types::Integer
    attribute :destination_region_name, Types::String
  end
end
