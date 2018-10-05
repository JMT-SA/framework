# frozen_string_literal: true

module MasterfilesApp
  class LocationAssignment < Dry::Struct
    attribute :id, Types::Integer
    attribute :assignment_code, Types::String
  end
end
