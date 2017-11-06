# frozen_string_literal: true

class ContactMethod < Dry::Struct
  attribute :id, Types::Int
  attribute :contact_method_type_id, Types::Int
  attribute :contact_method_code, Types::String
  attribute :active, Types::Bool
end
