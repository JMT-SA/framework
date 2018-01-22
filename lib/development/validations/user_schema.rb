# frozen_string_literal: true

UserSchema = Dry::Validation.Form do
  optional(:id).filled(:int?)
  required(:login_name).filled(:str?)
  required(:user_name).maybe(:str?)
  required(:email).maybe(:str?)
end
