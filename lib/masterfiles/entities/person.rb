# frozen_string_literal: true

class Person < Dry::Struct
  attribute :id, Types::Int
  attribute :party_id, Types::Int
  attribute :party_name, Types::String
  attribute :surname, Types::String
  attribute :first_name, Types::String
  attribute :title, Types::String
  attribute :vat_number, Types::String
  attribute :active, Types::Bool
  attribute :role_ids, Types::Array
  attribute :role_names, Types::Array
  attribute :address_ids, Types::Array
  attribute :contact_method_ids, Types::Array
end
