# frozen_string_literal: true

module MasterfilesApp
  class TargetMarket < Dry::Struct
    attribute :id, Types::Int
    attribute :target_market_name, Types::String
    attribute :country_ids, Types::Array
    attribute :tm_group_ids, Types::Array
  end
end
