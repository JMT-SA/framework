# frozen_string_literal: true

module DevelopmentApp
  class UserEmailGroup < Dry::Struct
    attribute :id, Types::Integer
    attribute :mail_group, Types::String
    attribute? :active, Types::Bool
  end
end
