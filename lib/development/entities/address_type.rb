# frozen_string_literal: true

class AddressType < Dry::Struct
  attribute :id, Types::Int
  attribute :address_type, Types::String
  attribute :active, Types::Bool
end