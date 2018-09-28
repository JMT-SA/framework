# frozen_string_literal: true

module DevelopmentApp
  class ContactMethodType < Dry::Struct
    attribute :id, Types::Integer
    attribute :contact_method_type, Types::String
    attribute :active, Types::Bool
  end
end
