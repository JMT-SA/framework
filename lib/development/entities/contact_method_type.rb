# frozen_string_literal: true

class ContactMethodType < Dry::Struct
  attribute :id, Types::Int
  attribute :contact_method_type, Types::String
end
