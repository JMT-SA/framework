# frozen_string_literal: true

module PackMaterialApp
  class VehicleType < Dry::Struct
    attribute :id, Types::Integer
    attribute :type_code, Types::String
  end
end
