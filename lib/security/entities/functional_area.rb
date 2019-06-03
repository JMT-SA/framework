# frozen_string_literal: true

module SecurityApp
  class FunctionalArea < Dry::Struct
    attribute :id, Types::Integer
    attribute :functional_area_name, Types::String
    attribute :rmd_menu, Types::Bool
    attribute :active, Types::Bool
  end
end
