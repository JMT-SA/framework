# frozen_string_literal: true

module MasterfilesApp
  class Commodity < Dry::Struct
    attribute :id, Types::Int
    attribute :commodity_group_id, Types::Int
    attribute :code, Types::String
    attribute :description, Types::String
    attribute :hs_code, Types::String
    attribute :active, Types::Bool
  end
end
