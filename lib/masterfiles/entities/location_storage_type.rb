# frozen_string_literal: true

module MasterfilesApp
  class LocationStorageType < Dry::Struct
    attribute :id, Types::Integer
    attribute :storage_type_code, Types::String
    attribute :location_short_code_prefix, Types::String
  end
end
