class User < Dry::Struct
  attribute :login_name, Types::String  
  attribute :user_name, Types::String
  attribute :password_hash, Types::String.optional
  attribute :email, Types::String.optional
  attribute :active, Types::Bool
end
