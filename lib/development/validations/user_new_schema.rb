# frozen_string_literal: true

UserNewSchema = Dry::Validation.Form do
  configure { config.type_specs = true }

  required(:login_name, Types::StrippedString).filled(:str?)
  required(:user_name, Types::StrippedString).filled(:str?)
  # required(:password, :string).filled(min_size?: 4).confirmation
  required(:password, Types::StrippedString).filled(min_size?: 4)
  required(:password_confirmation, Types::StrippedString).filled(:str?, min_size?: 4)
  required(:email, Types::StrippedString).maybe(:str?)

  rule(password_confirmation: [:password]) do |password|
    value(:password_confirmation).eql?(password)
  end
end
