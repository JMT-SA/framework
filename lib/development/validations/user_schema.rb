# frozen_string_literal: true

UserSchema = Dry::Validation.Form do
  configure { config.type_specs = true }

  optional(:id, :int).filled(:int?)
  required(:login_name, Types::StrippedString).filled(:str?)
  required(:user_name, Types::StrippedString).maybe(:str?)
  required(:email, Types::StrippedString).maybe(:str?)
end
