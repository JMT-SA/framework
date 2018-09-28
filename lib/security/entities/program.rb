# frozen_string_literal: true

module SecurityApp
  class Program < Dry::Struct
    attribute :id, Types::Integer
    attribute :program_name, Types::String
    attribute :functional_area_id, Types::Integer
    attribute :program_sequence, Types::Integer
    attribute :active, Types::Bool
  end
end
