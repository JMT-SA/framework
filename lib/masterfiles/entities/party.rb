# frozen_string_literal: true

module MasterfilesApp
  class Party < Dry::Struct
    attribute :id, Types::Int
    attribute :party_type, Types::String
    attribute :active, Types::Bool
    attribute :party_name, Types::String
  end
end
