# frozen_string_literal: true

module DevelopmentApp
  class User < Dry::Struct
    attribute :id, Types::Integer
    attribute :login_name, Types::String
    attribute :user_name, Types::String
    attribute :password_hash, Types::String
    attribute :email, Types::String
    attribute :active, Types::Bool
    # attribute? :permission_tree, Types::JSON::Hash
    # attribute? :profile, Types::JSON::Hash
    attribute? :permission_tree, Types::Hash
    attribute? :profile, Types::Hash
  end
end
