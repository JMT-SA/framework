# frozen_string_literal: true

module PackMaterialApp
  class LocationStorageType < Dry::Struct
    attribute :id, Types::Integer
    attribute :storage_type_code, Types::String
  end
end
