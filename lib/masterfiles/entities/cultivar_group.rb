# frozen_string_literal: true

module MasterfilesApp
  class CultivarGroup < Dry::Struct
    attribute :id, Types::Integer
    attribute :cultivar_group_code, Types::String
    attribute :description, Types::String
    attribute :cultivar_ids, Types::IntArray
  end
end
