# frozen_string_literal: true

module MasterfilesApp
  class CommodityGroup < Dry::Struct
    attribute :id, Types::Int
    attribute :code, Types::String
    attribute :description, Types::String
    attribute :active, Types::Bool
  end
end
