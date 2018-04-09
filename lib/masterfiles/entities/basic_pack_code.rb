# frozen_string_literal: true

module MasterfilesApp
  class BasicPackCode < Dry::Struct
    attribute :id, Types::Int
    attribute :basic_pack_code, Types::String
    attribute :description, Types::String
    attribute :length_mm, Types::Int
    attribute :width_mm, Types::Int
    attribute :height_mm, Types::Int
  end
end
