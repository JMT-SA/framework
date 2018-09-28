# frozen_string_literal: true

module MasterfilesApp
  class Cultivar < Dry::Struct
    attribute :id, Types::Integer
    attribute :commodity_id, Types::Integer
    attribute :cultivar_group_id, Types::Integer
    attribute :cultivar_group_code, Types::String
    attribute :cultivar_name, Types::String
    attribute :description, Types::String
  end
end
