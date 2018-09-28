# frozen_string_literal: true

module MasterfilesApp
  class FruitActualCountsForPack < Dry::Struct
    attribute :id, Types::Integer
    attribute :std_fruit_size_count_id, Types::Integer
    attribute :basic_pack_code_id, Types::Integer
    attribute :standard_pack_code_id, Types::Integer
    attribute :actual_count_for_pack, Types::Integer
    attribute :size_count_variation, Types::String
  end
end
