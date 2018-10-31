# frozen_string_literal: true

module MasterfilesApp
  class MrCostType < Dry::Struct
    attribute :id, Types::Integer
    attribute :cost_code_string, Types::String
  end
end
