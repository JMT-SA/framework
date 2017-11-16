# frozen_string_literal: true

class TargetMarketGroup < Dry::Struct
  attribute :id, Types::Int
  attribute :target_market_group_type_id, Types::Int
  attribute :target_market_group_name, Types::String
end
