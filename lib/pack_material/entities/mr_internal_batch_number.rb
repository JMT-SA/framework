# frozen_string_literal: true

module PackMaterialApp
  class MrInternalBatchNumber < Dry::Struct
    attribute :id, Types::Integer
    attribute :batch_number, Types::Integer
    attribute :description, Types::String
  end
end
