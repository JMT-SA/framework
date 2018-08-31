# frozen_string_literal: true

module PackMaterialApp
  class LocationAssignment < Dry::Struct
    attribute :id, Types::Int
    attribute :assignment_code, Types::String
  end
end
