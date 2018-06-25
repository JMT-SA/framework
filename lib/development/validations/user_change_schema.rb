# frozen_string_literal: true

module DevelopmentApp
  UserChangeSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    required(:old_password, Types::StrippedString).filled(min_size?: 4)
    required(:password, Types::StrippedString).filled(min_size?: 4)
    required(:password_confirmation, Types::StrippedString).filled(:str?, min_size?: 4)

    rule(password_confirmation: [:password]) do |password|
      value(:password_confirmation).eql?(password)
    end

    rule(old_password: [:password]) do |password|
      value(:old_password).not_eql?(password)
    end
  end
end
