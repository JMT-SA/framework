# frozen_string_literal: true

module MasterfilesApp
  class FruitSizeReference < Dry::Struct
    attribute :id, Types::Int
    attribute :fruit_actual_counts_for_pack_id, Types::Int
    attribute :size_reference, Types::String
  end
end
