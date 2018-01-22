# frozen_string_literal: true

UserNewSchema = Dry::Validation.Form do
  required(:login_name).filled(:str?)
  required(:user_name).filled(:str?)
  required(:password).filled(min_size?: 4).confirmation
  required(:email).maybe(:str?)
end
