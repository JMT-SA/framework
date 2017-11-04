# frozen_string_literal: true

UserSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:login_name).filled(:str?)
  required(:user_name).maybe(:str?)
  required(:password_hash).filled(:str?)
  required(:email).maybe(:str?)
  required(:active).maybe(:bool?)
end
