# frozen_string_literal: true

class CommodityGroup < Dry::Struct
  attribute :id, Types::Int
  attribute :code, Types::String
  attribute :description, Types::String
  attribute :active, Types::Bool
end
