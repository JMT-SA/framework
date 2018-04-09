# frozen_string_literal: true

module MasterfilesApp
  class StdFruitSizeCount < Dry::Struct
    attribute :id, Types::Int
    attribute :commodity_id, Types::Int
    attribute :size_count_description, Types::String
    attribute :marketing_size_range_mm, Types::String
    attribute :marketing_weight_range, Types::String
    attribute :size_count_interval_group, Types::String
    attribute :size_count_value, Types::Int
    attribute :minimum_size_mm, Types::Int
    attribute :maximum_size_mm, Types::Int
    attribute :average_size_mm, Types::Int
    attribute :minimum_weight_gm, Types::Float
    attribute :maximum_weight_gm, Types::Float
    attribute :average_weight_gm, Types::Float
  end
end
