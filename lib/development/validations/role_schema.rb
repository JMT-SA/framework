# frozen_string_literal: true

module DevelopmentApp
  RoleSchema = Dry::Validation.Form do
    configure { config.type_specs = true }

    optional(:id, :int).filled(:int?)
    required(:name, Types::StrippedString).filled(:str?)
    required(:active, :bool).filled(:bool?)
  end
end
