# frozen_string_literal: true

module MasterfilesApp
  class CultivarGroup < Dry::Struct
    attribute :id, Types::Int
    attribute :cultivar_group_code, Types::String
    attribute :description, Types::String
  end
end
