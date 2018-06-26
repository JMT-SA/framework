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

    rule(password: [:old_password]) do |old_password|
      value(:password).not_eql?(old_password)
    end
  end
end
