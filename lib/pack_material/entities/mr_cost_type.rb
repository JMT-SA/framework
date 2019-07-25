# frozen_string_literal: true

module PackMaterialApp
  class MrCostType < Dry::Struct
    attribute :id, Types::Integer
    attribute :cost_type_code, Types::String
    attribute :account_code, Types::String
  end
end
