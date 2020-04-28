# frozen_string_literal: true

module DevelopmentApp
  ScriptScaffoldNewSchema = Dry::Validation.Params do
    configure { config.type_specs = true }

    required(:script_class, Types::StrippedString).filled(:str?)
    required(:description, Types::StrippedString).filled(:str?)
    required(:reason, Types::StrippedString).filled(:str?)
  end
end
