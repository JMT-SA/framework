# frozen_string_literal: true

module MasterfilesApp
  class BasicPackCode < Dry::Struct
    attribute :id, Types::Integer
    attribute :basic_pack_code, Types::String
    attribute :description, Types::String
    attribute :length_mm, Types::Integer
    attribute :width_mm, Types::Integer
    attribute :height_mm, Types::Integer
  end
end
