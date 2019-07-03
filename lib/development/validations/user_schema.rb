# frozen_string_literal: true

module DevelopmentApp
  UserSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    optional(:login_name, Types::StrippedString).filled(:str?)
    required(:user_name, Types::StrippedString).maybe(:str?)
    required(:email, Types::StrippedString).maybe(:str?)
  end
end
