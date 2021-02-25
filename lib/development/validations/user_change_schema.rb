# frozen_string_literal: true

module DevelopmentApp
  class UserChangeContract < Dry::Validation::Contract
    params do
      required(:old_password).filled(Types::StrippedString, min_size?: 4)
      required(:password).filled(Types::StrippedString, min_size?: 4)
      required(:password_confirmation).filled(Types::StrippedString, min_size?: 4)
    end

    rule(:password_confirmation, :password) do
      key.failure('must match password') if values[:password] != values[:password_confirmation]
    end

    rule(:password, :old_password) do
      key.failure('must not be the same as old password') if values[:password] == values[:old_password]
    end
  end
end
