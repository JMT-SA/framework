# frozen_string_literal: true

module DevelopmentApp
  RoleSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    optional(:id, :integer).filled(:int?)
    required(:name, Types::StrippedString).filled(:str?)
    required(:active, :bool).filled(:bool?)
  end
end
