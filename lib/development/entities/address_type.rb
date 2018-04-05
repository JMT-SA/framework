# frozen_string_literal: true

module DevelopmentApp
  class AddressType < Dry::Struct
    attribute :id, Types::Int
    attribute :address_type, Types::String
    attribute :active, Types::Bool
  end
end
