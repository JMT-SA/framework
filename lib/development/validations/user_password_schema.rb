# frozen_string_literal: true

module DevelopmentApp
  UserPasswordSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    required(:password, Types::StrippedString).filled(min_size?: 4)
    required(:password_confirmation, Types::StrippedString).filled(:str?, min_size?: 4)

    rule(password_confirmation: [:password]) do |password|
      value(:password_confirmation).eql?(password)
    end
  end
end
