# frozen_string_literal: true

module DevelopmentApp
  class Role < Dry::Struct
    attribute :id, Types::Integer
    attribute :name, Types::String
    attribute :active, Types::Bool
  end
end
