# frozen_string_literal: true

class Party < Dry::Struct
  attribute :id, Types::Int
  attribute :party_type, Types::String
  attribute :active, Types::Bool
end
