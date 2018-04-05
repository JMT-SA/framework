# frozen_string_literal: true

module DevelopmentApp
  class User < Dry::Struct
    attribute :id, Types::Int
    attribute :login_name, Types::String
    attribute :user_name, Types::String
    attribute :password_hash, Types::String
    attribute :email, Types::String
    attribute :active, Types::Bool
  end
end
