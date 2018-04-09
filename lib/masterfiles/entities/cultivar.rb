# frozen_string_literal: true

module MasterfilesApp
  class Cultivar < Dry::Struct
    attribute :id, Types::Int
    attribute :commodity_id, Types::Int
    attribute :cultivar_group_id, Types::Int
    attribute :cultivar_name, Types::String
    attribute :description, Types::String
  end
end
