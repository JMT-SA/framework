# frozen_string_literal: true

module SecurityApp
  class Program < Dry::Struct
    attribute :id, Types::Int
    attribute :program_name, Types::String
    attribute :functional_area_id, Types::Int
    attribute :active, Types::Bool
  end
end
