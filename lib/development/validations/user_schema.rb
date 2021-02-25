# frozen_string_literal: true

module DevelopmentApp
  UserSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    optional(:login_name).filled(Types::StrippedString)
    required(:user_name).filled(Types::StrippedString)
    required(:email).maybe(Types::StrippedString)
    optional(:profile).maybe(:hash)
  end
end
