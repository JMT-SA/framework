# frozen_string_literal: true

module MasterfilesApp
  class Uom < Dry::Struct
    attribute :id, Types::Integer
    attribute :uoms_type_id, Types::Integer
    attribute :uom_code, Types::String
  end
end
