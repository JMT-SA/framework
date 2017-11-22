# frozen_string_literal: true

class FruitActualCountsForPack < Dry::Struct
  attribute :id, Types::Int
  attribute :std_fruit_size_count_id, Types::Int
  attribute :basic_pack_code_id, Types::Int
  attribute :standard_pack_code_id, Types::Int
  attribute :actual_count_for_pack, Types::Int
  attribute :size_count_variation, Types::String
end
