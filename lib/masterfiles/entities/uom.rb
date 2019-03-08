# frozen_string_literal: true

module MasterfilesApp
  class Uom < Dry::Struct
    attribute :id, Types::Integer
    attribute :uom_type_id, Types::Integer
    attribute :uom_code, Types::String
    attribute :uom_type_code, Types::String.optional
  end
end
