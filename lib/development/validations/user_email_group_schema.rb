# frozen_string_literal: true

module DevelopmentApp
  UserEmailGroupSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:mail_group, Types::StrippedString).filled(:str?)
  end
end
