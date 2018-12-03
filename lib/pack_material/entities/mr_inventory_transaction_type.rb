# frozen_string_literal: true

module PackMaterialApp
  class MrInventoryTransactionType < Dry::Struct
    attribute :id, Types::Integer
    attribute :type_name, Types::String
  end
end
