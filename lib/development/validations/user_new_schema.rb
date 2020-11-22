# frozen_string_literal: true

module DevelopmentApp
  class UserNewContract < Dry::Validation::Contract
    params do
      required(:login_name).filled(Types::StrippedString, min_size?: 3, format?: /\A[[:print:]]+\Z/)
      required(:user_name).filled(Types::StrippedString)
      required(:password).filled(Types::StrippedString, min_size?: 4)
      required(:password_confirmation).filled(Types::StrippedString, min_size?: 4)
      required(:email).maybe(Types::StrippedString)
    end

    rule(:password_confirmation, :password) do
      key.failure('must match password') if values[:password] != values[:password_confirmation]
    end
  end
end
