# frozen_string_literal: true

module MasterfilesApp
  class Address < Dry::Struct
    attribute :id, Types::Integer
    attribute :address_type_id, Types::Integer
    attribute :address_line_1, Types::String
    attribute :address_line_2, Types::String
    attribute :address_line_3, Types::String
    attribute :city, Types::String
    attribute :postal_code, Types::String
    attribute :country, Types::String
    attribute :active, Types::Bool
    attribute :address_type, Types::String
  end
end
