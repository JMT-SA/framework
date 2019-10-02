# frozen_string_literal: true

module PackMaterialApp
  class Vehicle < Dry::Struct
    attribute :id, Types::Integer
    attribute :vehicle_type_id, Types::Integer
    attribute :vehicle_code, Types::String
    attribute? :type_code, Types::String.optional
  end
end
